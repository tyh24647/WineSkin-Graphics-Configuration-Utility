//
//  Log.swift
//  SettingsLauncher
//
//  Created by Tyler hostager on 12/21/17.
//  Copyright © 2017 Tyler hostager. All rights reserved.
//

import Cocoa

public func Log(_ format: String, _ args: CVarArg..., debugTxtView: AnyObject? = nil, isError: Bool? = false, sender: Any? = nil) {
    
    #if DEBUG
        NSLog(format, args)
    #endif
    
    if debugTxtView != nil {
        if let dbgTxtView = debugTxtView as! NSTextView! {
            let txtToAdd = NSAttributedString(
                string: String(
                    format: format.appending("\n"),
                    arguments: args
                ),
                
                attributes: (
                    isError! ? [
                        .backgroundColor : NSColor.red,
                        .foregroundColor : NSColor.white
                        ] : [
                            .backgroundColor: NSColor.clear,
                            .foregroundColor: NSColor.black
                    ]
                )
            )
            
            dbgTxtView.textStorage?.append(txtToAdd)
        }
    }
}

public func Log(_ format: String, _ args: CVarArg...) {
    #if DEBUG
        NSLog(format, args)
    #endif
}

public func Log(_ message: String) {
    #if DEBUG
        NSLog(message)
    #endif
    
}

