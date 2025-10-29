import Foundation

struct Config {
    // TODO: Replace these placeholder values with actual API keys from Supabase dashboard
    // Get your Supabase URL and anon key from: https://app.supabase.com/project/_/settings/api
    static let supabaseURL = ProcessInfo.processInfo.environment["SUPABASE_URL"] ?? "PLACEHOLDER-https://your-project.supabase.co"
    static let supabaseKey = ProcessInfo.processInfo.environment["SUPABASE_KEY"] ?? "PLACEHOLDER-your-supabase-anon-key"

    // TODO: Update this to your backend API URL (default is localhost for development)
    static let apiBaseURL = ProcessInfo.processInfo.environment["API_BASE_URL"] ?? "http://localhost:5000"

    // TODO: Replace with actual YouTube Data API v3 key
    // Get your API key from: https://console.cloud.google.com/apis/credentials
    static let youtubeAPIKey = ProcessInfo.processInfo.environment["YOUTUBE_API_KEY"] ?? "PLACEHOLDER-your-youtube-api-key"

    struct App {
        static let name = "SmartSport"
        static let version = "1.0.0"
        static let minIOSVersion = "16.0"
    }

    struct Features {
        static let enableVideoSearch = true
        static let enableTrainingPlans = true
        static let enableStatsTracking = true
    }

    struct UI {
        static let primaryColor = "Basketball Orange"
        static let secondaryColor = "Navy Blue"
        static let accentColor = "Success Green"
    }
}
