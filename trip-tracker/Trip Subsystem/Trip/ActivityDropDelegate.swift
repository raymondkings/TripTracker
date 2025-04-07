//
//  ActivityDropDelegate.swift
//  trip-tracker
//
//  Created by Raymond King on 07.04.25.
//
import SwiftUI
import UniformTypeIdentifiers

struct ActivityDropDelegate: DropDelegate {
    let targetActivity: Activity
    @Binding var activities: [Activity]
    var trip: Trip
    var viewModel: TripViewModel

    func performDrop(info: DropInfo) -> Bool {
        guard let item = info.itemProviders(for: [.text]).first else { return false }

        item.loadItem(forTypeIdentifier: UTType.plainText.identifier, options: nil) { data, _ in
            DispatchQueue.main.async {
                if let data = data as? Data,
                   let idString = String(data: data, encoding: .utf8),
                   let uuid = UUID(uuidString: idString),
                   let draggedIndex = activities.firstIndex(where: { $0.id == uuid }),
                   let targetIndex = activities.firstIndex(of: targetActivity) {
                    var dragged = activities[draggedIndex]
                    dragged.date = Calendar.current.startOfDay(for: targetActivity.date)

                    activities.remove(at: draggedIndex)
                    activities.insert(dragged, at: targetIndex)

                    viewModel.updateTripActivities(activities, for: trip)
                }
            }
        }
        print("Drop delegate triggered for: \(targetActivity.name)")

        return true
    }
}
