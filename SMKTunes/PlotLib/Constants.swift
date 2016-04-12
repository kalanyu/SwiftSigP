//
//  Constants.swift
//  NativeSigP
//
//  Created by Kalanyu Zintus-art on 10/7/15.
//  Copyright © 2015 KoikeLab. All rights reserved.
//

import Foundation
import Cocoa

enum SystemMessages: String {
    case NetworkNoHostName = "Empty host name"
    case NetworkInvalidHost = "Invalid server, please check the address"
    case NetworkEstablished = "Connection established, retrieving packets"
    case NetworkNoPortNumber = "Empty port number"
    case NetworkValidation = "Validating connection"
    case NetworkTerminated = "Connection terminated"
}

enum SMKControlMode {
    case TV
    case Robot
}

//FIXME: add another extension
class NSTextLabel: NSTextField {
    
    required override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.bezeled = false
        self.drawsBackground = false
        self.editable = false
        self.selectable = false
        self.font = NSFont.systemFontOfSize(15)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}

