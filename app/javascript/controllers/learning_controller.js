import { Controller } from "@hotwired/stimulus"

// Learning controller for managing study sessions
// Tracks time spent, handles level progression, and saves progress to the server
// Requirements: FR-42 (学習セッション追跡)
export default class extends Controller {
  static targets = ["timer", "timerDisplay", "level", "score", "progressBar"]
  static values = {
    textId: Number,
    level: { type: Number, default: 0 },
    saveUrl: String,
    autoSave: { type: Boolean, default: true },
    autoSaveInterval: { type: Number, default: 30 } // seconds
  }

  connect() {
    this.startTime = Date.now()
    this.elapsedSeconds = 0
    this.score = 0
    this.isPaused = false

    // Start the timer
    this.startTimer()

    // Setup auto-save if enabled
    if (this.autoSaveValue) {
      this.setupAutoSave()
    }

    // Save progress when leaving the page
    this.boundBeforeUnload = this.handleBeforeUnload.bind(this)
    window.addEventListener("beforeunload", this.boundBeforeUnload)

    console.log(`Learning session started for text ${this.textIdValue} at level ${this.levelValue}`)
  }

  disconnect() {
    this.stopTimer()
    this.stopAutoSave()
    window.removeEventListener("beforeunload", this.boundBeforeUnload)

    // Save progress on disconnect
    this.saveProgress()
  }

  // Timer functionality
  startTimer() {
    this.timerInterval = setInterval(() => {
      if (!this.isPaused) {
        this.elapsedSeconds++
        this.updateTimerDisplay()
      }
    }, 1000)
  }

  stopTimer() {
    if (this.timerInterval) {
      clearInterval(this.timerInterval)
      this.timerInterval = null
    }
  }

  pauseTimer() {
    this.isPaused = true
    this.dispatch("paused", { detail: { elapsed: this.elapsedSeconds } })
  }

  resumeTimer() {
    this.isPaused = false
    this.dispatch("resumed", { detail: { elapsed: this.elapsedSeconds } })
  }

  togglePause() {
    if (this.isPaused) {
      this.resumeTimer()
    } else {
      this.pauseTimer()
    }
  }

  updateTimerDisplay() {
    if (this.hasTimerDisplayTarget) {
      const minutes = Math.floor(this.elapsedSeconds / 60)
      const seconds = this.elapsedSeconds % 60
      this.timerDisplayTarget.textContent = `${minutes.toString().padStart(2, "0")}:${seconds.toString().padStart(2, "0")}`
    }
  }

  // Auto-save functionality
  setupAutoSave() {
    this.autoSaveTimer = setInterval(() => {
      this.saveProgress(true) // silent save
    }, this.autoSaveIntervalValue * 1000)
  }

  stopAutoSave() {
    if (this.autoSaveTimer) {
      clearInterval(this.autoSaveTimer)
      this.autoSaveTimer = null
    }
  }

  // Progress management
  async saveProgress(silent = false) {
    if (!this.saveUrlValue || !this.textIdValue) {
      console.warn("Cannot save progress: missing saveUrl or textId")
      return
    }

    const data = {
      level: this.levelValue,
      time_spent: this.elapsedSeconds,
      score: this.score
    }

    try {
      const response = await fetch(this.saveUrlValue, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": this.csrfToken
        },
        body: JSON.stringify(data)
      })

      if (response.ok) {
        const result = await response.json()
        if (!silent) {
          this.dispatch("saved", { detail: result })
          this.showSaveIndicator()
        }
        console.log("Progress saved:", result)
      } else {
        console.error("Failed to save progress:", response.status)
        if (!silent) {
          this.dispatch("saveError", { detail: { status: response.status } })
        }
      }
    } catch (error) {
      console.error("Error saving progress:", error)
      if (!silent) {
        this.dispatch("saveError", { detail: { error: error.message } })
      }
    }
  }

  // Show a brief indicator that progress was saved
  showSaveIndicator() {
    const indicator = document.createElement("div")
    indicator.className = "fixed bottom-4 right-4 bg-green-500 text-white px-4 py-2 rounded-lg shadow-lg z-50 transition-opacity duration-300"
    indicator.textContent = "進捗を保存しました"
    document.body.appendChild(indicator)

    setTimeout(() => {
      indicator.classList.add("opacity-0")
      setTimeout(() => indicator.remove(), 300)
    }, 2000)
  }

  // Level progression
  nextLevel() {
    if (this.levelValue < 5) {
      this.levelValue++
      this.updateLevelDisplay()
      this.saveProgress()
      this.dispatch("levelChanged", { detail: { level: this.levelValue } })
    }
  }

  previousLevel() {
    if (this.levelValue > 0) {
      this.levelValue--
      this.updateLevelDisplay()
      this.dispatch("levelChanged", { detail: { level: this.levelValue } })
    }
  }

  setLevel(event) {
    const newLevel = parseInt(event.currentTarget.dataset.level, 10)
    if (newLevel >= 0 && newLevel <= 5) {
      this.levelValue = newLevel
      this.updateLevelDisplay()
      this.dispatch("levelChanged", { detail: { level: this.levelValue } })
    }
  }

  updateLevelDisplay() {
    if (this.hasLevelTarget) {
      this.levelTarget.textContent = this.levelValue
    }

    if (this.hasProgressBarTarget) {
      const percentage = (this.levelValue / 5) * 100
      this.progressBarTarget.style.width = `${percentage}%`
    }
  }

  // Score management
  incrementScore(points = 1) {
    this.score += points
    this.updateScoreDisplay()
    this.dispatch("scoreChanged", { detail: { score: this.score } })
  }

  setScore(score) {
    this.score = score
    this.updateScoreDisplay()
    this.dispatch("scoreChanged", { detail: { score: this.score } })
  }

  updateScoreDisplay() {
    if (this.hasScoreTarget) {
      this.scoreTarget.textContent = this.score
    }
  }

  // Complete learning session
  complete() {
    this.stopTimer()
    this.stopAutoSave()
    this.saveProgress()
    this.dispatch("completed", {
      detail: {
        textId: this.textIdValue,
        level: this.levelValue,
        timeSpent: this.elapsedSeconds,
        score: this.score
      }
    })
  }

  // Handle page unload
  handleBeforeUnload(event) {
    // Use sendBeacon for reliable progress saving on page unload
    if (this.saveUrlValue && this.textIdValue && this.elapsedSeconds > 0) {
      const data = new FormData()
      data.append("level", this.levelValue)
      data.append("time_spent", this.elapsedSeconds)
      data.append("score", this.score)
      data.append("authenticity_token", this.csrfToken)

      navigator.sendBeacon(this.saveUrlValue, data)
    }
  }

  // Get CSRF token from meta tag
  get csrfToken() {
    const metaTag = document.querySelector('meta[name="csrf-token"]')
    return metaTag ? metaTag.content : ""
  }

  // Value changed callbacks
  levelValueChanged() {
    this.updateLevelDisplay()
  }
}
