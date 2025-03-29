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
    @State private var location: String = ""
    @State private var isActivityNameValid: Bool = true
    @State private var isLocationValid: Bool = true
    @State private var activityType: ActivityType = .activity
    @State private var mealType: MealType = .breakfast

    @Environment(\.presentationMode) var presentationMode

    var activityToEdit: Activity?

    private var isEditing: Bool {
        return activityToEdit != nil
    }

    var isFormValid: Bool {
        !activityName.isEmpty && !location.isEmpty
    }

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    typeSection()
                    activityNameSection()
                    descriptionSection()
                    dateSection()
                    locationSection()
                    if activityType == .restaurant {
                        mealTypeSection()
                    }
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
        .onChange(of: activityToEdit) { _, activity in
            if let activity = activity {
                loadActivityData(activity)
            }
        }
    }

    // MARK: - Form Sections

    private func typeSection() -> some View {
        Section(header: Text("Type")) {
            Picker("Select type", selection: $activityType) {
                ForEach(ActivityType.allCases, id: \.self) { type in
                    Text(typeDisplayName(type)).tag(type)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
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
            DatePicker(
                "Select Date",
                selection: $activityDate,
                in: trip.startDate ... trip.endDate,
                displayedComponents: .date
            )
        }
    }

    private func locationSection() -> some View {
        Section(header: Text("Location")) {
            TextField("Enter location", text: $location)
                .onChange(of: location) { _, newValue in
                    isLocationValid = !newValue.isEmpty
                }

            if !isLocationValid && location.isEmpty {
                Text("Location cannot be empty")
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
    }

    private func mealTypeSection() -> some View {
        Section(header: Text("Meal Type")) {
            Picker("Select meal type", selection: $mealType) {
                ForEach(MealType.allCases, id: \.self) { type in
                    Text(mealTypeDisplayName(type)).tag(type)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }

    // MARK: - Save & Load

    private func saveActivity() {
        if isFormValid {
            let baseActivity = Activity(
                id: activityToEdit?.id ?? UUID(),
                name: activityName,
                description: activityDescription,
                date: activityDate,
                location: location,
                type: activityType,
                mealType: activityType == .restaurant ? mealType : nil
            )

            if isEditing {
                viewModel.editActivity(from: trip, activity: baseActivity)
            } else {
                viewModel.addActivity(to: trip, activity: baseActivity)
            }

            presentationMode.wrappedValue.dismiss()
        }
    }

    private func loadActivityData(_ activity: Activity) {
        activityName = activity.name
        activityDescription = activity.description
        activityDate = activity.date
        location = activity.location
        activityType = activity.type
        mealType = activity.mealType ?? .breakfast
    }

    // MARK: - Display Helpers

    private func typeDisplayName(_ type: ActivityType) -> String {
        switch type {
        case .activity: return "Activity"
        case .accommodation: return "Accommodation"
        case .restaurant: return "Restaurant"
        }
    }

    private func mealTypeDisplayName(_ type: MealType) -> String {
        switch type {
        case .breakfast: return "Breakfast"
        case .lunch: return "Lunch"
        case .dinner: return "Dinner"
        case .multiple: return "Multiple"
        }
    }
}
