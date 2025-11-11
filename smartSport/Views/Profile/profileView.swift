import SwiftUI

struct profileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showEditSheet = false
    let userId: UUID

    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading {
                    ProgressView("Loading profile...")
                } else if let profile = viewModel.profile {
                    ScrollView {
                        VStack(spacing: 20) {
                            basicInfoCard(profile: profile)

                            if let measurables = viewModel.measurables {
                                measurablesCard(measurables: measurables)
                            }

                            if let stats = viewModel.stats {
                                statsCard(stats: stats)
                            }
                        }
                        .padding()
                    }
                } else {
                    emptyStateView
                }
            }
            .navigationTitle(viewModel.profile?.name ?? "Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showEditSheet = true
                    } label: {
                        Text("Edit")
                            .foregroundColor(.orange)
                    }
                    .disabled(viewModel.profile == nil)
                }
            }
            .sheet(isPresented: $showEditSheet) {
                if let profile = viewModel.profile {
                    ProfileEditView(
                        viewModel: viewModel,
                        profile: profile,
                        measurables: viewModel.measurables,
                        stats: viewModel.stats
                    ) {
                        Task {
                            await viewModel.loadProfile(userId: userId)
                        }
                    }
                }
            }
            .task {
                await viewModel.loadProfile(userId: userId)
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }

    // MARK: - Basic Info Card

    private func basicInfoCard(profile: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Basic Info")
                .font(.headline)
                .foregroundColor(.gray)

            VStack(spacing: 16) {
                infoRow(label: "Age", value: profile.age.map { "\($0) years old" } ?? "Not specified")
                infoRow(label: "Position", value: profile.position?.fullName ?? "Not specified")
                infoRow(label: "Target Division", value: profile.targetDivision?.rawValue ?? "Not specified")
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }

    // MARK: - Measurables Card

    private func measurablesCard(measurables: UserMeasurables) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Measurables")
                .font(.headline)
                .foregroundColor(.gray)

            VStack(spacing: 16) {
                infoRow(label: "Height", value: measurables.heightFormatted)
                infoRow(label: "Weight", value: "\(measurables.weightLbs) lbs")
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }

    // MARK: - Stats Card

    private func statsCard(stats: UserStats) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Season Stats")
                .font(.headline)
                .foregroundColor(.gray)

            VStack(spacing: 16) {
                infoRow(label: "PPG", value: stats.ppg.map { $0.formatted(decimalPlaces: 1) } ?? "N/A")
                infoRow(label: "APG", value: stats.apg.map { $0.formatted(decimalPlaces: 1) } ?? "N/A")
                infoRow(label: "RPG", value: stats.rpg.map { $0.formatted(decimalPlaces: 1) } ?? "N/A")
                infoRow(label: "FG%", value: stats.fgPercent.map { "\($0.formatted(decimalPlaces: 1))%" } ?? "N/A")
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }

    // MARK: - Info Row

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.crop.circle.badge.exclamationmark")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("No Profile Found")
                .font(.title2)
                .fontWeight(.bold)

            Text("Unable to load your profile. Please try again.")
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

#Preview {
    profileView(userId: UUID())
}
