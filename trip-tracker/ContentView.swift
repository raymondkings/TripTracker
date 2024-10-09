//
//  ContentView.swift
//  trip-tracker
//
//  Created by Raymond King on 08.10.24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            Spacer()
            Button(action: addTrip) {
                Image(systemName: "plus")
                    .font(.largeTitle)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(20)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.trailing, 10)
        }
    }

    // Define the addTrip function
    func addTrip() {
        // Your code to add a trip goes here
        print("Trip added!")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
