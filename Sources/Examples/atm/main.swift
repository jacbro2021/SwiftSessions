//
//  main.swift
//  SwiftSessions
//
//  Created by jacob brown on 3/20/25.
//

import Foundation
import SwiftSessions

typealias ATMProtocol = Endpoint<Empty, (Int, Endpoint<Or<ATMAuthProtocol, ATMErrorProtocol>, Empty>)>
typealias ATMAuthProtocol = Endpoint<Empty, (String, Endpoint<Empty, Empty>)>
//typealias ATMDepositProtocol = Endpoint<Empty, Empty>
//typealias ATMWithdrawlProtocol = Endpoint<Empty, Empty>
typealias ATMErrorProtocol = Endpoint<Empty, (String, Endpoint<Empty, Empty>)>

let e = await Session.create { (e:ATMProtocol) in
    let (pin, e1) = await Session.recv(from: e)
    if pin == 1234 {
        let e2 = await Session.left(e1)
        let e3 = await Session.send("VALID PIN", on: e2)
        Session.close(e3)
    } else {
        let e2 = await Session.right(e1)
        let e3 = await Session.send("INVALID PIN", on: e2)
        Session.close(e3)
    }
}

let input = Int(readLine()!)!
let e1 = await Session.send(input, on: e)
let e2 = await Session.offer(e1)
switch e2 {
case .left(let e3):
    let (reply, e5) = await Session.recv(from: e3)
    print(reply)
    Session.close(e5)
case.right(let e4):
    let (reply, e5) = await Session.recv(from: e4)
    print(reply)
    Session.close(e5)
}

