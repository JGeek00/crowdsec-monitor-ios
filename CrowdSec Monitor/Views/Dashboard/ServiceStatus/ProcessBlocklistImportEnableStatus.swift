import SwiftUI

struct ProcessBlocklistImportEnableStatus: View {
    let process: APIStatusResponse_Process
    
    init(process: APIStatusResponse_Process) {
        self.process = process
    }
    
    var body: some View {
        let status: APIStatusResponse_ProcessBlocklist? = {
            if let blocklistImport = process.blocklistImport {
                return blocklistImport
            } else if let blocklistEnable = process.blocklistEnable {
                return blocklistEnable
            } else {
                return nil
            }
        }()
        
        if let status = status {
            VStack(alignment: .leading, spacing: 24) {
                if process.blocklistImport != nil {
                    Text("Import blocklist \(status.blocklistName)")
                        .fontWeight(.semibold)
                }
                else if process.blocklistEnable != nil {
                    Text("Enable blocklist \(status.blocklistName)")
                        .fontWeight(.semibold)
                }
                StatusProcessStepper(fetch: status.fetched, parse: status.parsed, imp: status.imported)
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
}

#Preview("Fetch running") {
    List {
        ProcessBlocklistImportEnableStatus(process: APIStatusResponse_Process(id: "", beginDatetime: "2026-04-11T16:20:00.000Z", endDatetime: nil, successful: nil, error: nil, blocklistImport: nil, blocklistEnable: APIStatusResponse_ProcessBlocklist(blocklistId: 1, blocklistName: "Blocklist 1", step: .fetch, fetched: .running, parsed: .pending, imported: .pending, processIps: .init(totalIps: 1000, processedIps: 0)), blocklistDisable: nil, blocklistDelete: nil, blocklistRefresh: nil))
    }
}

#Preview("Parse running") {
    List {
        ProcessBlocklistImportEnableStatus(process: APIStatusResponse_Process(id: "", beginDatetime: "2026-04-11T16:20:00.000Z", endDatetime: nil, successful: nil, error: nil, blocklistImport: nil, blocklistEnable: APIStatusResponse_ProcessBlocklist(blocklistId: 1, blocklistName: "Blocklist 1", step: .parse, fetched: .successful, parsed: .running, imported: .pending, processIps: .init(totalIps: 1000, processedIps: 0)), blocklistDisable: nil, blocklistDelete: nil, blocklistRefresh: nil))
    }
}

#Preview("Parse failed") {
    List {
        ProcessBlocklistImportEnableStatus(process: APIStatusResponse_Process(id: "", beginDatetime: "2026-04-11T16:20:00.000Z", endDatetime: "2026-04-11T16:20:07.000Z", successful: false, error: nil, blocklistImport: nil, blocklistEnable: APIStatusResponse_ProcessBlocklist(blocklistId: 1, blocklistName: "Blocklist 1", step: .parse, fetched: .successful, parsed: .failed, imported: .pending, processIps: .init(totalIps: 1000, processedIps: 0)), blocklistDisable: nil, blocklistDelete: nil, blocklistRefresh: nil))
    }
}

#Preview("Import running") {
    List {
        ProcessBlocklistImportEnableStatus(process: APIStatusResponse_Process(id: "", beginDatetime: "2026-04-11T16:20:00.000Z", endDatetime: nil, successful: nil, error: nil, blocklistImport: nil, blocklistEnable: APIStatusResponse_ProcessBlocklist(blocklistId: 1, blocklistName: "Blocklist 1", step: .import, fetched: .successful, parsed: .successful, imported: .running, processIps: .init(totalIps: 1000, processedIps: 200)), blocklistDisable: nil, blocklistDelete: nil, blocklistRefresh: nil))
    }
}

#Preview("Import success") {
    List {
        ProcessBlocklistImportEnableStatus(process: APIStatusResponse_Process(id: "", beginDatetime: "2026-04-11T16:20:00.000Z", endDatetime: "2026-04-11T16:20:10.000Z", successful: true, error: nil, blocklistImport: nil, blocklistEnable: APIStatusResponse_ProcessBlocklist(blocklistId: 1, blocklistName: "Blocklist 1", step: .import, fetched: .successful, parsed: .successful, imported: .successful, processIps: .init(totalIps: 1000, processedIps: 1000)), blocklistDisable: nil, blocklistDelete: nil, blocklistRefresh: nil))
    }
}

#Preview("Import failed") {
    List {
        ProcessBlocklistImportEnableStatus(process: APIStatusResponse_Process(id: "", beginDatetime: "2026-04-11T16:20:00.000Z", endDatetime: "2026-04-11T16:20:10.000Z", successful: false, error: nil, blocklistImport: nil, blocklistEnable: APIStatusResponse_ProcessBlocklist(blocklistId: 1, blocklistName: "Blocklist 1", step: .import, fetched: .successful, parsed: .successful, imported: .failed, processIps: .init(totalIps: 1000, processedIps: 700)), blocklistDisable: nil, blocklistDelete: nil, blocklistRefresh: nil))
    }
}
