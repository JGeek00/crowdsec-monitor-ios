import SwiftUI

struct ProcessBlocklistSingleRefreshStatus: View {
    let process: APIStatusResponse_Process

    init(process: APIStatusResponse_Process) {
        self.process = process
    }

    var body: some View {
        guard let status = process.blocklistSingleRefresh else { return AnyView(EmptyView()) }

        return AnyView(
            VStack(alignment: .leading, spacing: 24) {
                Text("Refresh blocklist \(status.blocklistName)")
                    .fontWeight(.semibold)

                StatusProcessStepper(fetch: status.fetched, parse: status.parsed, delete: status.deleted, imp: status.imported, joinedMode: true)

                if status.step == .import && process.successful == nil {
                    VStack {
                        HStack {
                            Text("Imported \(status.processIps.processedIps) of \(status.processIps.totalIps) IPs")
                            Spacer()
                            Text(verbatim: "\(Int(Double(status.processIps.processedIps) / Double(status.processIps.totalIps) * 100))%")
                        }
                        .font(.system(size: 14))
                        ProgressView(value: Double(status.processIps.processedIps) / Double(status.processIps.totalIps))
                    }
                }

                if status.step == .import && process.successful == false {
                    Text("\(status.processIps.processedIps) IP addresses imported of a total of \(status.processIps.totalIps)")
                        .font(.system(size: 14))
                }

                if process.successful == true {
                    Text("Processed all \(status.processIps.totalIps) IP addresses")
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
        )
    }
}

#Preview("Import running") {
    List {
        ProcessBlocklistSingleRefreshStatus(
            process: APIStatusResponse_Process(
                id: "1",
                beginDatetime: "2026-04-11T16:20:00.000Z",
                endDatetime: nil,
                successful: nil,
                error: nil,
                blocklistImport: nil,
                blocklistEnable: nil,
                blocklistDisable: nil,
                blocklistDelete: nil,
                blocklistRefresh: nil,
                blocklistSingleRefresh: APIStatusResponse_ProcessBlocklistSingleRefresh(
                    blocklistId: 16,
                    blocklistName: "blocklist.de",
                    step: .import,
                    fetched: .successful,
                    parsed: .successful,
                    deleted: .successful,
                    imported: .running,
                    processIps: .init(totalIps: 23915, processedIps: 12000)
                )
            )
        )
    }
}

#Preview("Success") {
    List {
        ProcessBlocklistSingleRefreshStatus(
            process: APIStatusResponse_Process(
                id: "2",
                beginDatetime: "2026-04-11T16:20:00.000Z",
                endDatetime: "2026-04-11T16:20:10.000Z",
                successful: true,
                error: nil,
                blocklistImport: nil,
                blocklistEnable: nil,
                blocklistDisable: nil,
                blocklistDelete: nil,
                blocklistRefresh: nil,
                blocklistSingleRefresh: APIStatusResponse_ProcessBlocklistSingleRefresh(
                    blocklistId: 16,
                    blocklistName: "blocklist.de",
                    step: .import,
                    fetched: .successful,
                    parsed: .successful,
                    deleted: .successful,
                    imported: .successful,
                    processIps: .init(totalIps: 23915, processedIps: 23915)
                )
            )
        )
    }
}

#Preview("Failed") {
    List {
        ProcessBlocklistSingleRefreshStatus(
            process: APIStatusResponse_Process(
                id: "3",
                beginDatetime: "2026-04-11T16:20:00.000Z",
                endDatetime: "2026-04-11T16:20:08.000Z",
                successful: false,
                error: nil,
                blocklistImport: nil,
                blocklistEnable: nil,
                blocklistDisable: nil,
                blocklistDelete: nil,
                blocklistRefresh: nil,
                blocklistSingleRefresh: APIStatusResponse_ProcessBlocklistSingleRefresh(
                    blocklistId: 16,
                    blocklistName: "blocklist.de",
                    step: .import,
                    fetched: .successful,
                    parsed: .successful,
                    deleted: .successful,
                    imported: .failed,
                    processIps: .init(totalIps: 23915, processedIps: 8500)
                )
            )
        )
    }
}
