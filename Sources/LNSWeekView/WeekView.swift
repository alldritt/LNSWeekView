//
//  WeekView.swift
//  DayView
//
//  Created by Mark Alldritt on 2023-08-07.
//

import SwiftUI
import LNSSwiftUIExtras


struct CurrentDayIndicator: Shape {
    let indicatorHeight = CGFloat(13)
    
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.midX - indicatorHeight * 0.7, y: 0))
        path.addLine(to: CGPoint(x: rect.midX, y: indicatorHeight))
        path.addLine(to: CGPoint(x: rect.midX + indicatorHeight * 0.7, y: 0))
        path.closeSubpath()

        return path
    }
    
    func sizeThatFits(_ proposal: ProposedViewSize) -> CGSize {
        return CGSize(width: proposal.width ?? 0, height: indicatorHeight)
    }

}


struct CurrentDateView: View {
    
    @Binding var today: Date
    @Binding var date: Date
    
    var formattedDate: String {
        let todayDays = today.daysSince1970
        let dateDays = date.daysSince1970
        
        if todayDays == dateDays {
            return "Today, \(date.monthName) \(date.dayOfMonth)"
        }
        else if todayDays - 1 == dateDays {
            return "Yesterday, \(date.monthName) \(date.dayOfMonth)"
        }
        else if todayDays + 1 == dateDays {
            return "Tomorrow, \(date.monthName) \(date.dayOfMonth)"
        }
        else {
            if date.year == today.year {
                //  Same year, show weekday, month & day

                return "\(date.weekdayName), \(date.monthName) \(date.dayOfMonth)"
            }
            else {
                //  Different year, show year, month & day
                
                return "\(date.monthName) \(date.dayOfMonth), \(date.year)"
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Text(formattedDate)
                .font(.title2)
                .padding(.top, 18)
                .padding(.bottom, 9)
            Rectangle()
                .fill(.primary.opacity(0.4))
                .frame(height: 0.5)
                .offset(y: 0.5)
            CurrentDayIndicator()
                .fill(.primary)
                .padding(.bottom, 4)
        }
    }
}


public struct WeekView<DateContent: View>: View {
    
    let dates: Set<Date> // collection of "visible" or "active" dates
    @Binding var selectedDate: Date // currently selected or focused date
    @ViewBuilder let content: (_ date: Date, _ today: Date) -> DateContent

    @State var todayDate = Date.today
    
    public init(dates: Set<Date>, selectedDate: Binding<Date>, @ViewBuilder content: @escaping (_: Date, _: Date) -> DateContent) {
        self.dates = dates
        self._selectedDate = selectedDate
        self.content = content
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            CurrentDateView(today: $todayDate, date: _selectedDate)
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    withAnimation {
                        selectedDate = Date.today
                    }
                }

            ScrollingWeekView(selectedDate: $selectedDate, dateRange: DateInterval(start: Date.today.next(day: -20), end: Date.today.next(day: 10))) { date in
                
                DateView(date: date, today: $todayDate, content: content)
            }
            .frame(height: 70)
            .padding(.bottom, 10)
        }
        .onChange(of: todayDate) { newValue in
            print("currentDate changed")
        }
        .onChange(of: selectedDate) { newValue in
            print("selectedDate changed")
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name.NSCalendarDayChanged).receive(on: DispatchQueue.main)) { _ in
            //  We have progressed from one day to another
            todayDate = Date.today
        }

    }
}


struct WeekView_Previews: PreviewProvider {
    @State var selectedDate = Date.today
    
    static var previews: some View {
        let dates = Set<Date>([Date.today.next(day: -8),
                               Date.today.next(day: -7),
                               Date.today.next(day: -3),
                               Date.today.next(day: -2),
                               Date.today.next(day: -1),
                               Date.today,
                               Date.today.next(day: 4),
                               Date.today.next(day: 5)])

        WeekView(dates: dates,
                 selectedDate: .constant(Date.yesterday)) {date, today in
            let active = dates.contains(date)

            Circle()
                .foregroundStyle(active ? Color.orange : Color.gray)
        }
        .border(.blue)
    }
}
