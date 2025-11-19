import Foundation

struct Config {
    // API keys are stored in Secrets.plist (not committed to git)
    private static let secrets: [String: Any] = {
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: Any] else {
            print("⚠️ WARNING: Secrets.plist not found or invalid")
            return [:]
        }
        return dict
    }()

    static let supabaseURL = secrets["SUPABASE_URL"] as? String ?? ""
    static let supabaseKey = secrets["SUPABASE_KEY"] as? String ?? ""
    static let apiBaseURL = secrets["API_BASE_URL"] as? String ?? "http://localhost:5000"
    static let youtubeAPIKey = secrets["YOUTUBE_API_KEY"] as? String ?? ""

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
