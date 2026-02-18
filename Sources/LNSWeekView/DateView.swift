//
//  DateView.swift
//  DateView
//
//  Created by Mark Alldritt on 2023-08-07.
//

import SwiftUI
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
                Text(weekdaySymbol)
                    .font(.caption.bold())
                    .foregroundColor(isToday ? (colorScheme == .dark ? .black : .white) :
                                        (colorScheme == .dark ? .white.opacity(0.4) : .black.opacity(0.4)))
            )
    }
}


struct DateView<DateContent: View>: View {
    let date: Date
    @Binding var today: Date
    @ViewBuilder let content: (_ date: Date, _ today: Date) -> DateContent

    var body: some View {
        VStack(spacing: 0) {
            DayOfWeekView(date: date)
                .frame(width: 22, height: 22)
                .padding(.bottom, 8)

            content(date, today)
        }
    }
}


struct DateView_Previews: PreviewProvider {
    static var previews: some View {
        let today = Date.today
        let tomorrow = Date.tomorrow

        DateView(date: today, today: .constant(today)) { date, today in
            Circle()
                .foregroundStyle(Color.orange)
        }
        DateView(date: today, today: .constant(today)) { date, today in
            Circle()
                .foregroundStyle(Color.gray)
        }
        DateView(date: tomorrow, today: .constant(today)) { date, today in
            Circle()
                .foregroundStyle(Color.orange)
        }
        DateView(date: tomorrow, today: .constant(today)) { date, today in
            Circle()
                .foregroundStyle(Color.gray)
        }
    }
}
