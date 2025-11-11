import SwiftUI

struct ProfileEditView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showSuccessMessage = false

    // Basic Info
    @State private var name: String
    @State private var age: String
    @State private var selectedPosition: Position?
    @State private var selectedDivision: Division?

    // Measurables
    @State private var heightFeet: Int
    @State private var heightInches: Int
    @State private var weight: String

    // Stats
    @State private var ppg: String
    @State private var apg: String
    @State private var rpg: String
    @State private var fgPercent: String

    let onSave: () -> Void

    init(viewModel: ProfileViewModel, profile: UserProfile, measurables: UserMeasurables?, stats: UserStats?, onSave: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onSave = onSave

        // Initialize basic info
        _name = State(initialValue: profile.name)
        _age = State(initialValue: profile.age.map { String($0) } ?? "")
        _selectedPosition = State(initialValue: profile.position)
        _selectedDivision = State(initialValue: profile.targetDivision)

        // Initialize measurables
        if let measurables = measurables {
            _heightFeet = State(initialValue: measurables.heightFeet)
            _heightInches = State(initialValue: measurables.heightRemainingInches)
            _weight = State(initialValue: String(measurables.weightLbs))
        } else {
            _heightFeet = State(initialValue: 5)
            _heightInches = State(initialValue: 10)
            _weight = State(initialValue: "")
        }

        // Initialize stats
        if let stats = stats {
            _ppg = State(initialValue: stats.ppg.map { String($0) } ?? "")
            _apg = State(initialValue: stats.apg.map { String($0) } ?? "")
            _rpg = State(initialValue: stats.rpg.map { String($0) } ?? "")
            _fgPercent = State(initialValue: stats.fgPercent.map { String($0) } ?? "")
        } else {
            _ppg = State(initialValue: "")
            _apg = State(initialValue: "")
            _rpg = State(initialValue: "")
            _fgPercent = State(initialValue: "")
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                basicInfoSection
                measurablesSection
                statsSection
            }
            .navigationTitle("Edit Profile")
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
                        saveProfile()
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

                        ProgressView("Saving...")
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                    }
                }

                if showSuccessMessage {
                    successOverlay
                }
            }
        }
    }

    // MARK: - Basic Info Section

    private var basicInfoSection: some View {
        Section("Basic Info") {
            TextField("Name", text: $name)
                .textInputAutocapitalization(.words)

            TextField("Age (Optional)", text: $age)
                .keyboardType(.numberPad)

            Picker("Position", selection: $selectedPosition) {
                Text("Select position").tag(nil as Position?)
                ForEach(Position.allCases, id: \.self) { position in
                    Text(position.fullName).tag(position as Position?)
                }
            }

            Picker("Target Division", selection: $selectedDivision) {
                Text("Select division").tag(nil as Division?)
                ForEach(Division.allCases, id: \.self) { division in
                    Text(division.rawValue).tag(division as Division?)
                }
            }
        }
    }

    // MARK: - Measurables Section

    private var measurablesSection: some View {
        Section("Measurables") {
            HStack {
                Text("Height")
                Spacer()
                Picker("Feet", selection: $heightFeet) {
                    ForEach(4...7, id: \.self) { feet in
                        Text("\(feet)'").tag(feet)
                    }
                }
                .pickerStyle(.menu)

                Picker("Inches", selection: $heightInches) {
                    ForEach(0...11, id: \.self) { inches in
                        Text("\(inches)\"").tag(inches)
                    }
                }
                .pickerStyle(.menu)
            }

            HStack {
                Text("Weight")
                Spacer()
                TextField("lbs", text: $weight)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
            }
        }
    }

    // MARK: - Stats Section

    private var statsSection: some View {
        Section("Season Stats") {
            HStack {
                Text("PPG")
                Spacer()
                TextField("Points per game", text: $ppg)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
            }

            HStack {
                Text("APG")
                Spacer()
                TextField("Assists per game", text: $apg)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
            }

            HStack {
                Text("RPG")
                Spacer()
                TextField("Rebounds per game", text: $rpg)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
            }

            HStack {
                Text("FG%")
                Spacer()
                TextField("Field goal %", text: $fgPercent)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
            }
        }
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

                Text("Profile Updated!")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            .padding(40)
            .background(Color(.systemBackground))
            .cornerRadius(20)
        }
    }

    // MARK: - Validation

    private var isValidInput: Bool {
        guard !name.isEmpty, selectedPosition != nil else { return false }

        if !weight.isEmpty, let weightValue = Int(weight) {
            guard Validators.isValidWeight(weightValue) else { return false }
        } else if !weight.isEmpty {
            return false
        }

        if !ppg.isEmpty, Double(ppg) == nil { return false }
        if !apg.isEmpty, Double(apg) == nil { return false }
        if !rpg.isEmpty, Double(rpg) == nil { return false }

        if !fgPercent.isEmpty, let fgValue = Double(fgPercent) {
            guard Validators.isValidStatPercentage(fgValue) else { return false }
        } else if !fgPercent.isEmpty {
            return false
        }

        return true
    }

    // MARK: - Save Profile

    private func saveProfile() {
        Task {
            guard let profile = viewModel.profile else { return }

            // Update profile
            var updatedProfile = profile
            updatedProfile.name = name
            updatedProfile.age = Int(age)
            updatedProfile.position = selectedPosition
            updatedProfile.targetDivision = selectedDivision
            updatedProfile.updatedAt = Date()

            await viewModel.updateProfile(updatedProfile)

            if viewModel.errorMessage != nil {
                return
            }

            // Update measurables
            if !weight.isEmpty, let weightValue = Int(weight) {
                let totalHeightInches = (heightFeet * 12) + heightInches
                let measurables = UserMeasurables(
                    id: viewModel.measurables?.id ?? UUID(),
                    userId: profile.userId,
                    heightInches: totalHeightInches,
                    weightLbs: weightValue,
                    wingspanInches: viewModel.measurables?.wingspanInches,
                    verticalJumpInches: viewModel.measurables?.verticalJumpInches,
                    updatedAt: Date()
                )

                await viewModel.updateMeasurables(measurables)

                if viewModel.errorMessage != nil {
                    return
                }
            }

            // Update stats
            let stats = UserStats(
                id: viewModel.stats?.id ?? UUID(),
                userId: profile.userId,
                ppg: Double(ppg),
                rpg: Double(rpg),
                apg: Double(apg),
                fgPercent: Double(fgPercent),
                threePPercent: viewModel.stats?.threePPercent,
                updatedAt: Date()
            )

            await viewModel.updateStats(stats)

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
    let viewModel = ProfileViewModel()
    let profile = UserProfile(
        id: UUID(),
        userId: UUID(),
        name: "John Doe",
        age: 17,
        position: .pg,
        targetDivision: .d1,
        createdAt: Date(),
        updatedAt: Date()
    )
    let measurables = UserMeasurables(
        id: UUID(),
        userId: UUID(),
        heightInches: 73,
        weightLbs: 180,
        wingspanInches: nil,
        verticalJumpInches: nil,
        updatedAt: Date()
    )
    let stats = UserStats(
        id: UUID(),
        userId: UUID(),
        ppg: 15.5,
        rpg: 4.2,
        apg: 6.8,
        fgPercent: 45.5,
        threePPercent: nil,
        updatedAt: Date()
    )

    return ProfileEditView(
        viewModel: viewModel,
        profile: profile,
        measurables: measurables,
        stats: stats
    ) {
        print("Profile updated")
    }
}
