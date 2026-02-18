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
    private let edgePadding = 3

    @Binding var selectedDate: Date
    @State private var scrollPositionIndex: Int?
    @State private var lastScrolledToIndex: Int?

    let dateRange: DateInterval
    let content: (_ value: Date) -> Content

    init(selectedDate: Binding<Date>, dateRange: DateInterval, @ViewBuilder content: @escaping (_ value: Date) -> Content) {
        self._selectedDate = selectedDate
        self.content = content
        let normalizedRange = DateInterval(start: dateRange.start.zeroHour, end: dateRange.end.zeroHour)
        self.dateRange = normalizedRange

        let oneDay = TimeInterval(24 * 60 * 60)
        let count = Int((normalizedRange.duration / oneDay).rounded()) + 1
        let clamped = max(selectedDate.wrappedValue.zeroHour, normalizedRange.start)
        let days = DateInterval(start: normalizedRange.start, end: clamped).duration / oneDay
        self._scrollPositionIndex = State(initialValue: min(Int(days.rounded()), count - 1))
    }

    private var dayCount: Int {
        let oneDay = TimeInterval(24 * 60 * 60)
        return Int((dateRange.duration / oneDay).rounded()) + 1
    }

    private func date(at index: Int) -> Date {
        dateRange.start.next(day: index)
    }

    private func dayIndex(for date: Date) -> Int {
        let oneDay = TimeInterval(24 * 60 * 60)
        let clamped = max(date.zeroHour, dateRange.start)
        let days = DateInterval(start: dateRange.start, end: clamped).duration / oneDay
        return min(Int(days.rounded()), dayCount - 1)
    }

    var body: some View {
        let totalCount = edgePadding + dayCount + edgePadding

        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: itemSpacing) {
                    ForEach(0..<totalCount, id: \.self) { index in
                        let dateIndex = index - edgePadding

                        if dateIndex >= 0 && dateIndex < dayCount {
                            let date = date(at: dateIndex)
                            content(date)
                                .containerRelativeFrame(.horizontal, count: 7, span: 1, spacing: itemSpacing)
                                .onTapGesture {
                                    selectedDate = date
                                    lastScrolledToIndex = dateIndex
                                    withAnimation {
                                        proxy.scrollTo(dateIndex, anchor: .leading)
                                    }
                                }
                        } else {
                            Color.clear
                                .containerRelativeFrame(.horizontal, count: 7, span: 1, spacing: itemSpacing)
                        }
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $scrollPositionIndex)
            .onChange(of: scrollPositionIndex) { _, newIndex in
                if let newIndex, newIndex >= 0, newIndex < dayCount {
                    let newDate = date(at: newIndex)
                    if selectedDate.zeroHour != newDate.zeroHour {
                        lastScrolledToIndex = newIndex
                        selectedDate = newDate
                    }
                }
            }
            .onAppear {
                let targetIndex = dayIndex(for: selectedDate)
                lastScrolledToIndex = targetIndex
                DispatchQueue.main.async {
                    proxy.scrollTo(targetIndex, anchor: .leading)
                }
            }
            .onChange(of: selectedDate) {
                let targetIndex = dayIndex(for: selectedDate)
                if lastScrolledToIndex != targetIndex {
                    lastScrolledToIndex = targetIndex
                    withAnimation {
                        proxy.scrollTo(targetIndex, anchor: .leading)
                    }
                }
            }
        }
    }
}
