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
    case tv
    case robot
}

//FIXME: add another extension
class NSTextLabel: NSTextField {
    
    required override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.isBezeled = false
        self.drawsBackground = false
        self.isEditable = false
        self.isSelectable = false
        self.font = NSFont.systemFont(ofSize: 15)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}

