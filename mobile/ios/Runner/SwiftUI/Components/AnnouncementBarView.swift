import SwiftUI

struct AnnouncementBarView: View {
    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "info.circle") // Fallback icon
                    .foregroundColor(.white)
                
                Text("See how Frete cut frontend build time by 70%")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
            }
            
            Divider()
                .background(Color.white.opacity(0.3))
                .frame(height: 16)
            
            HStack(spacing: 8) {
                Text("What are best AI tools? Take the State of AI survey")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(white: 0.1)) // Dark background
    }
}

#if DEBUG
@available(iOS 17.0, *)
#Preview {
    AnnouncementBarView()
}
#endif
