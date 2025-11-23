//
//  MatchView.swift
//  smartSport
//
//  Created by Claude Code on 2025-11-20.
//

import SwiftUI

struct MatchView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Spacer()

                // Icon
                Image(systemName: "person.2.crop.square.stack")
                    .font(.system(size: 80))
                    .foregroundColor(.orange)
                    .padding(.bottom, 10)

                // Title
                Text("Player Matching")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                // Description
                Text("Find college players who had similar high school stats to yours")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 40)

                // Features List
                VStack(alignment: .leading, spacing: 16) {
                    featureRow(icon: "chart.bar.fill", text: "K-NN algorithm matches your stats")
                    featureRow(icon: "graduationcap.fill", text: "Filter by target division (D1, D2, D3)")
                    featureRow(icon: "star.fill", text: "See top 5 most similar players")
                    featureRow(icon: "person.fill", text: "Compare stats side-by-side")
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.secondarySystemBackground))
                )
                .padding(.horizontal, 40)

                // Coming Soon Button
                Button {
                    // Phase 2 implementation
                } label: {
                    HStack {
                        Image(systemName: "sparkles")
                        Text("Coming in Phase 2")
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
            .navigationTitle("Match")
        }
    }

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.orange)
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
            Spacer()
        }
    }
}

#Preview {
    MatchView()
}
