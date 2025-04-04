//
//  Session+Closures.swift
//
//
//  Created by Alessio Rubicini on 22/05/24.
//

import Foundation

/// Extension for the Session class that provides methods using closures for session type communications.
///
/// This version of the library includes methods that allow users to send and receive messages,
/// as well as offer and select between branches using closures for continuation.
extension Session {
    
    /// Sends a message on the channel and invokes the specified closure upon completion.
    /// - Parameters:
    ///   - payload: The payload to be sent to the endpoint.
    ///   - endpoint: The endpoint to which the payload is sent.
    ///   - continuation: A closure to be invoked after the send operation completes.
    ///                    This closure receives the continuation endpoint for further communication.
    public static func send<A, B, C>(_ payload: A, on endpoint: Endpoint<(A, Endpoint<B, C>), Empty>, continuation: @escaping (Endpoint<C, B>) async -> Void) async {
        await endpoint.send(payload)
        let continuationEndpoint = Endpoint<C, B>(from: endpoint)
        await continuation(continuationEndpoint)
    }
    
    /// Receives a message from the channel and invokes the specified closure upon completion.
    /// - Parameters:
    ///   - endpoint: The endpoint from which the message is received.
    ///   - continuation: A closure to be invoked after the receive operation completes.
    ///                    This closure receives the received message and the continuation endpoint.
    public static func recv<A, B, C>(from endpoint: Endpoint<Empty, (A, Endpoint<B, C>)>, continuation: @escaping ((A, Endpoint<B, C>)) async -> Void) async {
        let msg = await endpoint.recv()
        let continuationEndpoint = Endpoint<B, C>(from: endpoint)
        await continuation((msg as! A, continuationEndpoint))
    }
    
    /// Offers a choice between two branches on the given channel, and executes the corresponding closure based on the selected branch.
    /// - Parameters:
    ///   - endpoint: The endpoint on which the choice is offered. This endpoint expects a value indicating the selected branch (`true` for the first branch, `false` for the second branch).
    ///   - side1: The closure to be executed if the first branch is selected. This closure receives a endpoint of type `Endpoint<A, B>`.
    ///   - side2: The closure to be executed if the second branch is selected. This closure receives a endpoint of type `Endpoint<C, D>`.
    public static func offer<A, B, C, D>(on endpoint: Endpoint<Empty, Or<Endpoint<A, B>, Endpoint<C, D>>>, _ side1: @escaping (Endpoint<A, B>) async -> Void, or side2: @escaping (Endpoint<C, D>) async -> Void) async {
        let bool = await endpoint.recv() as! Bool
        if bool {
            let continuationEndpoint = Endpoint<A, B>(from: endpoint)
            await side1(continuationEndpoint)
        } else {
            let continuationEndpoint = Endpoint<C, D>(from: endpoint)
            await side2(continuationEndpoint)
        }
    }
    
    /// Selects the left branch on the given endpoint and executes the provided continuation closure.
    /// - Parameters:
    ///   - endpoint: The channel on which the left branch is selected.
    ///   - continuation: A closure to be executed after the left branch is selected. This closure receives a endpoint of type `Endpoint<B, A>`.
    public static func left<A, B, C, D>(_ endpoint: Endpoint<Or<Endpoint<A, B>, Endpoint<C, D>>, Empty>, continuation: @escaping (Endpoint<B, A>) async -> Void) async {
        await endpoint.send(true)
        let continuationEndpoint = Endpoint<B, A>(from: endpoint)
        await continuation(continuationEndpoint)
    }
    
    /// Selects the right branch on the given channel and executes the provided continuation closure.
    /// - Parameters:
    ///   - endpoint: The endpoint on which the right branch is selected.
    ///   - continuation: A closure to be executed after the right branch is selected. This closure receives a endpoint of type `Endpoint<D, C>`.
    public static func right<A, B, C, D>(_ endpoint: Endpoint<Or<Endpoint<A, B>, Endpoint<C, D>>, Empty>, continuation: @escaping (Endpoint<D, C>) async -> Void) async {
        await endpoint.send(false)
        let continuationEndpoint = Endpoint<D, C>(from: endpoint)
        await continuation(continuationEndpoint)
    }
    
}
