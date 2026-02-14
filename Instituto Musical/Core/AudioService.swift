//
//  AudioService.swift
//  Instituto Musical
//
//  Handles piano note playback via AVAudioEngine + AVAudioUnitSampler,
//  sound effects, and metronome clicks.
//

import AVFoundation
import Foundation
import Combine

@MainActor
final class AudioService: ObservableObject {

    static let shared = AudioService()

    private var audioEngine = AVAudioEngine()
    private var sampler = AVAudioUnitSampler()
    private var isSetup = false

    // SFX players
    private var sfxPlayers: [SFXType: AVAudioPlayer] = [:]

    @Published var volume: Float = 0.8 {
        didSet {
            audioEngine.mainMixerNode.outputVolume = volume
        }
    }

    @Published var isMuted = false

    // MARK: - Setup

    func setup() {
        guard !isSetup else { return }

        audioEngine.attach(sampler)
        audioEngine.connect(sampler, to: audioEngine.mainMixerNode, format: nil)

        // Try to load a SoundFont if bundled
        if let url = Bundle.main.url(forResource: "piano", withExtension: "sf2") {
            do {
                try sampler.loadSoundBankInstrument(
                    at: url,
                    program: 0,
                    bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB),
                    bankLSB: UInt8(kAUSampler_DefaultBankLSB)
                )
            } catch {
                print("⚠️ Could not load SoundFont: \(error). Using default sampler.")
            }
        } else {
            // No SoundFont bundled — sampler will use a default sine-like tone
            print("ℹ️ No piano.sf2 found. Add a SoundFont to the bundle for realistic piano sound.")
        }

        audioEngine.mainMixerNode.outputVolume = volume

        do {
            try audioEngine.start()
            isSetup = true
        } catch {
            print("❌ Audio engine failed to start: \(error)")
        }

        // Preload SFX
        preloadSFX()

        // Configure audio session for playback
        configureAudioSession()
    }

    private func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            print("⚠️ Audio session configuration failed: \(error)")
        }
    }

    // MARK: - Note Playback

    /// Play a single MIDI note
    func playNote(_ midiNote: UInt8, velocity: UInt8 = 100, duration: TimeInterval = 1.0) {
        guard !isMuted else { return }

        sampler.startNote(midiNote, withVelocity: velocity, onChannel: 0)

        Task {
            try? await Task.sleep(for: .seconds(duration))
            sampler.stopNote(midiNote, onChannel: 0)
        }
    }

    /// Play a note by NoteName and octave
    func playNote(_ note: NoteName, octave: Int = 4, duration: TimeInterval = 1.0) {
        let midi = MusicTheory.toMIDI(note: note, octave: octave)
        playNote(midi, duration: duration)
    }

    /// Play a chord (multiple notes simultaneously)
    func playChord(_ midiNotes: [UInt8], velocity: UInt8 = 100, duration: TimeInterval = 1.5) {
        guard !isMuted else { return }

        for note in midiNotes {
            sampler.startNote(note, withVelocity: velocity, onChannel: 0)
        }

        Task {
            try? await Task.sleep(for: .seconds(duration))
            for note in midiNotes {
                sampler.stopNote(note, onChannel: 0)
            }
        }
    }

    /// Play a chord by NoteNames
    func playChord(_ notes: [NoteName], octave: Int = 4, duration: TimeInterval = 1.5) {
        let midiNotes = notes.map { MusicTheory.toMIDI(note: $0, octave: octave) }
        playChord(midiNotes, duration: duration)
    }

    /// Play a sequence of notes (scale, melody) with delay between each
    func playSequence(_ notes: [NoteName], octave: Int = 4, interval: TimeInterval = 0.3) {
        guard !isMuted else { return }

        for (index, note) in notes.enumerated() {
            let delay = TimeInterval(index) * interval
            Task {
                try? await Task.sleep(for: .seconds(delay))
                playNote(note, octave: octave, duration: interval * 0.9)
            }
        }
    }

    /// Stop all currently playing notes
    func stopAll() {
        for midi: UInt8 in 0...127 {
            sampler.stopNote(midi, onChannel: 0)
        }
    }

    // MARK: - Sound Effects

    enum SFXType: String, CaseIterable {
        case correct = "correct"
        case wrong = "wrong"
        case levelUp = "level_up"
        case bossDefeat = "boss_defeat"
        case metronomeTick = "metronome_tick"
        case bridgeBuild = "bridge_build"
        case bridgeBreak = "bridge_break"
        case buttonTap = "button_tap"
        case starEarned = "star_earned"
        case comboBonus = "combo"
    }

    private func preloadSFX() {
        for sfx in SFXType.allCases {
            if let url = Bundle.main.url(forResource: sfx.rawValue, withExtension: "wav") ??
                         Bundle.main.url(forResource: sfx.rawValue, withExtension: "mp3") {
                do {
                    let player = try AVAudioPlayer(contentsOf: url)
                    player.prepareToPlay()
                    sfxPlayers[sfx] = player
                } catch {
                    // SFX file not found — will use system sounds as fallback
                }
            }
        }
    }

    /// Play a sound effect
    func playSFX(_ type: SFXType) {
        guard !isMuted else { return }

        if let player = sfxPlayers[type] {
            player.currentTime = 0
            player.volume = volume
            player.play()
        } else {
            // Fallback: use system haptic + tone for essential feedback
            playFallbackSFX(type)
        }
    }

    private func playFallbackSFX(_ type: SFXType) {
        switch type {
        case .correct:
            // Quick high note as "correct" chime
            playNote(76, velocity: 80, duration: 0.2) // E5
        case .wrong:
            // Dissonant pair as "wrong" buzz
            playNote(48, velocity: 60, duration: 0.3) // C3
            playNote(49, velocity: 60, duration: 0.3) // C#3
        case .metronomeTick:
            playNote(80, velocity: 40, duration: 0.05) // High click
        default:
            break
        }
    }

    // MARK: - Metronome

    private var metronomeTimer: Timer?
    @Published var isMetronomeRunning = false

    func startMetronome(bpm: Double) {
        stopMetronome()
        isMetronomeRunning = true
        let interval = 60.0 / bpm

        metronomeTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.playSFX(.metronomeTick)
            }
        }
    }

    func stopMetronome() {
        metronomeTimer?.invalidate()
        metronomeTimer = nil
        isMetronomeRunning = false
    }
}
