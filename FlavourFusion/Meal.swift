//
//  Meal.swift
//  FlavourFusion
//
//  Created by Fahad Waseem on 24/05/2024.
//

import Foundation

struct Meal: Identifiable {
    let id = UUID()
    let idMeal: String
    let strMeal: String
    let strCategory: String
    let strInstructions: String
    let strMealThumb: String
    let ingredients: [String]
    
    var nonEmptyIngredients: [String] {
        return ingredients.filter { !$0.isEmpty }
    }
}
