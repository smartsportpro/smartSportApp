//
//  TrainingView.swift
//  smartSport
//
//  Phase 3: Training Plan Recommendations
//

import SwiftUI

struct TrainingView: View {
    @StateObject private var viewModel = TrainingViewModel()
    @State private var selectedDrill: TrainingDrill?
    @Environment(\.openURL) private var openURL

    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading {
                    loadingView
                } else if let errorMessage = viewModel.errorMessage {
                    errorView(message: errorMessage)
                } else if viewModel.recommendedDrills.isEmpty {
                    emptyStateView
                } else {
                    drillListView
                }
            }
            .navigationTitle("Training Plan")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selectedDrill) { drill in
                DrillDetailSheet(drill: drill)
            }
        }
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Creating your personalized plan...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }

    // MARK: - Empty State View

    private var emptyStateView: some View {
        ScrollView {
            VStack(spacing: 30) {
                Spacer()
                    .frame(height: 40)

                // Icon
                Image(systemName: "figure.basketball")
                    .font(.system(size: 80))
                    .foregroundColor(.orange)
                    .padding(.bottom, 10)

                // Title
                Text("Get Your Training Plan")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                // Description
                Text("Get 5-7 personalized drill recommendations based on your stats and weaknesses")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 40)

                // Drill Categories Preview
                VStack(alignment: .leading, spacing: 16) {
                    drillCategory(icon: "basketball.fill", name: "Shooting", color: .orange)
                    drillCategory(icon: "hand.raised.fill", name: "Ball-Handling", color: .blue)
                    drillCategory(icon: "shield.fill", name: "Defense", color: .red)
                    drillCategory(icon: "figure.run", name: "Conditioning", color: .green)
                    drillCategory(icon: "sportscourt.fill", name: "Passing", color: .purple)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.secondarySystemBackground))
                )
                .padding(.horizontal, 40)

                // Get Training Plan Button
                Button {
                    Task {
                        await viewModel.loadRecommendationsForCurrentUser()
                    }
                } label: {
                    HStack {
                        Image(systemName: "sparkles")
                        Text("Get My Training Plan")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 40)

                Spacer()
            }
        }
    }

    // MARK: - Drill List View

    private var drillListView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Generic Plan Banner (if applicable)
                if viewModel.isGenericPlan {
                    genericPlanBanner
                }

                // Header
                VStack(spacing: 8) {
                    Text(viewModel.isGenericPlan ? "Your Training Plan" : "Your Personalized Plan")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("\(viewModel.recommendedDrills.count) drills" + (viewModel.isGenericPlan ? " based on your position" : " tailored to your stats"))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)

                // Drill Cards
                ForEach(viewModel.recommendedDrills) { drill in
                    DrillCard(drill: drill)
                        .onTapGesture {
                            selectedDrill = drill
                        }
                }

                // Refresh Button
                Button {
                    Task {
                        await viewModel.refreshRecommendations()
                    }
                } label: {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Refresh Plan")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .foregroundColor(.orange)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.top, 10)
            }
            .padding()
        }
    }

    // MARK: - Generic Plan Banner

    private var genericPlanBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "info.circle.fill")
                .foregroundColor(.orange)
                .font(.title2)

            VStack(alignment: .leading, spacing: 4) {
                Text("Generic Training Plan")
                    .font(.headline)
                    .foregroundColor(.primary)

                Text("Add your game stats for personalized recommendations!")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.orange.opacity(0.15))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal)
    }

    // MARK: - Error View

    private func errorView(message: String) -> some View {
        VStack(spacing: 20) {
            Spacer()

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
                    await viewModel.loadRecommendationsForCurrentUser()
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

            Spacer()
        }
    }

    // MARK: - Helper Views

    private func drillCategory(icon: String, name: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            Text(name)
                .font(.subheadline)
            Spacer()
        }
    }
}

// MARK: - Drill Card Component

struct DrillCard: View {
    let drill: TrainingDrill
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(alignment: .top, spacing: 12) {
                // Category Icon
                categoryIcon

                // Drill Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(drill.name)
                        .font(.headline)
                        .fontWeight(.bold)

                    HStack(spacing: 8) {
                        Label(drill.category.rawValue, systemImage: "tag.fill")
                            .font(.caption)
                            .foregroundColor(.orange)

                        if let difficulty = drill.difficulty {
                            Label(difficulty.rawValue, systemImage: "chart.bar.fill")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Spacer()

                // Expand/Collapse Icon
                Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle")
                    .foregroundColor(.orange)
                    .font(.title3)
            }

            // Why Recommended
            if let why = drill.whyRecommended {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)

                    Text(why)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .italic()
                }
                .padding(.top, 4)
            }

            // Expandable Description
            if isExpanded {
                Divider()

                Text(drill.description)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)

                if let positionFocus = drill.positionFocus {
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(.orange)
                        Text("Best for: \(positionFocus.rawValue)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 4)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isExpanded.toggle()
            }
        }
    }

    private var categoryIcon: some View {
        ZStack {
            Circle()
                .fill(categoryColor.opacity(0.2))
                .frame(width: 44, height: 44)

            Image(systemName: categoryIconName)
                .foregroundColor(categoryColor)
                .font(.system(size: 20))
        }
    }

    private var categoryColor: Color {
        switch drill.category {
        case .shooting: return .orange
        case .ballHandling: return .blue
        case .defense: return .red
        case .conditioning: return .green
        case .passing: return .purple
        }
    }

    private var categoryIconName: String {
        switch drill.category {
        case .shooting: return "basketball.fill"
        case .ballHandling: return "hand.raised.fill"
        case .defense: return "shield.fill"
        case .conditioning: return "figure.run"
        case .passing: return "sportscourt.fill"
        }
    }
}

// MARK: - Drill Detail Sheet

struct DrillDetailSheet: View {
    let drill: TrainingDrill
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Category Badge
                    HStack {
                        Label(drill.category.rawValue, systemImage: "tag.fill")
                            .font(.subheadline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.orange.opacity(0.2))
                            .foregroundColor(.orange)
                            .cornerRadius(8)

                        if let difficulty = drill.difficulty {
                            Label(difficulty.rawValue, systemImage: "chart.bar.fill")
                                .font(.subheadline)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color(.secondarySystemBackground))
                                .foregroundColor(.secondary)
                                .cornerRadius(8)
                        }

                        Spacer()
                    }

                    // Why Recommended
                    if let why = drill.whyRecommended {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Why This Drill?", systemImage: "lightbulb.fill")
                                .font(.headline)
                                .foregroundColor(.orange)

                            Text(why)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                    }

                    // Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Instructions")
                            .font(.headline)

                        Text(drill.description)
                            .font(.body)
                    }

                    // Position Focus
                    if let positionFocus = drill.positionFocus {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Best For")
                                .font(.headline)

                            HStack {
                                Image(systemName: "person.fill")
                                    .foregroundColor(.orange)
                                Text(positionFocus.rawValue)
                                    .font(.body)
                            }
                        }
                    }

                    // Video (if available)
                    if let videoUrl = drill.videoUrl, !videoUrl.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Video Demo")
                                .font(.headline)

                            Link(destination: URL(string: videoUrl)!) {
                                HStack {
                                    Image(systemName: "play.rectangle.fill")
                                    Text("Watch Tutorial")
                                    Spacer()
                                    Image(systemName: "arrow.up.right")
                                }
                                .padding()
                                .background(Color.orange.opacity(0.2))
                                .foregroundColor(.orange)
                                .cornerRadius(12)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle(drill.name)
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
}

#Preview {
    TrainingView()
}
