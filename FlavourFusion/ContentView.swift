//
//  ContentView.swift
//  FlavourFusion
//
//  Created by Fahad Waseem on 24/05/2024.
//

import SwiftUI

// MARK: - Model

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

// MARK: - ViewModel

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
        
        for _ in 0..<10 {
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

// MARK: - View

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
                    .foregroundColor(.black)
            }
        }
        .background(Color("Lavender"))
        .navigationViewStyle(StackNavigationViewStyle()) // For iPad support
    }
}

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

// MARK: - Preview

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.currentIndex = hex.startIndex
        
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        let red = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgbValue & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
}


#Preview {
    ContentView()
}
