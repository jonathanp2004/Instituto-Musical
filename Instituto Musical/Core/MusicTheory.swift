//
//  MusicTheory.swift
//  Instituto Musical
//
//  Core music theory engine: note names, half/whole step calculations,
//  scale/chord building, MIDI mapping, and interval logic.
//

import Foundation

// MARK: - Note Representation

/// All 12 chromatic notes using sharp spelling (canonical form).
/// Index 0 = C/Do, Index 11 = B/Si
enum NoteName: Int, CaseIterable, Codable, Hashable {
    case C = 0, CSharp, D, DSharp, E, F, FSharp, G, GSharp, A, ASharp, B

    // MARK: Display Names

    var englishName: String {
        switch self {
        case .C: return "C"
        case .CSharp: return "C#"
        case .D: return "D"
        case .DSharp: return "D#"
        case .E: return "E"
        case .F: return "F"
        case .FSharp: return "F#"
        case .G: return "G"
        case .GSharp: return "G#"
        case .A: return "A"
        case .ASharp: return "A#"
        case .B: return "B"
        }
    }

    var spanishName: String {
        switch self {
        case .C: return "Do"
        case .CSharp: return "Do#"
        case .D: return "Re"
        case .DSharp: return "Re#"
        case .E: return "Mi"
        case .F: return "Fa"
        case .FSharp: return "Fa#"
        case .G: return "Sol"
        case .GSharp: return "Sol#"
        case .A: return "La"
        case .ASharp: return "La#"
        case .B: return "Si"
        }
    }

    var englishFlat: String {
        switch self {
        case .CSharp: return "Db"
        case .DSharp: return "Eb"
        case .FSharp: return "Gb"
        case .GSharp: return "Ab"
        case .ASharp: return "Bb"
        default: return englishName
        }
    }

    var spanishFlat: String {
        switch self {
        case .CSharp: return "Reb"
        case .DSharp: return "Mib"
        case .FSharp: return "Solb"
        case .GSharp: return "Lab"
        case .ASharp: return "Sib"
        default: return spanishName
        }
    }

    var isBlackKey: Bool {
        switch self {
        case .CSharp, .DSharp, .FSharp, .GSharp, .ASharp: return true
        default: return false
        }
    }

    /// Get the enharmonic equivalent (sharp ↔ flat)
    var enharmonicEnglish: String {
        isBlackKey ? englishFlat : englishName
    }

    var enharmonicSpanish: String {
        isBlackKey ? spanishFlat : spanishName
    }

    // MARK: Step Operations

    /// Move up by a given number of half steps (semitones)
    func up(_ halfSteps: Int) -> NoteName {
        let newRaw = (rawValue + halfSteps) %% 12
        return NoteName(rawValue: newRaw)!
    }

    /// Move down by a given number of half steps
    func down(_ halfSteps: Int) -> NoteName {
        let newRaw = (rawValue - halfSteps) %% 12
        return NoteName(rawValue: newRaw)!
    }

    /// Move up by whole steps
    func upWhole(_ wholeSteps: Int) -> NoteName {
        up(wholeSteps * 2)
    }

    /// Move down by whole steps
    func downWhole(_ wholeSteps: Int) -> NoteName {
        down(wholeSteps * 2)
    }

    // MARK: Parsing

    /// Parse a note name string (English or Spanish, sharp or flat) into a NoteName
    static func from(_ string: String) -> NoteName? {
        let cleaned = string
            .trimmingCharacters(in: .whitespaces)
            .replacingOccurrences(of: "♯", with: "#")
            .replacingOccurrences(of: "♭", with: "b")

        // Try all possible spellings
        for note in NoteName.allCases {
            let candidates = [
                note.englishName.lowercased(),
                note.spanishName.lowercased(),
                note.englishFlat.lowercased(),
                note.spanishFlat.lowercased()
            ]
            if candidates.contains(cleaned.lowercased()) {
                return note
            }
        }
        return nil
    }
}

// MARK: - Music Theory Calculator

struct MusicTheory {

    // MARK: Constants

    static let halfStep = 1
    static let wholeStep = 2

    /// Major scale formula in half steps: W-W-H-W-W-W-H
    static let majorScaleIntervals = [2, 2, 1, 2, 2, 2, 1]

    /// Natural minor scale formula: W-H-W-W-H-W-W
    static let minorScaleIntervals = [2, 1, 2, 2, 1, 2, 2]

    /// Major chord intervals from root (in half steps): root, +4, +3
    static let majorChordIntervals = [0, 4, 7]  // root, major 3rd, perfect 5th

    /// Minor chord intervals from root: root, +3, +4
    static let minorChordIntervals = [0, 3, 7]  // root, minor 3rd, perfect 5th

    // MARK: Scale Building

    /// Build a major scale from a root note. Returns 8 notes (root to octave).
    static func majorScale(from root: NoteName) -> [NoteName] {
        buildScale(from: root, intervals: majorScaleIntervals)
    }

    /// Build a natural minor scale from a root note. Returns 8 notes.
    static func minorScale(from root: NoteName) -> [NoteName] {
        buildScale(from: root, intervals: minorScaleIntervals)
    }

    /// Generic scale builder from any interval pattern
    static func buildScale(from root: NoteName, intervals: [Int]) -> [NoteName] {
        var notes: [NoteName] = [root]
        var current = root
        for interval in intervals {
            current = current.up(interval)
            notes.append(current)
        }
        return notes
    }

    // MARK: Chord Building

    /// Build a major chord (triad) from a root note. Returns [Root, Major 3rd, Perfect 5th].
    static func majorChord(from root: NoteName) -> [NoteName] {
        majorChordIntervals.map { root.up($0) }
    }

    /// Build a minor chord (triad) from a root note. Returns [Root, Minor 3rd, Perfect 5th].
    static func minorChord(from root: NoteName) -> [NoteName] {
        minorChordIntervals.map { root.up($0) }
    }

    // MARK: Interval Calculation

    /// Count half steps between two notes (ascending)
    static func halfStepsBetween(_ from: NoteName, _ to: NoteName) -> Int {
        (to.rawValue - from.rawValue) %% 12
    }

    /// Name the interval between two notes
    static func intervalName(from: NoteName, to: NoteName) -> String {
        let steps = halfStepsBetween(from, to)
        switch steps {
        case 0: return "Unison"
        case 1: return "Minor 2nd"
        case 2: return "Major 2nd"
        case 3: return "Minor 3rd"
        case 4: return "Major 3rd"
        case 5: return "Perfect 4th"
        case 6: return "Tritone"
        case 7: return "Perfect 5th"
        case 8: return "Minor 6th"
        case 9: return "Major 6th"
        case 10: return "Minor 7th"
        case 11: return "Major 7th"
        case 12: return "Octave"
        default: return "\(steps) semitones"
        }
    }

    /// Spanish interval name
    static func intervalNameES(from: NoteName, to: NoteName) -> String {
        let steps = halfStepsBetween(from, to)
        switch steps {
        case 0: return "Unísono"
        case 1: return "2da Menor"
        case 2: return "2da Mayor"
        case 3: return "3ra Menor"
        case 4: return "3ra Mayor"
        case 5: return "4ta Justa"
        case 6: return "Tritono"
        case 7: return "5ta Justa"
        case 8: return "6ta Menor"
        case 9: return "6ta Mayor"
        case 10: return "7ma Menor"
        case 11: return "7ma Mayor"
        case 12: return "Octava"
        default: return "\(steps) semitonos"
        }
    }

    // MARK: MIDI

    /// Convert a NoteName + octave to a MIDI note number.
    /// Middle C (C4) = MIDI 60.
    static func toMIDI(note: NoteName, octave: Int = 4) -> UInt8 {
        let midi = (octave + 1) * 12 + note.rawValue
        return UInt8(clamping: midi)
    }

    /// Convert a MIDI note number back to NoteName + octave
    static func fromMIDI(_ midi: UInt8) -> (note: NoteName, octave: Int) {
        let noteIndex = Int(midi) % 12
        let octave = Int(midi) / 12 - 1
        return (NoteName(rawValue: noteIndex)!, octave)
    }

    // MARK: Music Math (worksheet-style operations)

    /// Parse and evaluate a music math expression like "Do + W + H - W"
    /// Returns the resulting NoteName.
    static func evaluate(startNote: NoteName, operations: String) -> NoteName {
        var current = startNote
        let tokens = operations
            .replacingOccurrences(of: "+", with: " + ")
            .replacingOccurrences(of: "-", with: " - ")
            .split(separator: " ")
            .map(String.init)

        var i = 0
        while i < tokens.count {
            let token = tokens[i].trimmingCharacters(in: .whitespaces)

            if token == "+" && i + 1 < tokens.count {
                let next = tokens[i + 1].trimmingCharacters(in: .whitespaces).uppercased()
                current = applyStep(current, step: next, direction: 1)
                i += 2
            } else if token == "-" && i + 1 < tokens.count {
                let next = tokens[i + 1].trimmingCharacters(in: .whitespaces).uppercased()
                current = applyStep(current, step: next, direction: -1)
                i += 2
            } else {
                i += 1
            }
        }
        return current
    }

    private static func applyStep(_ note: NoteName, step: String, direction: Int) -> NoteName {
        // Handle multiplied steps like "3(W)" or "2(H)"
        let multiplierPattern = /(\d+)\(([WH])\)/
        if let match = step.firstMatch(of: multiplierPattern) {
            let count = Int(match.1)!
            let stepType = String(match.2)
            let halfSteps = (stepType == "W" ? 2 : 1) * count
            return direction > 0 ? note.up(halfSteps) : note.down(halfSteps)
        }

        switch step {
        case "H": return direction > 0 ? note.up(1) : note.down(1)
        case "W": return direction > 0 ? note.up(2) : note.down(2)
        default: return note
        }
    }

    // MARK: Key Signatures

    /// Number of sharps for each major key (using circle of fifths)
    static func sharpsInKey(_ root: NoteName) -> Int? {
        let sharpKeys: [NoteName: Int] = [
            .C: 0, .G: 1, .D: 2, .A: 3, .E: 4, .B: 5, .FSharp: 6
        ]
        return sharpKeys[root]
    }

    /// Number of flats for each major key
    static func flatsInKey(_ root: NoteName) -> Int? {
        let flatKeys: [NoteName: Int] = [
            .C: 0, .F: 1, .ASharp: 2, .DSharp: 3, .GSharp: 4, .CSharp: 5, .FSharp: 6
        ]
        return flatKeys[root]
    }

    /// Relative minor of a major key (down 3 half steps)
    static func relativeMinor(of majorRoot: NoteName) -> NoteName {
        majorRoot.down(3)
    }

    // MARK: All white keys in order (for keyboard reference)

    static let whiteKeys: [NoteName] = [.C, .D, .E, .F, .G, .A, .B]
    static let allNotes: [NoteName] = NoteName.allCases
}

// MARK: - Modulo that always returns positive (Swift % can be negative)

infix operator %%: MultiplicationPrecedence

func %% (lhs: Int, rhs: Int) -> Int {
    let result = lhs % rhs
    return result >= 0 ? result : result + rhs
}
