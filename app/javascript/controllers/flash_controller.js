import { Controller } from "@hotwired/stimulus"

// Flash message controller for dismissing notifications
// Provides both manual dismiss and auto-hide functionality
export default class extends Controller {
  static targets = ["message"]
  static values = {
    autoDismiss: { type: Number, default: 5000 }  // 自動非表示までのミリ秒（0で無効）
  }

  connect() {
    // Auto-dismiss after configured time (0 = disabled)
    if (this.autoDismissValue > 0) {
      this.timeout = setTimeout(() => {
        this.dismiss()
      }, this.autoDismissValue)
    }
  }

  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
  }

  dismiss() {
    // Fade out animation
    this.element.classList.add("opacity-0", "transition-opacity", "duration-300")

    // Remove element after animation
    setTimeout(() => {
      this.element.remove()
    }, 300)
  }
}
