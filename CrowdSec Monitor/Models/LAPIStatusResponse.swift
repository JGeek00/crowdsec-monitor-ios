struct LAPIStatusResponse: Codable {
    let status: String;
    let message: String;
    let lastSuccessfulSync: String;
    let timestamp: String;
}
