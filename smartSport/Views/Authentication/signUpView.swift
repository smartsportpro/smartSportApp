import SwiftUI

struct signUpView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showProfileCreation = false
    @State private var newUserId: UUID?
    @State private var showErrorAlert = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: Spacing.xl) {
                Text("Smart Sport")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 60)
                    .padding(.bottom, 40)

                VStack(spacing: Spacing.lg) {
                    TextField("Email", text: $email)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(CornerRadius.input)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .textContentType(.emailAddress)

                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(CornerRadius.input)
                        .textContentType(.newPassword)

                    Text("Password must be at least 6 characters")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal)

                Button {
                    signUp()
                } label: {
                    if authViewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Sign Up")
                    }
                }
                .buttonStyle(PrimaryButtonStyle(isDisabled: !isValidInput))
                .disabled(!isValidInput || authViewModel.isLoading)
                .padding(.horizontal)
                .padding(.top, Spacing.xl)

                Button {
                    dismiss()
                } label: {
                    Text("Already have an account? Sign In")
                        .foregroundColor(.primaryOrange)
                        .underline()
                }
                .padding(.top, 10)

                Spacer()
            }
            .padding()
            .background(Color(.systemBackground).ignoresSafeArea())
            .alert("Error", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(authViewModel.errorMessage ?? "Failed to create account")
            }
            .navigationDestination(isPresented: $showProfileCreation) {
                if let userId = newUserId {
                    ProfileCreationView(userId: userId) {
                        // Navigate to home after profile creation
                        authViewModel.isAuthenticated = true
                    }
                }
            }
        }
    }

    private var isValidInput: Bool {
        Validators.isValidEmail(email) && Validators.isValidPassword(password)
    }

    private func signUp() {
        Task {
            await authViewModel.signUp(email: email, password: password)

            if let user = authViewModel.currentUser {
                newUserId = user.id
                showProfileCreation = true
            } else if authViewModel.errorMessage != nil {
                showErrorAlert = true
            }
        }
    }
}

#Preview {
    signUpView()
        .environmentObject(AuthViewModel())
}

