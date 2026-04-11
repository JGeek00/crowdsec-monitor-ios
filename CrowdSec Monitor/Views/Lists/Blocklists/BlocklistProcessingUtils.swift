import Foundation

func getBlocklistActiveProcess(data: APIStatusResponse?, blocklistId: String) -> APIStatusResponse_Process? {
    guard let data = data else { return nil }
    let process = data.processes.first {
        if let b = $0.blocklistEnable  { return String(b.blocklistId) == blocklistId }
        if let b = $0.blocklistImport  { return String(b.blocklistId) == blocklistId }
        if let b = $0.blocklistDisable { return String(b.blocklistId) == blocklistId }
        if let b = $0.blocklistDelete  { return String(b.blocklistId) == blocklistId }
        return false
    }
    return process?.successful == nil ? process : nil
}

func getProcessType(_ process: APIStatusResponse_Process) -> String {
    if process.blocklistEnable != nil {
        return String(localized: "Enabling blocklist")
    }
    else if process.blocklistImport != nil {
        return String(localized: "Importing blocklist")
    }
    else if process.blocklistDelete != nil {
        return String(localized: "Deleting blocklist")
    }
    else if process.blocklistDisable != nil {
        return String(localized: "Disabling blocklist")
    }
    else {
        return ""
    }
}
