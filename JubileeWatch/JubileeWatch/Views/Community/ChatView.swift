import SwiftUI

struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    @State private var messageText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Online Users Banner
            HStack {
                Image(systemName: "person.2.fill")
                    .foregroundColor(.yellow)
                Text("\(viewModel.onlineUsers) users online")
                    .font(.caption)
                    .foregroundColor(.white)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.jubileeSecondary)
            
            // Messages List
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.messages) { message in
                            ChatMessageView(message: message)
                                .id(message.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: viewModel.messages.count) { _ in
                    withAnimation {
                        proxy.scrollTo(viewModel.messages.last?.id)
                    }
                }
            }
            
            // Input Bar
            HStack(spacing: 12) {
                TextField("Type a message...", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(Color.jubileePrimary))
                }
                .disabled(messageText.isEmpty)
            }
            .padding()
            .background(Color.jubileeSecondary)
        }
        .background(Color.jubileeBackground)
    }
    
    func sendMessage() {
        guard !messageText.isEmpty else { return }
        viewModel.sendMessage(messageText)
        messageText = ""
    }
}

struct ChatMessageView: View {
    let message: ChatMessage
    
    var isCurrentUser: Bool {
        message.username == "You"
    }
    
    var body: some View {
        HStack {
            if isCurrentUser { Spacer() }
            
            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
                HStack(spacing: 8) {
                    if !isCurrentUser {
                        Text(message.username)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(message.timestamp.timeAgoDisplay())
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    if isCurrentUser {
                        Text(message.username)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                }
                
                Text(message.content)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(isCurrentUser ? Color.jubileePrimary.opacity(0.2) : Color.gray.opacity(0.2))
                    )
                    .foregroundColor(.white)
            }
            
            if !isCurrentUser { Spacer() }
        }
    }
}

class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var onlineUsers = 47
    
    init() {
        setupMockMessages()
    }
    
    private func setupMockMessages() {
        messages = [
            ChatMessage(
                id: UUID(),
                userId: UUID(),
                username: "Sarah M.",
                content: "Seeing lots of movement near Fairhope pier!",
                timestamp: Date().addingTimeInterval(-120),
                location: nil,
                attachments: nil
            ),
            ChatMessage(
                id: UUID(),
                userId: UUID(),
                username: "Mike D.",
                content: "Water temp just dropped 3 degrees in 20 minutes",
                timestamp: Date().addingTimeInterval(-300),
                location: nil,
                attachments: nil
            ),
            ChatMessage(
                id: UUID(),
                userId: UUID(),
                username: "You",
                content: "Heading out now, conditions look perfect",
                timestamp: Date().addingTimeInterval(-480),
                location: nil,
                attachments: nil
            )
        ]
    }
    
    func sendMessage(_ text: String) {
        let newMessage = ChatMessage(
            id: UUID(),
            userId: UUID(),
            username: "You",
            content: text,
            timestamp: Date(),
            location: nil,
            attachments: nil
        )
        messages.append(newMessage)
    }
}

#Preview {
    ChatView()
        .preferredColorScheme(.dark)
}