//
//  ContentView.swift
//  DayView
//
//  Created by Mark Alldritt on 2023-08-07.
//

import SwiftUI
import LNSWeekView



struct DateContentView: View {
    let date: Date
    let dates: Set<Date>
    
    var body: some View {
        VStack {
            Spacer()
            Text("\(date.monthName) \(date.dayOfMonth)")
                .font(.title)
            Text("Weekday: \(date.weekday)")
            Text("Weekday: \(date.weekdaySymbol)")
            Text("Active Date: \(dates.contains(date) ? "YES" : "NO")")
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.1))
    }
}
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
        NavigationStack {
            WeekPageView(dates: dates,
                         selectedDate: $selectedDate,
                         activeOnly: true) { date, today in
                DateCalendarView(date: date, active: dates.contains(date))
            } dayContent: { date in
                DateContentView(date: date, dates: dates)
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
