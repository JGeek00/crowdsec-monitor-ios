import SwiftUI

struct AppSettingsView: View {
    @SharedAppStorage(StorageKeys.topItemsDashboard) private var amountItemsDashboard: Int = Defaults.topItemsDashboard
    @SharedAppStorage(StorageKeys.showDefaultActiveDecisions) private var showDefaultActiveDecisions: Bool = Defaults.showDefaultActiveDecisions
    @SharedAppStorage(StorageKeys.hideDefaultDuplicatedDecisions) private var hideDefaultDuplicatedDecisions: Bool = Defaults.hideDefaultDuplicatedDecisions
    
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(AppIconManager.self) private var appIconManager
            
    var body: some View {
        List {
            Section("Dashboard") {
                HStack {
                    Stepper("Amount of items to display in dashboard lists", value: $amountItemsDashboard, in: 5...10)
                    Spacer()
                        .frame(width: 24)
                    Text(verbatim: "\(amountItemsDashboard)")
                        .monospacedDigit()
                        .background(Circle().fill(Color.gray.opacity(0.2)).frame(width: 30, height: 30))
                }
            }
            
            Section("Decisions") {
                Toggle("Show by default only active decisions", isOn: $showDefaultActiveDecisions)
                // Toggle("Hide by default active duplicated decisions", isOn: $hideDefaultDuplicatedDecisions)
            }
            
            Section("Icon") {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 20) {
                        ForEach(AppIcon.allCases, id: \.self) { icon in
                            iconSelectorItem(
                                icon: icon,
                                isSelected: appIconManager.appIcon == icon,
                                onSelect: {
                                    appIconManager.setAlternateAppIcon(icon: icon)
                                }
                            )
                        }
                    }
                }
                .padding(.vertical, 8)
            }
        }
        .navigationTitle("Application settings")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    func iconSelectorItem(icon: AppIcon, isSelected: Bool, onSelect: @escaping () -> Void) -> some View {
        Button(action: onSelect) {
            VStack(spacing: 8) {
                Image("\(icon.id)-Image")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 3)
                    )
                    .overlay(alignment: .topTrailing) {
                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .fontWeight(.semibold)
                                .font(.system(size: 16))
                                .foregroundStyle(.blue)
                                .background(.white)
                                .clipShape(Circle())
                                .offset(x: 8, y: -8)
                        }
                    }
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    AppSettingsView()
}
