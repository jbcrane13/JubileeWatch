import Foundation
import Combine

class WebSocketManager: ObservableObject {
    private var webSocketTask: URLSessionWebSocketTask?
    private let session = URLSession.shared
    
    @Published var isConnected = false
    @Published var lastMessage: String?
    
    var onConnect: (() -> Void)?
    var onDisconnect: (() -> Void)?
    var onMessage: ((String) -> Void)?
    
    func connect() {
        guard let url = URL(string: Config.websocketURL) else { return }
        
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        
        isConnected = true
        onConnect?()
        
        receiveMessage()
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        isConnected = false
        onDisconnect?()
    }
    
    func sendMessage(_ message: String) {
        guard isConnected else { return }
        
        let message = URLSessionWebSocketTask.Message.string(message)
        webSocketTask?.send(message) { error in
            if let error = error {
                print("WebSocket send error: \(error)")
            }
        }
    }
    
    func broadcast(event: WebSocketEvent, data: Codable) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        do {
            let eventData = try encoder.encode(data)
            let eventString = String(data: eventData, encoding: .utf8) ?? ""
            let message = "{\"event\": \"\(event.rawValue)\", \"data\": \(eventString)}"
            sendMessage(message)
        } catch {
            print("Failed to encode WebSocket message: \(error)")
        }
    }
    
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    DispatchQueue.main.async {
                        self?.lastMessage = text
                        self?.onMessage?(text)
                    }
                case .data(let data):
                    if let text = String(data: data, encoding: .utf8) {
                        DispatchQueue.main.async {
                            self?.lastMessage = text
                            self?.onMessage?(text)
                        }
                    }
                @unknown default:
                    break
                }
                
                self?.receiveMessage()
                
            case .failure(let error):
                print("WebSocket receive error: \(error)")
                DispatchQueue.main.async {
                    self?.disconnect()
                }
            }
        }
    }
}