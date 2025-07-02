import SwiftUI

struct ProbabilityGaugeView: View {
    let probability: Double
    
    private var color: Color {
        switch probability {
        case 0..<30: return .green
        case 30..<60: return .yellow
        case 60..<80: return .orange
        default: return .red
        }
    }
    
    private var confidenceText: String {
        switch probability {
        case 0..<30: return "Low"
        case 30..<60: return "Moderate"
        case 60..<80: return "High"
        default: return "Critical"
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Jubilee Probability")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            ZStack {
                // Background Circle
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                
                // Progress Circle
                Circle()
                    .trim(from: 0, to: probability / 100)
                    .stroke(
                        AngularGradient(
                            colors: [color.opacity(0.5), color],
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1), value: probability)
                
                // Center Text
                VStack {
                    Text("\(Int(probability))%")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(color)
                    
                    Text(confidenceText)
                        .font(.headline)
                        .foregroundColor(color)
                }
            }
            .frame(width: 200, height: 200)
            
            Text("Next update in 5 minutes")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.jubileeSecondary)
        )
    }
}

#Preview {
    ProbabilityGaugeView(probability: 65.0)
        .preferredColorScheme(.dark)
}