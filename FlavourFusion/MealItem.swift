//
//  MealItem.swift
//  FlavourFusion
//
//  Created by Fahad Waseem on 24/05/2024.
//

import Foundation
import SwiftUI

struct MealItem: View {
    let meal: Meal
    @State private var isShowingDetail = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: {
                isShowingDetail.toggle()
            }) {
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
                .frame(height: 100)
                .cornerRadius(12)
            }
            .buttonStyle(PlainButtonStyle())
            
            Text(meal.strMeal)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .lineLimit(2)
        }
        .padding()
        .background(colorScheme == .light ? Color.white : Color(white: 0.2))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 10)
        .fullScreenCover(isPresented: $isShowingDetail) {
            NavigationView {
                MealDetailView(meal: meal)
                    .background(Color("Lavender"))
            }
        }
    }
}
