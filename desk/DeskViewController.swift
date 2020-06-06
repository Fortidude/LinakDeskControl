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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.deskConnect = DeskConnect()
    }
    
    @IBOutlet var valueLabel: NSTextField!
    
    @IBAction func up(_ sender: NSButton) {
        self.deskConnect.moveUp()
    }
    
    @IBAction func down(_ sender: NSButton) {
        self.deskConnect.moveDown()
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

