//
//  NJSchoolsModel.swift
//  NJSchools
//
//  Created by Zoë Klapman on 9/30/21.
//

import Foundation

// school properties (name, address, city, phone number, ratings, type of school, etc
struct Properties: Codable {
    var objectId: Int
    var schoolType: String?
    var county: String
    var name: String
    var phone: String?
    var rating: Int = 0
    
    enum CodingKeys: String, CodingKey {
        case objectId = "OBJECTID"
        case schoolType = "SOURCE"
        case county = "COUNTY"
        case name = "SCHOOLNAME"
        case phone = "PHONE"
    }
}

// geometry (gps location of the school)
struct Geometry: Codable {
    var coordinates: [Double]
    
    enum CodingKeys: String, CodingKey {
        case coordinates = "coordinates"
    }
}

// combined struct for the school
struct School: Codable {
    var properties: Properties
    var geometry: Geometry
}

class NJSchoolsModel {
    // singleton variable for instantiated object
    static let sharedInstance = NJSchoolsModel()
    
    // array of school
    var njSchools: [School] = []
    
    // dictionary with counties as keys and array of schools as value
    var njCountiesNschools: [String: [School]] = ["Atlantic": [], "Bergen": [],
                                                  "Burlington": [], "Camden": [],
                                                  "Cape May": [], "Cumberland": [],
                                                  "Essex": [], "Goucester": [],
                                                  "Hudson": [], "Hunterdon": [],
                                                  "Mercer": [], "Middlesex": [],
                                                  "Monmouth": [], "Morris": [],
                                                  "Ocean": [], "Passaic": [],
                                                  "Salem": [], "Somerset": [],
                                                  "Sussex": [], "Union": [],
                                                  "Warren": []]
    
    // constructor method
    private init() {
        readSchoolsData()
        mapSchoolsToCounty()
    }
    
    // 1. read JSON file as string
    // 2. convert string to data using UTF8 characters
    // 3. decode the data as an array of School structs
    // 4. wrap inside do try block and catch in case there is an error in above steps
    func readSchoolsData() {
        if let filename = Bundle.main.path(forResource: "NJSchools", ofType: "json") {
            do {
                let jsonStr = try String(contentsOfFile: filename)
                let jsonData = jsonStr.data(using: .utf8)!
                njSchools = try JSONDecoder().decode([School].self, from: jsonData)
                // shuffle for random order
                njSchools.shuffle()
            } catch {
                print("The file could not be loaded")
                print(error)
            }
        }
    }
    
    func mapSchoolsToCounty() {
        // get county names as an array of String from the dictionary
        let counties = Array(njCountiesNschools.keys)
        
        // filter the schools with county name and map the filtered list to
        // each counties array of Schools. Use case insensitve comparison.
        for county in counties {
            njCountiesNschools[county] = njSchools.filter({($0.properties.county).caseInsensitiveCompare(county) == .orderedSame})
            njCountiesNschools[county]?.sort(by: {$0.properties.name < $1.properties.name})
        }
    }
    
    // MARK: - Navigation Methods
    
    func getSchoolInfo(forSchoolId id: Int, inCounty county: String) -> School? {
        if let index = (njCountiesNschools[county])?.firstIndex(where: {$0.properties.objectId == id}) {
            return njCountiesNschools[county]?[index]
        }
        return nil;
    }
    
    func getSchoolInfo(forSchoolId id: Int) -> School? {
        if let index = (njSchools).firstIndex(where: {$0.properties.objectId == id}) {
            return njSchools[index]
        }
        return nil;
    }
    
    func getSchoolRating(forSchoolId id: Int) -> Int? {
        if let index = (njSchools).firstIndex(where: {$0.properties.objectId == id}) {
            return njSchools[index].properties.rating
        }
        return nil;
    }
    
    func updateSchoolsRating(forSchoolId id: Int, county: String, rating newRating: Int?) -> Bool {
        /* print(id)
        print(county)
        print(newRating)*/
        if let index = (njCountiesNschools[county])?.firstIndex(where: {$0.properties.objectId == id}) {
            njCountiesNschools[county]?[index].properties.rating = newRating ?? 0
            _ = updateSchoolRating(id, rating: newRating!)
            return true
        }
        return false
    }
    
    func updateSchoolRating(_ id: Int, rating new: Int) -> Bool {
        if let index = (njSchools).firstIndex(where: {$0.properties.objectId == id}) {
            self.njSchools[index].properties.rating = new
            return true
        }
        return false
    }
    
}
