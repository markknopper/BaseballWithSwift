//
//  AboutWebController.swift
//  BaseballWithSwift
//
//  Created by Mark Knopper on 2/8/18.
//  Copyright © 2018 Bulbous Ventures LLC. All rights reserved.
//
// Now featuring WKWebView.

import UIKit
import WebKit

class AboutController: UIViewController {
    
    /*
    // This is a singleton now!
    @objc static let shared = UIStoryboard(name: "MainStoryboard", bundle: nil).instantiateViewController(withIdentifier: "AboutWeb") as! AboutController
*/
    
    @IBOutlet weak var aboutWeb: WKWebView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.goAway(_:)))
        //self.aboutWeb.addGestureRecognizer(tap)
        let filePath = Bundle.main.path(forResource: "About", ofType: "html")
        let cssPath = Bundle.main.path(forResource: "about", ofType: "css")
        let htmlData = try! String(contentsOfFile: filePath!)
        // Good reason to keep this bulb out of an asset catalog.
        let bulbImage = UIImage(named: "bulb13")
        let bulbData = UIImagePNGRepresentation(bulbImage!)
        let bulb64 = bulbData?.base64EncodedString(options: [])
        let bulbURL = "data:application/png;base64," + bulb64!
        let cssData = try! String(contentsOfFile: cssPath!)
        let iconsDictionary = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String:Any]
        let primaryIconsDictionary = iconsDictionary!["CFBundlePrimaryIcon"] as? [String:Any]
        let iconFiles = primaryIconsDictionary!["CFBundleIconFiles"] as? [String]
        let lastIcon = iconFiles?.last
        let iconImage = UIImage(named: lastIcon!)
        let iconData = UIImagePNGRepresentation(iconImage!)
        let base64 = iconData?.base64EncodedString(options: [])
        let iconURL = "data:application/png;base64," + base64!
        let versionBuild = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
        let versionMain = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        let appDel = UIApplication.shared.delegate as! BaseballQueryAppDelegate
        let filledInHTML = String(format: htmlData, cssData, iconURL, LATEST_DATA_YEAR+1, LATEST_DATA_YEAR+1, versionMain, versionBuild, appDel.latest_year_in_database, bulbURL)
        self.aboutWeb.loadHTMLString(filledInHTML, baseURL: nil)
    }
    
    
    @objc func goAway(_ sender: UITapGestureRecognizer) {
        print("didn't hit a breakpoint")
        self.presentingViewController?.dismiss(animated: true, completion:nil)
    }
    
    /*
    @IBAction func moreButtonPressed(sender: UIBarButtonItem) {
        // Menu items here (how about with icons?):
        // Tips
        // Restore Purchase
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let tipsAction = UIAlertAction(title: "Tips", style: .default, handler: { (alert: UIAlertAction!) in
            self.performSegue(withIdentifier: "aboutToTips", sender: self)
            })
        alertController.addAction(tipsAction)
        let restoreAction = UIAlertAction(title: "Restore Purchase", style: .default, handler: { (alert: UIAlertAction!) in
            let purchaser = InAppPurchaseController.sharedInstance()
            purchaser?.restorePurchases()
            })
        alertController.addAction(restoreAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        // Configure the alert controller's popover presentation controller if it has one.
        if let popoverPresentationController = alertController.popoverPresentationController {
            popoverPresentationController.barButtonItem = sender
        }
        self.present(alertController, animated: true, completion: nil)
    }
*/
}
