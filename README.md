# Intro Course Project App of Raymond King Setia for the iPraktikum

To pass the intro course, you need to create your own unique iOS app (based on SwiftUI).

There are no requirements regarding the functions of your app, so you can get creative.
However, we provide you with Non-Functional Requirements (NFR) that your app needs to fulfill.

After each day of learning new Swift and SwiftUI concepts, these NFRs may change, or new NFRs get added.

## Submission procedure

You get a **personal repository** on Gitlab to work on your app.

Once you implemented a new feature into your app, you need to create a Merge Request (MR - Sometimes we will also reference these as "Pull Requests"(PR)) to merge your changes from the feature branch into your main branch.

Your tutor will review your changes and either request changes or approves the MR.

If your MR got approved, you also need to merge it!

### Deadline: **15.10.2024 23:59**

Until the deadline all of your PRs **need to be merged** and your final app **needs to fulfill** all of the requested NFRs!

---

## Problem Statement (max. 500 words)

Traveling can be an exciting yet overwhelming experience. Sometimes travelers lack the possibility to organize their vacation properly. Wouldn't it be nice if there was a dedicated app on your Iphone that lets you keep track of essential information such as landmarks, activities, dates, ticket purchases, and restaurant menus? Additionally, incorporating AI can significantly enhance the planning experience by generating personalized itineraries based on user preferences and estimating budgets.

## Requirements

- User can create, edit, delete, and view a trip
- User can create, edit, delete, and view an activity
- Activities can be filtered by name

## Analysis

![UML-Diagram](./UML-Diagram.png)

## System Design

![Design-System](./Subsystem-Decomposition-new.png)

## Product Backlog

| ID  | Feature                              | Description                                                                 | Priority | Status  |
| --- | ------------------------------------ | --------------------------------------------------------------------------- | -------- | ------- |
| A-1 | Create new trip                      | Allow users to create a new trip with relevant details like name and dates.  | Major   | Done |
| A-2 | Edit trip details                    | Allow users to edit trip details such as name, date, and description.        | Major   | Done |
| A-3 | Delete trip                          | Allow users to delete an existing trip.                                      | Minor   | Done |
| A-4 | Create new activity                  | Allow users to add new activities under a specific trip with date, description, etc.| Major   | Done |
| A-5 | Edit activity details                | Allow users to edit details of an existing activity.                         | Major   | Done |
| A-6 | Delete activity                      | Allow users to delete an activity from the trip.                             | Minor   | Done |
| A-7 | Filter activity by date              | Allow users to filter activities by date within a trip.                      | Minor   | Done |
| A-8 | Open activity location in Apple Maps | Launches Apple Maps with the location provided by the user for the activity, allowing them to get directions from their current location. | Minor | Done |