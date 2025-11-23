import Foundation
import SwiftUI

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let authService = AuthService.shared

    func signUp(email: String, password: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let user = try await authService.signUp(email: email, password: password)
            currentUser = user
            // Don't set isAuthenticated = true yet - wait until profile is created
            // Save user ID to UserDefaults for app-wide access
            UserDefaults.standard.set(user.id.uuidString, forKey: "currentUserId")
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let user = try await authService.signIn(email: email, password: password)
            currentUser = user
            isAuthenticated = true
            // Save user ID to UserDefaults for app-wide access
            UserDefaults.standard.set(user.id.uuidString, forKey: "currentUserId")
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func signOut() async {
        isLoading = true

        do {
            try await authService.signOut()
            currentUser = nil
            isAuthenticated = false
            // Clear user ID from UserDefaults
            UserDefaults.standard.removeObject(forKey: "currentUserId")
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func resetPassword(email: String) async {
        isLoading = true
        errorMessage = nil

        do {
            try await authService.resetPassword(email: email)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func checkAuthStatus() async {
        do {
            if let user = try await authService.getCurrentUser() {
                currentUser = user
                isAuthenticated = true
                // Save user ID to UserDefaults for app-wide access
                UserDefaults.standard.set(user.id.uuidString, forKey: "currentUserId")
            }
        } catch {
            isAuthenticated = false
            // Clear user ID if not authenticated
            UserDefaults.standard.removeObject(forKey: "currentUserId")
        }
    }
}
