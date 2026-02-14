import SwiftUI

struct Welcome: View {
    @Environment(OnboardingViewModel.self) private var viewModel
    
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    var body: some View {
        @Bindable var onboardingViewModel = viewModel
        
        VStack(alignment: .center) {
            VStack(alignment: .center) {
                Image("AppIconImage")
                    .resizable()
                    .frame(width: verticalSizeClass == .regular ? 130 : 90, height: verticalSizeClass == .regular ? 130 : 90)
                    .cornerRadius(12)
                    .shadow(radius: 10)
                Spacer()
                    .frame(height: 24)
                Text("Welcome to CrowdSec Monitor")
                    .font(.system(size: verticalSizeClass == .regular ? 40 : 36))
                    .fontWeight(.bold)
                    .padding(.bottom, 12)
                    .multilineTextAlignment(.center)
                Text("An application to control your CrowdSec instance")
                    .fontWeight(.medium)
                    .font(.system(size: verticalSizeClass == .regular ? 30 : 26))
                    .foregroundStyle(Color.gray)
                    .multilineTextAlignment(.center)
            }
            .padding(24)
            Spacer()
            HStack {
                Spacer()
                if #available(iOS 26, *) {
                    Button {
                        withAnimation(.default) {
                            onboardingViewModel.selectedTab = 1
                        }
                    } label: {
                        Text("Get started")
                            .fontWeight(.medium)
                            .font(.system(size: 20))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                    }
                    .buttonStyle(.glassProminent)
                    .padding(.bottom, 32)
                }
                else {
                    Button {
                        withAnimation(.default) {
                            onboardingViewModel.selectedTab = 1
                        }
                    } label: {
                        Text("Get started")
                            .fontWeight(.medium)
                            .font(.system(size: 20))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                    }
                    .buttonStyle(BorderedProminentButtonStyle())
                    .padding()
                }
                Spacer()
            }
            .padding(0)
        }
        .padding(0)
        .fontDesign(.rounded)
    }
}

#Preview {
    Welcome()
        .environment(OnboardingViewModel(showOnboarding: true, selectedTab: 0))
}
