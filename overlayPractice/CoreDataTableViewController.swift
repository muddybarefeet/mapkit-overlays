//
//  CoreDataTableViewController.swift
//  MapQuiz
//
//  Created by Anna Rogers on 8/28/16.
//  Copyright © 2016 Anna Rogers. All rights reserved.
//

import UIKit
import CoreData

class CoreDataTableViewController: UITableViewController {
    
    
    var fetchedResultsController : NSFetchedResultsController?{
        didSet{
            executeSearch()
        }
    }
    
    // Do not worry about this initializer. I has to be implemented
    // because of the way Swift interfaces with an Objective C
    // protocol called NSArchiving. It's not relevant.
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func executeSearch(){
        if let fc = fetchedResultsController{
            do{
                try fc.performFetch()
            }catch let e as NSError{
                print("Error while trying to perform a search: \n\(e)\n\(fetchedResultsController)")
            }
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        fatalError("This method MUST be implemented by a subclass of CoreDataTableViewController")
    }
    
}

// MARK:  - Table Data Source
extension CoreDataTableViewController{
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let fc = fetchedResultsController{
            return (fc.sections?.count)!;
        }else{
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let fc = fetchedResultsController{
            return fc.sections![section].numberOfObjects;
        }else{
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let fc = fetchedResultsController{
            return fc.sections![section].name;
        }else{
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        if let fc = fetchedResultsController{
            return fc.sectionForSectionIndexTitle(title, atIndex: index)
        }else{
            return 0
        }
    }
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        if let fc = fetchedResultsController{
            return  fc.sectionIndexTitles
        }else{
            return nil
        }
    }
    
    
}
//
//// MARK:  - Fetches
//extension CoreDataTableViewController{
//    
//    func executeSearch(){
//        if let fc = fetchedResultsController{
//            do{
//                try fc.performFetch()
//            }catch let e as NSError{
//                print("Error while trying to perform a search: \n\(e)\n\(fetchedResultsController)")
//            }
//        }
//    }
//}


//// MARK:  - Delegate
//extension CoreDataTableViewController: NSFetchedResultsControllerDelegate{
//    
//    
//    func controllerWillChangeContent(controller: NSFetchedResultsController) {
//        tableView.beginUpdates()
//    }
//    
//    func controller(controller: NSFetchedResultsController,
//                    didChangeSection sectionInfo: NSFetchedResultsSectionInfo,
//                                     atIndex sectionIndex: Int,
//                                             forChangeType type: NSFetchedResultsChangeType) {
//        
//        let set = NSIndexSet(index: sectionIndex)
//        
//        switch (type){
//            
//        case .Insert:
//            tableView.insertSections(set, withRowAnimation: .Fade)
//            
//        case .Delete:
//            tableView.deleteSections(set, withRowAnimation: .Fade)
//            
//        default:
//            // irrelevant in our case
//            break
//            
//        }
//    }
//    
//    
//    func controller(controller: NSFetchedResultsController,
//                    didChangeObject anObject: AnyObject,
//                                    atIndexPath indexPath: NSIndexPath?,
//                                                forChangeType type: NSFetchedResultsChangeType,
//                                                              newIndexPath: NSIndexPath?) {
//        
//        
//        
//        switch(type){
//            
//        case .Insert:
//            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
//            
//        case .Delete:
//            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
//            
//        case .Update:
//            tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
//            
//        case .Move:
//            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
//            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
//        }
//        
//    }
//    
//    func controllerDidChangeContent(controller: NSFetchedResultsController) {
//        tableView.endUpdates()
//    }
//}
