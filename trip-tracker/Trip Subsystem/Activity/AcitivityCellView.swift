//
//  AcitivityCellView.swift
//  trip-tracker
//
//  Created by Raymond King on 12.10.24.

import SwiftUI

struct ActivityCellView: View {
    var activity: Activity
    @State private var isActive = false

    var body: some View {
        ZStack {
            NavigationLink(destination: ActivityMapDetailView(activity: activity), isActive: $isActive) {
                EmptyView()
            }
            .hidden()

            HStack {
                // Category Icon
                Image(systemName: iconForType(activity.type))
                    .foregroundColor(colorForType(activity.type))
                    .frame(width: 30)
                    .padding(.trailing, 4)

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(activity.name)
                            .font(Font.custom("Onest-Bold", size: 18))
                            .foregroundColor(.primary)

                        if let badge = badgeText(for: activity) {
                            Text(badge)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.2))
                                .foregroundColor(.blue)
                                .clipShape(Capsule())
                        }
                    }

                    Text(activity.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    HStack {
                        Image(systemName: "calendar")
                        Text("Date: \(activity.date, formatter: dateFormatter)")
                            .font(.footnote)
                            .foregroundColor(.secondary)

                        Spacer()

                        Image(systemName: "location")
                        Text(activity.location)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .padding(.trailing)
            }
            .padding()
            .background(backgroundForType(activity.type))
            .cornerRadius(12)
            .onTapGesture {
                isActive = true
            }
        }
    }

    // MARK: - Helper Styling

    private func iconForType(_ type: ActivityType) -> String {
        switch type {
        case .activity: return "figure.walk"
        case .accommodation: return "bed.double.fill"
        case .restaurant: return "fork.knife"
        }
    }

    private func colorForType(_ type: ActivityType) -> Color {
        switch type {
        case .activity: return .blue
        case .accommodation: return .purple
        case .restaurant: return .orange
        }
    }

    private func backgroundForType(_ type: ActivityType) -> Color {
        switch type {
        case .activity: return Color.blue.opacity(0.05)
        case .accommodation: return Color.purple.opacity(0.05)
        case .restaurant: return Color.orange.opacity(0.05)
        }
    }

    private func badgeText(for activity: Activity) -> String? {
        if activity.type == .restaurant, let meal = activity.mealType {
            return meal.rawValue.capitalized
        }
        return nil
    }

    // MARK: - Date Formatting

    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
}

//#Preview {
//    let testActivity = Activity(
//        id: UUID(),
//        name: "Dinner at Trattoria",
//        description: "Try local Italian food",
//        date: Date(),
//        location: "Rome",
//        type: .restaurant,
//        mealType: .dinner
//    )
//    ActivityCellView(activity: testActivity)
//}
