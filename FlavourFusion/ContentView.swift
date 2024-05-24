//
//  ContentView.swift
//  FlavourFusion
//
//  Created by Fahad Waseem on 24/05/2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = MealsViewModel()
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            if viewModel.hasInternetAccess {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        ForEach(viewModel.meals) { meal in
                            MealItem(meal: meal)
                        }
                    }
                    .padding()
                }
                .background(colorScheme == .light ? Color(hue: 0.075, saturation: 0.112, brightness: 0.992) : Color(hex: "4D3C77"))
                .navigationTitle("FlavorFusion Picks")
                .onAppear {
                    viewModel.fetchMeals()
                }
            } else {
                Text("This App Requires Internet Access")
                    .font(.title)
                    .foregroundColor(.primary)
            }
        }
        .background(Color("Lavender"))
        .navigationViewStyle(StackNavigationViewStyle()) // For iPad support
    }
}

#Preview {
    ContentView()
}
