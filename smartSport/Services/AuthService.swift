import Foundation
// TODO: Uncomment when Supabase SDK is installed via Swift Package Manager
// import Supabase

class AuthService {
    static let shared = AuthService()

    // TODO: Uncomment when Supabase SDK is installed
    // private let client: SupabaseClient

    private init() {
        // TODO: Uncomment when Supabase SDK is installed
        // self.client = SupabaseClient(
        //     supabaseURL: URL(string: Config.supabaseURL)!,
        //     supabaseKey: Config.supabaseKey
        // )
    }

    func signUp(email: String, password: String) async throws -> User {
        // TODO: Uncomment when Supabase SDK is installed
        fatalError("Supabase SDK not installed. Install via Swift Package Manager.")

        // let response = try await client.auth.signUp(
        //     email: email,
        //     password: password
        // )
        //
        // guard let user = response.user else {
        //     throw AuthError.signUpFailed
        // }
        //
        // return User(
        //     id: user.id,
        //     email: user.email ?? email,
        //     createdAt: user.createdAt
        // )
    }

    func signIn(email: String, password: String) async throws -> User {
        // TODO: Uncomment when Supabase SDK is installed
        fatalError("Supabase SDK not installed. Install via Swift Package Manager.")

        // let response = try await client.auth.signIn(
        //     email: email,
        //     password: password
        // )
        //
        // return User(
        //     id: response.user.id,
        //     email: response.user.email ?? email,
        //     createdAt: response.user.createdAt
        // )
    }

    func signOut() async throws {
        // TODO: Uncomment when Supabase SDK is installed
        fatalError("Supabase SDK not installed. Install via Swift Package Manager.")
        // try await client.auth.signOut()
    }

    func resetPassword(email: String) async throws {
        // TODO: Uncomment when Supabase SDK is installed
        fatalError("Supabase SDK not installed. Install via Swift Package Manager.")
        // try await client.auth.resetPasswordForEmail(email)
    }

    func getCurrentUser() async throws -> User? {
        // TODO: Uncomment when Supabase SDK is installed
        fatalError("Supabase SDK not installed. Install via Swift Package Manager.")

        // guard let session = try await client.auth.session else {
        //     return nil
        // }
        //
        // return User(
        //     id: session.user.id,
        //     email: session.user.email ?? "",
        //     createdAt: session.user.createdAt
        // )
    }

    func getAccessToken() async throws -> String? {
        // TODO: Uncomment when Supabase SDK is installed
        fatalError("Supabase SDK not installed. Install via Swift Package Manager.")
        // return try await client.auth.session?.accessToken
    }
}

enum AuthError: Error {
    case signUpFailed
    case signInFailed
    case invalidCredentials
    case userNotFound
}
