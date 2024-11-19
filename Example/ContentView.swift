//
//  ContentView.swift
//  DayView
//
//  Created by Mark Alldritt on 2023-08-07.
//

import SwiftUI
import LNSWeekView


struct ContentView: View {
    
    let dates = Set<Date>([Date.today.next(day: -8),
                           Date.today.next(day: -7),
                           Date.today.next(day: -3),
                           Date.today.next(day: -2),
                           Date.today.next(day: -1),
                           Date.today,
                           Date.today.next(day: 4),
                           Date.today.next(day: 5)])

    @State var selectedDate = Date.today
    
    var body: some View {
        NavigationView {
            VStack {
                WeekView(dates: dates, selectedDate: $selectedDate) { date, today in
                    DateCalendarView(date: date, active: dates.contains(date))
                }
                
                Rectangle()
                    .foregroundStyle(Color.gray)
                    .overlay(
                        VStack {
                            Text("\(selectedDate.monthName) \(selectedDate.dayOfMonth)")
                            Text("Weekday: \(selectedDate.weekday)")
                            Text("Weekday: \(selectedDate.weekdaySymbol)")
                            Text("Active Date: \(dates.contains(selectedDate) ? "YES" : "NO")")
                        }
                    )
                    .padding(3)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("LNSWeekDay Example")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
