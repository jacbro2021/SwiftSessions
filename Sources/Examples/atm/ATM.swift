//
//  ATM.swift
//  SwiftSessions
//
//  Created by jacob brown on 3/24/25.
//

import Foundation

enum Action {
    case deposit(Double)
    case withdraw(Double)
}

class ATM {
    var bankAccount: BankAccount
    var sessionAction: Action?
    
    private init(bankAccount: BankAccount) {
        self.bankAccount = bankAccount
    }
    
    convenience init?(pin: Int) {
        guard let bankAccount = BankAccount.getAccount(pin: pin) else { return nil }
        self.init(bankAccount: bankAccount)
    }
    
    func setSessionAction(_ action: Action) {
        self.sessionAction = action
    }
    
    func performSessionAction() -> Double? {
        guard let action = sessionAction else { return nil }
        
        switch action {
        case .deposit(let amount):
            do {
                return try bankAccount.deposit(amount)
            } catch {
                return nil
            }
        case .withdraw(let amount):
            do {
                return try bankAccount.withdraw(amount)
            } catch {
                return nil
            }
        }
    }
}
