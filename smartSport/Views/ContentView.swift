//
//  ContentView.swift
//  smartSport
//
//  Main app content with TabView navigation
//

import SwiftUI

struct ContentView: View {
    // Store user ID from UserDefaults (set during login)
    @AppStorage("currentUserId") private var userIdString: String = ""
    @State private var selectedTab = 0

    // Compute userId from stored string
    private var userId: UUID {
        UUID(uuidString: userIdString) ?? UUID()
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(userId: userId, onFindMatch: {
                selectedTab = 1 // Switch to Match tab
            })
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            MatchView(userId: userId)
                .tabItem {
                    Label("Match", systemImage: "person.2.fill")
                }
                .tag(1)

            StatsView(userId: userId)
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }
                .tag(2)

            TrainingView()
                .tabItem {
                    Label("Training", systemImage: "figure.basketball")
                }
                .tag(3)

            ProfileView(userId: userId)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(4)
        }
        .tint(.primaryOrange) // Orange accent color for selected tab
    }
}

#Preview {
    ContentView()
}
