//
//  ProfessionalLicensing.swift
//  hustleXP final1
//
//  Professional Licensing & Skill Gating System
//  - Hard Gate for Licensed Trades (Electrical, Plumbing, HVAC)
//  - Experience-Based Leveling for General Skills
//  - Clean Feed Logic with 100% Actionable Tasks
//

import Foundation
import SwiftUI

// MARK: - Skill Type (Hard Gate vs Experience)

enum SkillType: String, Codable {
    case licensed = "licensed"      // Requires verified license (HARD GATE)
    case experienceBased = "experience"  // Unlocked via XP/task completion
    case basic = "basic"            // Available to all workers

    /// Safe decode — unknown values default to .basic
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        self = SkillType(rawValue: raw) ?? .basic
    }
}

// MARK: - Skill Category (100+ Skills organized into categories)

enum SkillCategory: String, Codable, CaseIterable {
    case generalLabor = "General Labor"
    case moving = "Moving & Lifting"
    case delivery = "Delivery & Errands"
    case cleaning = "Cleaning"
    case yardWork = "Yard & Outdoor"
    case petCare = "Pet Care"
    case tech = "Tech Help"
    case events = "Events & Setup"
    case trades = "Licensed Trades"
    case automotive = "Automotive"
    case personal = "Personal Services"

    /// Safe decode — unknown values default to .generalLabor
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        self = SkillCategory(rawValue: raw) ?? .generalLabor
    }

    var icon: String {
        switch self {
        case .generalLabor: return "figure.walk"
        case .moving: return "shippingbox.fill"
        case .delivery: return "car.fill"
        case .cleaning: return "sparkles"
        case .yardWork: return "leaf.fill"
        case .petCare: return "pawprint.fill"
        case .tech: return "desktopcomputer"
        case .events: return "party.popper.fill"
        case .trades: return "wrench.and.screwdriver.fill"
        case .automotive: return "car.2.fill"
        case .personal: return "person.2.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .generalLabor: return .infoBlue
        case .moving: return .warningOrange
        case .delivery: return .successGreen
        case .cleaning: return .accentPurple
        case .yardWork: return .heatMedium
        case .petCare: return .brandPurpleLight
        case .tech: return .infoBlue
        case .events: return .errorRed
        case .trades: return .instantYellow
        case .automotive: return .textSecondary
        case .personal: return .brandPurple
        }
    }
}

// MARK: - Worker Skill

struct WorkerSkill: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let category: SkillCategory
    let type: SkillType
    let icon: String
    
    // For licensed skills
    var licenseRequired: Bool { type == .licensed }
    var licenseType: LicenseType?
    
    // For experience-based skills
    var requiredLevel: Int  // 1-5, where 1 = basic, 5 = expert
    var xpToUnlock: Int     // XP needed if experience-based
    var tasksToUnlock: Int  // Number of related tasks to complete
    
    // Worker's progress
    var isUnlocked: Bool = false
    var currentXP: Int = 0
    var completedTasks: Int = 0
    var licenseVerified: Bool = false
    var licenseExpiresAt: Date?
    
    var unlockProgress: Double {
        if type == .basic { return 1.0 }
        if type == .licensed { return licenseVerified ? 1.0 : 0.0 }
        if tasksToUnlock > 0 {
            return min(1.0, Double(completedTasks) / Double(tasksToUnlock))
        }
        return min(1.0, Double(currentXP) / Double(max(1, xpToUnlock)))
    }
    
    var statusText: String {
        if isUnlocked { return "Unlocked" }
        if type == .licensed { return "License Required" }
        if tasksToUnlock > 0 {
            return "\(completedTasks)/\(tasksToUnlock) tasks"
        }
        return "\(currentXP)/\(xpToUnlock) XP"
    }
}

// MARK: - License Type (Regulated Trades)

enum LicenseType: String, Codable, CaseIterable {
    case electrician = "Electrician"
    case plumber = "Plumber"
    case hvac = "HVAC Technician"
    case generalContractor = "General Contractor"
    case pestControl = "Pest Control"
    case locksmith = "Locksmith"
    case realEstate = "Real Estate"
    case notary = "Notary Public"
    case cosmetology = "Cosmetology"
    case massage = "Massage Therapist"
    case personalTrainer = "Personal Trainer"
    case cpr = "CPR/First Aid"
    case foodHandler = "Food Handler"
    case cdl = "CDL (Commercial Driver)"
    case securityGuard = "Security Guard"

    /// Safe decode — unknown values default to .cpr (least restrictive)
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        self = LicenseType(rawValue: raw) ?? .cpr
    }

    var icon: String {
        switch self {
        case .electrician: return "bolt.fill"
        case .plumber: return "drop.fill"
        case .hvac: return "thermometer.snowflake"
        case .generalContractor: return "hammer.fill"
        case .pestControl: return "ant.fill"
        case .locksmith: return "key.fill"
        case .realEstate: return "house.fill"
        case .notary: return "signature"
        case .cosmetology: return "scissors"
        case .massage: return "hand.raised.fill"
        case .personalTrainer: return "figure.strengthtraining.traditional"
        case .cpr: return "cross.fill"
        case .foodHandler: return "fork.knife"
        case .cdl: return "truck.box.fill"
        case .securityGuard: return "shield.fill"
        }
    }
    
    var verificationFee: Double {
        switch self {
        case .electrician, .plumber, .hvac, .generalContractor: return 2.99
        case .cdl: return 4.99
        default: return 0.99
        }
    }
    
    var stateRegulated: Bool {
        switch self {
        case .electrician, .plumber, .hvac, .generalContractor, .pestControl,
             .locksmith, .realEstate, .notary, .cosmetology, .massage, .cdl, .securityGuard:
            return true
        default:
            return false
        }
    }
}

// MARK: - Professional License

struct ProfessionalLicense: Identifiable, Codable {
    let id: String
    let workerId: String
    let type: LicenseType
    let licenseNumber: String
    let issuingState: String
    let issuedAt: Date
    let expiresAt: Date?
    var verificationStatus: LicenseVerificationStatus
    var verifiedAt: Date?
    var documentURL: URL?
    
    // AI Judge verification
    var aiConfidenceScore: Double?
    var manualReviewRequired: Bool = false
    var rejectionReason: String?
    
    var isValid: Bool {
        guard verificationStatus == .verified else { return false }
        if let expires = expiresAt {
            return expires > Date()
        }
        return true
    }
    
    var daysUntilExpiry: Int? {
        guard let expires = expiresAt else { return nil }
        return Calendar.current.dateComponents([.day], from: Date(), to: expires).day
    }
}

enum LicenseVerificationStatus: String, Codable {
    case pending = "pending"
    case processing = "processing"
    case verified = "verified"
    case rejected = "rejected"
    case expired = "expired"
    case manualReview = "manual_review"

    /// Safe decode — unknown values default to .pending
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        self = LicenseVerificationStatus(rawValue: raw) ?? .pending
    }

    var color: Color {
        switch self {
        case .pending: return .textMuted
        case .processing: return .warningOrange
        case .verified: return .successGreen
        case .rejected: return .errorRed
        case .expired: return .errorRed
        case .manualReview: return .infoBlue
        }
    }
    
    var icon: String {
        switch self {
        case .pending: return "clock"
        case .processing: return "arrow.triangle.2.circlepath"
        case .verified: return "checkmark.seal.fill"
        case .rejected: return "xmark.seal.fill"
        case .expired: return "exclamationmark.triangle.fill"
        case .manualReview: return "eye.fill"
        }
    }
}

// MARK: - Worker Skill Profile

struct WorkerSkillProfile: Codable {
    let workerId: String
    var selectedSkills: Set<String>  // Skill IDs the worker has selected
    var unlockedSkills: Set<String>  // Skills the worker can use
    var licenses: [ProfessionalLicense]
    var skillLevels: [String: Int]   // Skill ID -> Level (1-5)
    var skillXP: [String: Int]       // Skill ID -> XP earned
    var skillTasksCompleted: [String: Int]  // Skill ID -> Tasks completed
    
    // Overall stats
    var generalLevel: Int = 1  // Overall worker level
    var totalSkillXP: Int = 0
    
    func isEligibleForTask(_ task: HXTask, skill: WorkerSkill) -> Bool {
        // Check if skill is unlocked
        guard unlockedSkills.contains(skill.id) else { return false }
        
        // Check if license is valid for licensed skills
        if skill.licenseRequired {
            guard let license = licenses.first(where: { $0.type == skill.licenseType }),
                  license.isValid else {
                return false
            }
        }
        
        // Check skill level requirement
        let workerLevel = skillLevels[skill.id] ?? 1
        return workerLevel >= skill.requiredLevel
    }
    
    func getVerifiedLicense(for type: LicenseType) -> ProfessionalLicense? {
        licenses.first { $0.type == type && $0.isValid }
    }
}

// MARK: - Task Eligibility Result

struct TaskEligibilityResult {
    let isEligible: Bool
    let task: HXTask
    let requiredSkill: WorkerSkill?
    let blockReason: EligibilityBlockReason?
    let unlockAction: UnlockAction?
    
    enum EligibilityBlockReason: String {
        case licenseRequired = "License Required"
        case skillNotSelected = "Skill Not Selected"
        case levelTooLow = "Level Too Low"
        case licenseExpired = "License Expired"
        case verificationPending = "Verification Pending"
        case outsideRadius = "Too Far Away"
        case tierTooLow = "Trust Tier Too Low"
    }
    
    enum UnlockAction {
        case uploadLicense(LicenseType)
        case selectSkill(WorkerSkill)
        case gainXP(Int)
        case completeTasks(Int)
        case upgradeTier
    }
}

// MARK: - Locked Quest (For "Nearly Eligible" tab)

struct LockedQuest: Identifiable {
    let id: String
    let task: HXTask
    let requiredSkill: WorkerSkill
    let blockReason: TaskEligibilityResult.EligibilityBlockReason
    let unlockAction: TaskEligibilityResult.UnlockAction?
    let distanceMeters: Double?
    let potentialEarnings: Double
    
    var hookMessage: String {
        switch blockReason {
        case .licenseRequired:
            return "Verify your \(requiredSkill.licenseType?.rawValue ?? "license") to unlock this \(task.formattedPayment) quest"
        case .levelTooLow:
            let needed = requiredSkill.requiredLevel
            return "Reach Level \(needed) in \(requiredSkill.name) to unlock"
        case .skillNotSelected:
            return "Add \(requiredSkill.name) to your skills to see quests like this"
        default:
            return "Complete requirements to unlock this \(task.formattedPayment) quest"
        }
    }
}

// MARK: - Feed Filter Settings

struct FeedFilterSettings: Codable, Sendable {
    var maxRadiusMeters: Double = 16093  // 10 miles default
    var showOnlyMatchingSkills: Bool = true
    var hideLockedQuests: Bool = false
    var prioritySort: FeedPrioritySort = .bestMatch
    
    enum FeedPrioritySort: String, Codable, CaseIterable {
        case bestMatch = "Best Match"
        case nearest = "Nearest"
        case highestPay = "Highest Pay"
        case newest = "Newest"
        case endingSoon = "Ending Soon"

        /// Safe decode — unknown values default to .bestMatch
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let raw = try container.decode(String.self)
            self = FeedPrioritySort(rawValue: raw) ?? .bestMatch
        }
    }
}

// MARK: - AI Matchmaker Result

struct AIMatchmakerResult {
    let eligibleTasks: [HXTask]
    let lockedQuests: [LockedQuest]
    let recommendations: [TaskRecommendation]
    let filterStats: FilterStats
    
    struct TaskRecommendation {
        let task: HXTask
        let matchScore: Double  // 0-100
        let reasons: [String]
    }
    
    struct FilterStats {
        let totalTasksInArea: Int
        let eligibleCount: Int
        let lockedCount: Int
        let filteredByDistance: Int
        let filteredBySkill: Int
        let filteredByLicense: Int
    }
}

// MARK: - Skill Catalog (100+ Skills)

struct SkillCatalog {
    
    static let allSkills: [WorkerSkill] = {
        var skills: [WorkerSkill] = []
        
        // MARK: General Labor (Basic - Available to all)
        let generalLabor: [(String, String)] = [
            ("Waiting in Line", "clock"),
            ("Holding Spots", "mappin"),
            ("Standing/Watching", "eye"),
            ("Basic Errands", "figure.walk"),
            ("Ticket Pickup", "ticket"),
            ("Package Receiving", "shippingbox"),
        ]
        skills += generalLabor.enumerated().map { idx, skill in
            WorkerSkill(
                id: "general-\(idx)",
                name: skill.0,
                category: .generalLabor,
                type: .basic,
                icon: skill.1,
                licenseType: nil,
                requiredLevel: 1,
                xpToUnlock: 0,
                tasksToUnlock: 0,
                isUnlocked: true
            )
        }
        
        // MARK: Moving & Lifting (Experience-Based)
        let moving: [(String, String, Int, Int)] = [
            ("Light Lifting (<25 lbs)", "cube", 1, 0),
            ("Medium Lifting (25-50 lbs)", "cube.fill", 2, 5),
            ("Heavy Lifting (50+ lbs)", "shippingbox.fill", 3, 15),
            ("Furniture Moving", "sofa.fill", 3, 10),
            ("Appliance Moving", "refrigerator.fill", 4, 20),
            ("Piano Moving", "pianokeys", 5, 30),
            ("Loading/Unloading", "truck.box", 2, 5),
            ("Packing", "archivebox.fill", 1, 3),
        ]
        skills += moving.enumerated().map { idx, skill in
            WorkerSkill(
                id: "moving-\(idx)",
                name: skill.0,
                category: .moving,
                type: skill.2 > 1 ? .experienceBased : .basic,
                icon: skill.1,
                licenseType: nil,
                requiredLevel: skill.2,
                xpToUnlock: skill.2 * 50,
                tasksToUnlock: skill.3,
                isUnlocked: skill.2 == 1
            )
        }
        
        // MARK: Delivery (Experience-Based)
        let delivery: [(String, String, Int)] = [
            ("Walking Delivery", "figure.walk", 1),
            ("Bike Delivery", "bicycle", 1),
            ("Car Delivery", "car.fill", 2),
            ("Grocery Shopping", "cart.fill", 1),
            ("Pharmacy Pickup", "cross.case.fill", 1),
            ("Restaurant Pickup", "takeoutbag.and.cup.and.straw.fill", 1),
            ("Large Item Delivery", "truck.box.fill", 3),
        ]
        skills += delivery.enumerated().map { idx, skill in
            WorkerSkill(
                id: "delivery-\(idx)",
                name: skill.0,
                category: .delivery,
                type: skill.2 > 1 ? .experienceBased : .basic,
                icon: skill.1,
                licenseType: nil,
                requiredLevel: skill.2,
                xpToUnlock: skill.2 * 40,
                tasksToUnlock: skill.2 * 3,
                isUnlocked: skill.2 == 1
            )
        }
        
        // MARK: Cleaning (Experience-Based)
        let cleaning: [(String, String, Int)] = [
            ("Light Cleaning", "sparkles", 1),
            ("Deep Cleaning", "bubbles.and.sparkles.fill", 2),
            ("Move-Out Cleaning", "door.left.hand.open", 3),
            ("Window Cleaning", "window.vertical.closed", 2),
            ("Carpet Cleaning", "rectangle.split.1x2.fill", 3),
            ("Pressure Washing", "drop.triangle.fill", 3),
            ("Junk Removal", "trash.fill", 2),
        ]
        skills += cleaning.enumerated().map { idx, skill in
            WorkerSkill(
                id: "cleaning-\(idx)",
                name: skill.0,
                category: .cleaning,
                type: skill.2 > 1 ? .experienceBased : .basic,
                icon: skill.1,
                licenseType: nil,
                requiredLevel: skill.2,
                xpToUnlock: skill.2 * 60,
                tasksToUnlock: skill.2 * 4,
                isUnlocked: skill.2 == 1
            )
        }
        
        // MARK: Yard & Outdoor (Experience-Based)
        let yard: [(String, String, Int)] = [
            ("Lawn Mowing", "leaf.fill", 1),
            ("Raking", "leaf.arrow.triangle.circlepath", 1),
            ("Weeding", "camera.macro", 1),
            ("Hedge Trimming", "scissors", 2),
            ("Tree Trimming", "tree.fill", 3),
            ("Landscaping", "mountain.2.fill", 4),
            ("Snow Shoveling", "snowflake", 1),
            ("Gutter Cleaning", "drop.fill", 2),
            ("Pool Maintenance", "figure.pool.swim", 3),
        ]
        skills += yard.enumerated().map { idx, skill in
            WorkerSkill(
                id: "yard-\(idx)",
                name: skill.0,
                category: .yardWork,
                type: skill.2 > 1 ? .experienceBased : .basic,
                icon: skill.1,
                licenseType: nil,
                requiredLevel: skill.2,
                xpToUnlock: skill.2 * 45,
                tasksToUnlock: skill.2 * 3,
                isUnlocked: skill.2 == 1
            )
        }
        
        // MARK: Pet Care (Experience-Based)
        let petCare: [(String, String, Int)] = [
            ("Dog Walking", "pawprint.fill", 1),
            ("Pet Sitting", "house.fill", 2),
            ("Pet Feeding", "fork.knife", 1),
            ("Pet Grooming", "scissors", 3),
            ("Pet Transport", "car.fill", 2),
        ]
        skills += petCare.enumerated().map { idx, skill in
            WorkerSkill(
                id: "petcare-\(idx)",
                name: skill.0,
                category: .petCare,
                type: skill.2 > 1 ? .experienceBased : .basic,
                icon: skill.1,
                licenseType: nil,
                requiredLevel: skill.2,
                xpToUnlock: skill.2 * 50,
                tasksToUnlock: skill.2 * 4,
                isUnlocked: skill.2 == 1
            )
        }
        
        // MARK: Tech Help (Experience-Based)
        let tech: [(String, String, Int)] = [
            ("Phone Setup", "iphone", 1),
            ("Computer Setup", "desktopcomputer", 2),
            ("WiFi Setup", "wifi", 2),
            ("TV Mounting", "tv.fill", 2),
            ("Smart Home Setup", "homekit", 3),
            ("Data Backup", "externaldrive.fill", 2),
            ("Virus Removal", "ladybug.fill", 3),
        ]
        skills += tech.enumerated().map { idx, skill in
            WorkerSkill(
                id: "tech-\(idx)",
                name: skill.0,
                category: .tech,
                type: skill.2 > 1 ? .experienceBased : .basic,
                icon: skill.1,
                licenseType: nil,
                requiredLevel: skill.2,
                xpToUnlock: skill.2 * 55,
                tasksToUnlock: skill.2 * 3,
                isUnlocked: skill.2 == 1
            )
        }
        
        // MARK: Events & Setup (Experience-Based)
        let events: [(String, String, Int)] = [
            ("Party Setup", "party.popper.fill", 1),
            ("Event Cleanup", "trash.fill", 1),
            ("Furniture Assembly", "screwdriver.fill", 2),
            ("Tent Setup", "tent.fill", 2),
            ("AV Equipment Setup", "speaker.wave.3.fill", 3),
            ("Stage Setup", "rectangle.3.group.fill", 4),
        ]
        skills += events.enumerated().map { idx, skill in
            WorkerSkill(
                id: "events-\(idx)",
                name: skill.0,
                category: .events,
                type: skill.2 > 1 ? .experienceBased : .basic,
                icon: skill.1,
                licenseType: nil,
                requiredLevel: skill.2,
                xpToUnlock: skill.2 * 50,
                tasksToUnlock: skill.2 * 3,
                isUnlocked: skill.2 == 1
            )
        }
        
        // MARK: Licensed Trades (HARD GATE - License Required)
        let trades: [(String, String, LicenseType)] = [
            ("Electrical Work", "bolt.fill", .electrician),
            ("Plumbing", "drop.fill", .plumber),
            ("HVAC Service", "thermometer.snowflake", .hvac),
            ("General Contracting", "hammer.fill", .generalContractor),
            ("Pest Control", "ant.fill", .pestControl),
            ("Locksmith", "key.fill", .locksmith),
            ("Notary Services", "signature", .notary),
            ("Security Services", "shield.fill", .securityGuard),
        ]
        skills += trades.enumerated().map { idx, skill in
            WorkerSkill(
                id: "trades-\(idx)",
                name: skill.0,
                category: .trades,
                type: .licensed,
                icon: skill.1,
                licenseType: skill.2,
                requiredLevel: 1,
                xpToUnlock: 0,
                tasksToUnlock: 0,
                isUnlocked: false
            )
        }
        
        // MARK: Automotive (Mixed)
        let automotive: [(String, String, Int, LicenseType?)] = [
            ("Jump Start", "bolt.car.fill", 1, nil),
            ("Tire Change", "circle.fill", 2, nil),
            ("Car Wash", "drop.fill", 1, nil),
            ("Interior Detailing", "car.fill", 2, nil),
            ("Commercial Driving", "truck.box.fill", 1, .cdl),
        ]
        skills += automotive.enumerated().map { idx, skill in
            WorkerSkill(
                id: "auto-\(idx)",
                name: skill.0,
                category: .automotive,
                type: skill.3 != nil ? .licensed : (skill.2 > 1 ? .experienceBased : .basic),
                icon: skill.1,
                licenseType: skill.3,
                requiredLevel: skill.2,
                xpToUnlock: skill.2 * 40,
                tasksToUnlock: skill.2 * 3,
                isUnlocked: skill.2 == 1 && skill.3 == nil
            )
        }
        
        // MARK: Personal Services (Mixed)
        let personal: [(String, String, Int, LicenseType?)] = [
            ("Companionship", "person.2.fill", 1, nil),
            ("Senior Assistance", "figure.stand.line.dotted.figure.stand", 2, nil),
            ("Personal Training", "figure.strengthtraining.traditional", 1, .personalTrainer),
            ("Massage", "hand.raised.fill", 1, .massage),
            ("Hair Styling", "scissors", 1, .cosmetology),
            ("CPR/First Aid", "cross.fill", 1, .cpr),
        ]
        skills += personal.enumerated().map { idx, skill in
            WorkerSkill(
                id: "personal-\(idx)",
                name: skill.0,
                category: .personal,
                type: skill.3 != nil ? .licensed : (skill.2 > 1 ? .experienceBased : .basic),
                icon: skill.1,
                licenseType: skill.3,
                requiredLevel: skill.2,
                xpToUnlock: skill.2 * 50,
                tasksToUnlock: skill.2 * 4,
                isUnlocked: skill.2 == 1 && skill.3 == nil
            )
        }
        
        return skills
    }()
    
    static func skills(for category: SkillCategory) -> [WorkerSkill] {
        allSkills.filter { $0.category == category }
    }
    
    static func licensedSkills() -> [WorkerSkill] {
        allSkills.filter { $0.type == .licensed }
    }
    
    static func basicSkills() -> [WorkerSkill] {
        allSkills.filter { $0.type == .basic }
    }
    
    static func skill(byId id: String) -> WorkerSkill? {
        allSkills.first { $0.id == id }
    }
}
