import SwiftUI
import WidgetKit
import ActivityKit

// MARK: - Live Activity Widget
public struct TripLiveActivityWidget: Widget {
    public init() {}

    public var body: some WidgetConfiguration {
        ActivityConfiguration(for: TripActivityAttributes.self) { context in
            // Lock Screen / Banner UI
            HStack(spacing: 16) {
                Text(context.state.countryFlag)
                    .font(.system(size: 42))

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(context.state.cityName)
                            .font(.headline.bold())
                        Spacer()
                        Text("Día \(context.state.dayNumber) de \(context.state.totalDays)")
                            .font(.caption.bold())
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.accentColor.opacity(0.15))
                            .clipShape(Capsule())
                    }

                    if let title = context.state.latestChronicleTitle {
                        Text("Última: \(title)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    } else {
                        Text("\(context.state.logsCountToday) crónicas registradas")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
            .activityBackgroundTint(Color.black.opacity(0.85))
            .activitySystemActionForegroundColor(Color.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 6) {
                        Text(context.state.countryFlag)
                            .font(.title2)
                        Text(context.state.cityName)
                            .font(.headline.bold())
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Día \(context.state.dayNumber)/\(context.state.totalDays)")
                        .font(.subheadline.bold())
                        .foregroundStyle(Color.accentColor)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Image(systemName: "pencil.and.list.clipboard")
                            .foregroundStyle(.secondary)
                        Text(context.state.latestChronicleTitle ?? "\(context.state.logsCountToday) notas hoy")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                        Spacer()
                    }
                    .padding(.top, 4)
                }
            } compactLeading: {
                HStack(spacing: 3) {
                    Text(context.state.countryFlag)
                    Text(context.state.cityName.prefix(4))
                        .font(.caption2.bold())
                }
            } compactTrailing: {
                Text("D\(context.state.dayNumber)")
                    .font(.caption2.bold())
                    .foregroundStyle(Color.accentColor)
            } minimal: {
                Text(context.state.countryFlag)
            }
        }
    }
}

// MARK: - Countdown Timeline Entry
public struct TripCountdownEntry: TimelineEntry {
    public let date: Date
    public let destination: String
    public let flag: String
    public let daysRemaining: Int
    public let isUnderway: Bool

    public init(date: Date = Date(), destination: String, flag: String, daysRemaining: Int, isUnderway: Bool) {
        self.date = date
        self.destination = destination
        self.flag = flag
        self.daysRemaining = daysRemaining
        self.isUnderway = isUnderway
    }
}

// MARK: - Countdown Timeline Provider
public struct TripCountdownProvider: TimelineProvider {
    public init() {}

    public func placeholder(in context: Context) -> TripCountdownEntry {
        TripCountdownEntry(destination: "Kioto, Japón", flag: "🇯🇵", daysRemaining: 14, isUnderway: false)
    }

    public func getSnapshot(in context: Context, completion: @escaping (TripCountdownEntry) -> Void) {
        completion(TripCountdownEntry(destination: "Kioto, Japón", flag: "🇯🇵", daysRemaining: 14, isUnderway: false))
    }

    public func getTimeline(in context: Context, completion: @escaping (Timeline<TripCountdownEntry>) -> Void) {
        let entry = TripCountdownEntry(destination: "Kioto, Japón", flag: "🇯🇵", daysRemaining: 14, isUnderway: false)
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 4, to: Date()) ?? Date()
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
}

// MARK: - Countdown Widget View
public struct TripCountdownWidgetView: View {
    public let entry: TripCountdownEntry

    public init(entry: TripCountdownEntry) {
        self.entry = entry
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(entry.flag)
                    .font(.title)
                Spacer()
                Text("Bitácora")
                    .font(.caption2.bold())
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if entry.isUnderway {
                Text("¡En ruta!")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(.green)
                Text(entry.destination)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            } else {
                Text("\(entry.daysRemaining)")
                    .font(.system(size: 38, weight: .black, design: .rounded))
                    .foregroundStyle(Color.accentColor)
                Text("días para \(entry.destination)")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .containerBackground(for: .widget) {
            Color(.systemBackground)
        }
    }
}

// MARK: - Countdown Widget
public struct TripCountdownWidget: Widget {
    public let kind: String = "TripCountdownWidget"

    public init() {}

    public var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TripCountdownProvider()) { entry in
            TripCountdownWidgetView(entry: entry)
        }
        .configurationDisplayName("Cuenta Atrás de Viaje")
        .description("Muestra los días que faltan para vuestra próxima aventura en pareja.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
