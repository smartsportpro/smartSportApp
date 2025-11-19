import Foundation
import Supabase

class AuthService {
    static let shared = AuthService()

    private let client: SupabaseClient

    private init() {
        guard let url = URL(string: Config.supabaseURL) else {
            fatalError("❌ Invalid Supabase URL. Check Secrets.plist configuration.")
        }

        self.client = SupabaseClient(
            supabaseURL: url,
            supabaseKey: Config.supabaseKey
        )
    }

    func signUp(email: String, password: String) async throws -> User {
        do {
            let response = try await client.auth.signUp(
                email: email,
                password: password
            )

            guard let session = response.session else {
                print("❌ Sign up failed: No session returned (email confirmation may be required)")
                throw AuthError.signUpFailed
            }

            return User(
                id: session.user.id,
                email: session.user.email ?? email,
                createdAt: session.user.createdAt
            )
        } catch let error as AuthError {
            // Re-throw our own errors
            throw error
        } catch {
            // Log the actual Supabase error for debugging
            print("❌ Sign up error: \(error)")
            print("❌ Error details: \(String(describing: error))")

            // Throw the original error so we can see what went wrong
            throw error
        }
    }

    func signIn(email: String, password: String) async throws -> User {
        do {
            let response = try await client.auth.signIn(
                email: email,
                password: password
            )

            return User(
                id: response.user.id,
                email: response.user.email ?? email,
                createdAt: response.user.createdAt
            )
        } catch let error as AuthError {
            throw error
        } catch {
            print("❌ Sign in error: \(error)")
            print("❌ Error details: \(String(describing: error))")
            throw error
        }
    }

    func signOut() async throws {
        try await client.auth.signOut()
    }

    func resetPassword(email: String) async throws {
        try await client.auth.resetPasswordForEmail(email)
    }

    func getCurrentUser() async throws -> User? {
        do {
            let session = try await client.auth.session

            return User(
                id: session.user.id,
                email: session.user.email ?? "",
                createdAt: session.user.createdAt
            )
        } catch {
            // No active session
            return nil
        }
    }

    func getAccessToken() async throws -> String? {
        do {
            let session = try await client.auth.session
            return session.accessToken
        } catch {
            return nil
        }
    }
}

enum AuthError: Error {
    case signUpFailed
    case signInFailed
    case invalidCredentials
    case userNotFound
}
