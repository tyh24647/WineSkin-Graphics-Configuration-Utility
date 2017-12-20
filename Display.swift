//
//  Display.swift
//  SettingsLauncher
//
//  Created by Tyler hostager on 12/19/17.
//  Copyright © 2017 Tyler hostager. All rights reserved.
//

import Foundation

public struct Display {
    
    // the display mode of the current monitor/screen
    public static var mode: CGDisplayMode? {
        get {
            return CGDisplayCopyDisplayMode(CGMainDisplayID())
        }
    }
    
    // The array containing the various supported display modes for the user
    public static var modes: [CGDisplayMode] {
        var result: [CGDisplayMode] = []
        let modes = CGDisplayCopyAllDisplayModes(CGMainDisplayID(), nil).unsafelyUnwrapped
        
        (0..<CFArrayGetCount(modes)).forEach({
            result.append(
                unsafeBitCast(CFArrayGetValueAtIndex(modes, $0), to: CGDisplayMode.self)
            )
        })
        
        return result
    }
}

// Extension of CGDisplayMode to allow for directly obtaining the string
// representation of the current resolution
extension CGDisplayMode {
    var resolution: String {
        get {
            return String(width) + " x " + String(height)
        }
    }
}

