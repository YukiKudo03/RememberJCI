import { Controller } from "@hotwired/stimulus"

// TTS (Text-to-Speech) controller using Web Speech API
// Provides text read-aloud functionality for learning practice
// Requirements: FR-43 (テキスト読み上げ機能)
export default class extends Controller {
  static targets = ["speakButton", "stopButton", "status"]
  static values = {
    text: String,          // 読み上げるテキスト
    lang: { type: String, default: "ja-JP" },  // 言語設定
    rate: { type: Number, default: 1.0 },      // 読み上げ速度
    pitch: { type: Number, default: 1.0 }      // ピッチ
  }

  connect() {
    this.speaking = false
    this.supported = "speechSynthesis" in window

    if (!this.supported) {
      this.disableControls()
    }
  }

  disconnect() {
    this.stop()
  }

  // テキストを読み上げる
  speak() {
    if (!this.supported) return
    if (this.speaking) {
      this.stop()
      return
    }

    const utterance = new SpeechSynthesisUtterance(this.textValue)
    utterance.lang = this.langValue
    utterance.rate = this.rateValue
    utterance.pitch = this.pitchValue

    utterance.onstart = () => {
      this.speaking = true
      this.updateUI(true)
    }

    utterance.onend = () => {
      this.speaking = false
      this.updateUI(false)
    }

    utterance.onerror = () => {
      this.speaking = false
      this.updateUI(false)
    }

    window.speechSynthesis.cancel()
    window.speechSynthesis.speak(utterance)
  }

  // 読み上げを停止する
  stop() {
    if (!this.supported) return

    window.speechSynthesis.cancel()
    this.speaking = false
    this.updateUI(false)
  }

  // UI状態を更新
  updateUI(isSpeaking) {
    if (this.hasSpeakButtonTarget) {
      this.speakButtonTarget.classList.toggle("text-indigo-600", isSpeaking)
      this.speakButtonTarget.classList.toggle("bg-indigo-50", isSpeaking)
    }

    if (this.hasStopButtonTarget) {
      this.stopButtonTarget.classList.toggle("hidden", !isSpeaking)
    }

    if (this.hasStatusTarget) {
      this.statusTarget.textContent = isSpeaking ? "読み上げ中..." : ""
    }
  }

  // Web Speech APIが利用不可の場合にコントロールを無効化
  disableControls() {
    if (this.hasSpeakButtonTarget) {
      this.speakButtonTarget.disabled = true
      this.speakButtonTarget.classList.add("opacity-50", "cursor-not-allowed")
      this.speakButtonTarget.title = "このブラウザでは読み上げ機能がサポートされていません"
    }
  }
}
