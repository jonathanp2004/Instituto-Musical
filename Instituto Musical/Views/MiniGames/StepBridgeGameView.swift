//
//  StepBridgeGameView.swift
//  Instituto Musical
//
//  Adventure 2 mini-game: Given a starting note and a step instruction,
//  tap the correct note on the keyboard to build a bridge.
//

import SwiftUI
import SwiftData

struct StepBridgeGameView: View {
    let coordinator: AppCoordinator
    @StateObject private var vm = StepBridgeViewModel()
    @Environment(\.modelContext) private var modelContext
    @Query private var allProgress: [TopicProgress]

    var body: some View {
        ZStack {
            Color.imBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Top HUD
                HStack {
                    // Score
                    VStack(alignment: .leading) {
                        Text("Puntos")
                            .font(.imCaption)
                            .foregroundStyle(.imTextMuted)
                        Text("\(vm.score)")
                            .font(.imHeadline)
                            .foregroundStyle(.imTextPrimary)
                    }

                    Spacer()

                    // Progress (questions answered)
                    Text("\(vm.currentIndex + 1)/\(vm.totalQuestions)")
                        .font(.imSubheadline)
                        .foregroundStyle(.imTextSecondary)

                    Spacer()

                    // Lives (wrong answers)
                    HStack(spacing: 4) {
                        ForEach(0..<3, id: \.self) { i in
                            Image(systemName: i < (3 - vm.wrongCount) ? "heart.fill" : "heart")
                                .foregroundStyle(i < (3 - vm.wrongCount) ? .imAccent : .imTextMuted)
                        }
                    }
                }
                .padding()

                // Bridge visualization
                BridgeProgressView(
                    progress: vm.bridgeProgress,
                    totalSegments: vm.totalQuestions
                )
                .frame(height: 60)
                .padding(.horizontal)

                Spacer()

                // Question prompt
                if let question = vm.currentQuestion {
                    VStack(spacing: 12) {
                        Text(question.startNoteName)
                            .font(.imLargeNumber)
                            .foregroundStyle(.imPrimary)

                        Text(question.instruction)
                            .font(.imGamePrompt)
                            .foregroundStyle(.imTextPrimary)
                            .multilineTextAlignment(.center)

                        if vm.streak >= 3 {
                            Text("🔥 Combo ×\(min(vm.streak, 5))")
                                .font(.imCaption)
                                .foregroundStyle(.orange)
                        }
                    }
                    .padding()
                }

                Spacer()

                // Feedback overlay
                if vm.showingFeedback {
                    FeedbackBanner(isCorrect: vm.lastCorrect, correctAnswer: vm.lastCorrectAnswer)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.horizontal)
                }

                // Piano keyboard
                PianoKeyboardView(
                    startOctave: 3,
                    octaveCount: 2,
                    onKeyTapped: { note, _ in
                        vm.submitAnswer(note)
                    },
                    showLabels: true,
                    labelLanguage: "es"
                )
                .frame(height: 170)
                .disabled(vm.showingFeedback || vm.isFinished)
                .padding(.bottom, 8)
            }

            // Game Over / Results overlay
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
        .navigationTitle("Step Bridge")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.imBackground, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear { vm.startGame() }
    }

    private func saveProgress() {
        if let progress = allProgress.first(where: { $0.topicID == "adventure_2" }) {
            progress.recordAttempt(questionsTotal: vm.totalQuestions, questionsCorrect: vm.correctCount)
            try? modelContext.save()
        }
    }
}

// MARK: - ViewModel

@MainActor
class StepBridgeViewModel: ObservableObject {
    struct Question {
        let startNote: NoteName
        let startNoteName: String
        let instruction: String
        let correctAnswer: NoteName
    }

    @Published var currentQuestion: Question?
    @Published var currentIndex = 0
    @Published var score = 0
    @Published var wrongCount = 0
    @Published var correctCount = 0
    @Published var streak = 0
    @Published var showingFeedback = false
    @Published var lastCorrect = false
    @Published var lastCorrectAnswer = ""
    @Published var isFinished = false

    let totalQuestions = 12
    private var questions: [Question] = []
    private let audio = AudioService.shared

    var bridgeProgress: Double {
        Double(correctCount) / Double(totalQuestions)
    }

    func startGame() {
        questions = generateQuestions()
        currentIndex = 0
        currentQuestion = questions.first
    }

    func submitAnswer(_ note: NoteName) {
        guard let question = currentQuestion, !showingFeedback else { return }

        let isCorrect = note == question.correctAnswer
        lastCorrect = isCorrect
        lastCorrectAnswer = question.correctAnswer.spanishName
        showingFeedback = true

        if isCorrect {
            audio.playNote(note, octave: 4, duration: 0.5)
            audio.playSFX(.correct)
            streak += 1
            correctCount += 1
            let multiplier = min(streak / 3 + 1, 5)
            score += 10 * multiplier
        } else {
            audio.playSFX(.wrong)
            streak = 0
            wrongCount += 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            self.showingFeedback = false

            if self.wrongCount >= 3 || self.currentIndex >= self.totalQuestions - 1 {
                withAnimation { self.isFinished = true }
            } else {
                self.currentIndex += 1
                if self.currentIndex < self.questions.count {
                    self.currentQuestion = self.questions[self.currentIndex]
                }
            }
        }
    }

    private func generateQuestions() -> [Question] {
        var result: [Question] = []
        let allNotes = NoteName.allCases

        let instructions: [(String, (NoteName) -> NoteName)] = [
            ("Un semitono más alto", { $0.up(1) }),
            ("Un semitono más bajo", { $0.down(1) }),
            ("Un tono más alto", { $0.up(2) }),
            ("Un tono más bajo", { $0.down(2) }),
            ("2 semitonos más alto", { $0.up(2) }),
            ("2 tonos más alto", { $0.up(4) }),
            ("3 semitonos más alto", { $0.up(3) }),
            ("2 semitonos más bajo", { $0.down(2) }),
            ("Un tono y medio más alto", { $0.up(3) }),
        ]

        for _ in 0..<totalQuestions {
            let startNote = allNotes.randomElement()!
            let instr = instructions.randomElement()!
            let answer = instr.1(startNote)

            result.append(Question(
                startNote: startNote,
                startNoteName: startNote.spanishName,
                instruction: instr.0,
                correctAnswer: answer
            ))
        }
        return result
    }
}

// MARK: - Supporting Views

struct BridgeProgressView: View {
    let progress: Double
    let totalSegments: Int

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                // Bridge base
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.imCard)

                // Built section
                RoundedRectangle(cornerRadius: 6)
                    .fill(
                        LinearGradient(
                            colors: [.imPrimary, .regionEcho],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geo.size.width * progress)
                    .animation(.spring(response: 0.4), value: progress)
            }
        }
    }
}

struct FeedbackBanner: View {
    let isCorrect: Bool
    let correctAnswer: String

    var body: some View {
        HStack {
            Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
            Text(isCorrect ? "¡Correcto!" : "Incorrecto — era \(correctAnswer)")
                .font(.imBody)
        }
        .foregroundStyle(.white)
        .padding()
        .frame(maxWidth: .infinity)
        .background(isCorrect ? Color.imCorrect : Color.imWrong)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct GameResultsOverlay: View {
    let score: Int
    let correct: Int
    let total: Int
    let onContinue: () -> Void

    private var percentage: Int {
        total > 0 ? (correct * 100) / total : 0
    }

    private var stars: Int {
        if percentage >= 90 { return 3 }
        if percentage >= 75 { return 2 }
        if percentage >= 50 { return 1 }
        return 0
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.7).ignoresSafeArea()

            VStack(spacing: 24) {
                Text(percentage >= 50 ? "🎉" : "😔")
                    .font(.system(size: 60))

                Text(percentage >= 50 ? "¡Buen trabajo!" : "¡Sigue practicando!")
                    .font(.imTitle)
                    .foregroundStyle(.imTextPrimary)

                StarRatingView(stars: stars, size: 36)

                VStack(spacing: 8) {
                    Text("\(correct)/\(total) correctas")
                        .font(.imSubheadline)
                        .foregroundStyle(.imTextSecondary)
                    Text("Puntuación: \(score)")
                        .font(.imHeadline)
                        .foregroundStyle(.imWarning)
                }

                Button("Continuar") {
                    onContinue()
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .padding(32)
            .background(Color.imSurface)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding(32)
        }
    }
}
