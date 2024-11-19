//
//  DateView.swift
//  DateView
//
//  Created by Mark Alldritt on 2023-08-07.
//

import SwiftUI
import HealthKitUI
import LNSSwiftUIExtras


let inactiveDayColor = Color(#colorLiteral(red: 0.8986077905, green: 0.8940393329, blue: 0.9150110483, alpha: 1))
let activeDayColor = Color(#colorLiteral(red: 0.1986843646, green: 0.6755225658, blue: 0.9030171037, alpha: 1))


struct DateCalendarView: View {
    let appearAnimationDuration = TimeInterval(0.25)

    let date: Date
    let active: Bool

    @State private var size = CGFloat(0)

    var body: some View {
        Circle()
            .fill(inactiveDayColor)
            .if(active) {
                $0.overlay(
                    GeometryReader { g in
                        Group {
                            Circle()
                                .fill(activeDayColor)
                                .frame(width: g.size.width * size,
                                       height: g.size.height * size)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                )
            }
            .overlay(
                Text("\(date.dayOfMonth)")
            )
            .onAppear() {
                withAnimation(.linear(duration: appearAnimationDuration)) {
                    size = active ? 1 : 0.1
                }
            }
    }
}


struct DateView_Previews: PreviewProvider {
    static var previews: some View {
        let today = Date.today
        let tomorrow = Date.tomorrow
        
        DateCalendarView(date: today, active: true)
        DateCalendarView(date: today, active: false)
        DateCalendarView(date: tomorrow, active: true)
        DateCalendarView(date: tomorrow, active: false)
    }
}
