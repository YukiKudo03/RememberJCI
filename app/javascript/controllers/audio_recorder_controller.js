import { Controller } from "@hotwired/stimulus"

// AudioRecorder controller for audio recording functionality
// Used for voice input in learning and test submissions
// Requirements: FR-52 (音声入力のサポート)
export default class extends Controller {
  static targets = [
    "recordButton",
    "stopButton",
    "playButton",
    "audio",
    "timer",
    "status",
    "waveform",
    "dataInput"
  ]

  static values = {
    maxDuration: { type: Number, default: 180 },  // 最大録音時間（秒）
    autoSubmit: { type: Boolean, default: false },
    targetInput: String,                           // 録音データを設定する入力フィールドのID
    onRecordingStart: String,                      // 録音開始時のコールバック
    onRecordingStop: String                        // 録音停止時のコールバック
  }

  connect() {
    this.mediaRecorder = null
    this.audioChunks = []
    this.recordedBlob = null
    this.isRecording = false
    this.isPlaying = false
    this.recordingStartTime = null
    this.timerInterval = null

    this.checkBrowserSupport()
    this.updateButtonStates()

    console.log("AudioRecorder initialized")
  }

  disconnect() {
    this.stopRecording()
    this.stopPlayback()
    this.cleanupMediaStream()
  }

  // ブラウザサポートを確認
  checkBrowserSupport() {
    if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
      this.updateStatus("お使いのブラウザは録音に対応していません")
      this.disableRecording()
      return false
    }
    return true
  }

  // 録音を開始
  async startRecording() {
    if (this.isRecording) return

    try {
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true })
      this.stream = stream

      // MediaRecorderの作成
      const options = this.getMediaRecorderOptions()
      this.mediaRecorder = new MediaRecorder(stream, options)

      this.audioChunks = []

      this.mediaRecorder.ondataavailable = (event) => {
        if (event.data.size > 0) {
          this.audioChunks.push(event.data)
        }
      }

      this.mediaRecorder.onstop = () => {
        this.processRecording()
      }

      this.mediaRecorder.onerror = (event) => {
        console.error("MediaRecorder error:", event.error)
        this.updateStatus("録音エラーが発生しました")
        this.stopRecording()
      }

      // 録音開始
      this.mediaRecorder.start(100) // 100ms ごとにデータを取得
      this.isRecording = true
      this.recordingStartTime = Date.now()

      this.startTimer()
      this.updateButtonStates()
      this.updateStatus("録音中...")

      // コールバックを実行
      this.executeCallback(this.onRecordingStartValue)
      this.dispatch("recordingStarted", { detail: {} })

      console.log("Recording started")
    } catch (error) {
      console.error("Error starting recording:", error)
      this.handleRecordingError(error)
    }
  }

  // 録音を停止
  stopRecording() {
    if (!this.isRecording || !this.mediaRecorder) return

    try {
      this.mediaRecorder.stop()
      this.isRecording = false

      this.stopTimer()
      this.cleanupMediaStream()
      this.updateButtonStates()
      this.updateStatus("録音完了")

      // コールバックを実行
      this.executeCallback(this.onRecordingStopValue)
      this.dispatch("recordingStopped", { detail: {} })

      console.log("Recording stopped")
    } catch (error) {
      console.error("Error stopping recording:", error)
    }
  }

  // 録音データを処理
  processRecording() {
    const mimeType = this.getAudioMimeType()
    this.recordedBlob = new Blob(this.audioChunks, { type: mimeType })

    // オーディオ要素にURLを設定
    if (this.hasAudioTarget) {
      const audioUrl = URL.createObjectURL(this.recordedBlob)
      this.audioTarget.src = audioUrl
    }

    // Base64データとして保存
    this.saveAsBase64()

    this.updateButtonStates()

    // 自動送信
    if (this.autoSubmitValue) {
      this.dispatch("autoSubmit", { detail: { blob: this.recordedBlob } })
    }
  }

  // Base64として保存
  async saveAsBase64() {
    if (!this.recordedBlob) return

    try {
      const reader = new FileReader()

      reader.onloadend = () => {
        const base64Data = reader.result

        // 隠しフィールドに保存
        if (this.hasDataInputTarget) {
          this.dataInputTarget.value = base64Data
        }

        // 指定されたターゲット入力に保存
        if (this.targetInputValue) {
          const targetElement = document.getElementById(this.targetInputValue)
          if (targetElement) {
            targetElement.value = base64Data
          }
        }

        this.dispatch("dataReady", { detail: { data: base64Data } })
      }

      reader.readAsDataURL(this.recordedBlob)
    } catch (error) {
      console.error("Error converting to Base64:", error)
    }
  }

  // 再生/停止を切り替え
  togglePlayback() {
    if (this.isPlaying) {
      this.stopPlayback()
    } else {
      this.startPlayback()
    }
  }

  // 再生を開始
  startPlayback() {
    if (!this.hasAudioTarget || !this.recordedBlob) return

    this.audioTarget.play()
    this.isPlaying = true
    this.updateStatus("再生中...")
    this.updatePlayButtonState()

    this.audioTarget.onended = () => {
      this.isPlaying = false
      this.updateStatus("再生完了")
      this.updatePlayButtonState()
    }

    this.dispatch("playbackStarted", { detail: {} })
  }

  // 再生を停止
  stopPlayback() {
    if (!this.hasAudioTarget) return

    this.audioTarget.pause()
    this.audioTarget.currentTime = 0
    this.isPlaying = false
    this.updatePlayButtonState()

    this.dispatch("playbackStopped", { detail: {} })
  }

  // タイマーを開始
  startTimer() {
    this.timerInterval = setInterval(() => {
      const elapsed = Math.floor((Date.now() - this.recordingStartTime) / 1000)

      this.updateTimerDisplay(elapsed)

      // 最大時間に達したら自動停止
      if (elapsed >= this.maxDurationValue) {
        this.stopRecording()
        this.updateStatus("最大録音時間に達しました")
      }
    }, 100)
  }

  // タイマーを停止
  stopTimer() {
    if (this.timerInterval) {
      clearInterval(this.timerInterval)
      this.timerInterval = null
    }
  }

  // タイマー表示を更新
  updateTimerDisplay(seconds) {
    if (!this.hasTimerTarget) return

    const minutes = Math.floor(seconds / 60)
    const secs = seconds % 60
    this.timerTarget.textContent = `${minutes.toString().padStart(2, "0")}:${secs.toString().padStart(2, "0")}`
  }

  // ステータス表示を更新
  updateStatus(message) {
    if (this.hasStatusTarget) {
      this.statusTarget.textContent = message
    }
  }

  // ボタン状態を更新
  updateButtonStates() {
    if (this.hasRecordButtonTarget) {
      this.recordButtonTarget.disabled = this.isRecording
      this.recordButtonTarget.classList.toggle("opacity-50", this.isRecording)
    }

    if (this.hasStopButtonTarget) {
      this.stopButtonTarget.disabled = !this.isRecording
      this.stopButtonTarget.classList.toggle("opacity-50", !this.isRecording)
    }

    if (this.hasPlayButtonTarget) {
      const hasRecording = this.recordedBlob !== null
      this.playButtonTarget.disabled = !hasRecording || this.isRecording
      this.playButtonTarget.classList.toggle("opacity-50", !hasRecording || this.isRecording)
    }
  }

  // 再生ボタンの状態を更新
  updatePlayButtonState() {
    if (!this.hasPlayButtonTarget) return

    // 再生中はアイコンを一時停止に変更（必要に応じて）
    this.playButtonTarget.setAttribute("aria-label", this.isPlaying ? "一時停止" : "再生")
  }

  // 録音を無効化
  disableRecording() {
    if (this.hasRecordButtonTarget) {
      this.recordButtonTarget.disabled = true
      this.recordButtonTarget.classList.add("opacity-50", "cursor-not-allowed")
    }
  }

  // メディアストリームをクリーンアップ
  cleanupMediaStream() {
    if (this.stream) {
      this.stream.getTracks().forEach(track => track.stop())
      this.stream = null
    }
  }

  // MediaRecorderのオプションを取得
  getMediaRecorderOptions() {
    const mimeType = this.getAudioMimeType()
    return mimeType ? { mimeType } : {}
  }

  // サポートされているオーディオMIMEタイプを取得
  getAudioMimeType() {
    const types = [
      "audio/webm;codecs=opus",
      "audio/webm",
      "audio/ogg;codecs=opus",
      "audio/ogg",
      "audio/mp4",
      "audio/mpeg"
    ]

    for (const type of types) {
      if (MediaRecorder.isTypeSupported(type)) {
        return type
      }
    }

    return null
  }

  // 録音エラーを処理
  handleRecordingError(error) {
    let message = "録音を開始できません"

    if (error.name === "NotAllowedError" || error.name === "PermissionDeniedError") {
      message = "マイクへのアクセスが許可されていません"
    } else if (error.name === "NotFoundError" || error.name === "DevicesNotFoundError") {
      message = "マイクが見つかりません"
    } else if (error.name === "NotReadableError" || error.name === "TrackStartError") {
      message = "マイクが使用中です"
    }

    this.updateStatus(message)
    this.dispatch("error", { detail: { error, message } })
  }

  // コールバックを実行
  executeCallback(callbackName) {
    if (!callbackName) return

    this.dispatch(callbackName, { detail: {} })

    if (typeof window[callbackName] === "function") {
      window[callbackName]()
    }
  }

  // 録音データをクリア
  clear() {
    this.recordedBlob = null
    this.audioChunks = []

    if (this.hasAudioTarget) {
      this.audioTarget.src = ""
    }

    if (this.hasDataInputTarget) {
      this.dataInputTarget.value = ""
    }

    this.updateTimerDisplay(0)
    this.updateStatus("録音準備完了")
    this.updateButtonStates()

    this.dispatch("cleared", { detail: {} })
  }

  // 録音データを取得
  getRecordingBlob() {
    return this.recordedBlob
  }

  // 録音データをBase64で取得
  async getRecordingBase64() {
    if (!this.recordedBlob) return null

    return new Promise((resolve, reject) => {
      const reader = new FileReader()
      reader.onloadend = () => resolve(reader.result)
      reader.onerror = reject
      reader.readAsDataURL(this.recordedBlob)
    })
  }
}
