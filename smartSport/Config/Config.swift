import Foundation

struct Config {
    // API keys are stored in Secrets.xcconfig (not committed to git)
    // Values are read from Info.plist which pulls from the xcconfig file
    static let supabaseURL = Bundle.main.infoDictionary?["SUPABASE_URL"] as? String ?? "https://your-project.supabase.co"
    static let supabaseKey = Bundle.main.infoDictionary?["SUPABASE_KEY"] as? String ?? "your-supabase-anon-key"

    // Backend API URL
    static let apiBaseURL = Bundle.main.infoDictionary?["API_BASE_URL"] as? String ?? "http://localhost:5000"

    // YouTube Data API v3 key
    static let youtubeAPIKey = Bundle.main.infoDictionary?["YOUTUBE_API_KEY"] as? String ?? "your-youtube-api-key"

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
