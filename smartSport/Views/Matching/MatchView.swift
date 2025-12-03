import SwiftUI

struct MatchView: View {
    let userId: UUID
    @StateObject private var viewModel = MatchingViewModel()
    @State private var showingPlayerDetail: MatchResult?

    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading {
                    loadingView
                } else if let errorMessage = viewModel.errorMessage {
                    errorView(message: errorMessage)
                } else if viewModel.matches.isEmpty {
                    emptyStateView
                } else {
                    matchResultsList
                }
            }
            .navigationTitle("Your Matches")
            .navigationBarTitleDisplayMode(.large)
            .task {
                await viewModel.findMatches(userId: userId)
            }
            .sheet(item: $showingPlayerDetail) { player in
                PlayerDetailView(player: player, userStats: viewModel.userStats)
            }
        }
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Finding your matches...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 30) {
            Spacer()

            Image(systemName: "person.2.crop.square.stack")
                .font(.system(size: 80))
                .foregroundColor(.orange)
                .padding(.bottom, 10)

            Text("Find Your Matches")
                .font(.title)
                .fontWeight(.bold)

            Text("Complete your profile with stats to find college players similar to you")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 40)

            Spacer()
        }
    }

    // MARK: - Error View

    private func errorView(message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.red)

            Text("Error")
                .font(.title)
                .fontWeight(.bold)

            Text(message)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 40)

            Button {
                Task {
                    await viewModel.findMatches(userId: userId)
                }
            } label: {
                Text("Try Again")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
        }
    }

    // MARK: - Match Results List

    private var matchResultsList: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Header
                VStack(spacing: 8) {
                    Text("Top \(viewModel.matches.count) Matches")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("College players with similar high school stats")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)

                // Match Cards
                ForEach(Array(viewModel.matches.enumerated()), id: \.element.id) { index, match in
                    MatchResultCard(match: match, rank: index + 1)
                        .onTapGesture {
                            showingPlayerDetail = match
                        }
                }
            }
            .padding()
        }
    }
}

// MARK: - Match Result Card

struct MatchResultCard: View {
    let match: MatchResult
    let rank: Int

    var body: some View {
        VStack(spacing: 0) {
            // Rank Badge & Similarity
            HStack {
                // Rank
                ZStack {
                    Circle()
                        .fill(rankColor)
                        .frame(width: 36, height: 36)

                    Text("#\(rank)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }

                Spacer()

                // Similarity Score
                VStack(alignment: .trailing, spacing: 2) {
                    Text(match.similarityPercentFormatted)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)

                    Text("Match")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()

            Divider()

            // Player Info
            HStack(spacing: 16) {
                // Player Photo Placeholder
                ZStack {
                    Circle()
                        .fill(Color(.systemGray5))
                        .frame(width: 60, height: 60)

                    Image(systemName: "person.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.gray)
                }

                // Name & School
                VStack(alignment: .leading, spacing: 4) {
                    Text(match.name)
                        .font(.headline)
                        .fontWeight(.bold)

                    Text(match.college)
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    HStack(spacing: 8) {
                        Label(match.division.rawValue, systemImage: "graduationcap.fill")
                            .font(.caption)
                            .foregroundColor(.orange)

                        Label(match.position.fullName, systemImage: "figure.basketball")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()

            Divider()

            // Stats Comparison
            HStack(spacing: 0) {
                statColumn(label: "PPG", value: match.hsPpg)
                statColumn(label: "APG", value: match.hsApg)
                statColumn(label: "RPG", value: match.hsRpg)
                statColumn(label: "FG%", value: match.hsFgPercent)
            }
            .padding(.vertical, 12)

            // Physical Stats
            Divider()

            HStack(spacing: 20) {
                physicalStat(icon: "ruler", label: "Height", value: match.heightFormatted)
                physicalStat(icon: "scalemass", label: "Weight", value: "\(match.collegeWeightLbs) lbs")
            }
            .padding()
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }

    private var rankColor: Color {
        switch rank {
        case 1: return .orange
        case 2: return .blue
        case 3: return .green
        default: return .gray
        }
    }

    private func statColumn(label: String, value: Double?) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)

            if let value = value {
                Text(String(format: "%.1f", value))
                    .font(.system(size: 16, weight: .semibold))
            } else {
                Text("-")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func physicalStat(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.orange)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Player Detail View

struct PlayerDetailView: View {
    let player: MatchResult
    let userStats: UserStatsSnapshot?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Player Header
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color(.systemGray5))
                                .frame(width: 120, height: 120)

                            Image(systemName: "person.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                        }

                        Text(player.name)
                            .font(.title)
                            .fontWeight(.bold)

                        Text(player.college)
                            .font(.title3)
                            .foregroundColor(.secondary)

                        HStack(spacing: 16) {
                            Label(player.division.rawValue, systemImage: "graduationcap.fill")
                                .font(.subheadline)
                                .foregroundColor(.orange)

                            Label(player.position.fullName, systemImage: "figure.basketball")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()

                    // Similarity Score
                    VStack(spacing: 8) {
                        Text("Similarity Score")
                            .font(.headline)
                            .foregroundColor(.secondary)

                        Text(player.similarityPercentFormatted)
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.orange)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    .padding(.horizontal)

                    // Measurables
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Measurables")
                            .font(.headline)

                        HStack(spacing: 40) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Height")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text(player.heightFormatted)
                                    .font(.title2)
                                    .fontWeight(.semibold)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Weight")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text("\(player.collegeWeightLbs) lbs")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                            }

                            Spacer()
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    .padding(.horizontal)

                    // High School Performance
                    VStack(alignment: .leading, spacing: 12) {
                        Text("High School Performance")
                            .font(.headline)

                        Text("High School: [To Be Added]")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .italic()

                        Divider()

                        Text("Senior Year Stats")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)

                        VStack(spacing: 12) {
                            if let ppg = player.hsPpg {
                                statRow(label: "Points Per Game", value: String(format: "%.1f", ppg))
                            }
                            if let rpg = player.hsRpg {
                                statRow(label: "Rebounds Per Game", value: String(format: "%.1f", rpg))
                            }
                            if let apg = player.hsApg {
                                statRow(label: "Assists Per Game", value: String(format: "%.1f", apg))
                            }
                            if let fg = player.hsFgPercent {
                                statRow(label: "Field Goal %", value: String(format: "%.1f%%", fg))
                            }
                            if let threePt = player.hs3pPercent {
                                statRow(label: "3-Point %", value: String(format: "%.1f%%", threePt))
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    .padding(.horizontal)

                    // Comparison Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("You vs \(player.name)")
                            .font(.headline)

                        Text("Complete your profile to see how your stats compare")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .italic()

                        Divider()

                        // Comparison table
                        VStack(spacing: 8) {
                            comparisonRow(
                                label: "PPG",
                                yourValue: userStats?.ppg.map { String(format: "%.1f", $0) } ?? "--",
                                theirValue: player.hsPpg.map { String(format: "%.1f", $0) } ?? "--",
                                isWeaker: compareStats(yours: userStats?.ppg, theirs: player.hsPpg)
                            )
                            comparisonRow(
                                label: "RPG",
                                yourValue: userStats?.rpg.map { String(format: "%.1f", $0) } ?? "--",
                                theirValue: player.hsRpg.map { String(format: "%.1f", $0) } ?? "--",
                                isWeaker: compareStats(yours: userStats?.rpg, theirs: player.hsRpg)
                            )
                            comparisonRow(
                                label: "APG",
                                yourValue: userStats?.apg.map { String(format: "%.1f", $0) } ?? "--",
                                theirValue: player.hsApg.map { String(format: "%.1f", $0) } ?? "--",
                                isWeaker: compareStats(yours: userStats?.apg, theirs: player.hsApg)
                            )
                            comparisonRow(
                                label: "FG%",
                                yourValue: userStats?.fgPercent.map { String(format: "%.1f%%", $0) } ?? "--",
                                theirValue: player.hsFgPercent.map { String(format: "%.1f%%", $0) } ?? "--",
                                isWeaker: compareStats(yours: userStats?.fgPercent, theirs: player.hsFgPercent)
                            )
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    .padding(.horizontal)

                    // Watch Film
                    if let videoUrl = player.videoUrl, !videoUrl.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Watch Film")
                                .font(.headline)

                            VideoCard(videoUrl: videoUrl, playerName: player.name)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(16)
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Player Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func statRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)

            Spacer()

            Text(value)
                .fontWeight(.semibold)
        }
    }

    private func compareStats(yours: Double?, theirs: Double?) -> Bool {
        // Returns true if your stat is weaker (lower) than theirs
        guard let yourStat = yours, let theirStat = theirs else {
            return false
        }
        return yourStat < theirStat
    }

    private func comparisonRow(label: String, yourValue: String, theirValue: String, isWeaker: Bool) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(width: 60, alignment: .leading)

            Text(yourValue)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(isWeaker ? .red : .primary)
                .frame(maxWidth: .infinity)

            Text("vs")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 30)

            Text(theirValue)
                .font(.subheadline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Video Card Component

struct VideoCard: View {
    let videoUrl: String
    let playerName: String

    @State private var videoID: String = ""
    @State private var thumbnailUrl: String = ""

    var body: some View {
        HStack(spacing: 12) {
            // YouTube Thumbnail
            AsyncImage(url: URL(string: thumbnailUrl)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                ZStack {
                    Color.gray.opacity(0.3)
                    Image(systemName: "play.rectangle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .frame(width: 160, height: 90)
            .cornerRadius(8)

            // Video Info
            VStack(alignment: .leading, spacing: 6) {
                Text("\(playerName) Highlights")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)

                HStack(spacing: 4) {
                    Image(systemName: "person.fill")
                        .font(.caption2)
                    Text("Individual Highlights")
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }

            Spacer()

            // Play Button
            Image(systemName: "play.circle.fill")
                .font(.title)
                .foregroundColor(.blue)
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4)
        .onTapGesture {
            openVideo()
        }
        .onAppear {
            extractVideoMetadata()
        }
    }

    private func extractVideoMetadata() {
        // Extract YouTube video ID from various URL formats
        let patterns = [
            "(?:youtube\\.com\\/watch\\?v=|youtu\\.be\\/)([a-zA-Z0-9_-]{11})",
            "youtube\\.com\\/embed\\/([a-zA-Z0-9_-]{11})"
        ]

        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern),
               let match = regex.firstMatch(in: videoUrl, range: NSRange(videoUrl.startIndex..., in: videoUrl)),
               let videoIDRange = Range(match.range(at: 1), in: videoUrl) {
                videoID = String(videoUrl[videoIDRange])
                thumbnailUrl = "https://img.youtube.com/vi/\(videoID)/hqdefault.jpg"
                return
            }
        }

        // Fallback thumbnail if parsing fails
        thumbnailUrl = ""
    }

    private func openVideo() {
        if let url = URL(string: videoUrl) {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    MatchView(userId: UUID())
}
