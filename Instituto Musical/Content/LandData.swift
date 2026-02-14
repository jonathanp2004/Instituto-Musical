//
//  LandData.swift
//  Instituto Musical
//
//  Static definitions for all 16 adventure lands.
//  This is the "content database" loaded at app startup.
//

import SwiftUI

// MARK: - Land Model (not persisted — static content)

struct Land: Identifiable, Hashable {
    let id: String
    let number: Int
    let region: Int
    let nameEN: String
    let nameES: String
    let icon: String              // SF Symbol
    let regionColor: Color
    let storyEN: String
    let storyES: String
    let objectivesEN: [String]
    let objectivesES: [String]
    let miniGameIDs: [String]
    let bossNameEN: String
    let bossNameES: String
    let bossQuestionCount: Int
    let bossPassingScore: Double  // 0.0–1.0
    let bossXP: Int
    let prerequisite: Int?        // adventure number that must be beaten first

    var topicID: String { "adventure_\(number)" }
}

// MARK: - All Lands

struct LandData {
    static let allLands: [Land] = [

        // ═══════════════════════════════════════
        // REGION 1 — Las Tierras del Eco
        // ═══════════════════════════════════════

        Land(
            id: "adventure_1", number: 1, region: 1,
            nameEN: "The Valley of Keys",
            nameES: "El Valle de las Teclas",
            icon: "pianokeys",
            regionColor: .regionEcho,
            storyEN: "A giant stone piano lies dormant in a barren valley. Learn every key's name to awaken it!",
            storyES: "Un piano de piedra gigante yace dormido en un valle. ¡Aprende el nombre de cada tecla para despertarlo!",
            objectivesEN: [
                "Identify all white keys: C D E F G A B",
                "Understand the repeating octave pattern",
                "Locate groups of 2 and 3 black keys"
            ],
            objectivesES: [
                "Identificar todas las teclas blancas: Do Re Mi Fa Sol La Si",
                "Entender el patrón de octava que se repite",
                "Localizar grupos de 2 y 3 teclas negras"
            ],
            miniGameIDs: ["key_hunter", "note_sorter"],
            bossNameEN: "The Stone Piano",
            bossNameES: "El Piano de Piedra",
            bossQuestionCount: 12,
            bossPassingScore: 0.9,
            bossXP: 300,
            prerequisite: nil
        ),

        Land(
            id: "adventure_2", number: 2, region: 1,
            nameEN: "The Cave of Half Steps",
            nameES: "La Cueva de los Semitonos",
            icon: "arrow.left.and.right",
            regionColor: .regionEcho,
            storyEN: "Deep inside a crystal cave, pathways are separated by half steps and whole steps. Navigate by calculating distances!",
            storyES: "Dentro de una cueva de cristal, los caminos están separados por semitonos y tonos. ¡Navega calculando distancias!",
            objectivesEN: [
                "Define half step (H) and whole step (W)",
                "Know that 2 half steps = 1 whole step",
                "Calculate notes any number of steps away"
            ],
            objectivesES: [
                "Definir semitono (H) y tono (W)",
                "Saber que 2 semitonos = 1 tono",
                "Calcular notas a cualquier número de pasos"
            ],
            miniGameIDs: ["step_bridge", "crystal_counter"],
            bossNameEN: "The Cave Guardian",
            bossNameES: "El Guardián de la Cueva",
            bossQuestionCount: 15,
            bossPassingScore: 0.8,
            bossXP: 350,
            prerequisite: 1
        ),

        Land(
            id: "adventure_3", number: 3, region: 1,
            nameEN: "The Enharmonic Fields",
            nameES: "Los Campos Enarmónicos",
            icon: "arrow.triangle.swap",
            regionColor: .regionEcho,
            storyEN: "A meadow where every flower has two names — just like enharmonic notes. C# and Db are the same key!",
            storyES: "Un prado donde cada flor tiene dos nombres — igual que las notas enarmónicas. ¡Do# y Reb son la misma tecla!",
            objectivesEN: [
                "Understand sharps (#) and flats (b)",
                "Identify all enharmonic pairs",
                "Navigate the chromatic scale"
            ],
            objectivesES: [
                "Entender sostenidos (#) y bemoles (b)",
                "Identificar todos los pares enarmónicos",
                "Navegar la escala cromática"
            ],
            miniGameIDs: ["twin_flowers", "chromatic_path"],
            bossNameEN: "The Mirror Maze",
            bossNameES: "El Laberinto de Espejos",
            bossQuestionCount: 20,
            bossPassingScore: 0.8,
            bossXP: 350,
            prerequisite: 2
        ),

        Land(
            id: "adventure_4", number: 4, region: 1,
            nameEN: "The Music Math Workshop",
            nameES: "El Taller de Matemáticas Musicales",
            icon: "function",
            regionColor: .regionEcho,
            storyEN: "A quirky inventor's workshop where music is built with math equations. Solve note arithmetic!",
            storyES: "Un taller de inventos donde la música se construye con ecuaciones. ¡Resuelve la aritmética de notas!",
            objectivesEN: [
                "Solve note math: C + W = D",
                "Chain operations: D + W + W − H = ?",
                "Apply multiplication: C + 3(W) = F#"
            ],
            objectivesES: [
                "Resolver matemáticas de notas: Do + W = Re",
                "Encadenar operaciones: Re + W + W − H = ?",
                "Aplicar multiplicación: Do + 3(W) = Fa#"
            ],
            miniGameIDs: ["note_calculator", "assembly_line"],
            bossNameEN: "The Inventor's Exam",
            bossNameES: "El Examen del Inventor",
            bossQuestionCount: 10,
            bossPassingScore: 0.8,
            bossXP: 400,
            prerequisite: 3
        ),

        // ═══════════════════════════════════════
        // REGION 2 — El Bosque Armónico
        // ═══════════════════════════════════════

        Land(
            id: "adventure_5", number: 5, region: 2,
            nameEN: "The Major Path",
            nameES: "El Sendero Mayor",
            icon: "leaf.fill",
            regionColor: .regionForest,
            storyEN: "A sunlit forest trail where trees grow in the pattern W-W-H-W-W-W-H. Follow the Major Scale formula!",
            storyES: "Un sendero iluminado donde los árboles crecen en patrón W-W-H-W-W-W-H. ¡Sigue la fórmula de la Escala Mayor!",
            objectivesEN: ["Memorize W-W-H-W-W-W-H", "Build major scales from any root", "Hear the major scale sound"],
            objectivesES: ["Memorizar W-W-H-W-W-W-H", "Construir escalas mayores desde cualquier nota", "Escuchar el sonido de la escala mayor"],
            miniGameIDs: ["trail_builder", "scale_detective"],
            bossNameEN: "The Forest Gate", bossNameES: "La Puerta del Bosque",
            bossQuestionCount: 15, bossPassingScore: 0.85, bossXP: 400, prerequisite: 4
        ),

        Land(
            id: "adventure_6", number: 6, region: 2,
            nameEN: "The Minor Shadow",
            nameES: "La Sombra Menor",
            icon: "moon.fill",
            regionColor: .regionForest,
            storyEN: "The forest darkens. Trees grow in a new pattern: W-H-W-W-H-W-W. Welcome to the Minor realm.",
            storyES: "El bosque oscurece. Los árboles crecen en un nuevo patrón: W-H-W-W-H-W-W. Bienvenido al reino Menor.",
            objectivesEN: ["Learn W-H-W-W-H-W-W", "Build minor scales", "Compare major vs. minor by ear"],
            objectivesES: ["Aprender W-H-W-W-H-W-W", "Construir escalas menores", "Comparar mayor vs. menor de oído"],
            miniGameIDs: ["shadow_scale", "major_or_minor"],
            bossNameEN: "The Shadow Trial", bossNameES: "La Prueba de la Sombra",
            bossQuestionCount: 15, bossPassingScore: 0.85, bossXP: 400, prerequisite: 5
        ),

        Land(
            id: "adventure_7", number: 7, region: 2,
            nameEN: "The Tower of Keys",
            nameES: "La Torre de las Tonalidades",
            icon: "building.columns.fill",
            regionColor: .regionForest,
            storyEN: "A spiraling tower where each floor is a different key signature. Climb by mastering the circle of fifths!",
            storyES: "Una torre espiral donde cada piso es una tonalidad diferente. ¡Sube dominando el círculo de quintas!",
            objectivesEN: ["Understand key signatures", "Navigate the circle of fifths", "Identify keys from sharps/flats"],
            objectivesES: ["Entender las armaduras", "Navegar el círculo de quintas", "Identificar tonalidades por sus alteraciones"],
            miniGameIDs: ["tower_climb", "circle_spinner"],
            bossNameEN: "The Tower Summit", bossNameES: "La Cima de la Torre",
            bossQuestionCount: 15, bossPassingScore: 0.85, bossXP: 450, prerequisite: 6
        ),

        Land(
            id: "adventure_8", number: 8, region: 2,
            nameEN: "The Chromatic Garden",
            nameES: "El Jardín Cromático",
            icon: "camera.macro",
            regionColor: .regionForest,
            storyEN: "A wild garden where every flower is one half step apart. Learn to name the intervals between notes!",
            storyES: "Un jardín donde cada flor está a un semitono de distancia. ¡Aprende a nombrar los intervalos entre notas!",
            objectivesEN: ["Calculate intervals in half steps", "Identify intervals visually", "Begin ear training for intervals"],
            objectivesES: ["Calcular intervalos en semitonos", "Identificar intervalos visualmente", "Comenzar entrenamiento auditivo"],
            miniGameIDs: ["interval_greenhouse", "ear_garden"],
            bossNameEN: "The Garden Keeper", bossNameES: "El Guardián del Jardín",
            bossQuestionCount: 20, bossPassingScore: 0.8, bossXP: 450, prerequisite: 7
        ),

        // ═══════════════════════════════════════
        // REGION 3 — La Ciudad Rítmica
        // ═══════════════════════════════════════

        Land(
            id: "adventure_9", number: 9, region: 3,
            nameEN: "The Pulse Plaza",
            nameES: "La Plaza del Pulso",
            icon: "metronome.fill",
            regionColor: .regionRhythm,
            storyEN: "A bustling city square where everyone moves to a pulse. Learn tempo markings: Largo, Andante, Allegro, Presto!",
            storyES: "Una plaza llena de vida donde todos se mueven al pulso. ¡Aprende los tempos: Largo, Andante, Allegro, Presto!",
            objectivesEN: ["Define tempo and BPM", "Learn 4 tempo markings", "Match tempos to real-world speeds"],
            objectivesES: ["Definir tempo y BPM", "Aprender 4 marcas de tempo", "Relacionar tempos con velocidades reales"],
            miniGameIDs: ["tempo_match", "bpm_tapper"],
            bossNameEN: "The Pulse Parade", bossNameES: "El Desfile del Pulso",
            bossQuestionCount: 8, bossPassingScore: 0.75, bossXP: 400, prerequisite: 8
        ),

        Land(
            id: "adventure_10", number: 10, region: 3,
            nameEN: "The Rhythm Factory",
            nameES: "La Fábrica de Ritmos",
            icon: "waveform",
            regionColor: .regionRhythm,
            storyEN: "A factory where note values are manufactured. Learn whole, half, quarter, eighth, and sixteenth notes!",
            storyES: "Una fábrica donde se fabrican los valores de las notas. ¡Aprende redonda, blanca, negra, corchea y semicorchea!",
            objectivesEN: ["Identify note values", "Understand relative durations", "Fill measures with note values"],
            objectivesES: ["Identificar valores de notas", "Entender duraciones relativas", "Llenar compases con valores de notas"],
            miniGameIDs: ["rhythm_assembly", "note_value_quiz"],
            bossNameEN: "Factory Foreman", bossNameES: "El Capataz de la Fábrica",
            bossQuestionCount: 10, bossPassingScore: 0.8, bossXP: 400, prerequisite: 9
        ),

        Land(
            id: "adventure_11", number: 11, region: 3,
            nameEN: "The Time Signature Clock",
            nameES: "El Reloj de los Compases",
            icon: "clock.fill",
            regionColor: .regionRhythm,
            storyEN: "A giant clock tower showing different time signatures. Read and feel meters: 4/4, 3/4, 2/4, 6/8!",
            storyES: "Una torre de reloj gigante con diferentes compases. ¡Lee y siente los metros: 4/4, 3/4, 2/4, 6/8!",
            objectivesEN: ["Read time signatures", "Understand beats per measure", "Tap rhythms in different meters"],
            objectivesES: ["Leer compases", "Entender pulsos por compás", "Tocar ritmos en diferentes metros"],
            miniGameIDs: ["clock_face", "measure_fill"],
            bossNameEN: "The Clockmaker", bossNameES: "El Relojero",
            bossQuestionCount: 12, bossPassingScore: 0.75, bossXP: 400, prerequisite: 10
        ),

        Land(
            id: "adventure_12", number: 12, region: 3,
            nameEN: "The Groove Stadium",
            nameES: "El Estadio del Groove",
            icon: "music.note.list",
            regionColor: .regionRhythm,
            storyEN: "A stadium where the crowd grooves to combined rhythms. Put it all together — tempo, notes, time signatures!",
            storyES: "Un estadio donde la multitud se mueve al ritmo combinado. ¡Junta todo — tempo, notas, compases!",
            objectivesEN: ["Read 4-8 bar patterns", "Maintain steady tempo", "Identify rhythmic errors"],
            objectivesES: ["Leer patrones de 4-8 compases", "Mantener un tempo estable", "Identificar errores rítmicos"],
            miniGameIDs: ["rhythm_hero", "error_spotter"],
            bossNameEN: "Stadium Showdown", bossNameES: "Duelo en el Estadio",
            bossQuestionCount: 16, bossPassingScore: 0.85, bossXP: 500, prerequisite: 11
        ),

        // ═══════════════════════════════════════
        // REGION 4 — Las Cumbres del Maestro
        // ═══════════════════════════════════════

        Land(
            id: "adventure_13", number: 13, region: 4,
            nameEN: "The Major Chord Forge",
            nameES: "La Forja de Acordes Mayores",
            icon: "hammer.fill",
            regionColor: .regionMaster,
            storyEN: "A mountain forge where you craft major chords: Root + Major 3rd (+4H) + Perfect 5th (+3H)!",
            storyES: "Una forja donde construyes acordes mayores: Fundamental + 3ra Mayor (+4H) + 5ta Justa (+3H)!",
            objectivesEN: ["Build major triads: Root + 4H + 3H", "Know all 7 major chords", "Hear major chord quality"],
            objectivesES: ["Construir tríadas mayores: Fundamental + 4H + 3H", "Conocer los 7 acordes mayores", "Escuchar la cualidad mayor"],
            miniGameIDs: ["chord_forge", "chord_ear_id"],
            bossNameEN: "The Master Smith", bossNameES: "El Maestro Herrero",
            bossQuestionCount: 12, bossPassingScore: 0.8, bossXP: 450, prerequisite: 12
        ),

        Land(
            id: "adventure_14", number: 14, region: 4,
            nameEN: "The Minor Chord Cave",
            nameES: "La Cueva de Acordes Menores",
            icon: "sparkle",
            regionColor: .regionMaster,
            storyEN: "A deep cave where minor chords echo. The formula shifts: Root + Minor 3rd (+3H) + Perfect 5th (+4H)!",
            storyES: "Una cueva profunda donde resuenan acordes menores. La fórmula cambia: Fundamental + 3ra Menor (+3H) + 5ta (+4H)!",
            objectivesEN: ["Build minor triads: Root + 3H + 4H", "Know all 7 minor chords", "Distinguish major vs. minor"],
            objectivesES: ["Construir tríadas menores: Fundamental + 3H + 4H", "Conocer los 7 acordes menores", "Distinguir mayor vs. menor"],
            miniGameIDs: ["crystal_chord", "major_or_minor_chord"],
            bossNameEN: "The Crystal Guardian", bossNameES: "El Guardián de Cristal",
            bossQuestionCount: 17, bossPassingScore: 0.8, bossXP: 450, prerequisite: 13
        ),

        Land(
            id: "adventure_15", number: 15, region: 4,
            nameEN: "The Progression Bridge",
            nameES: "El Puente de la Progresión",
            icon: "point.topleft.down.to.point.bottomright.curvepath.fill",
            regionColor: .regionMaster,
            storyEN: "Bridges connecting peaks, each a chord progression. Learn I-IV-V-I and I-V-vi-IV!",
            storyES: "Puentes conectando cumbres, cada uno una progresión. ¡Aprende I-IV-V-I y I-V-vi-IV!",
            objectivesEN: ["Understand Roman numeral notation", "Build common progressions", "Hear tonic-subdominant-dominant"],
            objectivesES: ["Entender números romanos", "Construir progresiones comunes", "Escuchar tónica-subdominante-dominante"],
            miniGameIDs: ["bridge_builder", "progression_ear"],
            bossNameEN: "The Grand Bridge", bossNameES: "El Gran Puente",
            bossQuestionCount: 10, bossPassingScore: 0.8, bossXP: 500, prerequisite: 14
        ),

        Land(
            id: "adventure_16", number: 16, region: 4,
            nameEN: "The Master Summit",
            nameES: "La Cumbre del Maestro",
            icon: "crown.fill",
            regionColor: .regionMaster,
            storyEN: "The Silence King awaits at the final peak. Prove your mastery of ALL music theory to defeat him and restore music to the world!",
            storyES: "El Rey del Silencio espera en la cumbre final. ¡Demuestra tu dominio de TODA la teoría musical para derrotarlo y restaurar la música al mundo!",
            objectivesEN: ["Demonstrate mastery of all 15 topics", "Apply concepts in combination", "Achieve speed and accuracy"],
            objectivesES: ["Demostrar dominio de los 15 temas", "Aplicar conceptos combinados", "Lograr rapidez y precisión"],
            miniGameIDs: ["gauntlet", "composition_chamber"],
            bossNameEN: "The Silence King", bossNameES: "El Rey del Silencio",
            bossQuestionCount: 50, bossPassingScore: 0.8, bossXP: 1000, prerequisite: 15
        )
    ]

    /// Get lands by region
    static func lands(for region: Int) -> [Land] {
        allLands.filter { $0.region == region }
    }

    /// Get a land by adventure number
    static func land(number: Int) -> Land? {
        allLands.first { $0.number == number }
    }

    /// Region names
    static let regionNames: [(en: String, es: String, color: Color)] = [
        ("The Echo Lands", "Las Tierras del Eco", .regionEcho),
        ("The Harmonic Forest", "El Bosque Armónico", .regionForest),
        ("Rhythm City", "La Ciudad Rítmica", .regionRhythm),
        ("The Master Peaks", "Las Cumbres del Maestro", .regionMaster)
    ]
}
