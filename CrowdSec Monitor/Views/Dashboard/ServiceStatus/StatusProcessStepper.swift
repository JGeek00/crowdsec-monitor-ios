import SwiftUI

struct StatusProcessStepper: View {
    let fetch: APIStatusResponse_ProcessBlocklistFieldStatus
    let parse: APIStatusResponse_ProcessBlocklistFieldStatus
    let imp: APIStatusResponse_ProcessBlocklistFieldStatus
    
    init(fetch: APIStatusResponse_ProcessBlocklistFieldStatus, parse: APIStatusResponse_ProcessBlocklistFieldStatus, imp: APIStatusResponse_ProcessBlocklistFieldStatus) {
        self.fetch = fetch
        self.parse = parse
        self.imp = imp
    }
    
    var body: some View {
        HStack {
            StepPill(step: .fetch, status: fetch)
            StepDivider()
            StepPill(step: .parse, status: parse)
            StepDivider()
            StepPill(step: .import, status: imp)
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    func StepPill(step: APIStatusResponse_ProcessBlocklistStep, status: APIStatusResponse_ProcessBlocklistFieldStatus) -> some View {
        let color = {
            switch status {
            case .pending:
                Color.gray
            case .running:
                Color.blue
            case .successful:
                Color.green
            case .failed:
                Color.red
            }
        }()
        
        let label = {
            switch step {
            case .fetch:
                return String(localized: "Fetch")
            case .parse:
                return String(localized: "Parse")
            case .import:
                return String(localized: "Import")
            }
        }()
        
        HStack(spacing: 4) {
            if status == .running {
                ProgressView()
                    .controlSize(.mini)
                    .tint(Color.white)
                Spacer().frame(width: 2)
            }
            else if status == .successful {
                Image(systemName: "checkmark")
                Spacer().frame(width: 2)
            }
            else if status == .failed {
                Image(systemName: "xmark")
                Spacer().frame(width: 2)
            }
            Text(label)
                .lineLimit(1)
                .fixedSize()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .font(.system(size: 14))
        .fontWeight(.semibold)
        .foregroundStyle(Color.white)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .foregroundStyle(color)
        )
    }
    
    @ViewBuilder
    func StepDivider() -> some View {
        RoundedRectangle(cornerRadius: 20)
            .frame(maxWidth: .infinity, minHeight: 4, maxHeight: 4)
            .foregroundStyle(Color.gray)
            .padding(.horizontal, 4)
    }
}

#Preview("Running fetch") {
    StatusProcessStepper(fetch: .running, parse: .pending, imp: .pending)
        .padding(.horizontal, 16)
}
#Preview("Failed fetch") {
    StatusProcessStepper(fetch: .failed, parse: .pending, imp: .pending)
        .padding(.horizontal, 16)
}
#Preview("Running parse") {
    StatusProcessStepper(fetch: .successful, parse: .running, imp: .pending)
        .padding(.horizontal, 16)
}
#Preview("Failed parse") {
    StatusProcessStepper(fetch: .successful, parse: .failed, imp: .pending)
        .padding(.horizontal, 16)
}
#Preview("Running import") {
    StatusProcessStepper(fetch: .successful, parse: .successful, imp: .running)
        .padding(.horizontal, 16)
}
#Preview("Failed import") {
    StatusProcessStepper(fetch: .successful, parse: .successful, imp: .failed)
        .padding(.horizontal, 16)
}
#Preview("Success import") {
    StatusProcessStepper(fetch: .successful, parse: .successful, imp: .successful)
        .padding(.horizontal, 16)
}
