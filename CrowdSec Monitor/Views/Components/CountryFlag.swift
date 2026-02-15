import SwiftUI

struct CountryFlag: View {
    let countryCode: String
    
    var body: some View {
        HStack {
            Text(flag)
                .font(.system(size: 24))
            Text(countryName)
        }
    }
    
    private var flag: String {
        let base: UInt32 = 127397
        var emoji = ""
        for scalar in countryCode.uppercased().unicodeScalars {
            if let unicodeScalar = UnicodeScalar(base + scalar.value) {
                emoji.append(String(unicodeScalar))
            }
        }
        return emoji
    }
    
    private var countryName: String {
        let locale = Locale.current
        return locale.localizedString(forRegionCode: countryCode.uppercased()) ?? countryCode.uppercased()
    }
}

#Preview {
    VStack(spacing: 16) {
        CountryFlag(countryCode: "ES")
        CountryFlag(countryCode: "US")
        CountryFlag(countryCode: "FR")
        CountryFlag(countryCode: "DE")
        CountryFlag(countryCode: "GB")
    }
    .padding()
}
