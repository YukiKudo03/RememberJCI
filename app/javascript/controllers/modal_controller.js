import { Controller } from "@hotwired/stimulus"

// Modal controller for handling modal dialog interactions
// Provides open/close functionality with animations and accessibility features
export default class extends Controller {
  static targets = ["backdrop", "dialog", "title", "header", "body", "footer"]

  connect() {
    // Store the original body overflow style to restore later
    this.originalBodyOverflow = document.body.style.overflow

    // Initially hide the modal
    this.element.classList.add("hidden")
  }

  disconnect() {
    // Restore body scroll when modal is removed from DOM
    this.unlockBodyScroll()
  }

  // Opens the modal with animation
  open() {
    // Show the modal
    this.element.classList.remove("hidden")

    // Lock body scroll
    this.lockBodyScroll()

    // Trigger enter animation
    requestAnimationFrame(() => {
      // Animate backdrop
      if (this.hasBackdropTarget) {
        this.backdropTarget.classList.add("opacity-100")
        this.backdropTarget.classList.remove("opacity-0")
      }

      // Animate dialog
      if (this.hasDialogTarget) {
        this.dialogTarget.classList.add("opacity-100", "scale-100")
        this.dialogTarget.classList.remove("opacity-0", "scale-95")
      }
    })

    // Set focus to the dialog for accessibility
    this.element.setAttribute("tabindex", "-1")
    this.element.focus()

    // Dispatch custom event
    this.dispatch("opened")
  }

  // Closes the modal with animation
  close() {
    // Animate out
    if (this.hasBackdropTarget) {
      this.backdropTarget.classList.add("opacity-0")
      this.backdropTarget.classList.remove("opacity-100")
    }

    if (this.hasDialogTarget) {
      this.dialogTarget.classList.add("opacity-0", "scale-95")
      this.dialogTarget.classList.remove("opacity-100", "scale-100")
    }

    // Hide after animation completes
    setTimeout(() => {
      this.element.classList.add("hidden")
      this.unlockBodyScroll()

      // Dispatch custom event
      this.dispatch("closed")
    }, 200) // Match CSS transition duration
  }

  // Close modal when clicking on the backdrop
  closeOnBackdrop(event) {
    // Only close if clicking directly on the modal container (backdrop area)
    // not on the dialog content
    if (event.target === this.element || event.target === this.backdropTarget) {
      this.close()
    }
  }

  // Close modal when pressing ESC key
  closeOnEsc(event) {
    if (event.key === "Escape" || event.keyCode === 27) {
      event.preventDefault()
      this.close()
    }
  }

  // Lock body scroll to prevent scrolling behind modal
  lockBodyScroll() {
    document.body.style.overflow = "hidden"
  }

  // Unlock body scroll
  unlockBodyScroll() {
    document.body.style.overflow = this.originalBodyOverflow || ""
  }
}
