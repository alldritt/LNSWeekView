//
//  InfinityScrollingView.swift
//  DayView
//
//  Created by Mark Alldritt on 2023-08-11.
//

import SwiftUI
import LNSSwiftUIExtras


//  Usage (Objective):
//
//      @State var currentDate = Date()
//
//      var body: some View {
//          InfinityScrollingView(value: $currentDate) { date: Date in
//              // create view for this date
//              Color.green
//          }
//          .visibleRange(DateInterval(start: Date.distantPast, end: Date.distantFuture)
//          .activeRange(DateRange(start: ..., end: ...)
//
//


struct DaysView<Content: View>: View {
    
    @Binding var value: Date
    @State private var currentDayChanged = false

    let firstDateIndex: Int
    let lastDateIndex: Int
    let itemWidth: CGFloat
    let itemSpacing: CGFloat
    let dateRange: DateInterval
    let content: (_ value: Date) -> Content
        
    func view(for date: Date) -> some View {
        let contentView = content(date)
            .frame(width: itemWidth)
            .onTapGesture {
                withAnimation {
                    value = date
                }
            }

        return AnyView(contentView)
    }
    
    var body: some View {
        HStack(spacing: 0) {
            let _ = currentDayChanged
            
            if firstDateIndex > 0 {
                Color.clear
                    .frame(width: CGFloat(firstDateIndex) * (itemWidth + itemSpacing) - itemSpacing / 2)
            }
            HStack(spacing: itemSpacing) {
                ForEach(firstDateIndex..<lastDateIndex, id: \.self) { day in
                    let date = dateRange.start.next(day: day)
                    
                    view(for: date)
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name.NSCalendarDayChanged).receive(on: DispatchQueue.main)) { _ in
            //  Force a redraw when the day changes to move the current day indicator
            currentDayChanged.toggle()
        }
    }
}

struct ScrollingWeekView<Content: View>: View {
    private let oneDay = TimeInterval(24 * 60 * 60)
    private let itemSpacing = CGFloat(2)
    
    @Binding var selectedDate: Date
    
    let dateRange: DateInterval
    let content: (_ value: Date) -> Content // ViewBuilder for a particular value

    @State private var scrollOffset = CGFloat(0)
    @State private var isDragging = false
    @State private var dragOffset = CGFloat(0)
    @State private var dateViews = [Date:any View]()

    init(selectedDate: Binding<Date>, dateRange: DateInterval, @ViewBuilder content: @escaping (_ value: Date) -> Content) {
        self._selectedDate = selectedDate
        self.content = content
        
        self.dateRange = DateInterval(start: dateRange.start.zeroHour, end: dateRange.end.zeroHour)
   }

    var visibleDates: Int {
        Int(dateRange.duration / oneDay) + 1
    }
            
    func calculateDateOffset(_ contentWidth: CGFloat, itemWidth: CGFloat, date: Date) -> (offset: CGFloat, dateIndex: Int) {
        let realDate = max(date.zeroHour, dateRange.start)
        let offsetDays = (DateInterval(start: dateRange.start, end: realDate).duration / oneDay).rounded()
        let newOffset = offsetDays * itemWidth + max(0, offsetDays - 1) * itemSpacing + itemWidth / 2
        
        return (offset: -(newOffset - contentWidth / 2), dateIndex: Int(offsetDays))
    }
    
    var body: some View {
        GeometryReader { g in
            let visibleDates = self.visibleDates
            let itemWidth = ((g.size.width - itemSpacing * 7) / 7.7).rounded(.up)
            let screenWidth = g.size.width
            let contentWidth: CGFloat = (CGFloat(visibleDates) * itemWidth + CGFloat(max(0, visibleDates - 1)) * itemSpacing).rounded()

            VStack(spacing: 0) {
                
                let baseOffset = scrollOffset + dragOffset
                let contentOffset = min(max(0, contentWidth / 2 - baseOffset - itemWidth / 2), contentWidth - itemWidth) 

                let leftOffset = max(0, contentOffset - screenWidth / 2)
                let rightOffset = leftOffset + screenWidth

                let firstDateIndex = Int((leftOffset / (itemWidth + itemSpacing)).rounded(.down))
                let lastDateIndex = min(Int((rightOffset / (itemWidth + itemSpacing)).rounded(.up)) + 1, visibleDates)
                    
                ZStack(alignment: .leading) {
                    Color.clear
                        .frame(width: contentWidth)
                    
                    DaysView(value: $selectedDate,
                             firstDateIndex: max(0, firstDateIndex - 4),
                             lastDateIndex: min(visibleDates, lastDateIndex + 4),
                             itemWidth: itemWidth,
                             itemSpacing: itemSpacing,
                             dateRange: dateRange,
                             content: content)
                }
                .frame(width: screenWidth, height: g.size.height)
                .offset(x: scrollOffset + dragOffset, y: 0)
                .onAppear() {
                    let (newOffset, _) = calculateDateOffset(contentWidth, itemWidth: itemWidth, date: selectedDate)
                    
                    scrollOffset = newOffset
                }
                .onChange(of: selectedDate) {
                    if !isDragging { // only update display if we are not dragging...
                        let (newOffset, _) = calculateDateOffset(contentWidth, itemWidth: itemWidth, date: selectedDate)
                        
                        // Animate snapping
                        withAnimation {
                            scrollOffset = newOffset
                        }
                    }
                }
                .gesture(DragGesture()
                    .onChanged({ event in
                        isDragging = true
                        dragOffset = event.translation.width
                        
                        let baseOffset = scrollOffset + dragOffset
                        let contentOffset = min(max(0, contentWidth / 2 - baseOffset - itemWidth / 2), contentWidth - itemWidth)
                        let offsetDate = dateRange.start.next(day: Int((contentOffset / (itemWidth + itemSpacing)).rounded()))
                        
                        if offsetDate != selectedDate {
                            withAnimation {
                                selectedDate = offsetDate
                            }
                        }
                    })
                    .onEnded({ event in
                        // Scroll to where user dragged
                        scrollOffset += event.predictedEndTranslation.width
                        dragOffset = 0
                        isDragging = false
                        
                        // Now calculate which item to snap to
                        
                        // Center position of current offset
                        let center = scrollOffset + (screenWidth / 2.0) + (contentWidth / 2.0)
                        
                        // Calculate which item we are closest to using the defined size
                        var index = (center - (screenWidth / 2.0)) / (itemWidth + itemSpacing)
                        
                        // Should we stay at current index or are we closer to the next item...
                        if index.remainder(dividingBy: 1) > 0.5 {
                            index += 1
                        } else {
                            index = CGFloat(Int(index))
                        }
                        
                        // Protect from scrolling out of bounds
                        index = min(index, CGFloat(visibleDates) - 1)
                        index = max(index, 0)
                        
                        // Set final offset (snapping to item)
                        let newOffset = index * itemWidth + (index - 1) * itemSpacing - (contentWidth / 2.0) + (screenWidth / 2.0) - ((screenWidth - itemWidth) / 2.0) + itemSpacing
                        
                        // Animate snapping
                        withAnimation {
                            scrollOffset = newOffset
                        }

                        let baseOffset = scrollOffset + dragOffset
                        let contentOffset = min(max(0, contentWidth / 2 - baseOffset - itemWidth / 2), contentWidth - itemWidth)
                        let offsetDate = dateRange.start.next(day: Int((contentOffset / (itemWidth + itemSpacing)).rounded()))
                        
                        if offsetDate != selectedDate {
                            withAnimation {
                                selectedDate = offsetDate
                            }
                        }
                    })
                )
                .onChange(of: g.size) {
                    let (newOffset, _) = calculateDateOffset(contentWidth, itemWidth: itemWidth, date: selectedDate)
                    
                    scrollOffset = newOffset
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
   }

}


struct ISVContentView: View {
    let dateRange: DateInterval
    
    @State var currentDate = Date.today
    
    var body: some View {
        VStack {
            Text("\(currentDate.formatted())")
            CurrentDayIndicator()
            ScrollingWeekView(selectedDate: $currentDate, dateRange: dateRange) { date in
                Color.green
                    .overlay(Text("\(date.formatted(.iso8601))"))
            }
        }
    }
}


struct ISVContentView_Previews: PreviewProvider {
    static var previews: some View {
        ISVContentView(dateRange: DateInterval(start: Date.yesterday.next(day: -1), end: Date.tomorrow))
        ISVContentView(dateRange: DateInterval(start: Date.today.next(day: -10), end: Date.today.next(day: 12)))
    }
}
