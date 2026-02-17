import SwiftUI

struct StyledListContainer<Data, RowContent, FooterContent>: View where Data: RandomAccessCollection, Data.Element: Hashable, RowContent: View, FooterContent: View {
    let sectionTitle: String?
    let data: Data
    let rowContent: (Data.Element) -> RowContent
    let footer: (() -> FooterContent)?
    
    init(sectionTitle: String? = nil, data: Data, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent, @ViewBuilder footer: @escaping () -> FooterContent) {
        self.sectionTitle = sectionTitle
        self.data = data
        self.rowContent = rowContent
        self.footer = footer
    }
    
    init(sectionTitle: String? = nil, data: Data, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent) where FooterContent == EmptyView {
        self.data = data
        self.rowContent = rowContent
        self.footer = nil
        self.sectionTitle = sectionTitle
    }
    
    var body: some View {
        VStack {
            if let sectionTitle = sectionTitle {
                Spacer()
                    .frame(width: 24)
                Text(sectionTitle)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            VStack(spacing: 0) {
                ForEach(Array(data.enumerated()), id: \.element) { index, item in
                    rowContent(item)
                        .listItemStyling()
                    
                    if index < data.count - 1 {
                        Divider()
                            .padding(.vertical, 12)
                    }
                }
                
                if let footer = footer {
                    Divider()
                        .padding(.vertical, 12)
                    footer()
                }
            }
            .listContainerStyling()
        }
    }
}


struct StyledListContainerWithNavLink<Data, RowContent>: View where Data: RandomAccessCollection, Data.Element: Hashable, RowContent: View {
    let sectionTitle: String?
    let data: Data
    let rowContent: (Data.Element) -> RowContent
    let navLinkTitle: String
    let navLinkDestination: AnyView
    
    init(sectionTitle: String? = nil, data: Data, navLinkTitle: String, @ViewBuilder navLinkDestination: @escaping () -> some View, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent) {
        self.sectionTitle = sectionTitle
        self.data = data
        self.rowContent = rowContent
        self.navLinkTitle = navLinkTitle
        self.navLinkDestination = AnyView(navLinkDestination())
    }
    
    var body: some View {
        VStack {
            if let sectionTitle = sectionTitle {
                HStack {
                    Spacer()
                        .frame(width: 24)
                    Text(sectionTitle)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
            }
            VStack(spacing: 0) {
                ForEach(Array(data.enumerated()), id: \.element) { index, item in
                    rowContent(item)
                        .listItemStyling()
                    
                    if index < data.count - 1 {
                        Divider()
                            .padding(.vertical, 12)
                    }
                }
                
                Divider()
                    .padding(.vertical, 12)
                
                NavigationLink {
                    navLinkDestination
                } label: {
                    HStack {
                        Text(navLinkTitle)
                            .foregroundColor(.foreground)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    .pressableListRow()
                }
                .buttonStyle(.plain)
            }
            .listContainerStyling()
        }
    }
}
