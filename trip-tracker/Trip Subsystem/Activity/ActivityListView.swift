//
//  ActivityListView.swift
//  trip-tracker
//
//  Created by Raymond King on 12.10.24.
//
import SwiftUI
import UniformTypeIdentifiers

struct ActivityListView: View {
    @Bindable var viewModel: TripViewModel
    var trip: Trip

    @State private var flatActivities: [Activity] = []
    @State private var isShowingCreateActivity = false
    @State private var activityToEdit: Activity?
    @State private var searchText: String = ""
    @State private var isShowingDateFilter = false
    @State private var selectedDate: Date?
    @State private var isShowingDeleteConfirmation = false
    @State private var activityToDelete: Activity?

    enum ActivityCategory: String, CaseIterable, Hashable {
        case activity = "🥳 Activities"
        case accommodation = "🏠 Accommodations"
        case restaurant = "🍴 Restaurants"
    }
    @State private var selectedCategories: Set<ActivityCategory> = []

    var body: some View {
        VStack {
            categoryChips

            List {
                ForEach(groupedActivities, id: \.date) { section in
                    Section(header: Text(formattedDate(section.date))) {
                        ForEach(section.activities) { activity in
                            activityCell(for: activity)
                                .onDrag {
                                    NSItemProvider(object: activity.id.uuidString as NSString)
                                }
                                .onDrop(of: [UTType.plainText.identifier], delegate: ActivityDropDelegate(
                                    targetActivity: activity,
                                    activities: $flatActivities,
                                    trip: trip,
                                    viewModel: viewModel
                                )
                                )
                        }
                    }
                    .onDrop(of: [UTType.plainText.identifier], delegate: SectionDropDelegate(
                        sectionDate: section.date,
                        activities: $flatActivities,
                        trip: trip,
                        viewModel: viewModel
                    ))
                }
            }
            .listStyle(PlainListStyle())
            .scrollContentBackground(.hidden)
            .environment(\.defaultMinListRowHeight, 0)
        }
        .navigationTitle("Activities")
        .navigationBarItems(trailing: HStack {
            NavigationLink(destination: ActivityMapOverviewView(trip: trip)) {
                Image(systemName: "map")
                    .imageScale(.large)
                    .frame(width: 44, height: 44)
            }
            Button {
                isShowingDateFilter = true
            } label: {
                Image(systemName: "calendar")
                    .foregroundColor(selectedDate != nil ? .green : .blue)
                    .imageScale(.large)
                    .frame(width: 44, height: 44)
            }
            Button {
                activityToEdit = nil
                isShowingCreateActivity = true
            } label: {
                Image(systemName: "plus")
                    .imageScale(.large)
                    .frame(width: 44, height: 44)
            }
        })
        .searchable(text: $searchText, prompt: "Search activities")
        .sheet(isPresented: $isShowingCreateActivity) {
            CreateEditActivity(viewModel: viewModel, trip: trip, activityToEdit: activityToEdit)
        }
        .onChange(of: activityToEdit) { _, newValue in
            if newValue != nil {
                isShowingCreateActivity = true
            }
        }
        .sheet(isPresented: $isShowingDateFilter) {
            dateFilterSheet
        }
        .alert(isPresented: $isShowingDeleteConfirmation) {
            Alert(
                title: Text("Delete Activity"),
                message: Text("Are you sure you want to delete \"\(activityToDelete?.name ?? "")\"?"),
                primaryButton: .destructive(Text("Delete")) {
                    if let activity = activityToDelete {
                        viewModel.deleteActivity(from: trip, activity: activity)
                    }
                },
                secondaryButton: .cancel()
            )
        }
        .onAppear {
            flatActivities = trip.activities
        }
    }

    private var groupedActivities: [(date: Date, activities: [Activity])] {
        let filtered = flatActivities.filter { activity in
            (searchText.isEmpty || activity.name.localizedCaseInsensitiveContains(searchText)) &&
            (selectedCategories.isEmpty || selectedCategories.contains(ActivityCategory(rawValue: activity.type.rawValue) ?? .activity)) &&
            (selectedDate == nil || Calendar.current.isDate(activity.date, inSameDayAs: selectedDate!))
        }

        let grouped = Dictionary(grouping: filtered) {
            Calendar.current.startOfDay(for: $0.date)
        }

        return grouped.map { (date: $0.key, activities: $0.value) }.sorted { $0.date < $1.date }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    private func activityCell(for activity: Activity) -> some View {
        ActivityCellView(activity: activity)
            .listRowInsets(EdgeInsets())
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
            .listRowBackground(Color.clear)
            .swipeActions {
                Button("Edit") {
                    activityToEdit = activity
                    isShowingCreateActivity = true
                }.tint(.blue)

                Button("Delete", role: .destructive) {
                    activityToDelete = activity
                    isShowingDeleteConfirmation = true
                }
            }
    }

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(ActivityCategory.allCases, id: \.self) { category in
                    let isSelected = selectedCategories.contains(category)
                    Text(category.rawValue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(isSelected ? Color.blue : Color.gray.opacity(0.3))
                        .foregroundColor(isSelected ? .white : .primary)
                        .clipShape(Capsule())
                        .onTapGesture {
                            if isSelected {
                                selectedCategories.remove(category)
                            } else {
                                selectedCategories.insert(category)
                            }
                        }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 4)
        }
    }

    private var dateFilterSheet: some View {
        NavigationView {
            VStack {
                DatePicker("Select Date", selection: Binding(get: {
                    selectedDate ?? Date()
                }, set: {
                    selectedDate = $0
                }), in: trip.startDate...trip.endDate, displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .padding()

                Button("Clear Filter") {
                    selectedDate = nil
                }
                .padding()

                Spacer()
            }
            .navigationBarTitle("Filter by Date", displayMode: .inline)
            .navigationBarItems(leading: Button("Cancel") {
                isShowingDateFilter = false
            })
        }
    }
}
