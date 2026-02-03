import { Controller } from "@hotwired/stimulus"

// Navigation controller for handling mobile menu toggle
export default class extends Controller {
  static targets = ["mobileMenu", "openIcon", "closeIcon"]

  toggle() {
    const isHidden = this.mobileMenuTarget.classList.contains("hidden")

    if (isHidden) {
      this.open()
    } else {
      this.close()
    }
  }

  open() {
    this.mobileMenuTarget.classList.remove("hidden")
    this.openIconTarget.classList.add("hidden")
    this.closeIconTarget.classList.remove("hidden")
  }

  close() {
    this.mobileMenuTarget.classList.add("hidden")
    this.openIconTarget.classList.remove("hidden")
    this.closeIconTarget.classList.add("hidden")
  }
}
