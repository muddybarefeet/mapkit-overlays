//
//  LandArea.swift
//  
//
//  Created by Anna Rogers on 8/7/16.
//
//

import Foundation
import CoreData


class LandArea: NSManagedObject {
    
    convenience init(name: String, continent: String, coordinates: String, coordType: String, annotation_point: String, context : NSManagedObjectContext){
        if let ent = NSEntityDescription.entityForName("LandArea",inManagedObjectContext: context){
            self.init(entity: ent, insertIntoManagedObjectContext: context)
            self.name = name
            self.continent = continent
            self.coordinates = coordinates
            self.coordinate_type = coordType
            self.annotation_point = annotation_point
        }else{
            fatalError("Unable to find Entity name!")
        }
    }
    
}

