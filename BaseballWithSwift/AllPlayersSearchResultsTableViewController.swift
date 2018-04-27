//
//  AllPlayersSearchResultsTableViewController.swift
//  BaseballQuery
//
//  Created by Mark Knopper on 2/25/15.
//  Copyright (c) 2015-2016 Bulbous Ventures LLC. All rights reserved.
//

import UIKit

@objc class AllPlayersSearchResultsTableViewController: UITableViewController {

    @objc var masterObjectsFromSearch: NSArray? = nil
    @objc var managedObjectContext: NSManagedObjectContext? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
/* Prevent warning: "Warning once only: Detected a case where constraints ambiguously suggest a height of zero for a tableview cell's content view. We're considering the collapse unintentional and using standard height instead."
*/
        self.tableView!.rowHeight = 44
        self.tableView!.register(UINib(nibName: "FirstLastBoldCell", bundle: nil), forCellReuseIdentifier: "FirstLastBoldCell")
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        if masterObjectsFromSearch==nil {
            return 0
        }
        return masterObjectsFromSearch!.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FirstLastBoldCell", for: indexPath) as! FirstLastBoldCell
        let ourMaster = managedObjectContext!.object(with: masterObjectsFromSearch![indexPath.row] as! NSManagedObjectID) as! Master
        cell.firstNameLabel.text = ourMaster.nameFirst
        cell.lastNameLabel.text = ourMaster.nameLast
        // This could be in StatHead or somewhere.
        cell.positionLabel.text = ourMaster.debutFinalYearsString()
        if ourMaster.checkIfPlayedInLatestYear() {
            cell.firstNameLabel.textColor = self.tableView.tintColor
            cell.lastNameLabel.textColor = self.tableView.tintColor
        } else {
            cell.firstNameLabel.textColor = UIColor.black
            cell.lastNameLabel.textColor = UIColor.black
        }
        return cell
    }

    override func tableView(_ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath)
    {
        // Can't use segues since this VC is progammatic.
        let playerYearsController: PlayerYearsController? = self.presentingViewController!.storyboard?.instantiateViewController(withIdentifier: "playerYearsController") as? PlayerYearsController
        let ourMaster = managedObjectContext!.object(with: masterObjectsFromSearch![indexPath.row] as! NSManagedObjectID) as! Master
        let yesPlayer = BQPlayer(player: ourMaster, teamSeason: nil)
        playerYearsController?.player = yesPlayer
        self.presentingViewController!.navigationController!.pushViewController(playerYearsController!, animated: true)
    }
    
}
