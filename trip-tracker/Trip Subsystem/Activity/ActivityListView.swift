//
//  ActivityListView.swift
//  trip-tracker
//
//  Created by Raymond King on 12.10.24.
//

import SwiftUI

struct ActivityListView: View {
    @Bindable var viewModel: TripViewModel
    var trip: Trip
    @State private var isShowingCreateActivity = false
    @State private var activityToEdit: Activity?

    @State private var searchText: String = ""
    @State private var isShowingDateFilter = false
    @State private var selectedDate: Date?

    @State private var isShowingDeleteConfirmation = false // State to show the delete confirmation modal
    @State private var activityToDelete: Activity? // State to track which activity to delete

    var body: some View {
        VStack {
            List {
                ForEach(filteredActivitiesByDate(), id: \.key) { date, activities in
                    Section(header: Text(formattedDate(date))) {
                        ForEach(activities) { activity in
                            ActivityCellView(activity: activity)
                                .listRowInsets(EdgeInsets())
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                                .swipeActions {
                                    Button("Edit") {
                                        activityToEdit = activity
                                        isShowingCreateActivity = true
                                    }
                                    .tint(.blue)

                                    Button("Delete", role: .destructive) {
                                        activityToDelete = activity // Set activity to be deleted
                                        isShowingDeleteConfirmation = true // Show confirmation modal
                                    }
                                }
                        }
                    }
                }
            }
        }
        .navigationTitle("Activities")
        .navigationBarItems(
            trailing: HStack {
                Button(action: {
                    isShowingDateFilter = true
                }) {
                    Image(systemName: "calendar")
                        .foregroundColor(selectedDate != nil ? .green : .blue)
                        .imageScale(.large)
                        .frame(width: 44, height: 44)
                }

                Button(action: {
                    activityToEdit = nil
                    isShowingCreateActivity = true
                }) {
                    Image(systemName: "plus")
                        .imageScale(.large)
                        .frame(width: 44, height: 44)
                }
            }
        )
        .searchable(text: $searchText, prompt: "Search activities")
        .sheet(isPresented: $isShowingCreateActivity) {
            CreateEditActivity(viewModel: viewModel, trip: trip, activityToEdit: activityToEdit)
        }
        .sheet(isPresented: $isShowingDateFilter) {
            dateFilterSheet
        }
        .alert(isPresented: $isShowingDeleteConfirmation) { // Alert for delete confirmation
            Alert(
                title: Text("Delete Activity"),
                message: Text("Are you sure you want to delete \"\(activityToDelete?.name ?? "")\"?"),
                primaryButton: .destructive(Text("Delete")) {
                    if let activity = activityToDelete {
                        viewModel.deleteActivity(from: trip, activity: activity) // Call delete method
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }

    private func filteredActivitiesByDate() -> [(key: Date, value: [Activity])] {
        let activities = trip.activities

        let filteredBySearch = activities.filter { activity in
            searchText.isEmpty || activity.name.localizedCaseInsensitiveContains(searchText)
        }

        let filteredByDate: [Activity]
        if let selectedDate = selectedDate {
            filteredByDate = filteredBySearch.filter { activity in
                Calendar.current.isDate(activity.date, inSameDayAs: selectedDate)
            }
        } else {
            filteredByDate = filteredBySearch
        }

        let grouped = Dictionary(grouping: filteredByDate) { activity -> Date in
            Calendar.current.startOfDay(for: activity.date)
        }

        return grouped.sorted { $0.key < $1.key }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    @ViewBuilder // Sheet for filtering activities based on their date
    private var dateFilterSheet: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "Select Date",
                    selection: Binding(
                        get: { selectedDate ?? Date() },
                        set: { newDate in selectedDate = newDate }
                    ),
                    in: trip.startDate ... trip.endDate,
                    displayedComponents: .date
                )
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding()

                Button("Clear Filter") {
                    selectedDate = nil
                }
                .padding()

                Spacer()
            }
            .navigationBarTitle("Filter by Date", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    isShowingDateFilter = false
                }
            )
        }
    }
}
