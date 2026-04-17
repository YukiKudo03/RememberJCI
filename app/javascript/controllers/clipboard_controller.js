import { Controller } from "@hotwired/stimulus"

// ClipboardController — copies text to clipboard with a graceful fallback.
//
// Usage:
//   <div data-controller="clipboard"
//        data-clipboard-success-value="コピーしました"
//        data-clipboard-failure-value="自動コピーに失敗しました">
//     <input type="hidden" data-clipboard-target="source" value="https://...">
//     <button type="button" data-action="click->clipboard#copy">コピー</button>
//   </div>
//
// Behavior:
//   - Happy path: uses navigator.clipboard.writeText (modern, async).
//   - Permission denied / not available (Safari in some contexts, insecure context,
//     permissions-policy block): falls back to select + execCommand('copy'), which
//     works via a transient input.
//   - If BOTH fail: shows a warning flash and inserts a visible, pre-selected text
//     field so the user can Cmd+C / Ctrl+C manually. Never silent.
export default class extends Controller {
  static targets = ["source"]
  static values = {
    success: { type: String, default: "コピーしました" },
    failure: { type: String, default: "自動コピーに失敗しました。手動でコピーしてください" }
  }

  async copy(event) {
    event.preventDefault()
    const text = this.sourceTarget.value

    // Try the modern API first.
    if (navigator.clipboard && window.isSecureContext) {
      try {
        await navigator.clipboard.writeText(text)
        this.#announce(this.successValue, "success")
        return
      } catch (err) {
        // Permission denied / rejected — fall through to legacy path.
      }
    }

    // Legacy fallback: a transient textarea + execCommand('copy').
    if (this.#copyViaExecCommand(text)) {
      this.#announce(this.successValue, "success")
      return
    }

    // Both paths failed — show a manual-copy affordance so the user isn't stuck.
    this.#revealManualCopy(text)
    this.#announce(this.failureValue, "warning")
  }

  #copyViaExecCommand(text) {
    const ta = document.createElement("textarea")
    ta.value = text
    ta.setAttribute("readonly", "")
    ta.style.position = "absolute"
    ta.style.left = "-9999px"
    document.body.appendChild(ta)
    ta.select()
    let ok = false
    try {
      ok = document.execCommand("copy")
    } catch (_) {
      ok = false
    }
    document.body.removeChild(ta)
    return ok
  }

  #revealManualCopy(text) {
    // Build (once) a visible readonly input next to the copy button so
    // the user can manually Cmd+C / Ctrl+C.
    if (this.element.querySelector("[data-clipboard-manual]")) return

    const manual = document.createElement("input")
    manual.type = "text"
    manual.readOnly = true
    manual.value = text
    manual.dataset.clipboardManual = "true"
    manual.className = "mt-2 w-full text-xs font-mono px-2 py-1 border border-yellow-300 rounded bg-yellow-50 text-gray-900 focus:outline-none focus:ring-2 focus:ring-yellow-400"
    manual.setAttribute("aria-label", "手動コピー用URL")
    this.element.appendChild(manual)
    manual.focus()
    manual.select()
  }

  #announce(message, type) {
    // Dispatch a custom event; the flash component (or a listener on <body>) can
    // translate that into a user-visible flash. The minimum acceptable behavior
    // here is an accessible live-region announcement.
    document.dispatchEvent(new CustomEvent("flash:append", {
      detail: { message, type }
    }))

    // Also surface a transient inline status for users without the flash listener.
    const status = document.createElement("span")
    status.textContent = message
    status.setAttribute("role", type === "warning" ? "alert" : "status")
    status.setAttribute("aria-live", type === "warning" ? "assertive" : "polite")
    status.className = `ml-2 text-xs ${type === "success" ? "text-green-700" : "text-yellow-700"}`
    this.element.appendChild(status)
    setTimeout(() => status.remove(), 2500)
  }
}
