//
//  AudioSessionObserverView.swift
//  VoiceAssistant
//
//  Created by Hiroshi Horie on 2025/03/17.
//

import AVFoundation
import SwiftUI

#if os(iOS)
class AudioSessionObserver: NSObject, ObservableObject {
    @Published var currentCategory: AVAudioSession.Category = .playback
    @Published var currentMode: AVAudioSession.Mode = .default
    @Published var currentCategoryOptions: AVAudioSession.CategoryOptions = []
    @Published var isActive: Bool = false
    @Published var inputLatency: TimeInterval = 0
    @Published var outputLatency: TimeInterval = 0
    @Published var sampleRate: Double = 0
    @Published var preferredSampleRate: Double = 0
    @Published var inputNumberOfChannels: Int = 0
    @Published var outputNumberOfChannels: Int = 0
    @Published var maximumInputNumberOfChannels: Int = 0
    @Published var maximumOutputNumberOfChannels: Int = 0
    @Published var preferredInputNumberOfChannels: Int = 0
    @Published var preferredOutputNumberOfChannels: Int = 0
    @Published var interruptionCount: Int = 0
    @Published var routeChangeCount: Int = 0
    @Published var lastInterruptionType: String = "None"
    @Published var lastRouteChangeReason: String = "None"

    private var observationTokens: [NSObjectProtocol] = []

    override init() {
        super.init()
        setupNotifications()
        updateSessionInfo()
    }

    deinit {
        // Remove all notification observers
        observationTokens.forEach { NotificationCenter.default.removeObserver($0) }
    }

    private func setupNotifications() {
        let center = NotificationCenter.default

        let interruptionToken = center.addObserver(
            forName: AVAudioSession.interruptionNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.handleInterruption(notification)
        }

        let routeChangeToken = center.addObserver(
            forName: AVAudioSession.routeChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.handleRouteChange(notification)
        }

        let mediaServicesResetToken = center.addObserver(
            forName: AVAudioSession.mediaServicesWereResetNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleMediaServicesReset()
        }

        let silenceSecondaryAudioToken = center.addObserver(
            forName: AVAudioSession.silenceSecondaryAudioHintNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.handleSilenceSecondaryAudio(notification)
        }

        observationTokens = [interruptionToken, routeChangeToken, mediaServicesResetToken, silenceSecondaryAudioToken]
    }

    func updateSessionInfo() {
        let session = AVAudioSession.sharedInstance()
        currentCategory = session.category
        currentMode = session.mode
        currentCategoryOptions = session.categoryOptions
        inputLatency = session.inputLatency
        outputLatency = session.outputLatency
        sampleRate = session.sampleRate
        preferredSampleRate = session.preferredSampleRate
        inputNumberOfChannels = session.inputNumberOfChannels
        outputNumberOfChannels = session.outputNumberOfChannels
        maximumInputNumberOfChannels = session.maximumInputNumberOfChannels
        maximumOutputNumberOfChannels = session.maximumOutputNumberOfChannels
        preferredInputNumberOfChannels = session.preferredInputNumberOfChannels
        preferredOutputNumberOfChannels = session.preferredOutputNumberOfChannels
    }

    // Handle interruption notifications
    private func handleInterruption(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue)
        else {
            return
        }

        interruptionCount += 1

        switch type {
        case .began:
            lastInterruptionType = "Notification: Began"
            print("Audio Session interruption began")
        case .ended:
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    lastInterruptionType = "Notification: Ended (Should Resume)"
                    print("Audio Session interruption ended with options: Should Resume")
                } else {
                    lastInterruptionType = "Notification: Ended"
                    print("Audio Session interruption ended")
                }
            } else {
                lastInterruptionType = "Notification: Ended"
                print("Audio Session interruption ended")
            }
        @unknown default:
            lastInterruptionType = "Notification: Unknown"
        }

        updateSessionInfo()
    }

    // Handle route change notifications
    private func handleRouteChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue)
        else {
            return
        }

        routeChangeCount += 1

        switch reason {
        case .newDeviceAvailable:
            lastRouteChangeReason = "New Device Available"
        case .oldDeviceUnavailable:
            lastRouteChangeReason = "Old Device Unavailable"
        case .categoryChange:
            lastRouteChangeReason = "Category Change"
        case .override:
            lastRouteChangeReason = "Override"
        case .wakeFromSleep:
            lastRouteChangeReason = "Wake From Sleep"
        case .noSuitableRouteForCategory:
            lastRouteChangeReason = "No Suitable Route For Category"
        case .routeConfigurationChange:
            lastRouteChangeReason = "Route Configuration Change"
        case .unknown:
            lastRouteChangeReason = "Unknown"
        @unknown default:
            lastRouteChangeReason = "Unknown (\(reasonValue))"
        }

        updateSessionInfo()
    }

    // Handle media services reset
    private func handleMediaServicesReset() {
        print("Media services were reset")
        updateSessionInfo()
    }

    // Handle silence secondary audio hint
    private func handleSilenceSecondaryAudio(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionSilenceSecondaryAudioHintTypeKey] as? UInt,
              let type = AVAudioSession.SilenceSecondaryAudioHintType(rawValue: typeValue)
        else {
            return
        }

        switch type {
        case .begin:
            print("Secondary audio did begin")
        case .end:
            print("Secondary audio did end")
        @unknown default:
            print("Unknown secondary audio hint type")
        }

        updateSessionInfo()
    }

    // Method to change audio session category and mode
    func setSessionCategory(_ category: AVAudioSession.Category, mode: AVAudioSession.Mode, options: AVAudioSession.CategoryOptions = []) {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(category, mode: mode, options: options)
            try session.setActive(true)
            updateSessionInfo()
        } catch {
            print("Failed to set audio session category: \(error)")
        }
    }
}

struct AudioSessionMonitorView: View {
    @StateObject private var sessionObserver = AudioSessionObserver()
    @State private var showDetails = false

    private func categoryName(for category: AVAudioSession.Category) -> String {
        switch category {
        case .ambient: return "Ambient"
        case .soloAmbient: return "Solo Ambient"
        case .playback: return "Playback"
        case .record: return "Record"
        case .playAndRecord: return "Play and Record"
        case .multiRoute: return "Multi-Route"
        default: return "Unknown"
        }
    }

    private func modeName(for mode: AVAudioSession.Mode) -> String {
        switch mode {
        case .default: return "Default"
        case .gameChat: return "Game Chat"
        case .measurement: return "Measurement"
        case .moviePlayback: return "Movie Playback"
        case .spokenAudio: return "Spoken Audio"
        case .videoChat: return "Video Chat"
        case .videoRecording: return "Video Recording"
        case .voiceChat: return "Voice Chat"
        case .voicePrompt: return "Voice Prompt"
        default: return "Unknown"
        }
    }

    private func categoryOptionsDescription(_ options: AVAudioSession.CategoryOptions) -> String {
        var descriptions: [String] = []

        if options.contains(.mixWithOthers) {
            descriptions.append("Mix With Others")
        }
        if options.contains(.duckOthers) {
            descriptions.append("Duck Others")
        }
        if options.contains(.allowBluetooth) {
            descriptions.append("Allow Bluetooth")
        }
        if options.contains(.defaultToSpeaker) {
            descriptions.append("Default To Speaker")
        }
        if options.contains(.interruptSpokenAudioAndMixWithOthers) {
            descriptions.append("Interrupt Spoken Audio")
        }
        if options.contains(.allowBluetoothA2DP) {
            descriptions.append("Allow Bluetooth A2DP")
        }
        if options.contains(.allowAirPlay) {
            descriptions.append("Allow AirPlay")
        }

        return descriptions.isEmpty ? "None" : descriptions.joined(separator: ", ")
    }

    var body: some View {
        List {
            // Current Session Information
            Section(header: Text("Current Audio Session")) {
                HStack {
                    Text("Category")
                    Spacer()
                    Text(categoryName(for: sessionObserver.currentCategory))
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("Mode")
                    Spacer()
                    Text(modeName(for: sessionObserver.currentMode))
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("Options")
                    Spacer()
                    Text(categoryOptionsDescription(sessionObserver.currentCategoryOptions))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.trailing)
                }
            }
        }
        .navigationTitle("Audio Session Monitor")
        .onAppear {
            sessionObserver.updateSessionInfo()
        }
    }
}
#endif
