//
//  UDPTestView.swift
//  UkatonSwiftDemo
//
//  Created by Zack Qattan on 10/18/23.
//

import Foundation
import Network
import SwiftUI

class UDPListener: ObservableObject {
    var listener: NWListener!
    var connection: NWConnection!
    var queue = DispatchQueue.global(qos: .userInitiated)

    @Published public private(set) var messageReceived: Data?
    @Published public private(set) var isReady: Bool = false

    convenience init(to host: String, on port: Int) {
        self.init(
            to: NWEndpoint.Host(stringLiteral: host),
            on: NWEndpoint.Port(integerLiteral: NWEndpoint.Port.IntegerLiteralType(port))
        )
    }

    init(to host: NWEndpoint.Host, on port: NWEndpoint.Port) {
        print(host, port)
        let messageToUDP: [UInt8] = [8, 5, 0, 3, 5, 20, 0]

        connection = NWConnection(host: host, port: port, using: .udp)
        connection.stateUpdateHandler = { [weak self] newState in
            print("This is stateUpdateHandler:")
            switch newState {
                case .ready:
                    print("State: Ready\n")
                    self?.sendUDP(Data(messageToUDP))
                    self?.receiveUDP()
                case .setup:
                    print("State: Setup\n")
                case .cancelled:
                    print("State: Cancelled\n")
                case .preparing:
                    print("State: Preparing\n")
                default:
                    print("ERROR! State not defined!\n")
            }
        }

        connection.start(queue: queue)
    }

    func sendUDP(_ content: Data) {
        connection.send(content: content, completion: NWConnection.SendCompletion.contentProcessed(({ NWError in
            if NWError == nil {
                print("Data was sent to UDP")
            } else {
                print("ERROR! Error when data (Type: Data) sending. NWError: \n \(NWError!)")
            }
        })))
    }

    func sendUDP(_ content: String) {
        let contentToSendUDP = content.data(using: String.Encoding.utf8)
        connection.send(content: contentToSendUDP, completion: NWConnection.SendCompletion.contentProcessed(({ NWError in
            if NWError == nil {
                print("Data was sent to UDP")
            } else {
                print("ERROR! Error when data (Type: Data) sending. NWError: \n \(NWError!)")
            }
        })))
    }

    func receiveUDP() {
        connection.receiveMessage { [weak self] data, _, isComplete, _ in
            if isComplete {
                print("Receive is complete")
                if data != nil {
                    self?.messageReceived = data
                    print(self?.messageString ?? "")
                } else {
                    print("Data == nil")
                }
            }
            self?.receiveUDP()
        }
    }

    var messageString: String {
        var string = ""
        if let messageReceived {
            messageReceived.forEach { value in
                string += "\(value),"
            }
        }
        return string
    }
}

struct UDPTestView: View {
    @StateObject private var udpListener: UDPListener = .init(to: "192.168.1.54", on: 9999)

    var body: some View {
        NavigationStack {
            List {
                Text("hello")
                Text(udpListener.messageString)
            }
            .navigationTitle("UDP Test ")
        }
    }
}

#Preview {
    UDPTestView()
        .frame(maxWidth: 300)
}
