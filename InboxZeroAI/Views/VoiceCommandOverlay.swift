import SwiftUI
import Speech
import AVFoundation

struct VoiceCommandOverlay: View {
    @ObservedObject var store: MailboxStore
    @Binding var isPresented: Bool

    @State private var isRecording = false
    @State private var transcript = ""
    @State private var audioLevel: CGFloat = 0.3
    @State private var timer: Timer?
    @State private var hasPermission = SFSpeechRecognizer.authorizationStatus() == .authorized

    var body: some View {
        ZStack {
            Color.izCanvas.opacity(0.97).ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                if hasPermission {
                    waveformView
                } else {
                    permissionView
                }

                VStack(spacing: 8) {
                    if transcript.isEmpty {
                        Text(isRecording ? "Listening..." : "Tap to speak")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(Color.izText)
                    } else {
                        Text(transcript)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(Color.izText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                }

                Spacer()

                if hasPermission {
                    micButton
                }

                Button {
                    dismiss()
                } label: {
                    Text("Close")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.izTextSecondary)
                }
                .buttonStyle(.plain)
                .padding(.bottom, 32)
            }
        }
        .onAppear {
            requestPermission()
        }
        .onDisappear {
            stopRecording()
        }
    }

    private var waveformView: some View {
        HStack(spacing: 4) {
            ForEach(0..<5, id: \.self) { i in
                Capsule()
                    .fill(Color.izAccentLight)
                    .frame(width: 5, height: isRecording ? 40 * audioLevel : 6)
                    .animation(.easeInOut(duration: 0.2), value: audioLevel)
            }
        }
        .frame(height: 50)
    }

    private var permissionView: some View {
        VStack(spacing: 12) {
            Image(systemName: "mic.slash.fill")
                .font(.system(size: 40))
                .foregroundStyle(Color.izTextSecondary)
            Text("Microphone access needed")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.izText)
            Text("Enable microphone in Settings to use voice commands.")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.izTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 32)
    }

    private var micButton: some View {
        Button {
            Haptics.tap()
            if isRecording {
                stopRecording()
            } else {
                startRecording()
            }
        } label: {
            ZStack {
                Circle()
                    .fill(isRecording ? Color.izError : Color.izAccent)
                    .frame(width: 72, height: 72)
                    .shadow(color: (isRecording ? Color.izError : Color.izAccent).opacity(0.4), radius: 12, y: 4)

                Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Color.izCanvas)
            }
        }
        .buttonStyle(.plain)
        .padding(.bottom, 16)
    }

    private func requestPermission() {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                hasPermission = status == .authorized
            }
        }
    }

    private func startRecording() {
        isRecording = true
        transcript = ""

        timer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.15)) {
                audioLevel = CGFloat.random(in: 0.3...1.0)
            }
        }

        // Simulated transcript for demo
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            if isRecording {
                transcript = "Archive the top email"
                stopRecording()
                store.processVoiceCommand(transcript)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    dismiss()
                }
            }
        }
    }

    private func stopRecording() {
        isRecording = false
        timer?.invalidate()
        timer = nil
        withAnimation(.easeInOut(duration: 0.2)) {
            audioLevel = 0.3
        }
    }

    private func dismiss() {
        isPresented = false
    }
}
