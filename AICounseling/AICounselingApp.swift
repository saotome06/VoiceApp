import SwiftUI

@main
struct AICounselingApp: App {
    @StateObject private var sessionManager = SessionManager()

    var body: some Scene {
        WindowGroup {
            NavigationView {
                if sessionManager.isLoggedIn {
                    if sessionManager.isUserDataComplete {
                        TopView()
                    } else {
                        UserRegistView()
                    }
                } else {
                    LoginView()
                }
            }
            .onAppear {
                
                let appDomain = Bundle.main.bundleIdentifier
                UserDefaults.standard.removePersistentDomain(forName: appDomain!)
                sessionManager.checkSession()
            }
        }
    }
}
