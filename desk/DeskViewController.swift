//
//  DeskViewcontroller.swift
//  desk
//
//  Created by Forti on 18/05/2020.
//  Copyright © 2020 Forti. All rights reserved.
//

import Cocoa

class DeskViewController: NSViewController {
    private var deskConnect: DeskConnect!
    private var longClick: NSPressGestureRecognizer?
    private var userDefaults: UserDefaults?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.deskConnect = DeskConnect()
        
        self.buttonUp.isEnabled = false
        self.buttonDown.isEnabled = false
        
        self.deskConnect.currentPosition.asObservable().subscribe({ value in
            if let position = value.element {
                if (position > 0) {
                    self.currentValue.stringValue = String(format:"%.1f", position)
                    self.currentPosition = position
                }
            }
            
        }).disposed(by: self.deskConnect.dispose)
        
        self.deskConnect.deviceName.asObservable().subscribe({ value in
            self.deskName.stringValue = "\(value.element ?? "Unknown desk")"
            self.buttonUp.isEnabled = true
            self.buttonDown.isEnabled = true
        }).disposed(by: self.deskConnect.dispose)
        
        self.userDefaults = UserDefaults.init(suiteName: "positions")
        self.initSavedPositions()
        
        self.buttonUp.sendAction(on: .leftMouseDown)
        self.buttonUp.isContinuous = true
        self.buttonUp.setPeriodicDelay(0, interval: 0.7)
        
        self.buttonDown.sendAction(on: .leftMouseDown)
        self.buttonDown.isContinuous = true
        self.buttonDown.setPeriodicDelay(0, interval: 0.7)
    }
    
    
    var currentPosition: Double!
    @IBOutlet var currentValue: NSTextField!
    @IBOutlet var deskName: NSTextField!
    @IBOutlet var buttonUp: NSButton!
    @IBOutlet var buttonDown: NSButton!
    
    @IBOutlet var buttonMoveToSit: NSButton!
    @IBOutlet var buttonMoveToStand: NSButton!
    
    @IBOutlet var sitPosition: NSTextField!
    @IBOutlet var standPosition: NSTextField!
    
    var isMovingToPositionValue = false
    var moveToPositionValue = 70.0
    
    var isWaitingForSecondPress = false
    @objc func stopMoving() {
        self.deskConnect.stopMoving()
        self.isWaitingForSecondPress = true
    }
    
    @objc func clearIsWairingForSecondPress() {
        self.isWaitingForSecondPress = false
    }
    
    func handleStopMovingIfSingleClick() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(clearIsWairingForSecondPress), object: nil)
        
        if (self.isWaitingForSecondPress == false) {
            perform(#selector(stopMoving), with: nil, afterDelay: 0.18)
        }
        
        perform(#selector(clearIsWairingForSecondPress), with: nil, afterDelay: 0.2)
    }
    
    @IBAction func up(_ sender: NSButton) {
        self.deskConnect.moveUp()
        self.handleStopMovingIfSingleClick()
    }
    
    @IBAction func down(_ sender: NSButton) {
        self.deskConnect.moveDown()
        self.handleStopMovingIfSingleClick()
    }
    
    @IBAction func saveAsSitPosition(_ sender: NSButton) {
        self.userDefaults?.set(self.currentPosition, forKey: "sit-position")
        self.sitPosition.stringValue = String(format:"%.1f", self.currentPosition)
    }
    
    @IBAction func saveAsStandPosition(_ sender: NSButton) {
        self.userDefaults?.set(self.currentPosition, forKey: "stand-position")
        self.standPosition.stringValue = String(format:"%.1f", self.currentPosition)
    }
    
    @IBAction func moveToSitPosition(_ sender: NSButton) {
        let position = self.userDefaults?.double(forKey: "sit-position") ?? .nan
        if (position != .nan) {
            self.deskConnect.moveToPosition(position: position)
        }
    }
    
    @IBAction func moveToStandPosition(_ sender: NSButton) {
        let position = self.userDefaults?.double(forKey: "stand-position") ?? .nan
        if (position != .nan) {
            self.deskConnect.moveToPosition(position: position)
        }
    }
    
    @IBAction func stop(_ sender: NSButton) {
        self.deskConnect.stopMoving()
    }
    
    private func initSavedPositions() {
        if let sitPosition = self.userDefaults?.double(forKey: "sit-position") {
            self.sitPosition.stringValue = String(format:"%.1f", sitPosition)
        }
        
        if let standPosition = self.userDefaults?.double(forKey: "stand-position") {
            self.standPosition.stringValue = String(format:"%.1f", standPosition)
        }
    }
}

extension DeskViewController {
    // MARK: Storyboard instantiation
    static func freshController() -> DeskViewController {
        //1.
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        //2.
        let identifier = NSStoryboard.SceneIdentifier("DeskViewController")
        //3.
        guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? DeskViewController else {
            fatalError("Why cant i find QuotesViewController? - Check Main.storyboard")
        }
        return viewcontroller
    }
}

