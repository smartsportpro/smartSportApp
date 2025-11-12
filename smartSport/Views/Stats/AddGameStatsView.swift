import SwiftUI

struct AddGameStatsView: View {
    @ObservedObject var viewModel: StatsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showSuccessMessage = false

    let userId: UUID
    let onSave: () -> Void

    // Form fields
    @State private var gameDate = Date()
    @State private var opponentName = ""
    @State private var minutesPlayed = ""
    @State private var points = ""
    @State private var rebounds = ""
    @State private var assists = ""
    @State private var steals = ""
    @State private var blocks = ""
    @State private var fgPercent = ""
    @State private var threePPercent = ""

    var body: some View {
        NavigationStack {
            Form {
                gameInfoSection
                scoringSection
                otherStatsSection
            }
            .navigationTitle("Add Game Stats")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(viewModel.isLoading)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveGame()
                    }
                    .disabled(!isValidInput || viewModel.isLoading)
                }
            }
            .disabled(viewModel.isLoading)
            .overlay {
                if viewModel.isLoading {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()

                        ProgressView("Saving game...")
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                    }
                }

                if showSuccessMessage {
                    successOverlay
                }
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "Failed to save game")
            }
        }
    }

    // MARK: - Game Info Section

    private var gameInfoSection: some View {
        Section("Game Info") {
            DatePicker("Date", selection: $gameDate, in: dateRange, displayedComponents: .date)

            TextField("Opponent (Optional)", text: $opponentName)
                .textInputAutocapitalization(.words)

            HStack {
                Text("Minutes Played")
                Spacer()
                TextField("0-48", text: $minutesPlayed)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
            }

            if let minutes = Int(minutesPlayed), !isValidMinutes(minutes) {
                Text("Minutes must be between 0 and 48")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }

    // MARK: - Scoring Section

    private var scoringSection: some View {
        Section("Scoring") {
            HStack {
                Text("Points")
                Spacer()
                TextField("0-100", text: $points)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
            }

            if let pts = Int(points), !isValidPoints(pts) {
                Text("Points must be between 0 and 100")
                    .font(.caption)
                    .foregroundColor(.red)
            }

            HStack {
                Text("Field Goal %")
                Spacer()
                TextField("0-100", text: $fgPercent)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
            }

            if let fg = Double(fgPercent), !isValidPercentage(fg) {
                Text("Percentage must be between 0 and 100")
                    .font(.caption)
                    .foregroundColor(.red)
            }

            HStack {
                Text("3-Point %")
                Spacer()
                TextField("0-100", text: $threePPercent)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
            }

            if let threeP = Double(threePPercent), !isValidPercentage(threeP) {
                Text("Percentage must be between 0 and 100")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .headerProminence(.increased)
    }

    // MARK: - Other Stats Section

    private var otherStatsSection: some View {
        Section("Other Stats") {
            HStack {
                Text("Rebounds")
                Spacer()
                TextField("0-50", text: $rebounds)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
            }

            if let reb = Int(rebounds), !isValidRebounds(reb) {
                Text("Rebounds must be between 0 and 50")
                    .font(.caption)
                    .foregroundColor(.red)
            }

            HStack {
                Text("Assists")
                Spacer()
                TextField("0-50", text: $assists)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
            }

            if let ast = Int(assists), !isValidAssists(ast) {
                Text("Assists must be between 0 and 50")
                    .font(.caption)
                    .foregroundColor(.red)
            }

            HStack {
                Text("Steals")
                Spacer()
                TextField("0-20", text: $steals)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
            }

            if let stl = Int(steals), !isValidSteals(stl) {
                Text("Steals must be between 0 and 20")
                    .font(.caption)
                    .foregroundColor(.red)
            }

            HStack {
                Text("Blocks")
                Spacer()
                TextField("0-20", text: $blocks)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
            }

            if let blk = Int(blocks), !isValidBlocks(blk) {
                Text("Blocks must be between 0 and 20")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .headerProminence(.increased)
    }

    // MARK: - Success Overlay

    private var successOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)

                Text("Game Saved!")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Your averages have been updated")
                    .foregroundColor(.gray)
            }
            .padding(40)
            .background(Color(.systemBackground))
            .cornerRadius(20)
        }
    }

    // MARK: - Validation

    private var dateRange: ClosedRange<Date> {
        let sixMonthsAgo = Calendar.current.date(byAdding: .month, value: -6, to: Date()) ?? Date()
        return sixMonthsAgo...Date()
    }

    private var isValidInput: Bool {
        // Check if any numeric fields have invalid values
        if !minutesPlayed.isEmpty, let minutes = Int(minutesPlayed), !isValidMinutes(minutes) {
            return false
        }

        if !points.isEmpty, let pts = Int(points), !isValidPoints(pts) {
            return false
        }

        if !rebounds.isEmpty, let reb = Int(rebounds), !isValidRebounds(reb) {
            return false
        }

        if !assists.isEmpty, let ast = Int(assists), !isValidAssists(ast) {
            return false
        }

        if !steals.isEmpty, let stl = Int(steals), !isValidSteals(stl) {
            return false
        }

        if !blocks.isEmpty, let blk = Int(blocks), !isValidBlocks(blk) {
            return false
        }

        if !fgPercent.isEmpty, let fg = Double(fgPercent), !isValidPercentage(fg) {
            return false
        }

        if !threePPercent.isEmpty, let threeP = Double(threePPercent), !isValidPercentage(threeP) {
            return false
        }

        // At least one stat should be entered
        let hasAnyStat = !minutesPlayed.isEmpty || !points.isEmpty || !rebounds.isEmpty ||
                         !assists.isEmpty || !steals.isEmpty || !blocks.isEmpty ||
                         !fgPercent.isEmpty || !threePPercent.isEmpty

        return hasAnyStat
    }

    private func isValidMinutes(_ value: Int) -> Bool {
        return value >= 0 && value <= 48
    }

    private func isValidPoints(_ value: Int) -> Bool {
        return value >= 0 && value <= 100
    }

    private func isValidRebounds(_ value: Int) -> Bool {
        return value >= 0 && value <= 50
    }

    private func isValidAssists(_ value: Int) -> Bool {
        return value >= 0 && value <= 50
    }

    private func isValidSteals(_ value: Int) -> Bool {
        return value >= 0 && value <= 20
    }

    private func isValidBlocks(_ value: Int) -> Bool {
        return value >= 0 && value <= 20
    }

    private func isValidPercentage(_ value: Double) -> Bool {
        return value >= 0 && value <= 100
    }

    // MARK: - Save Game

    private func saveGame() {
        let game = GameStats(
            id: UUID(),
            userId: userId,
            gameDate: gameDate,
            opponentName: opponentName.isEmpty ? nil : opponentName,
            minutesPlayed: Int(minutesPlayed),
            points: Int(points),
            rebounds: Int(rebounds),
            assists: Int(assists),
            steals: Int(steals),
            blocks: Int(blocks),
            fgPercent: Double(fgPercent),
            threePPercent: Double(threePPercent),
            createdAt: Date()
        )

        Task {
            await viewModel.addGame(game)

            if viewModel.errorMessage == nil {
                showSuccessMessage = true
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                onSave()
                dismiss()
            }
        }
    }
}

#Preview {
    let viewModel = StatsViewModel()
    return AddGameStatsView(viewModel: viewModel, userId: UUID()) {
        print("Game saved")
    }
}
