import { Controller } from "@hotwired/stimulus"

// Timer controller for countdown timer functionality
// Used for timed tests with configurable warnings and auto-submit
// Requirements: FR-54 (制限時間付きテストのサポート)
export default class extends Controller {
  static targets = ["display"]
  static values = {
    duration: Number,           // 総時間（秒）
    autoStart: { type: Boolean, default: false },
    warningThreshold: { type: Number, default: 300 },  // 警告表示開始（秒）
    dangerThreshold: { type: Number, default: 60 },    // 危険表示開始（秒）
    onExpire: String            // タイマー終了時のコールバック名
  }

  connect() {
    this.remainingSeconds = this.durationValue
    this.isRunning = false
    this.isPaused = false

    this.updateDisplay()

    if (this.autoStartValue) {
      this.start()
    }

    console.log(`Timer initialized: ${this.durationValue} seconds`)
  }

  disconnect() {
    this.stop()
  }

  // タイマーを開始
  start() {
    if (this.isRunning) return

    this.isRunning = true
    this.isPaused = false
    this.timerInterval = setInterval(() => this.tick(), 1000)
    this.dispatch("started", { detail: { remaining: this.remainingSeconds } })
    console.log("Timer started")
  }

  // タイマーを停止
  stop() {
    if (this.timerInterval) {
      clearInterval(this.timerInterval)
      this.timerInterval = null
    }
    this.isRunning = false
    this.dispatch("stopped", { detail: { remaining: this.remainingSeconds } })
  }

  // タイマーを一時停止
  pause() {
    if (!this.isRunning || this.isPaused) return

    this.isPaused = true
    this.dispatch("paused", { detail: { remaining: this.remainingSeconds } })
    console.log("Timer paused")
  }

  // タイマーを再開
  resume() {
    if (!this.isRunning || !this.isPaused) return

    this.isPaused = false
    this.dispatch("resumed", { detail: { remaining: this.remainingSeconds } })
    console.log("Timer resumed")
  }

  // 一時停止/再開の切り替え
  toggle() {
    if (this.isPaused) {
      this.resume()
    } else {
      this.pause()
    }
  }

  // タイマーをリセット
  reset() {
    this.stop()
    this.remainingSeconds = this.durationValue
    this.updateDisplay()
    this.resetStyles()
    this.dispatch("reset", { detail: { duration: this.durationValue } })
  }

  // 1秒ごとの処理
  tick() {
    if (this.isPaused) return

    this.remainingSeconds--

    this.updateDisplay()
    this.checkWarnings()

    if (this.remainingSeconds <= 0) {
      this.expire()
    }
  }

  // 表示を更新
  updateDisplay() {
    if (!this.hasDisplayTarget) return

    const minutes = Math.floor(this.remainingSeconds / 60)
    const seconds = this.remainingSeconds % 60
    this.displayTarget.textContent = `${minutes.toString().padStart(2, "0")}:${seconds.toString().padStart(2, "0")}`
  }

  // 警告状態をチェック
  checkWarnings() {
    if (!this.hasDisplayTarget) return

    const displayElement = this.displayTarget

    if (this.remainingSeconds <= this.dangerThresholdValue) {
      // 危険状態（赤）
      displayElement.classList.remove("text-gray-700", "text-yellow-600")
      displayElement.classList.add("text-red-600")
      this.element.classList.add("bg-red-50")
      this.element.classList.remove("bg-gray-100", "bg-yellow-50")

      // 残り10秒以下で点滅
      if (this.remainingSeconds <= 10) {
        displayElement.classList.add("animate-pulse")
      }

      this.dispatch("danger", { detail: { remaining: this.remainingSeconds } })
    } else if (this.remainingSeconds <= this.warningThresholdValue) {
      // 警告状態（黄色）
      displayElement.classList.remove("text-gray-700", "text-red-600")
      displayElement.classList.add("text-yellow-600")
      this.element.classList.add("bg-yellow-50")
      this.element.classList.remove("bg-gray-100", "bg-red-50")

      this.dispatch("warning", { detail: { remaining: this.remainingSeconds } })
    }
  }

  // スタイルをリセット
  resetStyles() {
    if (!this.hasDisplayTarget) return

    const displayElement = this.displayTarget
    displayElement.classList.remove("text-yellow-600", "text-red-600", "animate-pulse")
    displayElement.classList.add("text-gray-700")
    this.element.classList.remove("bg-yellow-50", "bg-red-50")
    this.element.classList.add("bg-gray-100")
  }

  // タイマー終了
  expire() {
    this.stop()
    this.remainingSeconds = 0
    this.updateDisplay()

    // コールバックを実行
    if (this.onExpireValue) {
      // カスタムイベントとして発火
      this.dispatch("expired", { detail: { callback: this.onExpireValue } })

      // グローバル関数として呼び出し
      if (typeof window[this.onExpireValue] === "function") {
        window[this.onExpireValue]()
      }
    } else {
      this.dispatch("expired", { detail: {} })
    }

    console.log("Timer expired")
  }

  // 残り時間を取得（秒）
  get remaining() {
    return this.remainingSeconds
  }

  // 残り時間を取得（分）
  get remainingMinutes() {
    return Math.ceil(this.remainingSeconds / 60)
  }

  // タイマーが動作中かどうか
  get running() {
    return this.isRunning && !this.isPaused
  }
}
