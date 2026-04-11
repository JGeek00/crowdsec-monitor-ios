import SwiftUI

struct ProcessBlocklistDeleteDisableStatus: View {
    let process: APIStatusResponse_Process
    
    init(process: APIStatusResponse_Process) {
        self.process = process
    }
    
    var body: some View {
        let status: APIStatusResponse_ProcessBlocklistIps? = {
            if let blocklistDelete = process.blocklistDelete {
                return blocklistDelete
            } else if let blocklistDisable = process.blocklistDisable {
                return blocklistDisable
            } else {
                return nil
            }
        }()
        
        if let status = status {
            VStack(alignment: .leading, spacing: 24) {
                if process.blocklistDelete != nil {
                    Text("Blocklist delete")
                        .fontWeight(.semibold)
                }
                else if process.blocklistDisable != nil {
                    Text("Blocklist disable")
                        .fontWeight(.semibold)
                }
                if process.successful == nil {
                    VStack {
                        HStack {
                            Text("Processed \(status.processedIps) of \(status.ipsToDelete) IPs")
                            Spacer()
                            Text(verbatim: "\(Int(Double(status.processedIps) / Double(status.ipsToDelete) * 100))%")
                        }
                        .font(.system(size: 14))
                        ProgressView(value: Double(status.processedIps) / Double(status.ipsToDelete))
                    }
                }
                if process.successful == false {
                    Text("\(status.processedIps) IP addresses processed of a total of \(status.ipsToDelete)")
                        .font(.system(size: 14))
                }
                if process.successful == true {
                    Text("Processed all \(status.processedIps) IP addresses")
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

#Preview("Processing") {
    List {
        ProcessBlocklistDeleteDisableStatus(process: APIStatusResponse_Process(id: "1", beginDatetime: "2026-04-11T16:20:00.000Z", endDatetime: "2026-04-11T16:20:07.000Z", successful: nil, error: nil, blocklistImport: nil, blocklistEnable: nil, blocklistDisable: APIStatusResponse_ProcessBlocklistIps(blocklistIps: 1000, ipsToDelete: 1500, processedIps: 800), blocklistDelete: nil, blocklistRefresh: nil))
    }
}

#Preview("Error") {
    List {
        ProcessBlocklistDeleteDisableStatus(process: APIStatusResponse_Process(id: "1", beginDatetime: "2026-04-11T16:20:00.000Z", endDatetime: "2026-04-11T16:20:07.000Z", successful: false, error: nil, blocklistImport: nil, blocklistEnable: nil, blocklistDisable: APIStatusResponse_ProcessBlocklistIps(blocklistIps: 1000, ipsToDelete: 1500, processedIps: 800), blocklistDelete: nil, blocklistRefresh: nil))
    }
}

#Preview("Success") {
    List {
        ProcessBlocklistDeleteDisableStatus(process: APIStatusResponse_Process(id: "1", beginDatetime: "2026-04-11T16:20:00.000Z", endDatetime: "2026-04-11T16:20:07.000Z", successful: true, error: nil, blocklistImport: nil, blocklistEnable: nil, blocklistDisable: APIStatusResponse_ProcessBlocklistIps(blocklistIps: 1000, ipsToDelete: 1500, processedIps: 1500), blocklistDelete: nil, blocklistRefresh: nil))
    }
}
