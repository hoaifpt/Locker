import SwiftUI

struct FooterView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            // Replaced LazyVGrid with a more compatible VStack of HStack rows
            VStack(alignment: .leading, spacing: 32) {
                HStack(alignment: .top, spacing: 32) {
                    FooterSection(title: "Platform", items: ["Fusion", "Publish", "Product Updates"])
                        .frame(maxWidth: .infinity, alignment: .leading)
                    FooterSection(title: "Use Cases", items: ["Design to Code", "CMS", "Web Apps", "Marketing Sites"])
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                HStack(alignment: .top, spacing: 32) {
                    FooterSection(title: "Developers", items: ["Documentation", "Fusion Docs", "Publish Docs"])
                        .frame(maxWidth: .infinity, alignment: .leading)
                    FooterSection(title: "Company", items: ["About", "News", "Careers", "Contact Sales"])
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            
            Divider()
                .background(Color.white.opacity(0.1))
            
            HStack(spacing: 24) {
                SocialIcon(name: "Twitter")
                SocialIcon(name: "GitHub")
                SocialIcon(name: "LinkedIn")
                SocialIcon(name: "YouTube")
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("© 2026 Builder.io, Inc.")
                    .font(.system(size: 14))
                
                HStack(spacing: 16) {
                    Text("Security")
                    Text("Privacy Policy")
                    Text("Terms")
                }
                .font(.system(size: 14))
                .foregroundColor(.gray)
            }
        }
        .padding(24)
        .background(Color.black)
        .foregroundColor(.white)
    }
}

struct FooterSection: View {
    let title: String
    let items: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(items, id: \.self) { item in
                    Text(item)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

struct SocialIcon: View {
    let name: String
    
    var body: some View {
        Image(systemName: "circle.fill") // Placeholder for social logos
            .resizable()
            .frame(width: 24, height: 24)
            .foregroundColor(.gray)
            .overlay(
                Text(name.prefix(1))
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
            )
    }
}

#if DEBUG
@available(iOS 17.0, *)
#Preview {
    ScrollView {
        FooterView()
    }
    .background(Color.black)
}
#endif
