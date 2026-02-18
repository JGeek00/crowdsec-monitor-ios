import SwiftUI

struct MultiSelectFilter: View {
    let options: [String]
    let selected: [String]
    let onChange: (_ values: [String]) -> Void
    let customComponent: ((_ value: String) -> AnyView)?
    
    init(options: [String], selected: [String], onChange: @escaping (_ values: [String]) -> Void, customComponent: ((_ value: String) -> AnyView)? = nil) {
        self.options = options
        self.selected = selected
        self.onChange = onChange
        self.customComponent = customComponent
    }
    
    private func handleOptionToggle(_ option: String) {
        onChange(selected.contains(option) ? selected.filter { $0 != option } : selected + [option])
    }
    
    var body: some View {
        List(options, id: \.self) { option in
            let isSelected = self.selected.contains(option)
            Button {
                handleOptionToggle(option)
            } label: {
                HStack {
                    if let customComponent = customComponent {
                        customComponent(option)
                    }
                    else {
                        Text(verbatim: option)
                    }
                    Spacer()
                    if isSelected {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.blue)
                            .fontWeight(.medium)
                    }
                }
            }
            .foregroundStyle(Color.foreground)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    @Previewable @State var selectedOptions: [String] = ["Option 1"]
    
    NavigationStack {
        MultiSelectFilter(
            options: ["Option 1", "Option 2", "Option 3"],
            selected: selectedOptions,
            onChange: { newValues in
                selectedOptions = newValues
            }
        )
        .navigationTitle("Multi Select Filter")
    }
}

#Preview("With custom view") {
    @Previewable @State var selectedOptions: [String] = ["Option 1"]
    
    NavigationStack {
        MultiSelectFilter(
            options: ["Option 1", "Option 2", "Option 3"],
            selected: selectedOptions,
            onChange: { newValues in
                selectedOptions = newValues
            },
            customComponent: { value in
                AnyView(
                    Text(verbatim: "Custom \(value)")
                        .foregroundStyle(.red)
                )
            }
        )
        .navigationTitle("Multi Select Filter")
    }
}
