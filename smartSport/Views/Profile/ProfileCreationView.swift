import SwiftUI

struct ProfileCreationView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var currentStep = 1
    @State private var showSuccessMessage = false
    @State private var showErrorAlert = false

    // Step 1: Basic Info
    @State private var name = ""
    @State private var age = ""
    @State private var selectedPosition: Position?

    // Step 2: Measurables
    @State private var heightFeet = 5
    @State private var heightInches = 10
    @State private var weight = ""

    // Step 3: Current Stats
    @State private var ppg = ""
    @State private var apg = ""
    @State private var rpg = ""
    @State private var fgPercent = ""

    // Step 4: Target Division
    @State private var selectedDivision: Division?

    let userId: UUID
    var onComplete: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                progressBar

                ScrollView {
                    VStack(spacing: 24) {
                        stepContent
                    }
                    .padding()
                }

                navigationButtons
            }
            .navigationTitle("Create Profile")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Error", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "An error occurred")
            }
            .overlay {
                if showSuccessMessage {
                    successOverlay
                }
            }
        }
    }

    // MARK: - Progress Bar

    private var progressBar: some View {
        VStack(spacing: 8) {
            HStack(spacing: 4) {
                ForEach(1...4, id: \.self) { step in
                    Rectangle()
                        .fill(step <= currentStep ? Color.blue : Color.gray.opacity(0.3))
                        .frame(height: 4)
                }
            }

            Text("Step \(currentStep) of 4")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
    }

    // MARK: - Step Content

    @ViewBuilder
    private var stepContent: some View {
        switch currentStep {
        case 1:
            step1BasicInfo
        case 2:
            step2Measurables
        case 3:
            step3Stats
        case 4:
            step4Division
        default:
            EmptyView()
        }
    }

    // MARK: - Step 1: Basic Info

    private var step1BasicInfo: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Let's start with the basics")
                .font(.title2)
                .fontWeight(.bold)

            VStack(alignment: .leading, spacing: 8) {
                Text("Name")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                TextField("Enter your full name", text: $name)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.words)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Age (Optional)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                TextField("Enter your age", text: $age)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Position")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Picker("Select Position", selection: $selectedPosition) {
                    Text("Select position").tag(nil as Position?)
                    ForEach(Position.allCases, id: \.self) { position in
                        Text(position.fullName).tag(position as Position?)
                    }
                }
                .pickerStyle(.menu)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    // MARK: - Step 2: Measurables

    private var step2Measurables: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Your measurements")
                .font(.title2)
                .fontWeight(.bold)

            VStack(alignment: .leading, spacing: 8) {
                Text("Height")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                HStack(spacing: 16) {
                    Picker("Feet", selection: $heightFeet) {
                        ForEach(4...7, id: \.self) { feet in
                            Text("\(feet) ft").tag(feet)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 100)

                    Picker("Inches", selection: $heightInches) {
                        ForEach(0...11, id: \.self) { inches in
                            Text("\(inches) in").tag(inches)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 100)
                }
                .frame(height: 150)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Weight (lbs)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                TextField("Enter weight", text: $weight)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
            }
        }
    }

    // MARK: - Step 3: Current Stats

    private var step3Stats: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Your current season stats")
                .font(.title2)
                .fontWeight(.bold)

            Text("Enter your high school senior year statistics")
                .font(.subheadline)
                .foregroundColor(.gray)

            VStack(alignment: .leading, spacing: 8) {
                Text("Points Per Game (PPG)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                TextField("e.g., 15.5", text: $ppg)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.decimalPad)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Assists Per Game (APG)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                TextField("e.g., 4.2", text: $apg)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.decimalPad)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Rebounds Per Game (RPG)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                TextField("e.g., 6.8", text: $rpg)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.decimalPad)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Field Goal Percentage (FG%)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                TextField("e.g., 45.5", text: $fgPercent)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.decimalPad)
            }
        }
    }

    // MARK: - Step 4: Target Division

    private var step4Division: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Your college goal")
                .font(.title2)
                .fontWeight(.bold)

            Text("Which division are you targeting?")
                .font(.subheadline)
                .foregroundColor(.gray)

            VStack(spacing: 12) {
                ForEach(Division.allCases, id: \.self) { division in
                    Button {
                        selectedDivision = division
                    } label: {
                        HStack {
                            Text(division.rawValue)
                                .font(.headline)
                            Spacer()
                            if selectedDivision == division {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selectedDivision == division ? Color.blue : Color.gray.opacity(0.3), lineWidth: 2)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Navigation Buttons

    private var navigationButtons: some View {
        VStack(spacing: 12) {
            if currentStep < 4 {
                Button {
                    withAnimation {
                        currentStep += 1
                    }
                } label: {
                    Text("Next")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(canProceedToNextStep ? Color.blue : Color.gray)
                        .cornerRadius(12)
                }
                .disabled(!canProceedToNextStep || viewModel.isLoading)
            } else {
                Button {
                    submitProfile()
                } label: {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        Text("Create Profile")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .background(canSubmit ? Color.blue : Color.gray)
                .cornerRadius(12)
                .disabled(!canSubmit || viewModel.isLoading)
            }

            if currentStep > 1 {
                Button {
                    withAnimation {
                        currentStep -= 1
                    }
                } label: {
                    Text("Back")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .disabled(viewModel.isLoading)
            }
        }
        .padding()
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

                Text("Profile Created!")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Let's find your matches")
                    .foregroundColor(.gray)
            }
            .padding(40)
            .background(Color.white)
            .cornerRadius(20)
        }
    }

    // MARK: - Validation

    private var canProceedToNextStep: Bool {
        switch currentStep {
        case 1:
            return !name.isEmpty && selectedPosition != nil
        case 2:
            guard let weightValue = Int(weight) else { return false }
            return Validators.isValidWeight(weightValue)
        case 3:
            guard let ppgValue = Double(ppg),
                  let apgValue = Double(apg),
                  let rpgValue = Double(rpg),
                  let fgValue = Double(fgPercent) else { return false }
            return ppgValue >= 0 && apgValue >= 0 && rpgValue >= 0 &&
                   Validators.isValidStatPercentage(fgValue)
        case 4:
            return selectedDivision != nil
        default:
            return false
        }
    }

    private var canSubmit: Bool {
        return canProceedToNextStep && currentStep == 4
    }

    // MARK: - Submit Profile

    private func submitProfile() {
        Task {
            // Step 1: Create profile with basic info
            let ageValue = Int(age)
            await viewModel.createProfile(
                userId: userId,
                name: name,
                age: ageValue,
                position: selectedPosition,
                targetDivision: selectedDivision
            )

            if viewModel.errorMessage != nil {
                showErrorAlert = true
                return
            }

            // Step 2: Update measurables
            let totalHeightInches = (heightFeet * 12) + heightInches
            let weightValue = Int(weight) ?? 0

            let measurables = UserMeasurables(
                id: UUID(),
                userId: userId,
                heightInches: totalHeightInches,
                weightLbs: weightValue,
                wingspanInches: nil,
                verticalJumpInches: nil,
                updatedAt: Date()
            )

            await viewModel.updateMeasurables(measurables)

            if viewModel.errorMessage != nil {
                showErrorAlert = true
                return
            }

            // Step 3: Update stats
            let stats = UserStats(
                id: UUID(),
                userId: userId,
                ppg: Double(ppg),
                rpg: Double(rpg),
                apg: Double(apg),
                fgPercent: Double(fgPercent),
                threePPercent: nil,
                updatedAt: Date()
            )

            await viewModel.updateStats(stats)

            if viewModel.errorMessage != nil {
                showErrorAlert = true
                return
            }

            // Success!
            showSuccessMessage = true

            // Wait 1.5 seconds then navigate
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            onComplete()
        }
    }
}

#Preview {
    ProfileCreationView(userId: UUID()) {
        print("Profile creation complete")
    }
}
