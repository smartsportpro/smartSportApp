import SwiftUI

struct loginScreenView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showSignUp = false
    @State private var showErrorAlert = false

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
                        .textContentType(.password)
                }
                .padding(.horizontal)

                Button {
                    signIn()
                } label: {
                    if authViewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Login")
                    }
                }
                .buttonStyle(PrimaryButtonStyle(isDisabled: !isValidInput))
                .disabled(!isValidInput || authViewModel.isLoading)
                .padding(.horizontal)
                .padding(.top, Spacing.xl)

                Button {
                    showSignUp = true
                } label: {
                    Text("Don't have an account? Sign Up")
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
                Text(authViewModel.errorMessage ?? "Failed to sign in")
            }
            .sheet(isPresented: $showSignUp) {
                signUpView()
            }
        }
    }

    private var isValidInput: Bool {
        !email.isEmpty && !password.isEmpty
    }

    private func signIn() {
        Task {
            await authViewModel.signIn(email: email, password: password)

            if authViewModel.errorMessage != nil {
                showErrorAlert = true
            }
        }
    }
}

#Preview {
    loginScreenView()
        .environmentObject(AuthViewModel())
}

