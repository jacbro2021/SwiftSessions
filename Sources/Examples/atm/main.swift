//
//  main.swift
//  SwiftSessions
//
//  Created by jacob brown on 3/20/25.
//

import Foundation
import SwiftSessions

func IsEvenWithClosures() async {
    await Session.create { e in
        // One side of the communication channel
        await Session.recv(from: e) { num, e in
            await Session.send(num % 2 == 0, on: e) { e in
                print("hi from server")
                Session.close(e)
            }
        }
    } _: { e in
        // Another side of the communication channel
        await Session.send(42, on: e) { e in
            await Session.recv(from: e) { isEven, e in
                Session.close(e)
                print("hi from client")
                assert(isEven == true)
            }
        }
    }
}

await IsEvenWithClosures()
