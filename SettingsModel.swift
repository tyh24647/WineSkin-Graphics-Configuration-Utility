//
//  SettingsModel.swift
//  SettingsLauncher
//
//  Created by Tyler hostager on 1/11/18.
//  Copyright © 2018 Tyler hostager. All rights reserved.
//

import Foundation

enum GameType {
    case BFME1
    case BFME2
    case ROTWK
    case NONE
}

func gameTypeFromTite(_ title: String) -> GameType {
    var tmpGameType = { () -> GameType in
        return title.contains("2") ? .BFME2 : title.lowercased().contains("rise") ? .ROTWK : title.contains("battle") ? .BFME1 : .NONE
    }()
    
    if tmpGameType == .NONE {
        Log("\n\n ERROR: No game type specified")
        Log("Assigning default value\n\n")
        tmpGameType = .BFME1
    }
    
    NSLog("\n\nGAME TYPE: \(tmpGameType)\n\n")
    
    return tmpGameType
}

func exePathForGame(named gameName: String) -> String! {
    var tmpPath = ""
    
    switch gameName {
    case "BFME", "Battle for Middle Earth", "Battle for Middle-Earth":
        tmpPath = "/Applications/Battle for Middle-Earth/Battle for Middle-Earth.app/Contents/Resources/drive_c/Program Files/EA GAMES/The Battle for Middle-earth (tm)/lotrbfme.exe"
        break
    case "BFME2":
        tmpPath = "/Applications/Battle for Middle-Earth II/Rise of the Witch King.app/Contents/Resources/drive_c/Program Files/Electronic Arts/The Battle for Middle-earth (tm) II/lotrbfme2.exe"
        break
    case "ROTWK":
        tmpPath = "/Applications/Battle for Middle-Earth II/Rise of the Witch King.app/Contents/Resources/drive_c/Program Files/Electronic Arts/The Lord of the Rings, The Rise of the Witch-king/lotrbfme2ep1.exe"
        break
    default:
        tmpPath = "/Applications/Battle for Middle-Earth/Battle for Middle-Earth.app/Contents/Resources/drive_c/Program Files/EA GAMES/The Battle for Middle-earth (tm)/lotrbfme.exe"
        break
    }
    
    return tmpPath
}


