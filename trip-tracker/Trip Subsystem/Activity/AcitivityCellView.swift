//
//  AcitivityCellView.swift
//  trip-tracker
//
//  Created by Raymond King on 12.10.24.
import SwiftUI

struct ActivityCellView: View {
    var activity: Activity
    @Binding var selectedActivity: Activity?
    @State private var isExpanded = false

    var body: some View {
        HStack(spacing: 0) {
            // Left color block
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

            // Right content
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(activity.name)
                            .font(Font.custom("Onest-Bold", size: 18))
                            .foregroundColor(.primary)
                            .fixedSize(horizontal: false, vertical: true)

                        Spacer()

                        Button(action: {
                            isExpanded.toggle()
                        }) {
                            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                .foregroundColor(.gray)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }

                    if isExpanded {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(activity.description)
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            Text(activity.location)
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.25), value: isExpanded)
                    }
                }
                .padding(.vertical, 8)

                Spacer()
            }
            .padding()
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
        .padding(.vertical, 4)
        .onTapGesture {
            selectedActivity = activity
        }
    }

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
