//
//  SchoolsTableViewController.swift
//  NJSchools
//
//  Created by Zoë Klapman on 9/29/21.
//

import UIKit

class SchoolsTableViewController: UITableViewController {
    
    // singleton the model object
    let njSchoolsModel = NJSchoolsModel.sharedInstance
    
    // local variables
    var njCountiesSorted: [String] = []
    var selectedIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // get the sorted counties from model's dictionary
        njCountiesSorted = Array(njSchoolsModel.njCountiesNschools.keys).sorted()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // can do following to refresh the table data (reloads entire table)
        // self.tableView.reloadData()
        
        // can just reload selective rows instead
        if let reloadIndexPath = selectedIndexPath {
            tableView.reloadRows(at: [reloadIndexPath], with: .automatic)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // number of sections is number of counties
        return njCountiesSorted.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // find the index to the county
        let county = njCountiesSorted[section]
        
        // find number of schools in that county.
        // possible the county may not have a key in the dictionary.
        // use optional and ternary operator to return 0 if such is the case
        return (njSchoolsModel.njCountiesNschools[county]?.count ?? 0)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return njCountiesSorted[section]
    }
    
    // this function will get called just before section's headerview is displayed
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as? UITableViewHeaderFooterView
        header?.textLabel?.font = UIFont.init(name: "Montserrat-Regular", size: 14)
        header?.textLabel?.textColor = .darkGray
    }
    
    // set size font for section header font
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 26
    }
    
    // this function will get called before display of section's footer
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        let footer = view as? UITableViewHeaderFooterView
        footer?.textLabel?.font = UIFont.init(name: "Monterrat-Regular", size: 14)
        footer?.textLabel?.textColor = .blue
    }
    
    // set size font for section footer font
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 26
    }
    
    // return count of schools in that county
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let county = njCountiesSorted[section]
        let totalSchools = njSchoolsModel.njCountiesNschools[county]?.count ?? 0
        return "Total: \(totalSchools)"
    }
    
    // set UITableViewCells properties - textLabel, detailedTextLabel, image
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "schoolCell", for: indexPath) as! SchoolInfoTableViewCell // don't forget the identifier set in view
        
        // Configure the cell...
        let county = njCountiesSorted[indexPath.section]    // get the section
        
        
        if let countyData = njSchoolsModel.njCountiesNschools[county] {
            let school = countyData[indexPath.row]  // get the school
            
            // NEW
            cell.nameLabel?.text = school.properties.name
            cell.phoneLabel?.text = "Phone: " + school.properties.phone!
            //cell.ratingLabel?.text = String(school.properties.rating)
            cell.ratingLabel?.text = "Rating: " + getStars(school.properties.rating)
            
            // set the image
            // based on schoolType
            switch (school.properties.schoolType) {
            case "CHARTER":
                cell.imageView?.image = UIImage(named: "charter")
            case "PRIVATE":
                cell.imageView?.image = UIImage(named: "private")
            case "PUBLIC":
                cell.imageView?.image = UIImage(named: "public")
            default:
                cell.imageView?.image = UIImage(systemName: "questionmark.square.dashed")
            }
        }
        
        return cell
    }
    
    // set row height
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    // side indexing
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return njCountiesSorted
    }

    // MARK: - TableView Delegates
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // print ("selected section: \(indexPath.section)   row: \(indexPath.row)")
        selectedIndexPath = indexPath
        performSegue(withIdentifier: "schoolDetailSegue", sender: self)
    }
    
    // return number of emoji stars
    func getStars(_ rating: Int) -> String {
        var s = ""
        if rating > 0 {
            for _ in 1...rating {
                s = s + "⭐️"
            }
        }
        return s
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let indexPath = selectedIndexPath {
            let selectedCounty = njCountiesSorted[indexPath.section]
            let selectedSchool = njSchoolsModel.njCountiesNschools[njCountiesSorted[indexPath.section]]?[indexPath.row]
            let editSchool = njSchoolsModel.getSchoolInfo(forSchoolId: selectedSchool!.properties.objectId, inCounty: selectedCounty)
            if(segue.identifier == "schoolDetailSegue") {
                // destination view controller
                let dvc = segue.destination as! SchoolDetailViewController
                dvc.editedSchool = editSchool
                dvc.county = selectedCounty
            }
        }
    }

}
