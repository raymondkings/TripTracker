//
//  SectionDropDelegate.swift
//  trip-tracker
//
//  Created by Raymond King on 07.04.25.
//
import SwiftUI
import UniformTypeIdentifiers

struct SectionDropDelegate: DropDelegate {
    let sectionDate: Date
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
                   let draggedIndex = activities.firstIndex(where: { $0.id == uuid }) {
                    var dragged = activities.remove(at: draggedIndex)
                    dragged.date = sectionDate

                    let insertIndex = activities.lastIndex(where: {
                        Calendar.current.isDate($0.date, inSameDayAs: sectionDate)
                    })?.advanced(by: 1) ?? activities.endIndex

                    activities.insert(dragged, at: insertIndex)
                    viewModel.updateTripActivities(activities, for: trip)
                }
            }
        }

        return true
    }
}
