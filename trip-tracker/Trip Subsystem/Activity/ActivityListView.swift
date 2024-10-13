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
    @State private var selectedDate: Date? = nil

    var body: some View {
        VStack {
            // List with search and filter
            List {
                ForEach(filteredActivitiesByDate(), id: \.key) { date, activities in
                    Section(header: Text(formattedDate(date))) {
                        ForEach(activities) { activity in
                            ActivityCellView(activity: activity)
                                .swipeActions {
                                    Button("Edit") {
                                        activityToEdit = activity
                                        isShowingCreateActivity = true
                                    }
                                    .tint(.blue)

                                    Button("Delete", role: .destructive) {
                                        viewModel.deleteActivity(from: trip, activity: activity)
                                    }
                                }
                        }
                    }
                }
            }
            .listStyle(.plain)
        }
        .navigationTitle("Activities")
        .navigationBarItems(
            leading: Button(action: {
                isShowingDateFilter = true
            }) {
                Image(systemName: "calendar")
            },
            trailing: Button(action: {
                activityToEdit = nil
                isShowingCreateActivity = true
            }) {
                Image(systemName: "plus")
            }
        )
        .searchable(text: $searchText, prompt: "Search activities")
        .sheet(isPresented: $isShowingCreateActivity) {
            CreateEditActivity(viewModel: viewModel, trip: trip, activityToEdit: activityToEdit)
        }
        .sheet(isPresented: $isShowingDateFilter) {
            dateFilterSheet
        }
    }

    // Filtered activities based on search and selected date
    private func filteredActivitiesByDate() -> [(key: Date, value: [Activity])] {
        let activities = trip.activities ?? []

        // Apply search filter
        let filteredBySearch = activities.filter { activity in
            searchText.isEmpty || activity.name.localizedCaseInsensitiveContains(searchText)
        }

        // Apply date filter only if selectedDate is not nil
        let filteredByDate: [Activity]
        if let selectedDate = selectedDate {
            filteredByDate = filteredBySearch.filter { activity in
                Calendar.current.isDate(activity.date, inSameDayAs: selectedDate)
            }
        } else {
            // No date filter applied, show all filtered by search
            filteredByDate = filteredBySearch
        }

        // Group activities by date and sort them
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

    // Date Filter Sheet
    @ViewBuilder
    private var dateFilterSheet: some View {
        NavigationView {
            VStack {
                DatePicker("Select Date", selection: Binding(
                    get: { selectedDate ?? Date() },  // Use current date if `selectedDate` is nil
                    set: { newDate in selectedDate = newDate }  // Update `selectedDate` with new date
                ), displayedComponents: .date)
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

