import Foundation

/// A saved birth profile that can be reused across multiple readings
/// This allows users to save their own and family members' birth information
struct BirthProfile: Codable, Identifiable, Equatable {
    let id: UUID
    var name: String                    // Profile name, e.g., "我自己", "妈妈", "爸爸"
    var solarDate: Date
    var lunarDate: LunarDate?
    var birthHour: Int
    var birthMinute: Int
    var location: String
    var locationProvince: String
    var locationCity: String
    var longitude: Double
    var latitude: Double
    var gender: Gender
    var calendarType: CalendarType
    var useRealSolarTime: Bool
    var createdAt: Date
    var updatedAt: Date
    var isDefault: Bool                 // Whether this is the default/primary profile

    init(
        id: UUID = UUID(),
        name: String,
        solarDate: Date,
        lunarDate: LunarDate? = nil,
        birthHour: Int,
        birthMinute: Int,
        location: String,
        locationProvince: String = "",
        locationCity: String = "",
        longitude: Double,
        latitude: Double,
        gender: Gender,
        calendarType: CalendarType = .solar,
        useRealSolarTime: Bool = true,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        isDefault: Bool = false
    ) {
        self.id = id
        self.name = name
        self.solarDate = solarDate
        self.lunarDate = lunarDate
        self.birthHour = birthHour
        self.birthMinute = birthMinute
        self.location = location
        self.locationProvince = locationProvince
        self.locationCity = locationCity
        self.longitude = longitude
        self.latitude = latitude
        self.gender = gender
        self.calendarType = calendarType
        self.useRealSolarTime = useRealSolarTime
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isDefault = isDefault
    }

    /// Create a BirthProfile from a BirthInfo (for saving after a reading)
    init(from birthInfo: BirthInfo, name: String, isDefault: Bool = false) {
        self.id = UUID()
        self.name = name
        self.solarDate = birthInfo.solarDate
        self.lunarDate = birthInfo.lunarDate
        self.birthHour = birthInfo.birthHour
        self.birthMinute = birthInfo.birthMinute
        self.location = birthInfo.location
        self.locationProvince = birthInfo.locationProvince
        self.locationCity = birthInfo.locationCity
        self.longitude = birthInfo.longitude
        self.latitude = birthInfo.latitude
        self.gender = birthInfo.gender
        self.calendarType = birthInfo.calendarType
        self.useRealSolarTime = birthInfo.useRealSolarTime
        self.createdAt = Date()
        self.updatedAt = Date()
        self.isDefault = isDefault
    }

    /// Convert to BirthInfo for use in analysis
    func toBirthInfo(topic: AnalysisTopic) -> BirthInfo {
        BirthInfo(
            solarDate: solarDate,
            lunarDate: lunarDate,
            birthTime: BirthInfo.getChineseHour(from: birthHour),
            birthHour: birthHour,
            birthMinute: birthMinute,
            location: location,
            locationProvince: locationProvince,
            locationCity: locationCity,
            longitude: longitude,
            latitude: latitude,
            gender: gender,
            calendarType: calendarType,
            useRealSolarTime: useRealSolarTime,
            analysisTopic: topic
        )
    }

    // MARK: - Display Helpers

    /// Formatted date string for display
    var displayDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: solarDate)
    }

    /// Formatted time string for display
    var displayTime: String {
        String(format: "%02d:%02d", birthHour, birthMinute)
    }

    /// Gender display string
    var genderDisplay: String {
        let strings = LocalizationManager.shared.strings
        return gender == .male ? strings.male : strings.female
    }

    /// Summary string for display in lists
    var displaySummary: String {
        "\(displayDate) · \(location) · \(genderDisplay)"
    }

    /// Extract year from solar date
    var solarYear: Int {
        Calendar.current.component(.year, from: solarDate)
    }

    /// Extract month from solar date
    var solarMonth: Int {
        Calendar.current.component(.month, from: solarDate)
    }

    /// Extract day from solar date
    var solarDay: Int {
        Calendar.current.component(.day, from: solarDate)
    }
}
