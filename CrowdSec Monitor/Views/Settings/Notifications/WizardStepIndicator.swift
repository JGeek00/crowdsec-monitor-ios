import SwiftUI

struct WizardStepIndicator: View {
    let totalSteps: Int
    let currentStep: Int

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<totalSteps, id: \.self) { index in
                Capsule()
                    .fill(index <= currentStep ? Color.accentColor : Color.gray.opacity(0.3))
                    .frame(width: index == currentStep ? 28 : 12, height: 6)
                    .animation(.default, value: currentStep)
            }
        }
        .accessibilityLabel(
            Text(
                verbatim: String(
                    format: String(localized: "Step %d of %d"),
                    currentStep + 1,
                    totalSteps
                )
            )
        )
    }
}
