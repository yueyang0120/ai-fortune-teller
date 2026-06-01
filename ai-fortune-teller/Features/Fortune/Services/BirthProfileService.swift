import Foundation
import Combine

/// Service to manage saved birth profiles
/// Allows users to save, edit, and delete birth profiles for themselves and family members
class BirthProfileService: ObservableObject {
    static let shared = BirthProfileService()

    private let userDefaults = UserDefaults.standard
    private let profilesKey = "saved_birth_profiles_v1"

    @Published private(set) var profiles: [BirthProfile] = []

    private init() {
        loadProfiles()
    }

    // MARK: - Public Methods

    /// Get all saved profiles
    var allProfiles: [BirthProfile] {
        profiles
    }

    /// Get the default profile (if any)
    var defaultProfile: BirthProfile? {
        profiles.first(where: { $0.isDefault })
    }

    /// Check if there are any saved profiles
    var hasProfiles: Bool {
        !profiles.isEmpty
    }

    /// Get profile count
    var profileCount: Int {
        profiles.count
    }

    /// Add a new profile
    func addProfile(_ profile: BirthProfile) {
        var newProfile = profile

        // If this is the first profile or marked as default, ensure it's the only default
        if profiles.isEmpty || profile.isDefault {
            newProfile.isDefault = true
            // Remove default status from other profiles
            for i in 0..<profiles.count {
                profiles[i].isDefault = false
            }
        }

        profiles.append(newProfile)
        saveProfiles()
        print("✅ Added new profile: \(profile.name)")
    }

    /// Create and add a profile from BirthInfo
    func createProfile(from birthInfo: BirthInfo, name: String, isDefault: Bool = false) -> BirthProfile {
        let profile = BirthProfile(from: birthInfo, name: name, isDefault: isDefault || profiles.isEmpty)
        addProfile(profile)
        return profile
    }

    /// Update an existing profile
    func updateProfile(_ profile: BirthProfile) {
        guard let index = profiles.firstIndex(where: { $0.id == profile.id }) else {
            print("⚠️ Profile not found for update: \(profile.id)")
            return
        }

        var updatedProfile = profile
        updatedProfile.updatedAt = Date()

        // Handle default status change
        if updatedProfile.isDefault {
            for i in 0..<profiles.count where i != index {
                profiles[i].isDefault = false
            }
        }

        profiles[index] = updatedProfile
        saveProfiles()
        print("✅ Updated profile: \(profile.name)")
    }

    /// Delete a profile by ID
    func deleteProfile(id: UUID) {
        guard let index = profiles.firstIndex(where: { $0.id == id }) else {
            print("⚠️ Profile not found for deletion: \(id)")
            return
        }

        let wasDefault = profiles[index].isDefault
        let deletedName = profiles[index].name
        profiles.remove(at: index)

        // If we deleted the default profile, make the first remaining profile default
        if wasDefault && !profiles.isEmpty {
            profiles[0].isDefault = true
        }

        saveProfiles()
        print("✅ Deleted profile: \(deletedName)")
    }

    /// Delete a profile
    func deleteProfile(_ profile: BirthProfile) {
        deleteProfile(id: profile.id)
    }

    /// Set a profile as the default
    func setDefaultProfile(id: UUID) {
        guard let index = profiles.firstIndex(where: { $0.id == id }) else {
            return
        }

        // Remove default from all profiles
        for i in 0..<profiles.count {
            profiles[i].isDefault = (i == index)
        }

        saveProfiles()
        print("✅ Set default profile: \(profiles[index].name)")
    }

    /// Get a profile by ID
    func getProfile(id: UUID) -> BirthProfile? {
        profiles.first(where: { $0.id == id })
    }

    /// Delete all profiles
    func deleteAllProfiles() {
        profiles.removeAll()
        saveProfiles()
        print("✅ Deleted all profiles")
    }

    // MARK: - Private Methods

    private func loadProfiles() {
        guard let data = userDefaults.data(forKey: profilesKey) else {
            profiles = []
            return
        }

        do {
            profiles = try JSONDecoder().decode([BirthProfile].self, from: data)
            print("✅ Loaded \(profiles.count) birth profiles")
        } catch {
            print("❌ Failed to decode profiles: \(error)")
            profiles = []
        }
    }

    private func saveProfiles() {
        do {
            let data = try JSONEncoder().encode(profiles)
            userDefaults.set(data, forKey: profilesKey)
        } catch {
            print("❌ Failed to encode profiles: \(error)")
        }
    }
}
