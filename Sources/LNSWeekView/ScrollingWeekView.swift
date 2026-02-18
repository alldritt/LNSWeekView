//
//  ScrollingWeekView.swift
//  DayView
//
//  Created by Mark Alldritt on 2023-08-11.
//

import SwiftUI
import LNSSwiftUIExtras


struct ScrollingWeekView<Content: View>: View {
    private let itemSpacing = CGFloat(5)

    @Binding var selectedDate: Date

    let dateRange: DateInterval
    let content: (_ value: Date) -> Content

    init(selectedDate: Binding<Date>, dateRange: DateInterval, @ViewBuilder content: @escaping (_ value: Date) -> Content) {
        self._selectedDate = selectedDate
        self.content = content
        self.dateRange = DateInterval(start: dateRange.start.zeroHour, end: dateRange.end.zeroHour)
    }

    private var dayCount: Int {
        let oneDay = TimeInterval(24 * 60 * 60)
        return Int((dateRange.duration / oneDay).rounded()) + 1
    }

    private func date(at index: Int) -> Date {
        dateRange.start.next(day: index)
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: itemSpacing) {
                    ForEach(0..<dayCount, id: \.self) { index in
                        let date = date(at: index)
                        content(date)
                            .containerRelativeFrame(.horizontal, count: 7, span: 1, spacing: itemSpacing)
                            .id(date)
                            .onTapGesture {
                                withAnimation {
                                    selectedDate = date
                                }
                            }
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .onAppear {
                proxy.scrollTo(selectedDate, anchor: .center)
            }
            .onChange(of: selectedDate) {
                withAnimation {
                    proxy.scrollTo(selectedDate, anchor: .center)
                }
            }
        }
    }
}
