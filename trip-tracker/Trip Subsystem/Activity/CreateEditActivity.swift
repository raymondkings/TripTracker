//
//  CreateEditActivity.swift
//  trip-tracker
//
//  Created by Raymond King on 12.10.24.
//
import SwiftUI

struct CreateEditActivity: View {
    @Bindable var viewModel: TripViewModel
    var trip: Trip

    @State private var activityName: String = ""
    @State private var activityDescription: String = ""
    @State private var activityDate = Date()
    @State private var latitude: String = ""
    @State private var longitude: String = ""
    @State private var isActivityNameValid: Bool = true

    @Environment(\.presentationMode) var presentationMode

    var activityToEdit: Activity?

    private var isEditing: Bool {
        return activityToEdit != nil
    }

    var isFormValid: Bool {
        !activityName.isEmpty &&
            !latitude.isEmpty &&
            !longitude.isEmpty &&
            Double(latitude) != nil &&
            Double(longitude) != nil
    }

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    activityNameSection()
                    descriptionSection()
                    dateSection()
                    coordinatesSection()
                }
            }
            .navigationBarTitle(isEditing ? "Edit Activity" : "Create Activity", displayMode: .inline)
            .navigationBarItems(
                leading: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Back")
                },
                trailing: Button(action: saveActivity) {
                    Text(isEditing ? "Save" : "Create")
                }
                .disabled(!isFormValid)
            )
        }
        .onAppear {
            if let activity = activityToEdit {
                loadActivityData(activity)
            }
        }
    }

    private func activityNameSection() -> some View {
        Section(header: Text("Activity Name")) {
            TextField("Enter activity name", text: $activityName)
                .onChange(of: activityName) { _, newValue in
                    isActivityNameValid = !newValue.isEmpty
                }

            if !isActivityNameValid && activityName.isEmpty {
                Text("Activity name cannot be empty")
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
    }

    private func descriptionSection() -> some View {
        Section(header: Text("Description")) {
            TextField("Enter activity description", text: $activityDescription)
        }
    }

    private func dateSection() -> some View {
        Section(header: Text("Date")) {
            DatePicker("Select Date", selection: $activityDate, displayedComponents: .date)
        }
    }

    private func coordinatesSection() -> some View {
        Section(header: Text("Location Coordinates")) {
            TextField("Latitude", text: $latitude)
                .keyboardType(.decimalPad)
            TextField("Longitude", text: $longitude)
                .keyboardType(.decimalPad)

            if (Double(latitude) == nil || Double(longitude) == nil) && !latitude.isEmpty && !longitude.isEmpty {
                Text("Invalid coordinates")
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
    }

    private func saveActivity() {
        if isFormValid {
            if let activityToEdit = activityToEdit {
                let updatedActivity = Activity(
                    id: activityToEdit.id,
                    name: activityName,
                    description: activityDescription,
                    date: activityDate,
                    latitude: Double(latitude) ?? 0,
                    longitude: Double(longitude) ?? 0
                )
                viewModel.editActivity(from: trip, activity: updatedActivity)
            } else {
                let newActivity = Activity(
                    id: UUID(),
                    name: activityName,
                    description: activityDescription,
                    date: activityDate,
                    latitude: Double(latitude) ?? 0,
                    longitude: Double(longitude) ?? 0
                )
                viewModel.addActivity(to: trip, activity: newActivity)
            }
            presentationMode.wrappedValue.dismiss()
        }
    }

    private func loadActivityData(_ activity: Activity) {
        activityName = activity.name
        activityDescription = activity.description
        activityDate = activity.date
        latitude = String(activity.latitude)
        longitude = String(activity.longitude)
    }
}
