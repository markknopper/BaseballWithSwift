//
//  AllYearsSearchResultsTableViewController.swift
//  BaseballQuery
//
//  Created by Mark Knopper on 3/13/15.
//  Copyright (c) 2015-2017 Bulbous Ventures LLC. All rights reserved.
//

import UIKit

@objc class AllYearsSearchResultsTableViewController: UITableViewController {
    
    @objc var sort_order_ascending: Bool = true

    // displayedYearsList is an array of Teams that is returned from a fetch request in the main AllYears, and passed here when searching. Here, compute the indices when it is passed in before doing anything else.
    //var displayedYearsList = [Teams]() as NSArray { // An array of Dictionaries with yearID keys.
    @objc var displayedYearsList = [Any]() as NSArray { // An array of Dictionaries with yearID keys.
         didSet {
            self.computeTableIndices(fromYearArray: displayedYearsList as! [Any], withKeyPath: "yearID", ascending: sort_order_ascending)
            }
    }
    @objc var indexDecades: NSArray = [String]() as NSArray
    @objc var decadeDict: NSDictionary? = nil
    @objc var managedObjectContext: NSManagedObjectContext? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView!.register(UINib(nibName: "BasicTableCell", bundle: nil), forCellReuseIdentifier: "BasicTableCell")
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        var sections_to_return = 1
        if indexDecades.count > 0 {
            sections_to_return = indexDecades.count
        }
        return sections_to_return
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return indexDecades.index(of: title)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowsToReturn = 0
        if indexDecades.count==0 {
            rowsToReturn = displayedYearsList.count
        } else {
            // Swift is stupid with all these ! and ?s.
            let decadeKey: NSString = indexDecades[section] as! NSString
            rowsToReturn = (decadeDict![decadeKey]! as AnyObject).count
        }
        return rowsToReturn
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BasicTableCell", for: indexPath) 
        if indexDecades.count == 0 {
            let displayedYearsListItem = displayedYearsList.object(at: indexPath.row) as! [String: Int]
            let yearItem: AnyObject? = displayedYearsListItem["yearID"] as AnyObject
            cell.textLabel!.text = yearItem!.description
        } else {
            // Use a key from indexDecades to obtain an array of years from decadeDict.
            let decadeKey: NSString = indexDecades[indexPath.section] as! NSString
            let decadeArray = decadeDict![decadeKey] as? NSArray
            let yearString: String = decadeArray!.object(at: indexPath.row) as! String
            cell.textLabel!.text = yearString
        }
        return cell
    }

}
