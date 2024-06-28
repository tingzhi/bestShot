//
//  ContentView.swift
//  BestShot
//
//  Created by Tingzhi Li on 6/25/24.
//

import SwiftUI

struct WorkoutSet: Identifiable {
    let id = UUID()
    let date: Date
    let exerciseName: String
    let reps: Int
    let weight: Int
    
    var summary: String {
        let formattedDate = date.formatted(date: .abbreviated, time: .omitted)
        return "\(formattedDate), \(exerciseName), \(reps), \(weight)"
    }
}

struct OneRMData: Identifiable {
    let id = UUID()
    let exerciseName: String
    let date: Date
    let oneRM: Int
}

struct ContentView: View {
    @State private var workoutData = [WorkoutSet]()
    @State private var uniqueExerciseNames = [String]()
    
    @Environment(\.colorScheme) var colorScheme
    
    let column = [
        GridItem(.adaptive(minimum: .infinity))
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: column) {
                    ForEach(uniqueExerciseNames, id: \.self) { exerciseName in
                        NavigationLink {
                            let overallOneRM = calculateOverallOneRM(for: exerciseName)
                            let oneRMDataArray = calculate1RM(for: exerciseName)
                            DetailView(exerciseName: exerciseName, 
                                       overallOneRM: overallOneRM,
                                       oneRMDataArray: oneRMDataArray)
                            .toolbarRole(.editor)
                        } label: {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(exerciseName)
                                        .font(.title.weight(.semibold))
                                    Text("One Rep Max • lbs")
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                Text("\(calculateOverallOneRM(for: exerciseName))")
                                    .font(.title.weight(.semibold))
                            }
                            .foregroundStyle(colorScheme == .dark ? .white : .black)
                            .padding()
                        }
                    }
                }
                .padding(.top, 8)
            }
        }
        .tint(.primary)
        .onAppear {
            loadWorkoutData(filename: "workoutData")
        }
    }
    
    private func loadWorkoutData(filename: String) {
        if let workoutDataUrl = Bundle.main.url(forResource: filename, withExtension: "txt") {
            if let workoutData = try? String(contentsOf: workoutDataUrl) {
                let allWorkoutSets = workoutData.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: "\n")
    
                var tempWorkoutSets = [WorkoutSet]()
                for workoutDataSet in allWorkoutSets {
                    let temp = workoutDataSet.components(separatedBy: ",")
                    // example temp: [Oct 11 2020, Back Squat, 10, 45]
                    //
                    
                    // convert Oct 10, 2020 to a Date object
                    //
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MMM dd yyyy"
                    formatter.locale = Locale(identifier: "en_US_POSIX")
                    
                    guard let date = formatter.date(from: temp[0]) else {
                        print("Error: can't convert date string \(temp[0]) to a Date object!")
                        continue
                    }
                    let exerciseName = temp[1]
                    guard let reps = Int(temp[2]) else {
                        print("Error: can't convert reps string \(temp[2]) to an Int!")
                        continue
                    }
                    guard let weight = Int(temp[3]) else {
                        print("Error: can't convert weight string \(temp[3]) to an Int!")
                        continue
                    }
                    
                    let workoutSet = WorkoutSet(date: date, exerciseName: exerciseName, reps: reps, weight: weight)
                    tempWorkoutSets.append(workoutSet)
                }
                self.workoutData = tempWorkoutSets
                self.uniqueExerciseNames = findUniqueExerciseNames()
                return
            }
        }
        
        fatalError("Could not load or parse workoutData.txt from bundle.")
    }
    
    private func findUniqueExerciseNames() -> [String] {
        var exercises = Set<String>()
        for workoutSet in self.workoutData {
            if !exercises.contains(workoutSet.exerciseName) {
                exercises.insert(workoutSet.exerciseName)
            }
        }
        
        return Array(exercises).sorted()
    }
    
    private func calculate1RM(for exerciseName: String) -> [OneRMData] {
        let exerciseSets = self.workoutData.filter { $0.exerciseName == exerciseName }
    
        var oneRMDict = [Date: Int]()
        for exerciseSet in exerciseSets {
            let oneRM = 36 * exerciseSet.weight / (37 - exerciseSet.reps)
            if let prevOneRM = oneRMDict[exerciseSet.date] {
                oneRMDict[exerciseSet.date] = max(oneRM, prevOneRM)
            } else {
                oneRMDict[exerciseSet.date] = oneRM
            }
        }
        
        var res = [OneRMData]()
        for (date, oneRM) in oneRMDict {
            res.append(OneRMData(exerciseName: exerciseName, date: date, oneRM: oneRM))
        }
        res.sort { $0.date < $1.date }
        
        return res
    }
    
    // from [OneRMData], we can get overallOneRM
    //
    private func calculateOverallOneRM(for exerciseName: String) -> Int {
        let data = calculate1RM(for: exerciseName)
        let sumArray = data.reduce(0, { $0 + $1.oneRM })
        let avg = sumArray / data.count
        
        return avg
    }
}

#Preview {
    ContentView()
}
