//
//  MealDetailView.swift
//  FlavourFusion
//
//  Created by Fahad Waseem on 24/05/2024.
//

import Foundation
import SwiftUI

struct MealDetailView: View {
    let meal: Meal
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                AsyncImage(url: URL(string: meal.strMealThumb)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: 300)
                .clipped()
                .cornerRadius(12)
                
                Text(meal.strMeal)
                    .font(.title)
                    .fontWeight(.bold)
                
                Divider()
                
                Text("Ingredients:")
                    .font(.headline)
                    .fontWeight(.bold)
                
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 20), GridItem(.flexible(), spacing: 20)], spacing: 20) {
                    ForEach(0..<meal.nonEmptyIngredients.count, id: \.self) { index in
                        Text("- \(meal.nonEmptyIngredients[index])")
                            .foregroundColor(.primary)
                    }
                }
                
                Divider()
                
                Text("Instructions:")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Text(meal.strInstructions)
                    .padding(.top, 8)
                    .foregroundColor(.primary)
            }
            .padding()
            .background(colorScheme == .light ? Color("Lavender") : Color(hex: "4D3C77"))
        }
        .navigationTitle("Meal Details")
        .navigationBarItems(trailing: Button("Close") {
            presentationMode.wrappedValue.dismiss()
        })
        .background(colorScheme == .light ? Color(hue: 0.075, saturation: 0.112, brightness: 0.992) : Color(hex: "4D3C77"))
    }
}
