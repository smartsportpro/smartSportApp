import Foundation
import Supabase

class AuthService {
    static let shared = AuthService()

    private let client: SupabaseClient

    private init() {
        self.client = SupabaseClient(
            supabaseURL: URL(string: Config.supabaseURL)!,
            supabaseKey: Config.supabaseKey
        )
    }

    func signUp(email: String, password: String) async throws -> User {
        let response = try await client.auth.signUp(
            email: email,
            password: password
        )

        guard let user = response.user else {
            throw AuthError.signUpFailed
        }

        return User(
            id: user.id,
            email: user.email ?? email,
            createdAt: user.createdAt
        )
    }

    func signIn(email: String, password: String) async throws -> User {
        let response = try await client.auth.signIn(
            email: email,
            password: password
        )

        return User(
            id: response.user.id,
            email: response.user.email ?? email,
            createdAt: response.user.createdAt
        )
    }

    func signOut() async throws {
        try await client.auth.signOut()
    }

    func resetPassword(email: String) async throws {
        try await client.auth.resetPasswordForEmail(email)
    }

    func getCurrentUser() async throws -> User? {
        guard let session = try await client.auth.session else {
            return nil
        }

        return User(
            id: session.user.id,
            email: session.user.email ?? "",
            createdAt: session.user.createdAt
        )
    }

    func getAccessToken() async throws -> String? {
        return try await client.auth.session?.accessToken
    }
}

enum AuthError: Error {
    case signUpFailed
    case signInFailed
    case invalidCredentials
    case userNotFound
}
