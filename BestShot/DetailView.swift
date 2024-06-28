//
//  DetailView.swift
//  BestShot
//
//  Created by Tingzhi Li on 6/25/24.
//

import SwiftUI
import Charts

struct DetailView: View {
    @Environment(\.colorScheme) var colorScheme
    
    let exerciseName: String
    let overallOneRM: Int
    let oneRMDataArray: [OneRMData]
    
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(exerciseName)
                        .font(.title.weight(.semibold))
                    Text("One Rep Max • lbs")
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Text("\(overallOneRM)")
                    .font(.title.weight(.semibold))
            }
            .foregroundStyle(.primary)
            .padding(.horizontal)
            
            Chart {
                ForEach(oneRMDataArray) { item in
                    LineMark(x: .value("Date", item.date), y: .value("1RM", item.oneRM))
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                        .symbol {
                            Circle()
                                .stroke()
                                .foregroundStyle(colorScheme == .dark ? .white : .black)
                                .frame(width: 6, height: 6)
                        }
                }
            }
            .frame(height: 200)
            .padding(.horizontal)
            
            Spacer()
        }
    }
}

#Preview {
    let oneRMData = OneRMData(exerciseName: "Deadlift", date: Date(), oneRM: 150)
    return DetailView(exerciseName: "Deadlift", overallOneRM: 200, oneRMDataArray: [oneRMData])
}
