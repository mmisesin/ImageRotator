//
//  WebHandler.swift
//  RotateTogether
//
//  Created by Artem Misesin on 6/1/17.
//
//

import Foundation
import Starscream

class WebHandler {
    
    private var socket = WebSocket(url: URL(string: "wss://ios-devchallenge-11.tk/write?id=organicMutt")!)
    
    func connect(){
        self.socket.delegate = self
        self.socket.connect()
    }
    
    var receivedData = ""
    
    var isConnected: Bool {
        return socket.isConnected
    }
    
    func setup(with devProtocol: String){
        if !socket.isConnected{
            if let url = URL(string: devProtocol){
                self.socket = WebSocket(url: url)
            } else {
                print("Wrong URL")
            }
        } else {
            print("You change protocol whilst being connected to the server.")
        }
    }
    
    func send(data: String){
        if socket.isConnected{
            self.socket.write(string: data)
        } else {
            print("You are trying to send data while not being connected to the server.")
        }
    }
    
}

extension WebHandler : WebSocketDelegate {
    public func websocketDidConnect(socket: Starscream.WebSocket) {
        print("Connected")
    }
    
    public func websocketDidDisconnect(socket: Starscream.WebSocket, error: NSError?) {
        print(error?.localizedDescription ?? "error is nil")
    }
    
    public func websocketDidReceiveMessage(socket: Starscream.WebSocket, text: String) {
        print("Text received: \(text)")
    }
    
    public func websocketDidReceiveData(socket: Starscream.WebSocket, data: Data) {
        receivedData = String(data: data, encoding: .utf8)!
    }
}
