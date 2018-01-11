//
//  UserDefaults.swift
//  SettingsLauncher
//
//  Created by Tyler hostager on 1/11/18.
//  Copyright © 2018 Tyler hostager. All rights reserved.
//

import Foundation

public class StringConstants {
    
    
    public struct Defaults {
        struct BFME2 {
            struct PropertyLists {
                enum Paths: String {
                    case wineskin = "/Applications/Battle for Middle-Earth II/Rise of the Witch King.app/Contents/Info.plist"
                }
                
                enum Values {
                    
                }
            }
            
            struct Paths {
                
                
                static let plist = "/Applications/Battle for Middle-Earth/BFME2.app/Contents/Info.plist"
                
                static let installation = "/Applications/Battle for Middle-Earth/Rise of the Witch King.app"
                static let winExe = ""
            }
            
            static var plistPath = "/Applications/Battle for Middle-Earth/BFME2.app/Contents/Info.plist"
            
        }
        
        enum ROTWK {
            static var plistPath = "/Applications/Battle for Middle-Earth/BFME2.app/Contents/Info.plist"
        }
        
        struct BFME1 {
            static let winExePath = "/Applications/Battle for Middle-Earth/Battle for Middle-Earth.app/Contents/Resources/drive_c/Program Files/EA GAMES/The Battle for Middle-earth (tm)/lotrbfme.exe"
            static let macAppPath = "/Applications/Battle for Middle-Earth/Battle for Middle-Earth.app"
            static let plistPath = "/Applications/Battle for Middle-Earth/Battle for Middle-Earth.app/Contents/Info.plist"
            
        }
        
        
        
        static var kBFME1_defaultPLISTLocalPath = "/Applications/Battle for Middle-Earth/Battle for Middle-Earth.app/Contents/Info.plist"
        
    }
}
