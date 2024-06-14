import Foundation

class SessionManager: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var isUserDataComplete: Bool = false
    
    private let userEmailKey = "user_email"
 
    func checkSession() {
        if let userEmail = UserDefaults.standard.string(forKey: userEmailKey) {
            isLoggedIn = true
            checkUserData(email: userEmail)
        } else {
            isLoggedIn = false
        }
    }

    func checkUserData(email: String) {
        self.isUserDataComplete = true
    }

    func logIn(email: String) {
        UserDefaults.standard.set(email, forKey: userEmailKey)
        isLoggedIn = true
        checkUserData(email: email)
    }

    func logOut() {
        UserDefaults.standard.removeObject(forKey: userEmailKey)
        isLoggedIn = false
        isUserDataComplete = false
    }
}
