import SwiftUI

struct AuthCoordinatorView: View {
    @StateObject private var authViewModel = AuthViewModel()

    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                ContentView()
                    .environmentObject(authViewModel)
            } else {
                loginScreenView()
                    .environmentObject(authViewModel)
            }
        }
        .task {
            await authViewModel.checkAuthStatus()
        }
    }
}

#Preview {
    AuthCoordinatorView()
}
