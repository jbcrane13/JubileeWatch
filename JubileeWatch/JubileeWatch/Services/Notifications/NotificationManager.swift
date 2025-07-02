import UserNotifications
import Foundation

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    private init() {
        checkAuthorizationStatus()
    }
    
    func requestAuthorization() async throws {
        let center = UNUserNotificationCenter.current()
        
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            
            DispatchQueue.main.async {
                self.authorizationStatus = granted ? .authorized : .denied
            }
            
            if granted {
                await registerForRemoteNotifications()
            }
        } catch {
            throw NotificationError.authorizationFailed(error.localizedDescription)
        }
    }
    
    func scheduleJubileeAlert(_ prediction: JubileePrediction) async throws {
        guard authorizationStatus == .authorized else {
            throw NotificationError.notAuthorized
        }
        
        let content = UNMutableNotificationContent()
        content.title = "High Jubilee Probability!"
        content.body = "\(Int(prediction.probability))% chance detected in your area"
        content.sound = .default
        content.badge = 1
        
        // Add location info if available
        content.userInfo = [
            "predictionId": prediction.id.uuidString,
            "probability": prediction.probability,
            "latitude": prediction.location.latitude,
            "longitude": prediction.location.longitude
        ]
        
        // Schedule for immediate delivery
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: prediction.id.uuidString,
            content: content,
            trigger: trigger
        )
        
        let center = UNUserNotificationCenter.current()
        try await center.add(request)
    }
    
    func scheduleHighProbabilityAlert(_ prediction: JubileePrediction) async throws {
        guard prediction.probability >= Constants.Notification.highProbabilityThreshold else {
            return
        }
        
        try await scheduleJubileeAlert(prediction)
    }
    
    func cancelNotification(with id: String) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [id])
    }
    
    func cancelAllNotifications() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
    }
    
    private func checkAuthorizationStatus() {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.authorizationStatus = settings.authorizationStatus
            }
        }
    }
    
    @MainActor
    private func registerForRemoteNotifications() async {
        UIApplication.shared.registerForRemoteNotifications()
    }
}

enum NotificationError: Error, LocalizedError {
    case notAuthorized
    case authorizationFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "Notifications not authorized"
        case .authorizationFailed(let message):
            return "Authorization failed: \(message)"
        }
    }
}

// MARK: - UIApplication Extension
extension UIApplication {
    var firstKeyWindow: UIWindow? {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive }
            .first?.keyWindow
    }
}