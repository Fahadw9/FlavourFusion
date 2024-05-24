//
//  MealsViewModel.swift
//  FlavourFusion
//
//  Created by Fahad Waseem on 24/05/2024.
//

import Foundation
import Combine

class MealsViewModel: ObservableObject {
    @Published var meals: [Meal] = []
    @Published var hasInternetAccess = true
    
    func fetchMeals() {
        guard let url = URL(string: "https://www.themealdb.com/api/json/v1/1/random.php") else {
            print("Invalid URL")
            hasInternetAccess = false
            return
        }
        
        let group = DispatchGroup()
        
        for _ in 0..<20 {
            group.enter()
            
            URLSession.shared.dataTask(with: url) { data, _, error in
                defer { group.leave() }
                
                guard let data = data, error == nil else {
                    DispatchQueue.main.async {
                        self.hasInternetAccess = false
                    }
                    return
                }
                
                do {
                    guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                          let mealsArray = json["meals"] as? [[String: Any]],
                          let mealDict = mealsArray.first else {
                        print("Invalid data format")
                        return
                    }
                    
                    guard let idMeal = mealDict["idMeal"] as? String,
                          let strMeal = mealDict["strMeal"] as? String,
                          let strCategory = mealDict["strCategory"] as? String,
                          let strInstructions = mealDict["strInstructions"] as? String,
                          let strMealThumb = mealDict["strMealThumb"] as? String else {
                        print("Missing or invalid data")
                        return
                    }
                    
                    let ingredients = (1...20).compactMap { mealDict["strIngredient\($0)"] as? String }
                    let meal = Meal(idMeal: idMeal,
                                    strMeal: strMeal,
                                    strCategory: strCategory,
                                    strInstructions: strInstructions,
                                    strMealThumb: strMealThumb,
                                    ingredients: ingredients)
                    
                    DispatchQueue.main.async {
                        self.meals.append(meal)
                    }
                } catch {
                    print("Failed to decode data: \(error.localizedDescription)")
                }
            }.resume()
        }
        
        group.notify(queue: .main) {
            print("Fetched \(self.meals.count) meals.")
        }
    }
}
