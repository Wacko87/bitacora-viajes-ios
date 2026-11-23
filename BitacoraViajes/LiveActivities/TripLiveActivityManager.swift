import Foundation
import ActivityKit

public final class TripLiveActivityManager: Sendable {
    public static let shared = TripLiveActivityManager()

    private init() {}

    public var isActivityActive: Bool {
        !Activity<TripActivityAttributes>.activities.isEmpty
    }

    public func startActivity(
        title: String,
        countryCode: String,
        city: String?,
        durationInDays: Int,
        logsCount: Int,
        latestLogTitle: String?
    ) async {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        // End any existing activities first
        await endAllActivities()

        let attributes = TripActivityAttributes(
            tripTitle: title,
            destinationCountry: countryCode
        )

        let initialContentState = TripActivityAttributes.ContentState(
            cityName: city ?? title,
            countryFlag: CountryCatalog.find(code: countryCode).flag,
            dayNumber: 1,
            totalDays: durationInDays,
            logsCountToday: logsCount,
            latestChronicleTitle: latestLogTitle
        )

        let activityContent = ActivityContent(state: initialContentState, staleDate: nil)

        do {
            _ = try Activity.request(
                attributes: attributes,
                content: activityContent,
                pushType: nil
            )
        } catch {
            print("Failed to start Trip Live Activity: \(error.localizedDescription)")
        }
    }

    public func updateActivity(
        title: String,
        countryCode: String,
        city: String?,
        dayNumber: Int,
        totalDays: Int,
        logsCount: Int,
        latestLogTitle: String?
    ) async {
        guard let activity = Activity<TripActivityAttributes>.activities.first else { return }

        let updatedContentState = TripActivityAttributes.ContentState(
            cityName: city ?? title,
            countryFlag: CountryCatalog.find(code: countryCode).flag,
            dayNumber: dayNumber,
            totalDays: totalDays,
            logsCountToday: logsCount,
            latestChronicleTitle: latestLogTitle
        )

        let activityContent = ActivityContent(state: updatedContentState, staleDate: nil)
        await activity.update(activityContent)
    }

    public func endAllActivities() async {
        for activity in Activity<TripActivityAttributes>.activities {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
    }
}
