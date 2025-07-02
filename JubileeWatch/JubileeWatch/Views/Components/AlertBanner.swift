import SwiftUI

struct AlertBanner: View {
    let message: String
    let type: AlertType
    @State private var isVisible = true
    
    enum AlertType {
        case info, warning, error, success
        
        var color: Color {
            switch self {
            case .info: return .jubileePrimary
            case .warning: return .jubileeWarning
            case .error: return .jubileeDanger
            case .success: return .jubileeAccent
            }
        }
        
        var icon: String {
            switch self {
            case .info: return "info.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .error: return "xmark.circle.fill"
            case .success: return "checkmark.circle.fill"
            }
        }
    }
    
    var body: some View {
        if isVisible {
            HStack(spacing: 12) {
                Image(systemName: type.icon)
                    .foregroundColor(type.color)
                    .font(.title3)
                
                Text(message)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                Button(action: { 
                    withAnimation(.easeOut(duration: 0.3)) {
                        isVisible = false
                    }
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(type.color.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(type.color.opacity(0.3), lineWidth: 1)
                    )
            )
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        AlertBanner(message: "High Jubilee Probability Detected!", type: .warning)
        AlertBanner(message: "Successfully updated location", type: .success)
        AlertBanner(message: "Unable to connect to server", type: .error)
        AlertBanner(message: "New update available", type: .info)
    }
    .padding()
    .background(Color.jubileeBackground)
    .preferredColorScheme(.dark)
}