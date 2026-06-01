import SwiftUI
import UserNotifications

@main
struct ZiWeiFortuneApp: App {
    let coreDataManager = CoreDataManager.shared
    @StateObject private var appDelegate = AppDelegate()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, coreDataManager.context)
                .environmentObject(appDelegate)
        }
    }
}

class AppDelegate: NSObject, ObservableObject {
    override init() {
        super.init()
        // 初始化通知设置（用于后台任务完成通知）
        UNUserNotificationCenter.current().delegate = self
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    // 处理前台收到的通知
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }

    // 处理用户点击通知
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo

        if let readingId = userInfo["readingId"] as? String {
            // 导航到对应的reading详情
            NotificationCenter.default.post(
                name: .readingCompleted,
                object: nil,
                userInfo: ["readingId": readingId]
            )
        }

        completionHandler()
    }
}

extension Notification.Name {
    static let readingCompleted = Notification.Name("readingCompleted")
    static let languageChanged = Notification.Name("languageChanged")
}
