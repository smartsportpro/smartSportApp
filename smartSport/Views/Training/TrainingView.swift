//
//  TrainingView.swift
//  smartSport
//
//  Created by Claude Code on 2025-11-20.
//

import SwiftUI

struct TrainingView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Spacer()

                // Icon
                Image(systemName: "figure.basketball")
                    .font(.system(size: 80))
                    .foregroundColor(.orange)
                    .padding(.bottom, 10)

                // Title
                Text("Training Plans")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                // Description
                Text("Get personalized drill recommendations based on your stats and weaknesses")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 40)

                // Drill Categories
                VStack(alignment: .leading, spacing: 16) {
                    drillCategory(icon: "basketball.fill", name: "Shooting Drills")
                    drillCategory(icon: "hand.raised.fill", name: "Ball-Handling")
                    drillCategory(icon: "shield.fill", name: "Defense")
                    drillCategory(icon: "figure.run", name: "Conditioning")
                    drillCategory(icon: "sportscourt.fill", name: "Passing & Court Vision")
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.secondarySystemBackground))
                )
                .padding(.horizontal, 40)

                // Coming Soon Button
                Button {
                    // Phase 3 implementation
                } label: {
                    HStack {
                        Image(systemName: "sparkles")
                        Text("Coming in Phase 3")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange.opacity(0.3))
                    .foregroundColor(.orange)
                    .cornerRadius(12)
                }
                .disabled(true)
                .padding(.horizontal, 40)

                Spacer()
            }
            .navigationTitle("Training")
        }
    }

    private func drillCategory(icon: String, name: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.orange)
                .frame(width: 24)
            Text(name)
                .font(.subheadline)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.caption)
        }
    }
}

#Preview {
    TrainingView()
}
