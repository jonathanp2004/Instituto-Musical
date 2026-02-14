//
//  NoteCalculatorGameView.swift
//  Instituto Musical
//
//  Adventure 4 mini-game: Solve music math equations like "Do + W = ?" or "Re + W + W - H = ?"
//

import SwiftUI
import SwiftData

struct NoteCalculatorGameView: View {
    let coordinator: AppCoordinator
    @StateObject private var vm = NoteCalculatorViewModel()
    @Environment(\.modelContext) private var modelContext
    @Query private var allProgress: [TopicProgress]

    var body: some View {
        ZStack {
            Color.imBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // HUD
                HStack {
                    Text("Puntos: \(vm.score)")
                        .font(.imSubheadline)
                        .foregroundStyle(.imTextPrimary)
                    Spacer()
                    Text("\(vm.currentIndex + 1)/\(vm.totalQuestions)")
                        .font(.imSubheadline)
                        .foregroundStyle(.imTextSecondary)
                    Spacer()
                    HStack(spacing: 4) {
                        ForEach(0..<3, id: \.self) { i in
                            Image(systemName: i < (3 - vm.wrongCount) ? "heart.fill" : "heart")
                                .foregroundStyle(i < (3 - vm.wrongCount) ? .imAccent : .imTextMuted)
                        }
                    }
                }
                .padding()

                Spacer()

                // Equation display
                if let q = vm.currentQuestion {
                    VStack(spacing: 16) {
                        Text("Resuelve:")
                            .font(.imCaption)
                            .foregroundStyle(.imTextMuted)

                        Text(q.equation)
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(.imPrimary)

                        Text("= ?")
                            .font(.imTitle)
                            .foregroundStyle(.imTextSecondary)
                    }
                    .padding()
                    .cardStyle()
                    .padding(.horizontal)
                }

                Spacer()

                // Feedback
                if vm.showingFeedback {
                    FeedbackBanner(isCorrect: vm.lastCorrect, correctAnswer: vm.lastCorrectAnswer)
                        .padding(.horizontal)
                }

                // Piano keyboard for answer
                PianoKeyboardView(
                    startOctave: 3,
                    octaveCount: 2,
                    onKeyTapped: { note, _ in vm.submitAnswer(note) },
                    showLabels: true,
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
            }
        }
        .navigationTitle("Note Calculator")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.imBackground, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear { vm.startGame() }
    }

    private func saveProgress() {
        if let progress = allProgress.first(where: { $0.topicID == "adventure_4" }) {
            progress.recordAttempt(questionsTotal: vm.totalQuestions, questionsCorrect: vm.correctCount)
            try? modelContext.save()
        }
    }
}

@MainActor
class NoteCalculatorViewModel: ObservableObject {
    struct MathQuestion {
        let equation: String
        let answer: NoteName
    }

    @Published var currentQuestion: MathQuestion?
    @Published var currentIndex = 0
    @Published var score = 0
    @Published var wrongCount = 0
    @Published var correctCount = 0
    @Published var showingFeedback = false
    @Published var lastCorrect = false
    @Published var lastCorrectAnswer = ""
    @Published var isFinished = false

    let totalQuestions = 10
    private var questions: [MathQuestion] = []
    private let audio = AudioService.shared

    func startGame() {
        questions = generateQuestions()
        currentIndex = 0
        currentQuestion = questions.first
    }

    func submitAnswer(_ note: NoteName) {
        guard let q = currentQuestion, !showingFeedback else { return }

        let isCorrect = note == q.answer
        lastCorrect = isCorrect
        lastCorrectAnswer = q.answer.spanishName
        showingFeedback = true

        if isCorrect {
            audio.playNote(note, octave: 4, duration: 0.5)
            audio.playSFX(.correct)
            correctCount += 1
            score += 15
        } else {
            audio.playSFX(.wrong)
            wrongCount += 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            self.showingFeedback = false

            if self.wrongCount >= 3 || self.currentIndex >= self.totalQuestions - 1 {
                withAnimation { self.isFinished = true }
            } else {
                self.currentIndex += 1
                self.currentQuestion = self.questions[self.currentIndex]
            }
        }
    }

    private func generateQuestions() -> [MathQuestion] {
        let notes = NoteName.allCases

        // Templates: (display string, operations to apply)
        let templates: [(String, [(Int, Bool)])] = [
            // (step amount in half steps, isUp)
            ("+ H", [(1, true)]),
            ("+ W", [(2, true)]),
            ("- H", [(1, false)]),
            ("- W", [(2, false)]),
            ("+ W + H", [(2, true), (1, true)]),
            ("+ W + W", [(2, true), (2, true)]),
            ("+ W - H", [(2, true), (1, false)]),
            ("+ W + W - H", [(2, true), (2, true), (1, false)]),
            ("- W - H", [(2, false), (1, false)]),
            ("+ H + H", [(1, true), (1, true)]),
        ]

        var result: [MathQuestion] = []
        for _ in 0..<totalQuestions {
            let start = notes.randomElement()!
            let template = templates.randomElement()!

            var current = start
            for (steps, isUp) in template.1 {
                current = isUp ? current.up(steps) : current.down(steps)
            }

            let equation = "\(start.spanishName) \(template.0)"
            result.append(MathQuestion(equation: equation, answer: current))
        }
        return result
    }
}
