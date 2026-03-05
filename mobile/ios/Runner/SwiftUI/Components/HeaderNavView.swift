import SwiftUI

struct HeaderNavView: View {
    var body: some View {
        HStack(spacing: 20) {
            // Builder.io Logo Placeholder
            HStack(spacing: 8) {
                Image(systemName: "square.grid.2x2.fill")
                    .foregroundColor(.blue)
                    .font(.title3)
                Text("Builder.io")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            // Large Nav Area (Simplified for Mobile)
            HStack(spacing: 16) {
                Button(action: {}) {
                    Text("Contact sales")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                }
                
                Button(action: {}) {
                    Text("Sign up")
                        .font(.system(size: 14, weight: .bold))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.black)
    }
}

#if DEBUG
@available(iOS 17.0, *)
#Preview {
    HeaderNavView()
        .background(Color.black)
}
#endif
