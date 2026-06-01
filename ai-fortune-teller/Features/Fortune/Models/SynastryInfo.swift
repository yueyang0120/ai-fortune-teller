import Foundation

// MARK: - Synastry Type

enum SynastryType: String, Codable, CaseIterable, Identifiable {
    case love = "爱情合盘"
    case parentChild = "亲子合盘"
    case pet = "宠物合盘"
    case siblings = "手足合盘"
    case friends = "朋友合盘"
    case business = "合伙合盘"

    var id: String { self.rawValue }

    var icon: String {
        switch self {
        case .love: return "heart.circle.fill"
        case .parentChild: return "figure.and.child.holdinghands"
        case .pet: return "pawprint.circle.fill"
        case .siblings: return "person.2.fill"
        case .friends: return "person.2.wave.2.fill"
        case .business: return "briefcase.circle.fill"
        }
    }

    /// Whether this synastry type requires specifying a relationship role
    var requiresRole: Bool {
        switch self {
        case .parentChild, .siblings: return true
        case .love, .pet, .friends, .business: return false
        }
    }

    /// Available roles for this synastry type
    var availableRoles: [RelationshipRole] {
        switch self {
        case .parentChild: return [.fatherSon, .fatherDaughter, .motherSon, .motherDaughter]
        case .siblings: return [.brothers, .sisters, .olderBrotherYoungerSister, .olderSisterYoungerBrother]
        case .love, .pet, .friends, .business: return []
        }
    }
}

// MARK: - Relationship Role

/// Specific role pairing for non-symmetric synastry types.
/// Person A is always the first role, Person B is the second.
enum RelationshipRole: String, Codable, CaseIterable, Identifiable {
    // Parent-Child: A is parent, B is child
    case fatherSon = "父子"
    case fatherDaughter = "父女"
    case motherSon = "母子"
    case motherDaughter = "母女"

    // Siblings
    case brothers = "兄弟"
    case sisters = "姐妹"
    case olderBrotherYoungerSister = "兄妹"
    case olderSisterYoungerBrother = "姐弟"

    var id: String { self.rawValue }

    var icon: String {
        switch self {
        case .fatherSon: return "figure.and.child.holdinghands"
        case .fatherDaughter: return "figure.and.child.holdinghands"
        case .motherSon: return "figure.and.child.holdinghands"
        case .motherDaughter: return "figure.and.child.holdinghands"
        case .brothers: return "person.2.fill"
        case .sisters: return "person.2.fill"
        case .olderBrotherYoungerSister: return "person.2.fill"
        case .olderSisterYoungerBrother: return "person.2.fill"
        }
    }

    /// Label for person A in this role
    var personARole: String {
        switch self {
        case .fatherSon, .fatherDaughter: return "父亲"
        case .motherSon, .motherDaughter: return "母亲"
        case .brothers: return "兄"
        case .sisters: return "姐"
        case .olderBrotherYoungerSister: return "兄"
        case .olderSisterYoungerBrother: return "姐"
        }
    }

    /// Label for person B in this role
    var personBRole: String {
        switch self {
        case .fatherSon: return "儿子"
        case .fatherDaughter: return "女儿"
        case .motherSon: return "儿子"
        case .motherDaughter: return "女儿"
        case .brothers: return "弟"
        case .sisters: return "妹"
        case .olderBrotherYoungerSister: return "妹"
        case .olderSisterYoungerBrother: return "弟"
        }
    }
}

// MARK: - Synastry Info

struct SynastryInfo: Codable, Equatable, Identifiable {
    let id: UUID
    let personA: BirthInfo
    let personB: BirthInfo
    let synastryType: SynastryType
    let relationshipRole: RelationshipRole?
    var chartA: ZiWeiChart?
    var chartB: ZiWeiChart?

    init(id: UUID = UUID(),
         personA: BirthInfo,
         personB: BirthInfo,
         synastryType: SynastryType,
         relationshipRole: RelationshipRole? = nil,
         chartA: ZiWeiChart? = nil,
         chartB: ZiWeiChart? = nil) {
        self.id = id
        self.personA = personA
        self.personB = personB
        self.synastryType = synastryType
        self.relationshipRole = relationshipRole
        self.chartA = chartA
        self.chartB = chartB
    }
}

// MARK: - Synastry Reading

struct SynastryReading: Codable, Equatable, Identifiable {
    let id: UUID
    let synastryInfo: SynastryInfo
    let analysis: String
    let timestamp: Date

    init(id: UUID = UUID(),
         synastryInfo: SynastryInfo,
         analysis: String,
         timestamp: Date = Date()) {
        self.id = id
        self.synastryInfo = synastryInfo
        self.analysis = analysis
        self.timestamp = timestamp
    }

    func toJSONString() throws -> String {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(self)
        guard let string = String(data: data, encoding: .utf8) else {
            throw FortuneReadingError.encodingFailed
        }
        return string
    }

    static func fromJSONString(_ jsonString: String) throws -> SynastryReading {
        guard let data = jsonString.data(using: .utf8) else {
            throw FortuneReadingError.invalidData
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(SynastryReading.self, from: data)
    }
}
