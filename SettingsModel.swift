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
    
    
    
    return tmpPath
}


