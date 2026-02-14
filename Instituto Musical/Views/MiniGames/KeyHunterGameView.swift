//
//  KeyHunterGameView.swift
//  Instituto Musical
//
//  Adventure 1 mini-game: A note name appears — tap the correct key on the piano.
//  Speed increases with each correct answer.
//

import SwiftUI
import SwiftData

struct KeyHunterGameView: View {
    let coordinator: AppCoordinator
    @StateObject private var vm = KeyHunterViewModel()
    @Environment(\.modelContext) private var modelContext
    @Query private var allProgress: [TopicProgress]

    var body: some View {
        ZStack {
            Color.imBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // HUD
                HStack {
                    VStack(alignment: .leading) {
                        Text("Puntos: \(vm.score)")
                            .font(.imSubheadline)
                            .foregroundStyle(.imTextPrimary)
                        if vm.streak >= 3 {
                            Text("🔥 ×\(min(vm.streak, 5))")
                                .font(.imCaption)
                                .foregroundStyle(.orange)
                        }
                    }

                    Spacer()

                    // Timer bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.1))
                            RoundedRectangle(cornerRadius: 4)
                                .fill(vm.timeRemaining > 0.3 ? Color.imCorrect : Color.imAccent)
                                .frame(width: geo.size.width * vm.timeRemaining)
                                .animation(.linear(duration: 0.1), value: vm.timeRemaining)
                        }
                    }
                    .frame(width: 120, height: 8)

                    Spacer()

                    Text("\(vm.correctCount)/\(vm.totalQuestions)")
                        .font(.imSubheadline)
                        .foregroundStyle(.imTextSecondary)
                }
                .padding()

                Spacer()

                // Target note display
                if let target = vm.currentTarget {
                    VStack(spacing: 8) {
                        Text("¡Encuentra esta nota!")
                            .font(.imCaption)
                            .foregroundStyle(.imTextMuted)

                        Text(target.spanishName)
                            .font(.system(size: 72, weight: .heavy, design: .rounded))
                            .foregroundStyle(.imPrimary)

                        Text(target.englishName)
                            .font(.imSubheadline)
                            .foregroundStyle(.imTextMuted)
                    }
                    .transition(.scale.combined(with: .opacity))
                }

                Spacer()

                // Feedback
                if vm.showingFeedback {
                    FeedbackBanner(isCorrect: vm.lastCorrect, correctAnswer: vm.lastCorrectAnswer)
                        .padding(.horizontal)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                // Piano
                PianoKeyboardView(
                    startOctave: 3,
                    octaveCount: 2,
                    onKeyTapped: { note, _ in vm.submitAnswer(note) },
                    showLabels: false,
                    labelLanguage: "es"
                )
                .frame(height: 170)
                .disabled(vm.showingFeedback || vm.isFinished)
                .padding(.bottom, 8)
            }

            if vm.isFinished {
                GameResultsOverlay(
                    score: vm.score,
                    correct: vm.correctCount,
                    total: vm.totalQuestions,
                    onContinue: {
                        saveProgress()
                        coordinator.mapNavigationPath.removeLast()
                    }
                )
                .transition(.opacity)
            }
        }
        .navigationTitle("Key Hunter")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.imBackground, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear { vm.startGame() }
        .onDisappear { vm.stopTimer() }
    }

    private func saveProgress() {
        if let progress = allProgress.first(where: { $0.topicID == "adventure_1" }) {
            progress.recordAttempt(questionsTotal: vm.totalQuestions, questionsCorrect: vm.correctCount)
            try? modelContext.save()
        }
    }
}

@MainActor
class KeyHunterViewModel: ObservableObject {
    @Published var currentTarget: NoteName?
    @Published var score = 0
    @Published var correctCount = 0
    @Published var streak = 0
    @Published var showingFeedback = false
    @Published var lastCorrect = false
    @Published var lastCorrectAnswer = ""
    @Published var timeRemaining: Double = 1.0
    @Published var isFinished = false

    let totalQuestions = 15
    private var currentIndex = 0
    private var timer: Timer?
    private var timePerQuestion: Double = 5.0
    private let audio = AudioService.shared

    func startGame() {
        currentIndex = 0
        nextQuestion()
    }

    func submitAnswer(_ note: NoteName) {
        guard let target = currentTarget, !showingFeedback else { return }

        stopTimer()
        let isCorrect = note == target
        lastCorrect = isCorrect
        lastCorrectAnswer = target.spanishName
        showingFeedback = true

        if isCorrect {
            audio.playNote(note, octave: 4, duration: 0.5)
            audio.playSFX(.correct)
            streak += 1
            correctCount += 1
            score += 10 * min(streak, 5)
            // Speed up slightly
            timePerQuestion = max(2.0, timePerQuestion - 0.15)
        } else {
            audio.playSFX(.wrong)
            streak = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            guard let self else { return }
            self.showingFeedback = false
            self.currentIndex += 1
            if self.currentIndex >= self.totalQuestions {
                withAnimation { self.isFinished = true }
            } else {
                self.nextQuestion()
            }
        }
    }

    private func nextQuestion() {
        currentTarget = NoteName.allCases.randomElement()!
        timeRemaining = 1.0
        startTimer()
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                self.timeRemaining -= 0.05 / self.timePerQuestion
                if self.timeRemaining <= 0 {
                    self.timeExpired()
                }
            }
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func timeExpired() {
        stopTimer()
        lastCorrect = false
        lastCorrectAnswer = currentTarget?.spanishName ?? ""
        showingFeedback = true
        streak = 0
        audio.playSFX(.wrong)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            guard let self else { return }
            self.showingFeedback = false
            self.currentIndex += 1
            if self.currentIndex >= self.totalQuestions {
                withAnimation { self.isFinished = true }
            } else {
                self.nextQuestion()
            }
        }
    }
}
