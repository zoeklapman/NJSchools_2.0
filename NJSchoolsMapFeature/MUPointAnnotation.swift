//
//  MUPointAnnotation.swift
//  NJSchoolsMapFeature
//
//  Created by Zoë Klapman on 10/18/21.
//

import UIKit
import MapKit

class MUPointAnnotation: MKPointAnnotation {
    var pinTintColor: UIColor?
    var id: Int = 0
    var type:AnnotationTypes = AnnotationTypes.college
}
