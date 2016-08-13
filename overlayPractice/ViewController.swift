//
//  ViewController.swift
//  overlayPractice
//
//  Created by Anna Rogers on 8/6/16.
//  Copyright © 2016 Anna Rogers. All rights reserved.
//

//    let continentCodes = [
//        "AF": "Africa",
//        "AN": "Antarctica",
//        "AS": "Asia",
//        "EU": "Europe",
//        "NA": "North America",
//        "OC": "Oceania",
//        "SA": "South America"
//    ]

import UIKit
import MapKit
import CoreData

//todo: better click accurcay!!!

//logic:
/*
 1. ask user question as pop up label from bottom
    - have a list of all the countries in the continent chosen
    - have a list of guessed: true if guessed/false if not guessed
    -OR make two lists then when choosing the rendom index to pick one fron you will know it has not been guessed
 
 2. store country asked
 3. when country clicked then check against guess country
 4. if correct - fade/color to show the country selected and then remove and add marker/label increment score
 5. if incorrect - after fade on second tap then make the country red not change score
 6. if incorrect stay on that counry until correct
 7. have a button to reveal all
 8. have a next button to re-generate a new country question
 */



class ViewController: CoreDataController, MKMapViewDelegate {

    @IBOutlet weak var worldMap: MKMapView!
    
    var continent: String?
    
    var score: Int = 0
    var totalCountries: Int = 0
    
    var game = [
        "guessed": [String:String](),
        "toPlay": [String:String](),
    ]
    
    var toFind = ""
    
    let label = UILabel()
    
    var createdPolygonOverlays = [String: MKPolygon]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let showButton: UIBarButtonItem = UIBarButtonItem(title: "Show", style: .Plain, target: self, action: #selector(self.showAllCountries))
        self.navigationItem.rightBarButtonItem = showButton
        
        score = createdPolygonOverlays.count
        let app = UIApplication.sharedApplication().delegate as! AppDelegate
        let land = app.landAreas
        let fetchRequest = NSFetchRequest(entityName: "LandArea")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: land.context, sectionNameKeyPath: nil, cacheName: nil)
        let entities = fetchedResultsController!.fetchedObjects as! [LandArea]
        print("entities", entities.count)
        
        //make an array of country models - loop through core data for all with desired continent code and make to model
        for entity in entities {
            if (entity.continent == continent) {
                let country = Country(name: entity.name!, points: entity.coordinates!, coordType: entity.coordinate_type!)
                game["toPlay"]![entity.name!] = entity.name
                addBoundary(country, resetZoom: true)
            }
        }
        totalCountries = createdPolygonOverlays.count
        self.title = String("\(score) / \(totalCountries)")
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.overlaySelected))
        view.addGestureRecognizer(gestureRecognizer)
        
        //start the game
        //make label to show the user and pick random index to grab country name with
        let index: Int = Int(arc4random_uniform(UInt32(game["toPlay"]!.count)))
        let randomVal = Array(game["toPlay"]!.values)[index]
        toFind = randomVal
        
        let screenSize = UIScreen.mainScreen().bounds.size
        let screenHeight = UIScreen.mainScreen().bounds.height
        label.frame = CGRectMake(0, (screenHeight - 105), (screenSize.width + 5), 44)
        
        label.textAlignment = NSTextAlignment.Center
        label.text = "Where is \(randomVal)?"
        label.backgroundColor = UIColor(red: 0.3,green: 0.5,blue: 1,alpha: 1)
        label.textColor = UIColor.whiteColor()
        view.frame.origin.y = 44 * (-1)
        worldMap.addSubview(label)
    }
    
    func showAllCountries () {
        //TODO: more functionality??
        //delete all overlays off the map
        for overlay: MKOverlay in worldMap.overlays {
            //TODO: show name of country
            worldMap.removeOverlay(overlay)
        }
        //delete the countries dictionary
        createdPolygonOverlays.removeAll()
    }
    
    var polys = [MKPolygon]()
    var previousMatch: String = ""
    
    func overlaySelected (gestureRecognizer: UIGestureRecognizer) {
        
        let pointTapped = gestureRecognizer.locationInView(worldMap)
        let newCoordinates = worldMap.convertPoint(pointTapped, toCoordinateFromView: worldMap)
        
        let point = MKMapPointForCoordinate(newCoordinates)
        let mapRect = MKMapRectMake(point.x, point.y, 0.000000000000001, 0.0000000000001);
       
        //empty out arrays of data
        polys.removeAll()
        
        //loop through the countries in continent
        for (key, _) in createdPolygonOverlays {
            //loop through all innner polygons for continent
            if createdPolygonOverlays[key]!.intersectsMapRect(mapRect) {
                polys.append(createdPolygonOverlays[key]!)
            }
        }
        
        if polys.count > 1 {
            //then need to find the nearest country found
            print("foudn multiple matches!")
            var closest: CLLocationDistance = 0
            var matchedCountry = MKPolygon()
            for p in 0..<polys.count {
                let center = MKMapPointForCoordinate(polys[p].coordinate)
                let distance = MKMetersBetweenMapPoints(center, point)
                if distance > closest {
                    closest = distance
                    matchedCountry = polys[p]
                } else if distance == closest {
                    print("SAME DISTAnCE!--- PROBLEM!")
                }
            }
            print("matched polygon", matchedCountry.title, createdPolygonOverlays[matchedCountry.title!]!.title)
            //now want to change the appearance of this polygon
            
            //if this matched country was not the previous one
            if createdPolygonOverlays[matchedCountry.title!]!.title == matchedCountry.title! && previousMatch != matchedCountry {
                switchOpacities(matchedCountry)
            //if the matched country is the same as the previous match then delete the overlay
            } else if createdPolygonOverlays[matchedCountry.title!]!.title == matchedCountry.title && previousMatch == matchedCountry {
                if (toFind == matchedCountry.title) {
                    self.label.text = "Found!"
                    label.backgroundColor = UIColor(red: 0.3, green: 0.9, blue: 0.5, alpha: 1.0)
                    //add toFind to guessed
                    game["guessed"]![toFind] = toFind
                    game["toPlay"]!.removeValueForKey(toFind)
                    resetQuestionLabel()
                    
                    //then we can delete country overlay from map as correct selection
                    updateMapOverlays(matchedCountry.title!)
                    previousMatch = ""
                } else {
                    //it was an incorrect guess, want to currently do nothing/change color/say wrong country on label
                    label.backgroundColor = UIColor(red: 0.8, green: 0.2, blue: 0.5, alpha: 1.0)
                    delay(1.0) {
                        self.label.text = "Where is \(self.toFind)?"
                        self.label.backgroundColor = UIColor(red: 0.3,green: 0.5,blue: 1,alpha: 1)
                    }
                }
            }
        } else if polys.count == 1 {
            //then only one country found
            //if this country has been tapped last then we want to delete it else we make it transparent
            if createdPolygonOverlays[polys[0].title!]!.title == polys[0].title! && previousMatch != polys[0].title! {
                switchOpacities(polys[0])
            } else if createdPolygonOverlays[polys[0].title!]!.title == polys[0].title! && previousMatch == polys[0].title! {
                if (toFind == polys[0].title!) {
                    self.label.text = "Found!"
                    label.backgroundColor = UIColor(red: 0.3, green: 0.9, blue: 0.5, alpha: 1.0)
                    game["guessed"]![toFind] = toFind
                    game["toPlay"]!.removeValueForKey(toFind)
                    resetQuestionLabel()
                    
                    //then we can delete country overlay from map as correct selection
                    updateMapOverlays(polys[0].title!)
                    previousMatch = ""
                } else {
                    //it was an incorrect guess, want to currently do nothing/change color/say wrong country on label
                    label.backgroundColor = UIColor(red: 0.8, green: 0.2, blue: 0.5, alpha: 1.0)
                    delay(1.0) {
                        self.label.text = "Where is \(self.toFind)?"
                        self.label.backgroundColor = UIColor(red: 0.3,green: 0.5,blue: 1,alpha: 1)
                    }
                }
            }
        }
        
    }
    

    func delay (delay:Double, closure:()->()) {
        //set the time to dispatch after
        //dispatch_time: creates dispatch time relative to now then this is in a dispatch after this amount of time method
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,Int64(delay * Double(NSEC_PER_SEC))),
        //then run the closure fn in the main queue when delay over
        dispatch_get_main_queue(), closure)
    }
    
    //ask new question
    func resetQuestionLabel () {
        if game["toPlay"]?.count > 0 {
            let index: Int = Int(arc4random_uniform(UInt32(game["toPlay"]!.count)))
            let randomVal = Array(game["toPlay"]!.values)[index]
            toFind = randomVal
            label.text = "Where is \(randomVal)?"
            label.backgroundColor = UIColor(red: 0.3,green: 0.5,blue: 1,alpha: 1)
        } else {
            //nothing left to play - all countries have been guessed
            //push to score screen
            performSegueWithIdentifier("showScore", sender: nil)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "showScore" {
            let controller = segue.destinationViewController as! ScoreViewController
            //get the id property on the annotation
            controller.score = score
            controller.scoreTotal = totalCountries
        }
    }
    
    //logic for the switching of country if the same country is not tapped again
    func switchOpacities (currentMatch: MKPolygon) {
        print("current prev", previousMatch, currentMatch.title!)
        //make the subtitle 0.8
        createdPolygonOverlays[currentMatch.title!]!.subtitle = "0.8"
        
        //if the previous polygon exists the reset the value
        if (createdPolygonOverlays[previousMatch] != nil) && previousMatch != "" {
            //update the polygon in the polygon dictionary
            createdPolygonOverlays[previousMatch]!.subtitle = "1.0"
            print("---->retrun prev to 1", createdPolygonOverlays[previousMatch]!.subtitle)
            worldMap.removeOverlay(createdPolygonOverlays[previousMatch]!)
            worldMap.addOverlay(createdPolygonOverlays[previousMatch]!)
        }
        previousMatch = polys[0].title!
        //delete the polygon and then re-add it
        worldMap.removeOverlay(createdPolygonOverlays[currentMatch.title!]!)
        worldMap.addOverlay(createdPolygonOverlays[currentMatch.title!]!)
    }

    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId: String = "reuseid"
        
        var aView: MKAnnotationView
        
        if let av = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) {
            av.annotation = annotation
            aView = av
        } else {
            let av = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            let lbl = UILabel(frame: CGRectMake(0, 0, 40, 15))
            lbl.adjustsFontSizeToFitWidth = true
            lbl.backgroundColor = UIColor.blackColor()
            lbl.textColor = UIColor.whiteColor()
            lbl.alpha = 0.5
            lbl.tag = 42
            lbl.numberOfLines = 0
            av.addSubview(lbl)
            //Following lets the callout still work if you tap on the label...
            av.canShowCallout = true
            av.frame = lbl.frame
            aView = av
        }
        let lbl: UILabel = (aView.viewWithTag(42) as! UILabel)
        lbl.text = annotation.title!
        return aView
    }
    
    func updateMapOverlays(titleOfPolyToRemove: String) {
        for overlay: MKOverlay in worldMap.overlays {
            //worldMap.removeOverlay(overlay)
            if overlay.title! == titleOfPolyToRemove {
                createdPolygonOverlays.removeValueForKey(titleOfPolyToRemove)
                let annotation = MKPointAnnotation()
                annotation.coordinate = overlay.coordinate
                annotation.title = titleOfPolyToRemove
                worldMap.addAnnotation(annotation)
                worldMap.removeOverlay(overlay)
            }
        }
        score += 1
        self.title = String("\(score) / \(totalCountries)")
    }

    func addBoundary(countryShape: Country, resetZoom: Bool) {

        if countryShape.geojsonFormat == "MultiPolygon" {
            var polygons = [MKPolygon]()
            //then need to loop through each boundary and make each a polygon and calculate the number of points
            for var landArea in (countryShape.multiBoundary) {
                let multiPolygon = MKPolygon(coordinates: &landArea, count: landArea.count)
                multiPolygon.title = countryShape.country
                multiPolygon.subtitle = countryShape.alpha
                //let overlay = customPolygon(countryName: country.country, alphaValue: 1.0, polygon: multiPolygon)
                polygons.append(multiPolygon)
                worldMap.addOverlay(multiPolygon)
                createdPolygonOverlays[multiPolygon.title!] = multiPolygon
            }
            //countries[key]?.polygons = polygons
        } else {
            let polygon = MKPolygon(coordinates: &countryShape.boundary, count: countryShape.boundaryPointsCount)
            polygon.title = countryShape.country
            polygon.subtitle = countryShape.alpha
            //let overlay = customPolygon(countryName: country.country, alphaValue: 1.0, polygon: polygon)
            //countries[key]?.polygons = [polygon]
            worldMap.addOverlay(polygon)
            createdPolygonOverlays[polygon.title!] = polygon
        }
        
        if resetZoom {
            //I could find the max and min lat and long but as there are only 6/7 continents this feels ugly and I would rather have a dictionary of all the coordinates and a scale to use
            var midPoints = [
                "EU": ["lat": 50.9630, "long": 10.1875, "scale": 70.0],
                "AF": ["lat": 2.897318, "long": 18.105618, "scale": 110.0],
                "OC": ["lat": -29.962515, "long": 172.562187, "scale": 130.0],
                "AS": ["lat": 20.4507, "long": 85.8319, "scale": 130.0],
                "NA": ["lat": 55.856794, "long":  -101.585755, "scale": 130.0],
                "SA": ["lat": -25.643226, "long": -57.442726, "scale": 80.0]
            ]
            
            let latDelta:CLLocationDegrees = midPoints[continent!]!["scale"]!
            let longDelta:CLLocationDegrees = midPoints[continent!]!["scale"]!
            let theSpan:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
            let pointLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(midPoints[continent!]!["lat"]!, midPoints[continent!]!["long"]!)
            let region:MKCoordinateRegion = MKCoordinateRegionMake(pointLocation, theSpan)
            worldMap.setRegion(region, animated: true)
        }

    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolygon {
            let polygonView = MKPolygonRenderer(overlay: overlay)
            polygonView.lineWidth = 0.75
            polygonView.strokeColor = UIColor.whiteColor()
            polygonView.fillColor = UIColor.orangeColor()
            if let n = NSNumberFormatter().numberFromString(overlay.subtitle!!) {
                polygonView.alpha = CGFloat(n)
            }
            return polygonView
        }
        return MKOverlayRenderer()
    }

}

//class customPolygon: MKPolygon {
//    var alpha: CGFloat
//    var country: String
//    var polygonShape: MKPolygon
//    
//    init(countryName: String, alphaValue: CGFloat, polygon: MKPolygon) {
//        country = countryName
//        alpha = alphaValue
//        polygonShape = polygon
//    }
//}


