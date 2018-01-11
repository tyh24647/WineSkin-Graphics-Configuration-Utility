//
//  AppDelegate.swift
//  SettingsLauncher
//
//  Created by Tyler hostager on 12/19/17.
//  Copyright © 2017 Tyler hostager. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        NSApplication.shared.mainWindow?.isMovableByWindowBackground = true
        NSApplication.shared.mainWindow?.styleMask.remove(.resizable)
        
        NSLog("Initializing application..")
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        NSLog("Terminating application...")
        
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        NSApplication.shared.terminate(self)
        NSLog("Application Terminated")
        return true
    }
    
    
}

