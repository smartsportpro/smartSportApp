//
//  HomeView.swift
//  smartSport
//
//  Main home screen showing user stats and navigation
//

import SwiftUI

struct HomeView: View {
    let userId: UUID
    let onFindMatch: () -> Void
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Welcome Header
                    if let profile = viewModel.userProfile {
                        welcomeHeader(name: profile.name)
                    }

                    // Season Stats Card
                    if let stats = viewModel.seasonAverages {
                        seasonStatsCard(stats: stats)
                    }

                    // Find My Match CTA
                    findMatchButton()

                    // Last Game Card
                    if let game = viewModel.lastGame {
                        lastGameCard(game: game)
                    } else if !viewModel.isLoading {
                        noGamesMessage()
                    }
                }
                .padding()
            }
            .navigationTitle("Home")
            .task {
                await viewModel.loadHomeData(userId: userId)
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                }
            }
        }
    }

    // MARK: - View Components

    private func welcomeHeader(name: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Welcome back,")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(name)
                    .font(.title)
                    .fontWeight(.bold)
            }
            Spacer()
        }
        .padding(.top)
    }

    private func seasonStatsCard(stats: UserStats) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Season Averages")
                .font(.headline)

            HStack(spacing: 20) {
                statItem(value: String(format: "%.1f", stats.ppg ?? 0.0), label: "PPG")
                statItem(value: String(format: "%.1f", stats.rpg ?? 0.0), label: "RPG")
                statItem(value: String(format: "%.1f", stats.apg ?? 0.0), label: "APG")
                statItem(value: String(format: "%.1f%%", stats.fgPercent ?? 0.0), label: "FG%")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.orange)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    private func findMatchButton() -> some View {
        Button {
            onFindMatch()
        } label: {
            HStack {
                Image(systemName: "person.2.fill")
                Text("Find My Match")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.orange)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
    }

    private func lastGameCard(game: GameStats) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Last Game")
                    .font(.headline)
                Spacer()
                Text(game.gameDate, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(game.points ?? 0)")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Points")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Divider()
                    .frame(height: 40)

                HStack(spacing: 12) {
                    gameStatItem(value: game.rebounds ?? 0, label: "REB")
                    gameStatItem(value: game.assists ?? 0, label: "AST")
                    gameStatItem(value: game.steals ?? 0, label: "STL")
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private func gameStatItem(value: Int, label: String) -> some View {
        VStack(spacing: 2) {
            Text("\(value)")
                .font(.title3)
                .fontWeight(.semibold)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }

    private func noGamesMessage() -> some View {
        VStack(spacing: 12) {
            Image(systemName: "basketball")
                .font(.system(size: 48))
                .foregroundColor(.orange.opacity(0.5))
            Text("No games recorded yet")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text("Add your first game in the Stats tab")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

#Preview {
    HomeView(userId: UUID(), onFindMatch: {})
}
