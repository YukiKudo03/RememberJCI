import { Controller } from "@hotwired/stimulus"

// TextDisplay controller for interactive blank-filling practice
// Handles revealing blanks and tracking user interactions
export default class extends Controller {
  static targets = ["blank", "content"]
  static values = {
    level: { type: Number, default: 0 }
  }

  connect() {
    this.revealedBlanks = new Set()
    console.log(`TextDisplay controller connected at level ${this.levelValue}`)
  }

  // Reveal a single blank when clicked
  revealBlank(event) {
    const blankElement = event.currentTarget
    const answer = blankElement.dataset.answer
    const index = blankElement.dataset.index

    if (this.revealedBlanks.has(index)) {
      // Already revealed, hide it again
      this.hideBlank(blankElement, index)
    } else {
      // Reveal the answer
      this.showBlank(blankElement, answer, index)
    }
  }

  showBlank(element, answer, index) {
    element.textContent = answer
    element.classList.remove("bg-gray-100", "border-dashed", "border-gray-400")
    element.classList.add("bg-green-100", "border-solid", "border-green-400", "text-green-800")
    this.revealedBlanks.add(index)

    this.dispatch("blankRevealed", {
      detail: { index, answer, totalRevealed: this.revealedBlanks.size }
    })
  }

  hideBlank(element, index) {
    const originalLength = element.dataset.answer.length
    element.innerHTML = "&nbsp;".repeat(Math.max(originalLength, 4))
    element.classList.add("bg-gray-100", "border-dashed", "border-gray-400")
    element.classList.remove("bg-green-100", "border-solid", "border-green-400", "text-green-800")
    this.revealedBlanks.delete(index)

    this.dispatch("blankHidden", {
      detail: { index, totalRevealed: this.revealedBlanks.size }
    })
  }

  // Reveal all blanks at once
  revealAll() {
    this.blankTargets.forEach((blank, idx) => {
      const answer = blank.dataset.answer
      const index = blank.dataset.index || idx.toString()
      if (!this.revealedBlanks.has(index)) {
        this.showBlank(blank, answer, index)
      }
    })

    this.dispatch("allRevealed", {
      detail: { totalBlanks: this.blankTargets.length }
    })
  }

  // Hide all revealed blanks
  hideAll() {
    this.blankTargets.forEach((blank, idx) => {
      const index = blank.dataset.index || idx.toString()
      if (this.revealedBlanks.has(index)) {
        this.hideBlank(blank, index)
      }
    })

    this.dispatch("allHidden")
  }

  // Toggle all blanks
  toggleAll() {
    if (this.revealedBlanks.size === this.blankTargets.length) {
      this.hideAll()
    } else {
      this.revealAll()
    }
  }

  // Get current stats
  get stats() {
    return {
      totalBlanks: this.blankTargets.length,
      revealedBlanks: this.revealedBlanks.size,
      hiddenBlanks: this.blankTargets.length - this.revealedBlanks.size,
      completionPercentage: this.blankTargets.length > 0
        ? Math.round((this.revealedBlanks.size / this.blankTargets.length) * 100)
        : 0
    }
  }

  // Check if all blanks are revealed
  get isComplete() {
    return this.blankTargets.length > 0 && this.revealedBlanks.size === this.blankTargets.length
  }
}
