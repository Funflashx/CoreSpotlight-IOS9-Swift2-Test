//
//  CoreSpotLightController.swift
//  CoreSpotlight-IOS9-Swift2-Test
//
//  Created by François Caillet on 28/08/2015.
//  Copyright © 2015 François Caillet. All rights reserved.
//

import Foundation
import UIKit
import CoreSpotlight
import MobileCoreServices


//MARK: https://www.hackingwithswift.com/read/32/4/how-to-add-core-spotlight-to-index-your-app-content

class CoreSpotLightController: UITableViewController {
    
    var favorites = [Int]()
    var pastas: [String] = ["Fusilli","Spaghetti","Lasagne","Tagliatelle","Cannelloni","Macaroni","Penne","Rigatoni","Rotini","Conchiglie","Farfalle","Mandala","Rotelle","Tortelloni"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if let savedFavorites = defaults.objectForKey("favorites") as? [Int] {
            self.favorites = savedFavorites
        }
        
        tableView.editing = true
        tableView.allowsSelectionDuringEditing = true
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let cell = UITableViewCell()
        cell.textLabel?.text = pastas[indexPath.row]
        if favorites.contains(indexPath.row) {
            cell.editingAccessoryType = .Checkmark
        } else {
            cell.editingAccessoryType = .None
        }
        
        return cell
        
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        if favorites.contains(indexPath.row) {
            return .Delete
        } else {
            return .Insert
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return pastas.count
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Insert {
            favorites.append(indexPath.row)
            indexItem(indexPath.row)
        } else {
            if let index = favorites.indexOf(indexPath.row) {
                favorites.removeAtIndex(index)
                deindexItem(indexPath.row)
            }
        }
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(favorites, forKey: "favorites")
        
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
    }
    
    func indexItem(which: Int) {
        
        let pasta = pastas[which]
        
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
        attributeSet.title = pasta
        //attributeSet.contentDescription = pasta[1]
        
        let item = CSSearchableItem(uniqueIdentifier: "\(which)", domainIdentifier: "com.Calopea", attributeSet: attributeSet)
        //Useful info -> "[...][Indexed content] has an expiration date of one month[...]"
        item.expirationDate = NSDate.distantFuture() //make items never expire
        CSSearchableIndex.defaultSearchableIndex().indexSearchableItems([item]) { (error: NSError?) -> Void in
            if let error = error {
                print("Indexing error: \(error.localizedDescription)")
            } else {
                print("Search item successfully indexed!")
            }
        }
    }
    
    func deindexItem(which: Int) {
        CSSearchableIndex.defaultSearchableIndex().deleteSearchableItemsWithIdentifiers(["\(which)"]) { (error: NSError?) -> Void in
            if let error = error {
                print("Deindexing error: \(error.localizedDescription)")
            } else {
                print("Search item successfully removed!")
            }
        }
    }
    
    
    
}