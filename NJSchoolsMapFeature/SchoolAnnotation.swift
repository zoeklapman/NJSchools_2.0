//
//  SchoolAnnotation.swift
//  NJSchoolsMapFeature
//
//  Created by Zoë Klapman on 10/16/21.
//

import Foundation
import UIKit
import MapKit
import Contacts

// MKAnnotation is a Protocol - we need to provide the coordinate, title, and subtitle variables

class SchoolAnnotation: NSObject, MKAnnotation {
    
    let njSchoolsModel = NJSchoolsModel.sharedInstance
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    // variables to associate w obj for use in app
    
    var pinTintColor: UIColor?
    var schoolID: Int
    var type = AnnotationTypes.school
    var schoolType: String?
    
    init(latitude: CLLocationDegrees, longitude: CLLocationDegrees, title: String, subTitle: String, schoolID id: Int, schoolType: String?) {
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.title = title
        self.subtitle = subTitle
        schoolID = id
        self.schoolType = schoolType
    }
    
    // to provide annotation to a Directions app (e..g. Apple Map, Google Map, Waze)
    func mapItem() -> MKMapItem {
        let destintationTitle = title! + ", " + subtitle!
        let addrDict = [CNPostalAddressCityKey: destintationTitle]
        let placemark = MKPlacemark (coordinate: coordinate, addressDictionary: addrDict)
        let mapItem = MKMapItem (placemark: placemark)
        return mapItem
    }
    
}
