//
//  ContentView.swift
//  hobby
//
//  Created by Никита Мартьянов on 19.08.23.
//

import SwiftUI

struct Habit: Codable {
    var name: String
    var description: String
    var count: Int
}

class HabitsData: ObservableObject {
    @Published var habits: [Habit] = []
    
    init() {
        loadHabits()
    }
    
    func loadHabits() {
        if let data = UserDefaults.standard.data(forKey: "habits") {
            if let decodedHabits = try? JSONDecoder().decode([Habit].self, from: data) {
                habits = decodedHabits
                return
            }
        }
        
        habits = []
    }
    
    func saveHabits() {
        if let encodedHabits = try? JSONEncoder().encode(habits) {
            UserDefaults.standard.set(encodedHabits, forKey: "habits")
        }
    }
    
    func increaseCount(for habit: Habit) {
        if let index = habits.firstIndex(where: { $0.name == habit.name }) {
            habits[index].count += 1
            saveHabits()
        }
    }
}

struct ContentView: View {
    @ObservedObject var habitsData = HabitsData()
    
    @State private var showingAddHabitSheet = false
    @State private var newHabitName = ""
    @State private var newHabitDescription = ""
    
    var body: some View {
        NavigationView {
            List {
                ForEach(habitsData.habits, id: \.name) { habit in
                    NavigationLink(destination: HabitDetailView(habit: habit)) {
                        Text(habit.name)
                    }
                }
            }
            .navigationBarTitle("Hobby")
            .navigationBarItems(trailing:
                Button(action: {
                    self.showingAddHabitSheet = true
                }) {
                    Image(systemName: "plus")
                }
            )
        }
        .sheet(isPresented: $showingAddHabitSheet) {
            VStack {
                TextField("Hobby Name", text: self.$newHabitName)
                TextField("Hobyy Description", text: self.$newHabitDescription)
                Button(action: {
                    let newHabit = Habit(name: self.newHabitName, description: self.newHabitDescription, count: 0)
                    self.habitsData.habits.append(newHabit)
                    self.habitsData.saveHabits()
                    self.showingAddHabitSheet = false
                }) {
                    Text("Add Hobby")
                }
            }
            .padding()
        }
    }
}

struct HabitDetailView: View {
    @ObservedObject var habitsData = HabitsData()
    var habit: Habit
    
    var body: some View {
        VStack {
            Text(habit.name)
                .font(.title)
            Text(habit.description)
                .padding()
            Text("Count: \(habit.count)")
            Button(action: {
                self.habitsData.increaseCount(for: self.habit)
            }) {
                Text("Increase Count")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

