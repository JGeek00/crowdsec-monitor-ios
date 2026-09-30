import SwiftUI

struct FormInfoBox: View {
    let label: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: "info.square")
                .font(.system(size: 40))
            Text(verbatim: label)
                .font(.headline)
        }
        .foregroundStyle(Color.secondary)
        .listRowBackground(Color.listBackground)
    }
}

#Preview {
    List {
        Section {
            FormInfoBox(label: "A notification channel defines how the backend delivers a notification: through ntfy or by email. Configure the provider access once here, then pick one or more channels in each notification.")
        }
    }
}
