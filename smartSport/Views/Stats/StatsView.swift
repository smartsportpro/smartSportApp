import SwiftUI

struct StatsView: View {
    @StateObject private var viewModel = StatsViewModel()
    @State private var showAddGameSheet = false
    let userId: UUID

    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading && viewModel.games.isEmpty {
                    ProgressView("Loading stats...")
                } else if viewModel.games.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            if let seasonAverages = viewModel.seasonAverages {
                                seasonAveragesCard(stats: seasonAverages)
                            }

                            gamesListSection
                        }
                        .padding()
                    }
                    .refreshable {
                        await viewModel.loadStats(userId: userId)
                    }
                }
            }
            .navigationTitle("Stats")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddGameSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(.orange)
                    }
                }
            }
            .sheet(isPresented: $showAddGameSheet) {
                AddGameStatsView(viewModel: viewModel, userId: userId) {
                    Task {
                        await viewModel.loadStats(userId: userId)
                    }
                }
            }
            .task {
                await viewModel.loadStats(userId: userId)
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

    // MARK: - Season Averages Card

    private func seasonAveragesCard(stats: UserStats) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Season Averages")
                .font(.headline)
                .foregroundColor(.gray)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                statItem(label: "PPG", value: stats.ppg?.formatted(decimalPlaces: 1) ?? "0.0")
                statItem(label: "RPG", value: stats.rpg?.formatted(decimalPlaces: 1) ?? "0.0")
                statItem(label: "APG", value: stats.apg?.formatted(decimalPlaces: 1) ?? "0.0")
                statItem(label: "FG%", value: stats.fgPercent.map { "\($0.formatted(decimalPlaces: 1))%" } ?? "0.0%")
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }

    private func statItem(label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.orange)
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }

    // MARK: - Games List Section

    private var gamesListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Game History")
                .font(.headline)
                .foregroundColor(.gray)
                .padding(.horizontal)

            ForEach(viewModel.games.sorted(by: { $0.gameDate > $1.gameDate })) { game in
                gameCard(game: game)
            }
        }
    }

    private func gameCard(game: GameStats) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(game.gameDate.formattedMedium())
                        .font(.headline)

                    if let opponent = game.opponentName {
                        Text("vs \(opponent)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }

                Spacer()

                Button(action: {
                    deleteGame(game)
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }

            Divider()

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                if let points = game.points {
                    miniStatItem(label: "PTS", value: "\(points)")
                }
                if let rebounds = game.rebounds {
                    miniStatItem(label: "REB", value: "\(rebounds)")
                }
                if let assists = game.assists {
                    miniStatItem(label: "AST", value: "\(assists)")
                }
                if let steals = game.steals {
                    miniStatItem(label: "STL", value: "\(steals)")
                }
                if let blocks = game.blocks {
                    miniStatItem(label: "BLK", value: "\(blocks)")
                }
                if let minutes = game.minutesPlayed {
                    miniStatItem(label: "MIN", value: "\(minutes)")
                }
            }

            if game.fgPercent != nil || game.threePPercent != nil {
                Divider()

                HStack(spacing: 20) {
                    if let fg = game.fgPercent {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("FG%")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("\(fg.formatted(decimalPlaces: 1))%")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                    }

                    if let threeP = game.threePPercent {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("3P%")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("\(threeP.formatted(decimalPlaces: 1))%")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }

    private func miniStatItem(label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
            Text(label)
                .font(.caption2)
                .foregroundColor(.gray)
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("No Games Yet")
                .font(.title2)
                .fontWeight(.bold)

            Text("Add your first game to start tracking your progress!")
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)

            Button {
                showAddGameSheet = true
            } label: {
                Text("Add Game")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.orange)
                    .cornerRadius(10)
            }
            .padding(.top)
        }
        .padding()
    }

    // MARK: - Delete Game

    private func deleteGame(_ game: GameStats) {
        Task {
            await viewModel.deleteGame(game)
        }
    }
}

#Preview {
    StatsView(userId: UUID())
}
