import SwiftUI

fileprivate let LEFT_RADIUS = UnevenRoundedRectangle(
    cornerRadii: .init(
        topLeading: 20,
        bottomLeading: 20,
        bottomTrailing: 0,
        topTrailing: 0
    )
)
fileprivate let RIGHT_RADIUS = UnevenRoundedRectangle(
    cornerRadii: .init(
        topLeading: 0,
        bottomLeading: 0,
        bottomTrailing: 20,
        topTrailing: 20
    )
)
fileprivate let NO_RADIUS = UnevenRoundedRectangle(
    cornerRadii: .init(
        topLeading: 0,
        bottomLeading: 0,
        bottomTrailing: 0,
        topTrailing: 0
    )
)

struct StatusProcessStepper: View {
    let fetch: APIStatusResponse_ProcessBlocklistFieldStatus
    let parse: APIStatusResponse_ProcessBlocklistFieldStatus
    let delete: APIStatusResponse_ProcessBlocklistFieldStatus?
    let imp: APIStatusResponse_ProcessBlocklistFieldStatus
    let joinedMode: Bool
    
    init(fetch: APIStatusResponse_ProcessBlocklistFieldStatus, parse: APIStatusResponse_ProcessBlocklistFieldStatus, delete: APIStatusResponse_ProcessBlocklistFieldStatus? = nil, imp: APIStatusResponse_ProcessBlocklistFieldStatus, joinedMode: Bool = false) {
        self.fetch = fetch
        self.parse = parse
        self.delete = delete
        self.imp = imp
        self.joinedMode = joinedMode
    }
    
    var body: some View {
        HStack(spacing: joinedMode ? 2 : 6) {
            StepPill(step: .fetch, status: fetch)
            StepDivider()
            StepPill(step: .parse, status: parse)
            StepDivider()
            if let del = delete {
                StepPill(step: .delete, status: del)
                StepDivider()
            }
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
            case .delete:
                return String(localized: "Delete")
            }
        }()
        
        HStack(spacing: 4) {
            if status == .running {
                ProgressView()
                    .controlSize(.mini)
                    .tint(Color.white)
                Spacer().frame(width: 2)
            }
            else if status == .successful && !joinedMode {
                Image(systemName: "checkmark")
                Spacer().frame(width: 2)
            }
            else if status == .failed && !joinedMode {
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
            Group {
                if joinedMode == true {
                    step == .fetch ? LEFT_RADIUS : step == .import ? RIGHT_RADIUS : NO_RADIUS
                }
                else {
                    RoundedRectangle(cornerRadius: 20)
                }
            }
            .foregroundStyle(color)
        )
    }
    
    @ViewBuilder
    func StepDivider() -> some View {
        if !joinedMode {
            RoundedRectangle(cornerRadius: 20)
                .frame(maxWidth: .infinity, minHeight: 2, maxHeight: 2)
                .foregroundStyle(Color.gray)
                .padding(.horizontal, 4)
        }
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
#Preview("With delete") {
    StatusProcessStepper(fetch: .successful, parse: .successful, delete: .running, imp: .pending, joinedMode: true)
        .padding(.horizontal, 16)
}
