import Vapor
import Foundation
import Dispatch


let room = Room()

extension Droplet {
    public func setup() throws {
        get("/") { _ in
            try self.view.make("welcome.html")
//            try req.make(ViewRenderer.self).render("welcome.html")
        }
        
        socket("chat") { req, ws in
            var pingTimer: DispatchSourceTimer? = nil
            var username: String? = nil
//
            pingTimer = DispatchSource.makeTimerSource()
            pingTimer?.scheduleRepeating(deadline: .now(), interval: .seconds(25))
            pingTimer?.setEventHandler { try? ws.ping() }
            pingTimer?.resume()
//var pingTimer  = DispatchSource.makeTimerSource()
//pingTimer.scheduleRepeating(deadline: .now(), interval: .seconds(25))
//pingTimer.setEventHandler { try? ws.ping() }
//pingTimer.resume()
            
            ws.onText = { ws, text in
                let json = try JSON(bytes: text.makeBytes())
                
                if let u = json.object?["username"]?.string {
                    username = u
                    
                    let message = "\(u) has joined. 👋".truncated(to: 256)
                    let messageNode: [String: NodeRepresentable] = [
                        "username": u,
                        "message": message
                    ]
                    guard let json = try? JSON(node: messageNode) else {
                        return
                    }
                    try? ws.send(json)
//                    for (username, socket) in connections {
//                        guard username != name else {
//                            continue
//                        }
//                        try? socket.send(json)
//                    }
                    
                    
                    
                   
                    
                    
                    
//                    room.connections[u] = ws
//                    room.bot("\(u) has joined. 👋")
                    print("\(u) has joined.")
                }
                
                if let u = username, let m = json.object?["message"]?.string {
                    let message = m.truncated(to: 256)
                    let messageNode: [String: NodeRepresentable] = [
                        "username": u,
                        "message": message
                    ]
                    guard let json = try? JSON(node: messageNode) else {
                        return
                    }
                    try? ws.send(json)
                    //                    for (username, socket) in connections {
                    //                        guard username != name else {
                    //                            continue
                    //                        }
                    //                        try? socket.send(json)
                    //                    }
                    
                    
                    
//                    room.send(name: u, message: m)
                    print("\(u) send \(m)")
                }
            }
            
            ws.onClose = { ws, _, _, _ in
                pingTimer?.cancel()
                pingTimer = nil
//                pingTimer.cancel()
                print("onclose")
                
                guard let u = username else {
                    return
                }
                
                
                let message = "\(u) has left. 👋".truncated(to: 256)
                let messageNode: [String: NodeRepresentable] = [
                    "username": u,
                    "message": message
                ]
                guard let json = try? JSON(node: messageNode) else {
                    return
                }
                try? ws.send(json)
                print("\(u) has left.")
                
                
                
//                room.bot("\(u) has left")
//                room.connections.removeValue(forKey: u)
            }
        }
    }
}
