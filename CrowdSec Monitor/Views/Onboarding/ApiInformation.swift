import SwiftUI

struct ApiInformation: View {
    @Environment(OnboardingViewModel.self) private var viewModel

    /// Hero symbol size: 60 pt default, scales with the system text size setting
    @ScaledMetric(relativeTo: .largeTitle) private var heroSymbolSize: CGFloat = 60
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Image(systemName: "server.rack")
                    .font(.system(size: heroSymbolSize))
                Spacer()
                    .frame(height: 24)
                Text("API information")
                    .font(.title)
                    .fontWeight(.semibold)
                    .padding(.bottom, 12)
            }
            Spacer()
                .frame(height: 48)
            
            Text("This application requires an intermediate API to function. This API is responsible for obtaining data from CrowdSec, processing it, and delivering it appropriately to this application. \nBefore continuing, ensure that you have correctly deployed it on your machine alongside CrowdSec.")
                .font(.title3)
            Spacer()
                .frame(height: 48)
            Button {
                openURL(URLs.crowdsecMonitorApiRepo)
            } label: {
                Label("View API repository on GitHub", systemImage: "link")
            }

            
            Spacer()
            
            HStack(alignment: .center) {
                Button {
                    withAnimation(.default) {
                        viewModel.selectedTab = 0
                    }
                } label: {
                    Label("Back", systemImage: "chevron.left")
                }
                .normalButton()
                Spacer()
                Button {
                    withAnimation(.default) {
                        viewModel.selectedTab = 2
                    }
                } label: {
                    HStack {
                        Text("Next")
                        Image(systemName: "chevron.right")
                    }
                }
                .normalButton()
            }
        }
        .frame(minWidth: 0, idealWidth: .infinity)
        .padding(24)
    }
}

#Preview {
    ApiInformation()
        .environment(OnboardingViewModel(showOnboarding: true, selectedTab: 1))
}
