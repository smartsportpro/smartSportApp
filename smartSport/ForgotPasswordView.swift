import SwiftUI
import Supabase

struct ForgotPasswordView: View {
    @State private var email: String = ""
    @State private var message: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Reset Password")
                .font(.title)
                .bold()

            TextField("Enter your email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)

            Button("Send Reset Link") {
                sendResetEmail()
            }
            .buttonStyle(.borderedProminent)

            Text(message)
                .foregroundColor(.gray)
                .font(.footnote)

            Spacer()
        }
        .padding()
    }

    func sendResetEmail() {
        let client = SupabaseClient(
            supabaseURL: URL(string: "https://twcwyfebqjtpxxrzsogt.supabase.co")!,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR3Y3d5ZmVicWp0cHh4cnpzb2d0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk4MjA0MjgsImV4cCI6MjA3NTM5NjQyOH0.tgs-3DCYexZ244Vf9r9PrXfKdrWSff8-08TuYWTo5PQ"
        )

        Task {
            do {
                try await client.auth.resetPasswordForEmail(email)
                message = "Check your email for the reset link."
            } catch {
                message = error.localizedDescription
            }
        }
    }
}
