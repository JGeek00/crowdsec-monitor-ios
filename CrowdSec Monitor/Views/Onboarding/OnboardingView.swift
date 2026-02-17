import SwiftUI

struct OnboardingView: View {
    @Environment(OnboardingViewModel.self) private var viewModel
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        @Bindable var onboardingViewModel = viewModel
        if horizontalSizeClass == .compact {
            TabView(selection: $onboardingViewModel.selectedTab) {
                Welcome()
                    .tag(0)
                    .contentShape(Rectangle()).simultaneousGesture(DragGesture())
                ApiInformation()
                    .tag(1)
                    .contentShape(Rectangle()).simultaneousGesture(DragGesture())
                ConnectionForm()
                    .tag(2)
                    .contentShape(Rectangle()).simultaneousGesture(DragGesture())
            }
            .background(Color.listBackground)
            .fontDesign(.rounded)
            .tabViewStyle(.page(indexDisplayMode: .never))
            .contentShape(Rectangle()).simultaneousGesture(DragGesture())
            .onAppear {
                  UIScrollView.appearance().isScrollEnabled = false
            }
        }
        else {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Group {
                        TabView(selection: $onboardingViewModel.selectedTab) {
                            Welcome()
                                .tag(0)
                                .contentShape(Rectangle()).simultaneousGesture(DragGesture())
                            ApiInformation()
                                .tag(1)
                                .contentShape(Rectangle()).simultaneousGesture(DragGesture())
                            ConnectionForm()
                                .tag(2)
                                .contentShape(Rectangle()).simultaneousGesture(DragGesture())
                        }
                        .padding()
                        .fontDesign(.rounded)
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        .contentShape(Rectangle()).simultaneousGesture(DragGesture())
                    }
                    .background(Color.listBackground)
                    .frame(maxWidth: 600, maxHeight: 800)
                    .cornerRadius(24)
                    .shadow(radius: 20)
                    Spacer()
                }
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
        }
    }
}

#Preview {
    OnboardingView()
        .environment(OnboardingViewModel(showOnboarding: true, selectedTab: 0))
}
