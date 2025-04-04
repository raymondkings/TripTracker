//
//  AcitivityCellView.swift
//  trip-tracker
//
//  Created by Raymond King on 12.10.24.

import SwiftUI

struct ActivityCellView: View {
    var activity: Activity
    @State private var isActive = false
    @State private var isExpanded = false

    var body: some View {
        ZStack {
            NavigationLink(destination: ActivityMapDetailView(activity: activity), isActive: $isActive) {
                EmptyView()
            }
            .hidden()

            HStack(spacing: 0) {
                ZStack {
                    Rectangle()
                        .fill(colorForType(activity.type).opacity(0.15))
                        .frame(width: 80)
                        .cornerRadius(12, corners: [.topLeft, .bottomLeft])
                    VStack {
                        Image(systemName: iconForType(activity.type))
                            .foregroundColor(colorForType(activity.type))
                            .frame(width: 30)
                            .padding(.trailing, 4)
                        if let badge = badgeText(for: activity) {
                            Text(badge)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .foregroundColor(.orange)
                        }
                    }
                }

                // Right content section
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(activity.name)
                                .font(Font.custom("Onest-Bold", size: 18))
                                .foregroundColor(.primary)

                            Spacer()

                            Button(action: {
                                withAnimation {
                                    isExpanded.toggle()
                                }
                            }) {
                                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                    .foregroundColor(.gray)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }

                        if isExpanded {
                            Text(activity.description)
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            Text(activity.location)
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)

                    Spacer()
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12, corners: [.topRight, .bottomRight])
            }
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

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
