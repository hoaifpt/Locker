import SwiftUI

struct NewsletterSignupView: View {
    @State private var email: String = ""
    @State private var isDevDropSelected: Bool = false
    @State private var isProductSelected: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Get the latest from Builder.io")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.black)
            
            VStack(alignment: .leading, spacing: 16) {
                NewsletterOptionRow(
                    title: "Dev Drop Newsletter",
                    description: "News, tips, and tricks from Builder, for frontend developers",
                    isSelected: $isDevDropSelected
                )
                
                NewsletterOptionRow(
                    title: "Product Newsletter",
                    description: "Latest features and updates on the Builder.io platform",
                    isSelected: $isProductSelected
                )
            }
            
            VStack(alignment: .leading, spacing: 12) {
                TextField("Email address", text: $email)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                
                Button(action: {}) {
                    Text("Subscribe")
                        .font(.system(size: 16, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.black)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            
            Text("By clicking subscribe, you agree to our privacy policy.")
                .font(.system(size: 12))
                .foregroundColor(.gray)
        }
        .padding(24)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 16)
    }
}

struct NewsletterOptionRow: View {
    let title: String
    let description: String
    @Binding var isSelected: Bool
    
    var body: some View {
        Button(action: { isSelected.toggle() }) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .foregroundColor(isSelected ? .blue : .gray)
                    .font(.system(size: 20))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                    Text(description)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .multilineTextAlignment(.leading)
            }
        }
    }
}

#if DEBUG
@available(iOS 17.0, *)
#Preview {
    NewsletterSignupView()
        .padding()
        .background(Color.gray.opacity(0.1))
}
#endif
