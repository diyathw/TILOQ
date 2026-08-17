import Foundation

enum KeyboardAlternates {
    private static let values: [String: [String]] = [
        "a": ["á", "à", "â", "ä", "æ", "ã", "å", "ā"],
        "c": ["ç", "ć", "č"],
        "e": ["é", "è", "ê", "ë", "ē", "ė", "ę"],
        "i": ["í", "ì", "î", "ï", "ī", "į"],
        "l": ["ł"],
        "n": ["ñ", "ń"],
        "o": ["ó", "ò", "ô", "ö", "õ", "ø", "œ", "ō"],
        "s": ["ß", "ś", "š"],
        "u": ["ú", "ù", "û", "ü", "ū"],
        "y": ["ý", "ÿ"],
        "z": ["ź", "ż", "ž"],
        ".": ["…"],
        "-": ["–", "—", "•"],
        "'": ["’", "‘", "`"],
        "\"": ["“", "”", "„"],
        "$": ["€", "£", "¥", "₩", "₹"],
        "0": ["°"]
    ]

    static func characters(for key: String) -> [String] {
        let lowercase = key.lowercased()
        let alternates = values[lowercase] ?? []
        guard key != lowercase, key.rangeOfCharacter(from: .letters) != nil else {
            return alternates
        }
        return alternates.map { $0.uppercased() }
    }
}
