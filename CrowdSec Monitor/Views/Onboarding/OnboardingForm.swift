import SwiftUI

struct OnboardingForm: View {
    @Environment(OnboardingViewModel.self) private var onboardingViewModel
    
    @State private var viewModel = ConnectionFormViewModel()
    
    var body: some View {
        ConnectionForm(viewModel: viewModel)
            .padding(.bottom, 84)
            .overlay(alignment: .bottom, content: {
                HStack(alignment: .center) {
                    Button {
                        withAnimation(.default) {
                            onboardingViewModel.selectedTab = 1
                        }
                    } label: {
                        HStack {
                            Spacer()
                            Image(systemName: "chevron.left")
                            Text("Back")
                            Spacer()
                        }
                        .fontWeight(.semibold)
                    }
                    .normalButton()
                    Spacer()
                        .frame(width: 16)
                    Button {
                        viewModel.connect()
                    } label: {
                        Group {
                            Spacer()
                            if viewModel.connecting == true {
                                ProgressView()
                            }
                            else {
                                Text("Connect")
                                    .fontWeight(.semibold)
                                    .font(.system(size: 18))
                            }
                            Spacer()
                        }
                    }
                    .prominentButton()
                }
                .padding(.horizontal, 24)
                .frame(height: 84, alignment: .center)
                .disabled(viewModel.connecting)
                .background(Color.listBackground)
            })
    }
}

#Preview {
    OnboardingForm()
}
