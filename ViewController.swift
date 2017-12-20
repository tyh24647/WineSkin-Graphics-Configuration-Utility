//
//  ViewController.swift
//  SettingsLauncher
//
//  Created by Tyler hostager on 12/19/17.
//  Copyright © 2017 Tyler hostager. All rights reserved.
//

import Cocoa

struct FilePaths {
    static var dBFMESettingsPath = "/Applications/Battle for Middle-Earth/Battle for Middle-Earth.app/Contents/Info.plist"
    static var optionsIniFilePath = "/Applications/Battle for Middle-Earth/Battle for Middle-Earth.app/drive_c/users/Wineskin/Application Data/My Battle for Middle-earth Files/options.ini"
}

class ViewController: NSViewController, NSComboBoxDelegate, NSComboBoxDataSource {
    @IBOutlet var resCB: NSComboBox!
    @IBOutlet var cancelBtn: NSButton!
    @IBOutlet var applyBtn: NSButton!
    
    let defaultResolutionOptions: [String] = [
        "800 x 600",
        "1024 x 768",
        "1280 x 800",
        "1440 x 900",
        "1680 x 1050",
        "1920 x 1080",
        "1920 x 1200"
    ]
    
    var resolutionOptions: [String]!
    var selectedItem: String!
    var alert: NSAlert!
    var errStr: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let tmpCB = resCB {
            var currentResIndex: Int!
            var tmpArr = Array<CGDisplayMode>.init(Display.modes)
            self.resolutionOptions = [String]()
            tmpCB.delegate = self
            tmpCB.dataSource = self
            
            let resolution: String! = Display.mode!.resolution
            
            if resolution != nil {
                
                for index in 0 ... tmpArr.count - 1 {
                    if tmpArr[index].resolution == resolution {
                        currentResIndex = index
                    }
                }
                
                if tmpArr.count > 0 {
                    for mode in tmpArr { self.resolutionOptions.append(mode.resolution) }
                    self.resCB.selectItem(at: currentResIndex)
                }
            }
            
            tmpCB.selectItem(at: currentResIndex)
        }
        
        if self.resolutionOptions.count == 0 {
            self.resolutionOptions = defaultResolutionOptions
        }
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        exitApplication()
    }
    
    @available(macOS, deprecated: 10.10)
    @IBAction func applyBtnPressed(_ sender: Any) {
        let fileManager = FileManager.default
        
        NSLog("Searching for file at path: \(FilePaths.dBFMESettingsPath)")
        if fileManager.fileExists(atPath:  FilePaths.dBFMESettingsPath) {
            NSLog("Property list file found successfully")
            
            let plistDict = NSMutableDictionary(contentsOfFile: FilePaths.dBFMESettingsPath)
            
            var splitStr = self.resolutionOptions[resCB.indexOfSelectedItem].components(separatedBy: " x ")
            let xVal = splitStr[0]
            let yVal = splitStr[1]
            
            NSLog("Setting plist values...")
            plistDict?.setValue("-xres \(xVal) -yres \(yVal)" as AnyObject, forKey: "Program Flags")
            if plistDict != nil {
                NSLog("Value set successfully")
            }
            
            NSLog("Parsing and editing \"options.ini\" file at path:  \(FilePaths.optionsIniFilePath)")
            parseAndEditIniFile(
                with: fileManager,
                withXValue: xVal,
                withYValue: yVal
            )
            NSLog("\"options.ini\" file configured successfully")
            
            do {
                try plistDict?.write(to: URL(fileURLWithPath: FilePaths.dBFMESettingsPath, isDirectory: false))
            } catch {
                errStr = "ERROR: Unable to write to file at path \(FilePaths.dBFMESettingsPath)\nSkipping procedure"
            }
        } else {
            errStr = "ERROR: File not found\nSkipping procedure."
        }
        
        var clickResult: Bool!
        if errStr != nil && !errStr.isEmpty {
            clickResult = resultDialogue(prompt: "An error occurred while changing the resolution values.", description: errStr)
        } else {
            clickResult = resultDialogue(prompt: "Settings changes applied successfully!", description: "The changes will be applied the next time the application is launched.")
        }
        
        
        if clickResult == true {
            exitApplication()
        }
    }
    
    
    
    
    /// Parses the windows "options.ini" file (not supported by mac computers so we have to do it manually),
    /// and re-writes the value for the resolution so the changes are saved in the AppData folder and will remain
    /// the same until the user decides to change it again.
    ///
    /// - Parameters:
    ///   - fileManager: The file manager shared in this instance to handle file parsing, reading, and writing
    ///   - xVal: The value in which the width of the resolution should be set
    ///   - yVal: The value in which the height of the resolution should be set
    @available(macOS, deprecated: 10.10) func parseAndEditIniFile(with fileManager: FileManager, withXValue xVal: String!, withYValue yVal: String!) -> Void {
        if fileManager.fileExists(atPath: FilePaths.optionsIniFilePath) {
            do {
                var fileContents = try String(contentsOfFile: FilePaths.optionsIniFilePath)
                let resHeaderSubStr = "Resolution = "
                if fileContents.contains(resHeaderSubStr) {
                    let substringVal = fileContents.slice(from: resHeaderSubStr, to: "\n")
                    let newResVal = "\(xVal!) \(yVal!)"
                    
                    // Replace the value at the corresponding "Resolution" header with the string containing the new values
                    NSLog("Replacing options.ini value: \"\(resHeaderSubStr.appending(substringVal!))\" --> \"\(resHeaderSubStr.appending(newResVal))\"")
                    fileContents = fileContents.replacingOccurrences(of: substringVal!, with: newResVal)
                    NSLog("Replacement successful")
                    
                    
                    // Delete old file with the incorrect value, and replace it with the file whose value
                    // was changed. This is only necessary because macOS doesn't support writing *.ini files
                    NSLog("Removing old file...")
                    try fileManager.removeItem(atPath: FilePaths.optionsIniFilePath)
                    NSLog("File removed successfully")
                    NSLog("Creating and replacing the ini file with one containing the requested changes...")
                    
                    // behaves similarly to JSON in the file writer
                    fileManager.createFile(
                        atPath: FilePaths.optionsIniFilePath,
                        contents: fileContents.data(using: .utf8),
                        attributes: [
                            FileAttributeKey.type: "ini",
                            FileAttributeKey.extensionHidden: false,
                            FileAttributeKey.groupOwnerAccountName: "wheel"
                        ]
                    )
                    
                    NSLog("File replaced successfully")
                }
            } catch {
                self.errStr = "ERROR: Unable to write to \"options.ini\".\nSkipping procedure"
            }
        }
    }
    
    fileprivate func exitApplication() -> Void {
        NSLog("Closing window...n")
        self.view.window?.close()
    }
    
    func resultDialogue(prompt: String, description: String) -> Bool {
        self.alert = NSAlert()
        self.alert.messageText = prompt
        self.alert.informativeText = description
        self.alert.alertStyle = .warning
        self.alert.addButton(withTitle: "OK")
        
        return self.alert.runModal() == .alertFirstButtonReturn
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
            self.selectedItem = self.resCB.objectValueOfSelectedItem as! String
        }
    }
    
    func comboBoxSelectionIsChanging(_ notification: Notification) {
        //
    }
    
    func numberOfItems(in comboBox: NSComboBox) -> Int {
        return self.resolutionOptions.count
    }
    
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        return index > -1 ? self.resolutionOptions[index] : "Select a resolution..."
    }
}

