import SwiftUI

struct FullListDashboardPieChart: View {
    let data: [FullItemDashboardItemDataForView]
    @State private var selectedSlice: FullItemDashboardItemDataForView?
    @State private var tooltipPosition: CGPoint = .zero
    
    init(data: [FullItemDashboardItemDataForView]) {
        self.data = data
    }
    
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let radius = size / 2
            
            ZStack {
                ForEach(Array(data.enumerated()), id: \.element) { index, item in
                    PieSlice(
                        startAngle: startAngle(for: index),
                        endAngle: endAngle(for: index),
                        color: item.color
                    )
                    .frame(width: size, height: size)
                    .position(center)
                }
                
                // Tooltip
                if let selectedSlice = selectedSlice {
                    TooltipView(item: selectedSlice)
                        .position(tooltipPosition)
                        .transition(.opacity.combined(with: .scale(scale: 0.8)))
                        .allowsHitTesting(false)
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        handleDrag(at: value.location, center: center, radius: radius)
                    }
                    .onEnded { _ in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedSlice = nil
                        }
                    }
            )
        }
        .aspectRatio(1, contentMode: .fit)
    }
    
    private func startAngle(for index: Int) -> Angle {
        let previousPercentages = data.prefix(index).reduce(0.0) { $0 + $1.percentage }
        return Angle(degrees: previousPercentages * 360 - 90)
    }
    
    private func endAngle(for index: Int) -> Angle {
        let previousPercentages = data.prefix(index + 1).reduce(0.0) { $0 + $1.percentage }
        return Angle(degrees: previousPercentages * 360 - 90)
    }
    
    private func handleDrag(at location: CGPoint, center: CGPoint, radius: CGFloat) {
        // Calculate angle from center to touch point
        let dx = location.x - center.x
        let dy = location.y - center.y
        
        // Check if touch is within the circle
        let distance = sqrt(dx * dx + dy * dy)
        guard distance <= radius else {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedSlice = nil
            }
            return
        }
        
        // Calculate angle (0° is right, increases counter-clockwise)
        var touchAngle = atan2(dy, dx) * 180 / .pi
        // Adjust to start from top (like our pie chart)
        touchAngle = touchAngle + 90
        if touchAngle < 0 {
            touchAngle += 360
        }
        
        // Find which slice contains this angle
        for (index, item) in data.enumerated() {
            let start = startAngle(for: index).degrees + 90
            let end = endAngle(for: index).degrees + 90
            
            let normalizedStart = start >= 0 ? start : start + 360
            let normalizedEnd = end >= 0 ? end : end + 360
            
            let isInSlice: Bool
            if normalizedEnd < normalizedStart {
                // Slice crosses 0°
                isInSlice = touchAngle >= normalizedStart || touchAngle <= normalizedEnd
            } else {
                isInSlice = touchAngle >= normalizedStart && touchAngle <= normalizedEnd
            }
            
            if isInSlice {
                withAnimation(.easeInOut(duration: 0.15)) {
                    // Calculate tooltip position at the middle of the slice
                    let midAngle = (startAngle(for: index).radians + endAngle(for: index).radians) / 2
                    let tooltipDistance = radius * 0.65 // Position tooltip at 65% of radius
                    
                    let x = center.x + cos(midAngle) * tooltipDistance
                    let y = center.y + sin(midAngle) * tooltipDistance
                    
                    tooltipPosition = CGPoint(x: x, y: y)
                    selectedSlice = item
                }
                return
            }
        }
    }
}

// MARK: - Tooltip View
fileprivate struct TooltipView: View {
    let item: FullItemDashboardItemDataForView
    
    var body: some View {
        VStack(spacing: 4) {
            Text(displayName)
                .font(.headline)
                .foregroundColor(.white)
            Text("\(item.value)")
                .font(.subheadline)
                .foregroundColor(.white)
            Text(verbatim: "\(Int(item.percentage * 100))%")
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black.opacity(0.8))
        )
        .shadow(radius: 4)
    }
    
    private var displayName: String {
        // Check if it's "Otros" or similar non-country code
        if item.item == "Otros" || item.item == "Others" {
            return item.item
        }
        
        // Try to get country name from code
        let locale = Locale.current
        return locale.localizedString(forRegionCode: item.item.uppercased()) ?? item.item
    }
}

fileprivate struct PieSlice: View {
    let startAngle: Angle
    let endAngle: Angle
    let color: Color
    
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let radius = size / 2
            
            Path { path in
                path.move(to: center)
                path.addArc(
                    center: center,
                    radius: radius,
                    startAngle: startAngle,
                    endAngle: endAngle,
                    clockwise: false
                )
                path.closeSubpath()
            }
            .fill(color)
        }
    }
}

#Preview {
    FullListDashboardPieChart(data: [
        FullItemDashboardItemDataForView(item: "ES", value: 100, percentage: 0.5, color: .blue),
        FullItemDashboardItemDataForView(item: "US", value: 50, percentage: 0.25, color: .red),
        FullItemDashboardItemDataForView(item: "FR", value: 30, percentage: 0.15, color: .green),
        FullItemDashboardItemDataForView(item: "Otros", value: 20, percentage: 0.1, color: .gray)
    ])
    .frame(width: 300, height: 300)
    .padding()
}
