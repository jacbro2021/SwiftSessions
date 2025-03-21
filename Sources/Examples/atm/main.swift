//
//  main.swift
//  SwiftSessions
//
//  Created by jacob brown on 3/20/25.
//

import Foundation
import SwiftSessions

typealias ATMProtocol = Endpoint<Empty, (Int, Endpoint<Or<ATMAuthProtocol, ATMErrorProtocol>, Empty>)>
typealias ATMAuthProtocol = Endpoint<Empty, (String, Endpoint<Or<ATMDepositProtocol, ATMWithdrawProtocol>, Empty>)>

typealias ATMDepositProtocol = Endpoint<Empty, (Double, Endpoint<Or<ATMSuccessProtocol, ATMErrorProtocol>, Empty>)>
typealias ATMWithdrawProtocol = Endpoint<Empty, (Double, Endpoint<Or<ATMSuccessProtocol, ATMErrorProtocol>, Empty>)>

typealias ATMSuccessProtocol = Endpoint<Empty, (String, Endpoint<Empty, Empty>)>
typealias ATMErrorProtocol = Endpoint<Empty, (String, Endpoint<Empty, Empty>)>

var accountBalance: Double = 10.00

// ATM
let e = await Session.create { (e:ATMProtocol) in
    let (pin, e1) = await Session.recv(from: e)
    if pin == 1234 {
        let e2 = await Session.left(e1)
        let e3 = await Session.send("VALID PIN", on: e2)
        let e4 = await Session.offer(e3)
        switch e4 {
        case .left(let left):
            let (depositAmount, e5) = await Session.recv(from: left)
            if depositAmount > 0 {
                let e6 = await Session.left(e5)
                accountBalance += depositAmount
                let e7 = await Session.send("DEPOSIT SUCCESS: NEW BALANCE IS $\(accountBalance) -> LOGGING OUT...", on: e6)
                Session.close(e7)
            } else {
                let e6 = await Session.right(e5)
                let e7 = await Session.send("DEPOSIT FAILED: DEPOSIT AMOUNT LESS THAN 0 -> LOGGING OUT...", on: e6)
                Session.close(e7)
            }
        case .right(let right):
            let (withdrawAmount, e5) = await Session.recv(from: right)
            if withdrawAmount > 0 && accountBalance >= withdrawAmount {
                let e6 = await Session.left(e5)
                accountBalance -= withdrawAmount
                let e7 = await Session.send("WITHDRAW SUCCESS: NEW BALANCE IS $\(accountBalance) -> LOGGING OUT...", on: e6)
                Session.close(e7)
            } else {
                let e6 = await Session.right(e5)
                let e7 = await Session.send("WITHDRAW FAILED: INVALID WITHDRAW AMOUNT -> LOGGING OUT...", on: e6)
                Session.close(e7)
            }
        }
    } else {
        let e2 = await Session.right(e1)
        let e3 = await Session.send("INVALID PIN -> ENDING SESSION...", on: e2)
        Session.close(e3)
    }
}

// Client
print("Enter your pin:")
let input = Int(readLine()!)!
let e1 = await Session.send(input, on: e)
let e2 = await Session.offer(e1)
switch e2 {
case .left(let left):
    let (reply, e3) = await Session.recv(from: left)
    print(reply)
    print("Choose an option: \n1. Deposit \n2. Withdraw")
    
    let input = Int(readLine()!)!
    if input <= 0 || input > 2 {
        fatalError("Invalid input")
    }
    
    if input == 1 {
        let e4 = await Session.left(e3)
        print("Enter the amount you would like to deposit:")
        let amountToDeposit = Double(readLine()!)!
        let e5 = await Session.send(amountToDeposit, on: e4)
        let e6 = await Session.offer(e5)
        switch e6 {
        case .left(let left2):
            let (res, e7) = await Session.recv(from: left2)
            print(res)
            Session.close(e7)
        case .right(let right2):
            let (res, e7) = await Session.recv(from: right2)
            print(res)
            Session.close(e7)
        }
    } else {
        let e4 = await Session.right(e3)
        print("Enter the amount you would like to withdraw:")
        let amountToWithdraw = Double(readLine()!)!
        let e5 = await Session.send(amountToWithdraw, on: e4)
        let e6 = await Session.offer(e5)
        switch e6 {
        case .left(let left2):
            let (res, e7) = await Session.recv(from: left2)
            print(res)
            Session.close(e7)
        case .right(let right2):
            let (res, e7) = await Session.recv(from: right2)
            print(res)
            Session.close(e7)
        }
    }
    
case .right(let right):
    let (reply, e3) = await Session.recv(from: right)
    print(reply)
    Session.close(e3)
}

