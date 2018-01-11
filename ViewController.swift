//
//  ViewController.swift
//  SettingsLauncher
//
//  Created by Tyler hostager on 12/19/17.
//  Copyright © 2017 Tyler hostager. All rights reserved.
//

import Cocoa

struct FilePaths {
    static var kBFME2_defaultPLISTLocalPath = "/Applications/Battle for Middle-Earth/Battle for Middle-Earth.app/Contents/Info.plist"
    static var optionsIniFilePath = "/Applications/Battle for Middle-Earth/Battle for Middle-Earth.app/drive_c/users/Wineskin/Application Data/My Battle for Middle-earth Files/options.ini"
    static var userRegistry = "/Applications/Battle for Middle-Earth/Battle for Middle-Earth.app/drive_c/user.reg"
    static var defaultGamePath = "/Applications/Battle for Middle-Earth/Battle for Middle-Earth.app/Contents/Resources/drive_c/Program Files/EA GAMES/The Battle for Middle-earth (tm)/lotrbfme.exe"
    static var defaultBFME2gamePathn = ""
    
}

class ViewController: NSViewController, NSComboBoxDelegate, NSComboBoxDataSource, NSOpenSavePanelDelegate {
    
    // MARK: Init IBOutlet vars
    @IBOutlet var resCB: NSComboBox!
    @IBOutlet var cancelBtn: NSButton!
    @IBOutlet var applyBtn: NSButton!
    @IBOutlet var launchGameOnExitBox: NSButton!
    @IBOutlet var browseModsBtn: NSButton!
    @IBOutlet var fNInputField: NSTextField!
    @IBOutlet var installModBtn: NSButton!
    @IBOutlet var useXQuartzChkBx: NSButton!
    @IBOutlet var decorateViewsBtn: NSButton!
    @IBOutlet var detectGPU: NSButton!
    @IBOutlet var decorateViews: NSButton!
    @IBOutlet var forceWindowedchkBx: NSButton!
    @IBOutlet var exeFlagsTextField: NSTextField!
    @IBOutlet var gamesChooserCB: NSComboBox!
    @IBOutlet var forceUseWrapperQuartzWM: NSButton!
    @IBOutlet var multithreadingBtn: NSButton!
    @IBOutlet var gameEXETxtField: NSTextField!
    @IBOutlet var changeExeTxtField: NSButton!
    @IBOutlet var viewSrcCodeBtn: NSButton!
    @IBOutlet var bgTitleViewBox: NSBox!
    @IBOutlet var bgTitleView: NSView!
    
    // MARK: Init constants
    let defaultAppName = "Battle for Middle-Earth"
    let defaultResolutionOptions = [
        "800 x 600",
        "1024 x 768",
        "1280 x 800",
        "1440 x 900",
        "1680 x 1050",
        "1920 x 1080",
        "1920 x 1200"
    ]
    
    // MARK: Init variables
    var resolutionOptions: [String]!
    var selectedItem: String!
    var alert: NSAlert!
    var errStr: String!
    var recommendedIndex: Int?
    var defaultGameSelection = GameType.BFME1
    var selectedGame: GameType!
    var fnFIlePath: String!
    
    // MARK: Init player variables
    var p_useXQuartz: Bool!
    var p_useDirect3D: Bool!
    var p_decorateViews: Bool!
    var p_forceWindowdMode: Bool!
    var p_selectedFilePath: String!
    var p_exeFlags: String!
    var p_forceWindowedMode: Bool!
    var p_force_wrapper_use_quartz_wm: Bool!
    var p_isThreadedLoad: Bool!
    var p_selectedEXEPath: String!
    var p_selectedResolutionIndex: Int!
    
    private var _specifiedAppName: String!
    public var specifiedAppName: String! {
        get {
            return _specifiedAppName ?? self.defaultAppName
        } set {
            _specifiedAppName = newValue ?? _specifiedAppName ?? self.defaultAppName
        }
    }
    
    override func viewWillAppear() {
        //self.view.window!.isOpaque = false
        //self.view.window?.alphaValue; 0.8
        //self.view.window!.backgroundColor = .clear
        
        
        self.viewSrcCodeBtn.title = "View Source Code"
        //self.bgTitleViewBox.fillColor = .clear
        
        self.fnFIlePath = StringConstants.Defaults.kBFME1_defaultPLISTLocalPath
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.recommendedIndex = -1      // this will change before the user sees it
        self.gamesChooserCB.selectItem(at: 0) // default selection
        self.resolutionOptions = ["Select a resolution..."]
        
        if let tmpCB = resCB {
            var currentResIndex: Int!
            var tmpArr = Array<CGDisplayMode>.init(Display.modes)
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
                    for mode in tmpArr {
                        if !self.resolutionOptions.contains(mode.resolution) {
                            self.resolutionOptions.append(mode.resolution)
                            
                        }
                        
                    }
                    
                    self.resCB.selectItem(at: self.resolutionOptions.index(of: resolution as String)!)
                    //self.resCB.selectItem(at: currentResIndex)
                    
                }
            }
            
            currentResIndex = self.resolutionOptions.index(of: resolution as String)!
            tmpCB.selectItem(at: currentResIndex)
            
            //tmpCB.selectItem(at: currentResIndex)
            self.resCB = tmpCB
        }
        
        
        if self.resolutionOptions.count == 0 {
            self.resolutionOptions = defaultResolutionOptions
        }
        
        Log("Valid screen resolutions detected for this display: \n\nSupported resolutionss[\n\(self.resolutionOptions.debugDescription)\n]")
        Log("Automatically selecting the user's screen size unless specified otherwise...")
        
        // get current screen resolution
        if let scrn: NSScreen = NSScreen.main {
            let rect: NSRect = scrn.frame
            let height = rect.size.height
            let width = rect.size.width
            
            let formattedStr = "\(width) x \(height)"
            
            // Compare it to see iff it's on the list--if it is, select that by default
            var index: Int = 0
            for str in self.resolutionOptions {
                if str == formattedStr || str == Display.mode?.resolution {
                    Log("\(self.resolutionOptions[index]) (Recommended)")
                    self.p_selectedResolutionIndex = index
                    break
                }
                
                Log(self.resolutionOptions[index])
                index += 1
            }
            
            self.recommendedIndex = index // accounting for the first cell at index of -1
            self.resCB.selectItem(at: p_selectedResolutionIndex!)
            
            
            // Do any additional setup after loading the view.
            //self.resCB.selectItem(withObjectValue: self.resolutionOptions[self.recommendedIndex!])
            setupDefaultChkBxValues()
            setupEXEPathTF()
        }
        
    }
    
    /// Update the required values after the game has been changed
    @IBAction func gameCBSelected(_ sender: Any) {
        setupEXEPathTF()
    }
    
    
    
    
    func setupEXEPathTF() -> Void {
        
        // FIXME: Add selected exe path from user defaults file, if present
        let exePath = exePathForGame(named: "Battle for Middle-Earth")!
        
        Log("Setting up exe path...")
        
        //changeEXEPath(FilePaths.kBFME2_defaultPLISTLocalPath)
        //var plistPath = "/Applications/Battle for Middle-Earth/Battle for Middle-Earth.app/Contents/Info.plist"
        var plistPath: String!
        let selectedCellTitle: String! = self.gamesChooserCB.selectedCell()?.title
        
        Log("Configuring property list file...")
        if selectedCellTitle != nil && !selectedCellTitle.isEmpty {
            if selectedCellTitle == "BFME2" {
                plistPath = "/Applications/Battle for Middle-Earth II/BFME2.app/Contents/Info.plist"
            } else if selectedCellTitle == "BFME" || selectedCellTitle == "ROTWK" {
                plistPath = "/Applications/Battle for Middle-Earth II/Rise of the Witch King.app/Contents/Info.plist"
            } else {
                // TODO Change from brute-forcing in the view controller to setting in this
            }
        }
        
        changeEXEPath(
            self.selectedGame == nil ?
                FilePaths.defaultGamePath :
                exePathForGame(named: exePath)
        )
    }
    
    func changeEXEPath(_ path: String!) -> Void {
        Log("Searching for property-list file at the specified path: \"%@\"", path)
        if (FileManager.default.fileExists(atPath: path)) {
            Log("Property list file found successfully")
            let plistDict = NSMutableDictionary(contentsOfFile: path)
            
            //self.p_selectedEXEPath = FilePaths.defaultGamePath
            self.p_selectedEXEPath = exePathForGame(named: (self.gamesChooserCB.selectedCell()?.title)!)
            plistDict?.setValue(self.p_selectedEXEPath, forKey: "Program Name and Path")
            self.gameEXETxtField.stringValue = self.p_selectedEXEPath
        }
        
        /*
         if FileManager.default.fileExists(atPath: FilePaths.defaultGamePath) {
         Log("Property list file found successfully")
         let plistDict = NSMutableDictionary(contentsOfFile: FilePaths.defaultGamePath)
         self.p_selectedEXEPath = FilePaths.defaultGamePath
         plistDict?.setValue(self.p_selectedEXEPath, forKey: "Program Name and Path")
         self.gameEXETxtField.stringValue = p_selectedEXEPath
         }
         */
    }
    
    fileprivate func setupDefaultChkBxValues() -> Void {
        self.launchGameOnExitBox.state = .on
        //self.forceWindowedchkBx.state = .off
        
    }
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        //NSApplication.shared.undoManager?.undoNestedGroup()
        //exitApplication()
    }
    
    @IBAction func chgGameExeBtnPressed(_ sender: Any) {
        browseModsBtnPressed(sender)
    }
    
    func gameTypeFromPicker(_ cName: String!) -> GameType! {
        return cName.contains("2") ? .BFME2 : cName.lowercased().contains("rise") ? .ROTWK : cName.contains("battle") ? .BFME1 : .NONE
    }
    
    @available(macOS, deprecated: 10.10)
    @IBAction func applyBtnPressed(_ sender: Any) {
        let fileManager = FileManager.default
        if resCB.indexOfSelectedItem == -1 {
            resCB.selectItem(at: 0)
            
        }
        
        let selectedCellTitle: String! = self.gamesChooserCB.selectedCell()?.title
        var plistPath: String!
        
        Log("Configuring property list file...")
        if selectedCellTitle != nil && !selectedCellTitle.isEmpty {
            if selectedCellTitle == "BFME2" {
                plistPath = "/Applications/Battle for Middle-Earth II/BFME2.app/Contents/Info.plist"
            } else if selectedCellTitle == "BFME" || selectedCellTitle == "ROTWK" {
                plistPath = "/Applications/Battle for Middle-Earth II/Rise of the Witch King.app/Contents/Info.plist"
            } else {
                // TODO Change from brute-forcing in the view controller to setting in this
            }
        }
        
        self.p_selectedFilePath = plistPath
        
        Log("Searching for file at path: \(plistPath)")
        if fileManager.fileExists(atPath:  plistPath) {
            Log("Property list file found successfully")
            let plistDict = NSMutableDictionary(contentsOfFile: plistPath)
            var splitStr = self.resolutionOptions[resCB.indexOfSelectedItem].components(separatedBy: " x ")
            
            let xVal = splitStr[0]
            let yVal = splitStr[1]
            
            // SET RESOLUTION
            Log("Setting plist values...")
            plistDict?.setValue("-xres \(xVal) -yres \(yVal)" as AnyObject, forKey: "Program Flags")
            if plistDict != nil {
                Log("Value set successfully")
            }
            
            // USE XQUARTZ
            self.p_useXQuartz = self.useXQuartzChkBx.state == .on
            plistDict?.setValue(self.p_useXQuartz, forKey: "Use XQuartz")
            
            self.p_force_wrapper_use_quartz_wm = self.forceUseWrapperQuartzWM!.state == .on
            plistDict?.setValue(true, forKey: "force wrapper quartz-wm")
            
            
            /* TODO: Registry editor values
             if let registryDict = NSMutableDictionary(contentsOfFile: FilePaths.userRegistry) {
             Log("User registry data: \(registryDict)")
             
             
             //if registryDict.keyEnumerator().contains(where: { (String) -> Bool in
             //keyWhen
             //})
             }
             */
            //}
            
            self.p_isThreadedLoad = self.multithreadingBtn.state == .on
            plistDict?.setValue(self.p_isThreadedLoad , forKey: "IsThreadedLoad")
            
            var iniFilePath = ""
            Log("Launching application saved in the property list...")
            let selectedCellTitle: String! = self.gamesChooserCB.selectedCell()?.title
            if selectedCellTitle != nil && !selectedCellTitle.isEmpty {
                if selectedCellTitle == "BFME2" || selectedCellTitle == "ROTWK" {
                    iniFilePath = "/Applications/Battle for Middle-Earth II/Rise of the Witch King.app/Contents/Resources/drive_c/users/Wineskin/AppData/Roaming/My Battle for Middle-earth(tm) II Files/Options.ini"
                } else if selectedCellTitle == "BFME" {
                    iniFilePath = FilePaths.optionsIniFilePath
                } else {
                    // TODO: add other mac ports
                }
            }
            
            Log("Parsing and editing \"options.ini\" file at path: \"%@\"", iniFilePath)
            self.parseAndEditIniFile(
                with: fileManager,
                withXValue: xVal,
                withYValue: yVal,
                atPath: iniFilePath
            )
            
            Log("\"options.ini\" file configured successfully")
            Log("Applying property list file changes...")
            
            var plistPath: String!
            Log("Configuring property list file...")
            if selectedCellTitle != nil && !selectedCellTitle.isEmpty {
                if selectedCellTitle == "BFME2" {
                    plistPath = "/Applications/Battle for Middle-Earth II/BFME2.app/Contents/Info.plist"
                } else if selectedCellTitle == "BFME" || selectedCellTitle == "ROTWK" {
                    plistPath = "/Applications/Battle for Middle-Earth II/Rise of the Witch King.app/Contents/Info.plist"
                } else {
                    // TODO Change from brute-forcing in the view controller to setting in this
                }
            }
            
            // ensure property list path has been assigned properly
            plistPath = { () -> String in
                return plistPath != nil && !plistPath.isEmpty ? plistPath : FilePaths.kBFME2_defaultPLISTLocalPath
            }()
            
            do {
                if #available(macOS 10.13, *) {
                    try plistDict?.write(
                        to: URL(
                            fileURLWithPath: plistPath,
                            isDirectory: false
                        )
                    )
                } else {
                    plistDict!.write(
                        toFile: plistPath,
                        atomically: true
                    )
                    
                    Log("Replacement property list saved successfully")
                }
            } catch {
                errStr = "ERROR: Unable to write to file at path \(plistPath)\n\nSkipping procedure"
            }
        } else {
            errStr = "ERROR: File not found\nSkipping procedure."
        }
        
        if errStr != nil && !errStr.isEmpty {
            resultDialogue(prompt: "An error occurred while changing the resolution values.", description: errStr)
        } else {
            resultDialogue(prompt: "Settings changes applied successfully!", description: "The changes will be applied the next time the application is launched.")
        }
        
        self.launchApplicationInPLIST()
    }
    
    func applyPlistChangesToFileAtPath(_ filePath: String!) {
        
    }
    
    
    /// The "Browse for mods button was clicked -- allows for the user to specify
    /// and install mods
    ///
    /// - Parameter sender: The browse files button
    @IBAction func browseModsBtnPressed(_ sender: Any) {
        let dialog = NSOpenPanel()
        dialog.title = "Choose a valid .exe/.msi file"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = true
        dialog.canCreateDirectories = true
        dialog.allowsMultipleSelection = false
        dialog.allowedFileTypes  = ["exe", "msi"]
        dialog.hasShadow = true
        dialog.canChooseDirectories = false
        dialog.resolvesAliases = true
        dialog.treatsFilePackagesAsDirectories = true
        
        if dialog.runModal() == .OK {
            let result = dialog.url // Pathname of the file
            
            if result != nil {
                let path = result?.path
                if sender as? NSButton == self.browseModsBtn {
                    self.fNInputField.stringValue = path!
                } else if sender as? NSButton == self.changeExeTxtField {
                    self.changeExeTxtField.stringValue = path!
                    return
                }
                
                self.installModBtn.isEnabled = true
            }
        } else {
            // User clicked on "Cancel"
            return
        }
    }
    
    @IBAction func InstallModBtnPressed(_ sender: Any) {
        if self.fNInputField != nil && !self.fNInputField.stringValue.isEmpty {
            Log("Checking for installation file at the specified path...")
            if FileManager.default.fileExists(atPath: self.fNInputField.stringValue) {
                Log("File discovered. Launching in a new window...")
                let selectedCellTitle: String! = self.gamesChooserCB.selectedCell()?.title
                var plistPath: String!
                
                Log("Configuring property list file...")
                if selectedCellTitle != nil && !selectedCellTitle.isEmpty {
                    if selectedCellTitle == "BFME2" {
                        plistPath = "/Applications/Battle for Middle-Earth II/BFME2.app/Contents/Info.plist"
                    } else if selectedCellTitle == "BFME" || selectedCellTitle == "ROTWK" {
                        plistPath = "/Applications/Battle for Middle-Earth II/Rise of the Witch King.app/Contents/Info.plist"
                    } else {
                        // TODO Change from brute-forcing in the view controller to setting in this
                    }
                }
                
                if FileManager.default.fileExists(atPath: plistPath) {
                    Log("Property list file found successfully")
                    let plistDict = NSMutableDictionary(contentsOfFile: plistPath)
                    self.p_selectedFilePath = plistPath
                    Log("Setting plist values...")
                    plistDict?.setValue(self.fNInputField.stringValue as AnyObject, forKey: "Program Name and Path")
                    
                    self.p_useXQuartz = self.useXQuartzChkBx.state == .on
                    plistDict?.setValue(self.p_useXQuartz!.description, forKey: "Use XQuartz")
                    
                    do {
                        if #available(macOS 10.13, *) {
                            try plistDict?.write(
                                to: URL(
                                    fileURLWithPath: plistPath,
                                    isDirectory: false
                                )
                            )
                        } else {
                            plistDict!.write(
                                toFile: plistPath,
                                atomically: true
                            )
                            
                            Log("Replacement property list saved successfully")
                        }
                        
                        Log("Running installer package...")
                        launchApplicationInPLIST()
                        
                    } catch {
                        errStr = "ERROR: Unable to write to file at path \(plistPath)\nSkipping procedure"
                    }
                } else {
                    resultDialogue(prompt: "Error: Unable to locate property list file \"Info.plist\"", description: "Please ensure everything is in the same location and is named correctly")
                }
            } else {
                resultDialogue(prompt: "Error: The specified mod file doesn't seem to exist, isn't in the specified folder, or cannot be opened", description: "Please verify everything was put into the right place and try again\nNote: Some mods will not work in WineSkin")
            }
        } else {
            Log("Install button pressed with no input. Ignoring action.")
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
    @available(macOS, deprecated: 10.10) func parseAndEditIniFile(with fileManager: FileManager, withXValue xVal: String!, withYValue yVal: String!, atPath iniFilePath: String!) -> Void {
        if fileManager.fileExists(atPath: iniFilePath) {
            do {
                var fileContents = try String(contentsOfFile: iniFilePath)
                let resHeaderSubStr = "Resolution = "
                if fileContents.contains(resHeaderSubStr) {
                    let substringVal = fileContents.slice(from: resHeaderSubStr, to: "\n")
                    let newResVal = "\(xVal!) \(yVal!)"
                    
                    
                    // Replace the value at the corresponding "Resolution" header with the string containing the new values
                    Log("Replacing options.ini value: \"\(resHeaderSubStr.appending(substringVal!))\" --> \"\(resHeaderSubStr.appending(newResVal))\"")
                    fileContents = fileContents.replacingOccurrences(of: substringVal!, with: newResVal)
                    Log("Replacement successful")
                    
                    
                    // Delete old file with the incorrect value, and replace it with the file whose value
                    // was changed. This is only necessary because macOS doesn't support writing *.ini files
                    Log("Removing old file...")
                    try fileManager.removeItem(atPath: iniFilePath)
                    Log("File removed successfully")
                    Log("Creating and replacing the ini file with one containing the requested changes...")
                    
                    // behaves similarly to JSON in the file writer
                    fileManager.createFile(
                        atPath: iniFilePath,
                        contents: fileContents.data(using: .utf8),
                        attributes: [
                            FileAttributeKey.type: "ini",
                            FileAttributeKey.extensionHidden: false,
                            FileAttributeKey.groupOwnerAccountName: "wheel"
                        ]
                    )
                    
                    Log("File replaced successfully")
                }
            } catch {
                self.errStr = "ERROR: Unable to write to \"options.ini\".\nSkipping procedure"
            }
        }
    }
    
    @IBAction func viewSrcBtnPressed(_ sender: Any) {
        Log("Button pressed -> \"View Source\"")
        Log("Opening link \"\"")
        let webLink = "https://github.com/tyh24647/WineSkin-Graphics-Configuration-Utility"
        if let url = URL(string: webLink) {
            NSWorkspace.shared.open(url)
            Log("Web page opened successfully")
        } else {
            Log("Unable to open link")
            Log("Skipping procedure")
        }
        
        
    }
    
    func launchApplicationInPLIST() -> Void {
        var gameToLaunch = ""
        
        Log("Launching application saved in the property list...")
        let selectedCellTitle: String! = self.gamesChooserCB.selectedCell()?.title
        if selectedCellTitle != nil && !selectedCellTitle.isEmpty {
            if selectedCellTitle == "BFME2" {
                gameToLaunch = "BFME2"
            } else if selectedCellTitle == "BFME" {
                gameToLaunch = "Battle for Middle-Earth"
            } else if selectedCellTitle == "ROTWK" {
                gameToLaunch = "Rise of the Witch King"
            }
        }
        
        self.specifiedAppName = self.fNInputField.stringValue.isEmpty ?
            gameToLaunch.isEmpty ? self.defaultAppName : gameToLaunch : self.fNInputField.stringValue
        
        
        /* UNCOMMENT THIS CODE BLOCK TO LAUNCH CUSTOM/DIFFERENT .APP FILES VIA BATCH SCRIPT
         
         
         Log("Creating launcher command to send to the environment...")
         
         // Create a Task instance
         let task = Process()
         task.launchPath = "/usr/bin/env"
         task.arguments = []
         
         // Create a Pipe and make the task
         // put all the output there
         let pipe = Pipe()
         task.standardOutput = pipe
         task.launch()
         
         // Get the data
         let data = pipe.fileHandleForReading.readDataToEndOfFile()
         let output = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
         
         Log(output! as String)
         
         if !self.specifiedAppName.contains(self.defaultAppName) {
         Log("Bash shell script executed: %@", ShellScriptExecutionTask.bash(command: "open", arguments: [self.specifiedAppName, "-a", "Battle for Middle-Earth"]))
         Log("Mods installer launched successfully")
         } else if self.specifiedAppName.contains("2") {
         Log("Bash shell script executed: %@", (ShellScriptExecutionTask.bash(command: "open", arguments: [ "-a", "Battle for Middle-Earth" ])))
         }
         */
        
        Log("Launching application \"%\"", self.specifiedAppName)
        if NSWorkspace.shared.launchApplication(self.specifiedAppName) {
            Log("Application launched successfully")
        } else {
            let errMsg = "Unable to launch application \"%@\""
            Log("ERROR: %@", errMsg)
            resultDialogue(prompt: "Application Launch ERROR", description: String(format: errMsg, self.specifiedAppName))
        }
    }
    
    // Ensure we've capturd the right value for what application to launch before we leave
    override func viewWillDisappear() {
        if self.launchGameOnExitBox.state == .on {
            launchApplicationInPLIST()
        }
    }
    
    
    fileprivate func exitApplication() -> Void {
        Log("Closing window...")
        Log("Telling the applicxation to open the game, if necessary")
        if self.launchGameOnExitBox.state == .on {
            launchApplicationInPLIST()
            return
        }
        
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
    
    func numberOfItems(in comboBox: NSComboBox) -> Int {
        return self.resolutionOptions.count
    }
    
    
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        return index > -1 ? self.resolutionOptions[index] : "Select a resolution..."
    }
    
    /*
    func comboBox(_ comboBox: NSComboBox, completedString string: String) -> String? {
        
    }\*/
    
    func comboBox(_ comboBox: NSComboBox, indexOfItemWithStringValue string: String) -> Int {
        var itemIndex = 0
        
        for resolution in resolutionOptions {
            if resolution == string {
                return itemIndex
            }
            
            itemIndex += 1
        }
        
        return -1
    }
    
    // parse the resolution and set thevalues in the custom exe flags so it
    // is set in both the application itself as well as the wine configuration
    func comboBoxWillDismiss(_ notification: Notification) {
        if self.resCB.indexOfSelectedItem > -1 {
            let strForEXEFlag = self.resolutionOptions[self.resCB.indexOfSelectedItem]
            let splitStr = strForEXEFlag.components(separatedBy: " x ")
            
            let xVal = splitStr[0]
            let yVal = splitStr[1]
            
            Log("Applying resolution changes: current resolution --> : \"%@x%@\"", xVal, yVal)
            
            let formattedStr = "-xres \(xVal) -yres \(yVal)"
            self.exeFlagsTextField.stringValue = formattedStr
        }
        
        
    }
}

