import SwiftUI

struct ProcessBlocklistRefreshStatus: View {
    let process: APIStatusResponse_Process
    
    init(process: APIStatusResponse_Process) {
        self.process = process
    }
    
    var body: some View {
        let status: APIStatusResponse_ProcessBlocklistRefresh? = {
            if let blocklistRefresh = process.blocklistRefresh {
                return blocklistRefresh
            } else {
                return nil
            }
        }()
        
        if let status = status {
            VStack(alignment: .leading, spacing: 24) {
                Text("Refresh blocklists")
                    .fontWeight(.semibold)
                if process.successful == nil {
                    let currentBlocklist = status.blocklists[status.currentBlocklist-1]
                    VStack {
                        HStack {
                            Text("Current")
                            Spacer()
                            Text(verbatim: currentBlocklist.name)
                        }
                        .font(.system(size: 14))
                        StatusProcessStepper(fetch: currentBlocklist.steps.fetch, parse: currentBlocklist.steps.parse, delete: currentBlocklist.steps.delete, imp: currentBlocklist.steps.import, joinedMode: true)
                        Spacer()
                            .frame(height: 24)
                        HStack {
                            Text("Total")
                            Spacer()
                            Text("\(status.currentBlocklist) of \(status.totalBlocklists)")
                        }
                        .font(.system(size: 14))
                        ProgressView(value: Double(status.currentBlocklist) / Double(status.totalBlocklists))
                        .font(.system(size: 14))
                    }
                }
                if process.successful == false {
                    let successfulAmount = status.blocklists.filter({ $0.steps.fetch == .successful && $0.steps.parse == .successful && $0.steps.delete == .successful && $0.steps.import == .successful }).count
                    Text("\(successfulAmount) blocklists processed of a total of \(status.totalBlocklists)")
                        .font(.system(size: 14))
                }
                if process.successful == true {
                    Text("Processed all \(status.totalBlocklists) blocklists")
                        .font(.system(size: 14))
                }
                HStack {
                    if let startDate = process.beginDatetime.toDateFromISO8601() {
                        Text("Started at \(startDate.formatted(date: .omitted, time: .standard))")
                    }
                    if let endDate = process.endDatetime?.toDateFromISO8601() {
                        Spacer()
                        Text("Finished at \(endDate.formatted(date: .omitted, time: .standard))")
                    }
                }
                .fontWeight(.medium)
                .font(.system(size: 14))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    @ViewBuilder
    func step(stepType: APIStatusResponse_ProcessBlocklistStep, status: APIStatusResponse_ProcessBlocklistFieldStatus) -> some View {
        let label = {
            switch stepType {
            case .fetch:
                return String(localized: "Fetch")
            case .parse:
                return String(localized: "Parse")
            case .delete:
                return String(localized: "Delete")
            case .import:
                return String(localized: "Import")
            }
        }
        Group {
            switch status {
            case .pending:
                HStack(spacing: 6) {
                    Text(verbatim: label())
                }
                .foregroundStyle(.gray)
            case .running:
                HStack(spacing: 6) {
                    Text(verbatim: label())
                    ProgressView()
                        .controlSize(.small)
                }
                .foregroundStyle(.blue)
            case .successful:
                HStack(spacing: 6) {
                    Text(verbatim: label())
                    Image(systemName: "checkmark")
                }
                .foregroundStyle(.green)
            case .failed:
                HStack(spacing: 6) {
                    Text(verbatim: label())
                    Image(systemName: "xmark")
                }
                .foregroundStyle(.red)
            }
        }
        .fontWeight(.medium)
    }
}

#Preview {
    List {
        ProcessBlocklistRefreshStatus(
            process: APIStatusResponse_Process(
                id: "1",
                beginDatetime: "2026-04-11T16:20:00.000Z",
                endDatetime: "2026-04-11T16:20:07.000Z",
                successful: nil,
                error: nil,
                blocklistImport: nil,
                blocklistEnable: nil,
                blocklistDisable: nil,
                blocklistDelete: nil,
                blocklistRefresh: APIStatusResponse_ProcessBlocklistRefresh(
                    totalBlocklists: 3,
                    currentBlocklist: 2,
                    blocklists: [
                        APIStatusResponse_ProcessBlocklistRefresh_Blocklist(
                            number: 1,
                            name: "Blocklist 1",
                            steps: APIStatusResponse_ProcessBlocklistRefresh_Blocklist_Steps(
                                fetch: .successful,
                                parse: .successful,
                                delete: .successful,
                                import: .successful
                            )
                        ),
                        APIStatusResponse_ProcessBlocklistRefresh_Blocklist(
                            number: 2,
                            name: "Blocklist 2",
                            steps: APIStatusResponse_ProcessBlocklistRefresh_Blocklist_Steps(
                                fetch: .successful,
                                parse: .successful,
                                delete: .running,
                                import: .pending
                            )
                        ),
                        APIStatusResponse_ProcessBlocklistRefresh_Blocklist(
                            number: 3,
                            name: "Blocklist 3",
                            steps: APIStatusResponse_ProcessBlocklistRefresh_Blocklist_Steps(
                                fetch: .pending,
                                parse: .pending,
                                delete: .pending,
                                import: .pending
                            )
                        )
                    ],
                    totalIPS: 10000
                ),
                blocklistSingleRefresh: nil
            )
        )
    }
}
