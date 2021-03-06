//
//  MIDIAccess.swift
//  WebMIDIKit
//
//  Created by Adam Nemecek on 12/7/16.
//
//

import CoreMIDI
import Foundation

/// https://www.w3.org/TR/webmidi/#midiaccess-interface
public final class MIDIAccess : CustomStringConvertible, CustomDebugStringConvertible {

    public let inputs: MIDIInputMap
    public let outputs: MIDIOutputMap
    
    public let hotfixInputs: MIDIPortMap<MIDIInput>
    /*
     I have no idea what I am doing here but so far the types appear to be compatible.
     
     On
     
     ```
         for (id, port) in midi.inputs {
             print(id)
         }
     ```
     
     I only got
     
     ```
         'MIDIInputMap' requires the types 'IndexingIterator<MIDIPortMap<MIDIInput>>' and 'IndexingIterator<MIDIInputMap>' be equivalent
     ```
     
     and even reverting to Swift 4 didn't seem to satisfy Xcode. No idea why this didn't cause
     trouble for other people but it sure did for me. idk but anyway now I'm able to iterate
     over and set the input port as well as, based on that, set the output port as well, nice.
     
     */
    
    
    public let testsA = ["a","b"]

    public var onStateChange: ((MIDIPort) -> ())? = nil

    public init() {
        self._client = MIDIClient()

        self.inputs = MIDIInputMap(client: _client)
        self.outputs = MIDIOutputMap(client: _client)
        
        self.hotfixInputs = MIDIInputMap(client: _client) //see above
        

        //    self._input = MIDIInput(virtual: _client)
        //    self._output = MIDIOutput(virtual: _client) {
        //      print($0.0)
        //    }
        //    //todo
        //    self._input.onMIDIMessage = {
        //      //          self.midi(src: 0, lst: $0)
        //      print($0)
        //    }

        self._observer = NotificationCenter.default.observeMIDIEndpoints {
            self._notification(endpoint: $0, type: $1).map {
                self.onStateChange?($0)
            }
        }
    }

    deinit {
        _observer.map(NotificationCenter.default.removeObserver)
    }

    public var description: String {
        return "inputs: \(inputs)\n, output: \(outputs)"
    }

    private func _notification(endpoint: MIDIEndpoint, type: MIDIEndpointNotificationType) -> MIDIPort? {
        switch (endpoint.type, type) {

        case (.input, .added):
            return inputs.add(endpoint)

        case (.output, .added):
            return outputs.add(endpoint)

        case (.input, .removed):
            return inputs.remove(endpoint).map {
                $0.close()
                return $0
            }

        case (.output, .removed):
            return outputs.remove(endpoint).map {
                $0.close()
                return $0
            }
        }
    }

    /// given an output, tries to find the corresponding input port (non-standard)
    public func input(for port: MIDIOutput) -> MIDIInput? {
        return inputs.port(with: port.displayName)
    }

    /// given an input, tries to find the corresponding output port (non-standard)
    public func output(for port: MIDIInput) -> MIDIOutput? {
        return outputs.port(with: port.displayName)
    }

    /// Stops and restarts MIDI I/O (non-standard)
    public func restart() {
        MIDIRestart()
    }

    private let _client: MIDIClient
    //  private let _clients: Set<MIDIClient> = []

    //  private let _input: MIDIInput
    //  private let _output: MIDIOutput

    private var _observer: NSObjectProtocol? = nil

}

fileprivate extension NotificationCenter {
    final func observeMIDIEndpoints(_ callback: @escaping (MIDIEndpoint, MIDIEndpointNotificationType) -> ()) -> NSObjectProtocol {
        return addObserver(forName: .MIDISetupNotification, object: nil, queue: nil) {
            _ = ($0.object as? MIDIObjectAddRemoveNotification).map {
                callback(.init(notification: $0),
                         MIDIEndpointNotificationType($0.messageID))
            }
        }
    }
}
