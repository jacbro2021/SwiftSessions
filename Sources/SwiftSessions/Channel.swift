//
//  Channel.swift
//
//
//  Created by Alessio Rubicini on 04/05/24.
//

import Foundation
import AsyncAlgorithms

/// Represents a communication channel that enforces session types
///   - `A`: The type of messages that can be sent on the channel.
///   - `B`: The type of messages that can be received on the channel.
actor Channel<A, B> {
    
    /// Underlying asynchronous channel for communication.
    let asyncChannel: AsyncChannel<Sendable>
    
    var isUsed: Bool = false
    
    /// Initializes a new channel with the given asynchronous channel.
    /// - Parameter channel: The underlying asynchronous channel for communication.
    init(channel: AsyncChannel<Sendable>) {
        self.asyncChannel = channel
    }
    
    init<C, D>(from channel: Channel<C, D>) {
        self.asyncChannel = channel.asyncChannel
    }
    
    /// Sends the given element on the async channel
    /// - Parameter element: the element to be sent
    public func send(_ element: Sendable) async {
        guard !isUsed else {
            close()
            fatalError("Cannot send. Channel already used.")
        }
        isUsed = true
        await asyncChannel.send(element)
    }
    
    /// Receives an element from the async channel
    /// - Returns: the element received
    public func recv() async -> Sendable {
        guard !isUsed else {
            close()
            fatalError("Cannot recv. Channel already used.")
        }
        isUsed = true
        return await asyncChannel.first(where: { _ in true })!
    }
    
    /// Resumes all the operations on the underlying asynchronous channel
    /// and ends the communication
    public func close() {
        asyncChannel.finish()
    }
    
}
