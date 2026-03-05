import SwiftUI

struct MainContentView: View {
    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                content
                    .navigationTitle("Builder.io")
                    .navigationBarTitleDisplayMode(.large)
                    .toolbarBackground(Color.black, for: .navigationBar)
                    .toolbarColorScheme(.dark, for: .navigationBar)
            }
        } else {
            NavigationView {
                content
                    .navigationBarTitle("Builder.io", displayMode: .large)
            }
        }
    }

    private var content: some View {
        ScrollView {
            VStack(spacing: 0) {
                AnnouncementBarView()

                HeaderNavView()

                ErrorStateView()

                NewsletterSignupView()
                    .padding(.vertical, 40)

                FooterView()
            }
        }
        .background(Color.white)
        .ignoresSafeArea(edges: .bottom)
    }
}

#if DEBUG
@available(iOS 17.0, *)
#Preview {
    MainContentView()
}
#endif
