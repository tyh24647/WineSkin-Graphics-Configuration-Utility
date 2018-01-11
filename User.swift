//
//  User.swift
//  SettingsLauncher
//
//  Created by Tyler hostager on 1/11/18.
//  Copyright © 2018 Tyler hostager. All rights reserved.
//

import Foundation

@objc protocol User {
    static var isAdmin: Bool { get }
    
    static func hasAdminPermissions() -> Bool
    
    init()
    
}

public class DefaultUser: User {
    
    public static var isAdmin: Bool {
        get {
            return true
        }
    }
    
    public static func hasAdminPermissions() -> Bool {
        return true
    }
    
    required public init() {
        
    }
    
    
}

public class AdminUser: User {
    public static var isAdmin = true
    
    public static func hasAdminPermissions() -> Bool {
        return true
    }
    
    required public init() {
        
    }
}

public class StandardUser: User {
    public static var isAdmin = false
    
    public static func hasAdminPermissions() -> Bool {
        return false
    }
    
    required public init() {
        
    }
}

public class DebugUser: AdminUser {
    
}

