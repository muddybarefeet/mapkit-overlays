//
//  ChooseQuizMode.swift
//  overlayPractice
//
//  Created by Anna Rogers on 8/14/16.
//  Copyright © 2016 Anna Rogers. All rights reserved.
//

import UIKit

class ChooseQuizMode: CoreDataController {
    
    var continent: String!
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showPractice" {
            let controller = segue.destinationViewController as! MapViewController
            controller.continent = continent
        } else if segue.identifier == "showChallenge" {
            let controller = segue.destinationViewController as! ChallengeViewController
            controller.continent = continent
        }
    }
    
}
