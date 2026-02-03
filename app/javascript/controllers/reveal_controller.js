import { Controller } from "@hotwired/stimulus"

// Reveal controller for toggling visibility of content sections
// Used for collapsible panels, accordions, and show/hide functionality
export default class extends Controller {
  static targets = ["content", "icon"]

  connect() {
    this.isOpen = false
  }

  toggle() {
    this.isOpen = !this.isOpen

    if (this.hasContentTarget) {
      if (this.isOpen) {
        this.contentTarget.classList.remove("hidden")
      } else {
        this.contentTarget.classList.add("hidden")
      }
    }

    if (this.hasIconTarget) {
      if (this.isOpen) {
        this.iconTarget.classList.add("rotate-180")
      } else {
        this.iconTarget.classList.remove("rotate-180")
      }
    }

    // Dispatch custom event
    this.dispatch(this.isOpen ? "opened" : "closed")
  }

  open() {
    if (!this.isOpen) {
      this.toggle()
    }
  }

  close() {
    if (this.isOpen) {
      this.toggle()
    }
  }
}
