import SwiftUI

struct CommunityView: View {
    @State private var selectedSegment = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Segmented Control
                Picker("Community Section", selection: $selectedSegment) {
                    Text("Chat").tag(0)
                    Text("Forum").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                .background(Color.jubileeBackground)
                
                // Content
                Group {
                    if selectedSegment == 0 {
                        ChatView()
                    } else {
                        ForumView()
                    }
                }
            }
            .background(Color.jubileeBackground)
            .navigationTitle("Community")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    CommunityView()
        .preferredColorScheme(.dark)
}