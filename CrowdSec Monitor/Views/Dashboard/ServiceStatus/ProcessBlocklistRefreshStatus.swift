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
                    VStack {
                        HStack {
                            Text("Processed \(status.processedBlocklists) of \(status.totalBlocklists) blocklists")
                            Spacer()
                            Text(verbatim: "\(Int(Double(status.processedBlocklists) / Double(status.totalBlocklists) * 100))%")
                        }
                        .font(.system(size: 14))
                        ProgressView(value: Double(status.processedBlocklists) / Double(status.totalBlocklists))
                    }
                }
                if process.successful == false {
                    Text("\(status.processedBlocklists) blocklists processed of a total of \(status.totalBlocklists)")
                        .font(.system(size: 14))
                }
                if process.successful == true {
                    Text("Processed all \(status.processedBlocklists) blocklists")
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

#Preview {
    List {
        ProcessBlocklistRefreshStatus(process: APIStatusResponse_Process(id: "1", beginDatetime: "2026-04-11T16:20:00.000Z", endDatetime: "2026-04-11T16:20:07.000Z", successful: nil, error: nil, blocklistImport: nil, blocklistEnable: nil, blocklistDisable: nil, blocklistDelete: nil, blocklistRefresh: APIStatusResponse_ProcessBlocklistRefresh(totalBlocklists: 10, processedBlocklists: 10, successful: 8, failed: 2)))
    }
}
