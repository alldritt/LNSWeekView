//
//  WeekPageView.swift
//  LNSWeekView
//
//  Created by Mark Alldritt on 2026-02-18.
//

import SwiftUI
import LNSSwiftUIExtras


public struct WeekPageView<DateContent: View, DayContent: View>: View {

    let dates: Set<Date>
    @Binding var selectedDate: Date
    let activeOnly: Bool
    @ViewBuilder let dateContent: (_ date: Date, _ today: Date) -> DateContent
    @ViewBuilder let dayContent: (_ date: Date) -> DayContent

    @State private var scrollPositionIndex: Int?
    @State private var lastPagedToIndex: Int?

    private let pageDates: [Date]

    public init(
        dates: Set<Date>,
        selectedDate: Binding<Date>,
        activeOnly: Bool = false,
        @ViewBuilder dateContent: @escaping (_ date: Date, _ today: Date) -> DateContent,
        @ViewBuilder dayContent: @escaping (_ date: Date) -> DayContent
    ) {
        self.dates = dates
        self._selectedDate = selectedDate
        self.activeOnly = activeOnly
        self.dateContent = dateContent
        self.dayContent = dayContent

        if activeOnly {
            self.pageDates = dates.sorted()
        } else {
            let rangeStart = min(Date.today, dates.min() ?? Date.today).zeroHour
            let rangeEnd = max(Date.today, dates.max() ?? Date.today).zeroHour
            let oneDay = TimeInterval(24 * 60 * 60)
            let count = Int((DateInterval(start: rangeStart, end: rangeEnd).duration / oneDay).rounded()) + 1
            self.pageDates = (0..<count).map { rangeStart.next(day: $0) }
        }
    }

    private func pageIndex(for date: Date) -> Int {
        let normalized = date.zeroHour
        if activeOnly {
            // Find nearest active date
            if let exact = pageDates.firstIndex(where: { $0.zeroHour == normalized }) {
                return exact
            }
            // Snap to nearest
            var bestIndex = 0
            var bestDistance = Int.max
            for (i, d) in pageDates.enumerated() {
                let dist = abs(d.daysSince1970 - normalized.daysSince1970)
                if dist < bestDistance {
                    bestDistance = dist
                    bestIndex = i
                }
            }
            return bestIndex
        } else {
            guard let first = pageDates.first else { return 0 }
            let oneDay = TimeInterval(24 * 60 * 60)
            let clamped = max(normalized, first.zeroHour)
            let days = DateInterval(start: first.zeroHour, end: clamped).duration / oneDay
            return min(Int(days.rounded()), pageDates.count - 1)
        }
    }

    public var body: some View {
        VStack(spacing: 0) {
            WeekView(dates: dates, selectedDate: $selectedDate, content: dateContent)

            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 0) {
                        ForEach(0..<pageDates.count, id: \.self) { index in
                            dayContent(pageDates[index])
                                .containerRelativeFrame(.horizontal)
                                .id(index)
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.paging)
                .scrollPosition(id: $scrollPositionIndex)
                .onChange(of: scrollPositionIndex) { _, newIndex in
                    if let newIndex, newIndex >= 0, newIndex < pageDates.count {
                        let newDate = pageDates[newIndex]
                        if selectedDate.zeroHour != newDate.zeroHour {
                            lastPagedToIndex = newIndex
                            selectedDate = newDate
                        }
                    }
                }
                .onChange(of: selectedDate) {
                    let targetIndex = pageIndex(for: selectedDate)

                    // When activeOnly, snap non-active dates to nearest active date
                    if activeOnly && !pageDates.contains(where: { $0.zeroHour == selectedDate.zeroHour }) {
                        let snapped = pageDates[targetIndex]
                        selectedDate = snapped
                        return
                    }

                    if lastPagedToIndex != targetIndex {
                        lastPagedToIndex = targetIndex
                        withAnimation {
                            proxy.scrollTo(targetIndex, anchor: .leading)
                        }
                    }
                }
                .onAppear {
                    var targetIndex = pageIndex(for: selectedDate)

                    if activeOnly && !pageDates.contains(where: { $0.zeroHour == selectedDate.zeroHour }) {
                        let snapped = pageDates[targetIndex]
                        selectedDate = snapped
                        targetIndex = pageIndex(for: snapped)
                    }

                    lastPagedToIndex = targetIndex
                    DispatchQueue.main.async {
                        proxy.scrollTo(targetIndex, anchor: .leading)
                    }
                }
            }
        }
    }
}
