//
//  DateView.swift
//  DateView
//
//  Created by Mark Alldritt on 2023-08-07.
//

import SwiftUI
import HealthKitUI
import LNSSwiftUIExtras


struct DayOfWeekView: View {
    @Environment(\.colorScheme) var colorScheme
    let date: Date

    var weekdaySymbol: String {
        date.formatted(Date.FormatStyle().weekday(.narrow))
    }

    var body: some View {
        let isToday = Date.today == date.zeroHour
        
        Circle()
            .fill(isToday ? Color.primary : Color.clear)
            .overlay(
                VStack {
                    GeometryReader { g in
                        Text(weekdaySymbol)
                            .font(.system(size: g.size.height * 0.7).bold())
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .foregroundColor(isToday ? (colorScheme == .dark ? .black : .white) :
                                                (colorScheme == .dark ? .white.opacity(0.4) : .black.opacity(0.4)))
                    }
                }
            )
    }
}


struct DateView<DateContent: View>: View {
    let date: Date
    @Binding var today: Date
    @ViewBuilder let content: (_ date: Date, _ today: Date) -> DateContent
    
    @State var frame = CGRect.zero

    var body: some View {
        let size = max(frame.width, frame.height)
        let dayHeightPercent = CGFloat(0.3)
        let daySpacePercent = CGFloat(0.1)
        
        VStack(spacing: 0) {
            //  Display day of week
            DayOfWeekView(date: date)
                .frame(width: frame.width, height: frame.height * dayHeightPercent)
                //.border(.green)

            //  Display calendat content for this day
            content(date, today)
                .frame(width: frame.width, height: frame.width)
                .padding(EdgeInsets(top: size * daySpacePercent,
                                    leading: 0,
                                    bottom: 0, //size * daySpacePercent,
                                    trailing: 0))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .saveFrame(in: $frame)
        .padding(5)
    }
}


struct DateView_Previews: PreviewProvider {
    static var previews: some View {
        let today = Date.today
        let tomorrow = Date.tomorrow
        
        DateView(date: today, today: .constant(today)) { date, today in
            let active = true
            
            Circle()
                .foregroundStyle(active ? Color.orange : Color.gray)
        }
        DateView(date: today, today: .constant(today)) { date, today in
            let active = false
            
            Circle()
                .foregroundStyle(active ? Color.orange : Color.gray)
        }
        DateView(date: tomorrow, today: .constant(today)) { date, today in
            let active = true
            
            Circle()
                .foregroundStyle(active ? Color.orange : Color.gray)
        }
        DateView(date: tomorrow, today: .constant(today)) { date, today in
            let active = false
            
            Circle()
                .foregroundStyle(active ? Color.orange : Color.gray)
        }
    }
}