import SwiftUI

struct ErrorStateView: View {
    var body: some View {
        VStack(spacing: 24) {
            Text("Oops!")
                .font(.system(size: 64, weight: .black))
                .foregroundColor(.black)
            
            Text("Well, this is awkward, the page you were trying to view does not exist.")
                .font(.system(size: 18))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Button(action: {}) {
                Text("Back to Home")
                    .font(.system(size: 16, weight: .bold))
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(.vertical, 80)
        .frame(maxWidth: .infinity)
        .background(Color.white)
    }
}

#if DEBUG
@available(iOS 17.0, *)
#Preview {
    ErrorStateView()
}
#endif
