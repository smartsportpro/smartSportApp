import SwiftUI

struct loginScreenView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showSignUp = false
    @State private var showErrorAlert = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Smart Sport")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 60)
                    .padding(.bottom, 40)

                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .textContentType(.emailAddress)

                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .textContentType(.password)
                }
                .padding(.horizontal)

                Button {
                    signIn()
                } label: {
                    if authViewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .orange))
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        Text("Login")
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .background(isValidInput ? Color.black : Color.gray)
                .foregroundColor(.orange)
                .cornerRadius(8)
                .disabled(!isValidInput || authViewModel.isLoading)
                .padding(.horizontal)
                .padding(.top, 20)

                Button {
                    showSignUp = true
                } label: {
                    Text("Don't have an account? Sign Up")
                        .foregroundColor(.black)
                        .underline()
                }
                .padding(.top, 10)

                Spacer()
            }
            .padding()
            .background(Color.orange.ignoresSafeArea())
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

