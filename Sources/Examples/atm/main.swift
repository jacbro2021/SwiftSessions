//
//  main.swift
//  SwiftSessions
//
//  Created by jacob brown on 3/20/25.
//

import Foundation
import SwiftSessions

func simpleExample() async {
    typealias Protocol = Endpoint<Empty, (String, Endpoint<(String, Endpoint<Empty, Empty>), Empty>)>
    
    let e = await Session.create { (e:Protocol) in
        let (msg, e1) = await Session.recv(from: e)
        let e2 = await Session.send("Hello \(msg)!", on: e1)
        Session.close(e2)
    }
   
    let e1 = await Session.send("world", on: e)
    let (reply, e2) = await Session.recv(from: e1)
    Session.close(e2)
    
    print(reply)
}

await simpleExample()
