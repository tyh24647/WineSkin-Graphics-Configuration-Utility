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
    static var userRegistry = "/Applications/Battle for Middle-Earth/Battle for Middle-Earth.app/Contents/Resources/user.reg"
}

class ViewController: NSViewController, NSComboBoxDelegate, NSComboBoxDataSource {
    @IBOutlet var resCB: NSComboBox!
    @IBOutlet var cancelBtn: NSButton!
    @IBOutlet var applyBtn: NSButton!
    @IBOutlet var launchGameOnExitBox: NSButton!
    @IBOutlet var browseModsBtn: NSButton!
    @IBOutlet var fNInputField: NSTextField!
    @IBOutlet var installModBtn: NSButton!
    @IBOutlet var useXQuartzChkBx: NSButton!
    @IBOutlet var decorateViewsBtn: NSButton!
    
    let defaultResolutionOptions = [
        "800 x 600",
        "1024 x 768",
        "1280 x 800",
        "1440 x 900",
        "1680 x 1050",
        "1920 x 1080",
        "1920 x 1200"
    ]
    
    let defaultAppName = "Battle for Middle-Earth"
    var resolutionOptions: [String]!
    var selectedItem: String!
    var alert: NSAlert!
    var errStr: String!
    var p_useXQuartz: Bool!
    var p_useDirect3D: Bool!
    var p_decorateViews: Bool!
    
    private var _specifiedAppName: String!
    public var specifiedAppName: String! {
        get {
            return _specifiedAppName ?? self.defaultAppName
        } set {
            _specifiedAppName = newValue ?? _specifiedAppName ?? self.defaultAppName
        }
    }
    
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
        
        self.launchGameOnExitBox.state = .on    // launch app on exit by default
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
            
            
            // SET RESOLUTION
            NSLog("Setting plist values...")
            plistDict?.setValue("-xres \(xVal) -yres \(yVal)" as AnyObject, forKey: "Program Flags")
            if plistDict != nil {
                NSLog("Value set successfully")
            }
            
            
            // USE XQUARTZ
            self.p_useXQuartz = self.useXQuartzChkBx.state == .on
            plistDict?.setValue(self.p_useXQuartz, forKey: "Use XQuartz")
            
            // Configure windows registry-related values
            if fileManager.fileExists(atPath: FilePaths.userRegistry) {
                if let registryDict = NSMutableDictionary(contentsOfFile: FilePaths.userRegistry) {
                    
                    
                    NSLog("User registry data: \(registryDict)")
                }
            }
            
            
            
            NSLog("Parsing and editing \"options.ini\" file at path:  \(FilePaths.optionsIniFilePath)")
            parseAndEditIniFile(
                with: fileManager,
                withXValue: xVal,
                withYValue: yVal
            )
            
            NSLog("\"options.ini\" file configured successfully")
            
            do {
                if #available(macOS 10.13, *) {
                    try plistDict?.write(
                        to: URL(
                            fileURLWithPath: FilePaths.dBFMESettingsPath,
                            isDirectory: false
                        )
                    )
                } else {
                    plistDict!.write(
                        toFile: FilePaths.dBFMESettingsPath,
                        atomically: true
                    )
                    
                    NSLog("Replacement property list saved successfully")
                }
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
            
            // Asynchronously load BFME from dispatch queue while this app closes
            //launchApplicationInPLIST()
        }
    }
    
    
    /// The "Browse for mods button was clicked -- allows for the user to specify
    /// and install mods
    ///
    /// - Parameter sender: The browse files button
    @IBAction func browseModsBtnPressed(_ sender: Any) {
        let dialog = NSOpenPanel();
        dialog.title = "Choose a valid .exe/.msi file"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canChooseDirectories = true
        dialog.canCreateDirectories = true
        dialog.allowsMultipleSelection = false
        dialog.allowedFileTypes  = ["exe", "msi"]
        
        if (dialog.runModal() == .OK) {
            let result = dialog.url // Pathname of the file
            
            if (result != nil) {
                let path = result?.path
                self.fNInputField.stringValue = path!
            }
        } else {
            // User clicked on "Cancel"
            return
        }
    }
    
    @IBAction func InstallModBtnPressed(_ sender: Any) {
        if self.fNInputField != nil && !self.fNInputField.stringValue.isEmpty {
            NSLog("Checking for installation file at the specified path...")
            if FileManager.default.fileExists(atPath: self.fNInputField.stringValue) {
                NSLog("File discovered. Launching in a new window...")
                if FileManager.default.fileExists(atPath: FilePaths.dBFMESettingsPath) {
                    NSLog("Property list file found successfully")
                    let plistDict = NSMutableDictionary(contentsOfFile: FilePaths.dBFMESettingsPath)
                    NSLog("Setting plist values...")
                    plistDict?.setValue(self.fNInputField.stringValue as AnyObject, forKey: "Program Name and Path")
                    do {
                        if #available(macOS 10.13, *) {
                            try plistDict?.write(
                                to: URL(
                                    fileURLWithPath: FilePaths.dBFMESettingsPath,
                                    isDirectory: false
                                )
                            )
                        } else {
                            plistDict!.write(
                                toFile: FilePaths.dBFMESettingsPath,
                                atomically: true
                            )
                            
                            NSLog("Replacement property list saved successfully")
                        }
                        
                        NSLog("Running installer package...")
                        launchApplicationInPLIST()
                        
                    } catch {
                        errStr = "ERROR: Unable to write to file at path \(FilePaths.dBFMESettingsPath)\nSkipping procedure"
                    }
                    
                } else {
                    resultDialogue(prompt: "Error: Unable to locate property list file \"Info.plist\"", description: "Please ensure everything is in the same location and is named correctly")
                }
                
            } else {
                resultDialogue(prompt: "Error: The specified mod file doesn't seem to exist, isn't in the specified folder, or cannot be opened", description: "Please verify everything was put into the right place and try again\nNote: Some mods will not work in WineSkin")
            }
            
        } else {
            NSLog("Install button pressed with no input. Ignoring action.")
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
    
    func launchApplicationInPLIST() -> Void {
        NSLog("Launching application saved in the property list...")
        /*
        OperationQueue.main.addOperation({
            NSWorkspace.shared.launchApplication(self.defaultAppName)
        })
 */
        // Create a Task instance
        let task = Process()
        
        // Set the task parameters
        task.launchPath = "/usr/bin/env"
        task.arguments = []
        
        // Create a Pipe and make the task
        // put all the output there
        let pipe = Pipe()
        task.standardOutput = pipe
        
        // Launch the task
        task.launch()
        
        // Get the data
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        
        NSLog(output! as String)
        /*
        NSLog("Bash shell script executed:\"\(ShellScriptExecutionTask.bash(command: "open \(self.defaultAppName)", arguments: ["-a", "Battle for Middle-Earth"]))\"")
 */
        
        NSLog("Application launched successfully")
    }
    
    fileprivate func exitApplication() -> Void {
        NSLog("Closing window...n")
        NSLog("Telling the application to open the game, if necessary")
        self.view.window?.close()
    }
    
    @discardableResult func resultDialogue(prompt: String, description: String) -> Bool {
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
    
    func numberOfItems(in comboBox: NSComboBox) -> Int {
        return self.resolutionOptions.count
    }
    
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        return index > -1 ? self.resolutionOptions[index] : "Select a resolution..."
    }
}

