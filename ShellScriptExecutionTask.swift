//
//  ShellScriptExecutionTask.swift
//  SettingsLauncher
//
//  Created by Tyler hostager on 12/20/17.
//  Copyright © 2017 Tyler hostager. All rights reserved.
//

import Foundation

public struct ShellScriptExecutionTask {
    
    init(_ args: String) {
        addTask(args)
        
    }
    
    @discardableResult
    public func addTask(_ args: String...) -> String {
        Log("Adding shell script task: \"%@\"", args)
        let task = Process()
        task.launchPath = "/usr/bin/env"
        task.arguments = args
        
        let pipe = Pipe()
        task.standardOutput = pipe
        
        task.launch()
        task.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        Log("Task data: \"\(data.debugDescription)\"")
        
        guard let output: String = String(data: data, encoding: .utf8) else {
            return ""
        }
        
        return output
    }
    
    
    static func shell(launchPath: String, arguments: [String]) -> String {
        let task = Process()
        let pipe = Pipe()
        
        task.launchPath = launchPath
        task.arguments = arguments
        task.standardOutput = pipe
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        Log("Task data: \"\(data.debugDescription)\"")
        
        let output = String(data: data, encoding: String.Encoding.utf8)!
        if output.count > 0 {
            //remove newline character.
            let lastIndex = output.index(before: output.endIndex)
            return String(output[output.startIndex ..< lastIndex])
        }
        
        return output
    }
    
    static func bash(command: String, arguments: [String]) -> String {
        Log("Bash command received: \n\n\tCommand:\"%@\"\n\tArguments:\"%@\"", command, arguments)
        let whichPathForCommand = shell(launchPath: "/bin/bash", arguments: [ "-l", "-c", "which \(command)" ])
        return shell(launchPath: whichPathForCommand, arguments: arguments)
    }
}
