//
//  LeftMenuTVC.swift
//  BaseballWithSwift
//
//  Created by Mark Knopper on 2/13/18.
//  Copyright © 2018 Bulbous Ventures LLC. All rights reserved.
//

import UIKit

@objc class LeftMenuTVC: UITableViewController {
    
    // Parent controller actually calls this since the main table view moves to the right and has a nice shadow on left edge. Just like Shirabe Jisho app if you want to know.
    @objc public class func shadowizeViewLayer(_ layer: CALayer) {
        layer.masksToBounds = false
        layer.shadowOpacity = 0.7
        layer.shadowOffset = CGSize(width: 3, height: 3)
        layer.shadowRadius = 15.0
        layer.shadowColor = UIColor.darkGray.cgColor
    }
    
    override func viewDidLoad() {
        if self.tableView.backgroundView == nil {
            let backTap = UITapGestureRecognizer(target: self, action: #selector(tappedOutsideOfTable(_:)))
            self.tableView.backgroundView = UIView()
            self.tableView.backgroundView?.addGestureRecognizer(backTap)
        }
    }
    
    @objc func tappedOutsideOfTable(_ sender: UITapGestureRecognizer) {
        let parentVC: SettingsTableCalls = self.parent as! SettingsTableCalls
        parentVC.closeSettingsView()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)
        var labelText = ""
        var theImage: UIImage? = nil
        cell.imageView?.image = nil
        switch (indexPath.row) {
        case 0:
            labelText = "About the App"
            theImage = UIImage(named: "info")
        case 1:
            labelText = "Restore Purchases"
            theImage = UIImage(named: "creditcard")
        case 2:
            labelText = "Tips"
            theImage = UIImage(named: "TipsBulb")
        default: print("duh")
        }
        cell.textLabel!.text = labelText
        if theImage != nil {
            cell.imageView?.image = theImage
        }
        return cell
    }
    
    override  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let parentVC: SettingsTableCalls = self.parent as! SettingsTableCalls
        switch (indexPath.row) {
        case 0:
            parentVC.segueToAbout()
        case 1:
            let purchaser = InAppPurchaseController.sharedInstance()
            purchaser?.restorePurchases()
        case 2:
            parentVC.segueToTips()
        default:
            print("not really anything")
        }
    }

}
