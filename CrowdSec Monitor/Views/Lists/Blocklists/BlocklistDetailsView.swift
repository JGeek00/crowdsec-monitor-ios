import SwiftUI

struct BlocklistDetailsView: View {
    let blocklistId: Int
    
    @State private var viewModel: BlocklistDetailsViewModel
    
    init(blocklistId: Int) {
        self.blocklistId = blocklistId
        _viewModel = State(wrappedValue: BlocklistDetailsViewModel(blocklistId: blocklistId))
    }
    
    @Environment(BlocklistsListViewModel.self) private var blocklistsViewModel
    
    var body: some View {
        let blocklist = blocklistsViewModel.state.data?.items.first { $0.id == blocklistId }
        Group {
            switch viewModel.status {
            case .loading:
                ProgressView("Loading...")
            case .success(let data):
                content(data.data)
            case .failure:
                ContentUnavailableView("Cannot get blocklist information", systemImage: "exclamationmark.circle", description: Text("An error occured when fetching the blocklist data"))
            }
        }
        .transition(.opacity)
        .navigationTitle(blocklist?.name ?? "Blocklist details")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: blocklistId) { _, newValue in
            viewModel.updateBlocklistId(newValue)
        }
    }
    
    @ViewBuilder
    func content(_ data: BlocklistDataResponse_Data) -> some View {
        let newMin = Config.ipsAmountBatch*viewModel.ipsRound
        let endIndex = newMin > data.blocklistIPS.count ? data.blocklistIPS.count : newMin
        let slicedIps = Array(data.blocklistIPS[0..<endIndex])
        
        List {
            Section("Information") {
                HStack {
                    Text("Name")
                    Spacer()
                    Text(verbatim: data.name)
                        .foregroundStyle(Color.gray)
                }
                HStack {
                    Text("Amount of blocked IPs")
                    Spacer()
                    Text(data.countIPS.formatted())
                        .foregroundStyle(Color.gray)
                }
            }
            
            Section("Blocked IPs") {
                if data.blocklistIPS.isEmpty {
                    ContentUnavailableView("Blocklist with no IPs", systemImage: "list.bullet", description: Text("This blocklist does not contain any blocked IP address"))
                }
                else {
                    ForEach(slicedIps, id: \.self) { ip in
                        Text(verbatim: ip)
                            .onAppear {
                                if ip == slicedIps.last && endIndex < data.blocklistIPS.count {
                                    viewModel.incrementIpsRound()
                                }
                            }
                    }
                }
            }
        }
        .searchable(
            text: Binding(
                get: { viewModel.searchText },
                set: { newValue in
                    withAnimation {
                        viewModel.searchText = newValue
                    }
                }
            ),
            isPresented: Binding(
                get: { viewModel.searchPresented },
                set: { newValue in
                    withAnimation {
                        viewModel.searchPresented = newValue
                    }
                }
            ),
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Search IPs"
        )
        .refreshable {
            await viewModel.fetchData()
        }
        .overlay {
            if viewModel.searchPresented {
                if viewModel.searchText.isEmpty {
                    ContentUnavailableView("Input search text", systemImage: "magnifyingglass")
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .background(Color.background)
                        .transition(.opacity)
                }
                else {
                    let filterIps = data.blocklistIPS.filter() { $0.hasPrefix(viewModel.searchText) }
                    let endIndex = newMin > filterIps.count ? filterIps.count : newMin
                    let slicedIps = Array(filterIps[0..<endIndex])
                    if slicedIps.isEmpty {
                        ContentUnavailableView("No results for '\(viewModel.searchText)'", systemImage: "magnifyingglass", description: Text("Change the inputted search term"))
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                            .background(Color.background)
                            .transition(.opacity)
                    }
                    else {
                        List(slicedIps, id: \.self) { ip in
                            Text(verbatim: ip)
                        }
                        .animation(.default, value: slicedIps)
                        .transition(.opacity)
                    }
                }
            }
        }
    }
}
