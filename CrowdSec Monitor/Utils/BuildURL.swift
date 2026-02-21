func buildUrl(server: CSServer) -> String {
    var urlString = "\(server.http ?? "https")://\(server.domain ?? "")"
    
    if server.port > 0 {
        urlString += ":\(server.port)"
    }
    
    if let path = server.path, !path.isEmpty {
        if path.hasPrefix("/") {
            urlString += path
        } else {
            urlString += "/\(path)"
        }
    }
    
    return urlString
}
