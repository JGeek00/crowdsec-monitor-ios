import SwiftUI

struct DurationPickerView: View {
    @Binding var days: Int
    @Binding var hours: Int
    @Binding var minutes: Int
    
    var body: some View {
        HStack(spacing: 8) {
            // Days Picker
            Picker(String(), selection: $days) {
                ForEach(0...30, id: \.self) { day in
                    Text(verbatim: "\(day)").tag(day)
                }
            }
            .pickerStyle(.wheel)
            .frame(maxWidth: .infinity)
            .clipped()
            
            Text("days")
                .foregroundStyle(.secondary)
                .frame(width: 40, alignment: .leading)
            
            // Hours Picker
            Picker(String(), selection: $hours) {
                ForEach(0...23, id: \.self) { hour in
                    Text(verbatim: "\(hour)").tag(hour)
                }
            }
            .pickerStyle(.wheel)
            .frame(maxWidth: .infinity)
            .clipped()
            
            Text("hours")
                .foregroundStyle(.secondary)
                .frame(width: 50, alignment: .leading)
            
            // Minutes Picker
            Picker(String(), selection: $minutes) {
                ForEach(0...59, id: \.self) { minute in
                    Text(verbatim: "\(minute)").tag(minute)
                }
            }
            .pickerStyle(.wheel)
            .frame(maxWidth: .infinity)
            .clipped()
            
            Text(verbatim: "min")
                .foregroundStyle(.secondary)
                .frame(width: 40, alignment: .leading)
        }
        .frame(height: 120)
    }
}

#Preview {
    @Previewable @State var days = 0
    @Previewable @State var hours = 4
    @Previewable @State var minutes = 0
    
    DurationPickerView(days: $days, hours: $hours, minutes: $minutes)
}
