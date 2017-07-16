
import UIKit

class TableViewController: UITableViewController {
    // contains all the courses
    var courses: [Course] = []
    // contains the filtered ones
    var filteredCourses: [Course] = []
    // netID
    var netID: String?
    // for the search bar
    var searchController: UISearchController?
    
    deinit {
        searchController?.view.removeFromSuperview()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController = UISearchController(searchResultsController: nil)
        
        // Do any additional setup after loading the viewt, typically from a nib.
        navigationItem.title = "Courses"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: netID, style: .plain, target: self, action: #selector(handleLogout))
        
        tableView.register(CourseCell.self, forCellReuseIdentifier: "cellID")
        
        // json loading into an array
        var data:NSData
        let path:String = Bundle.main.path(forResource: "courses", ofType: "json")!
        data = NSData(contentsOfFile: path)!
        var json: Array<AnyObject>!
        do {
            json = try JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions()) as? Array
        } catch {
            json = []
            print(error)
        }
        
        // courses now contain all the courses!
        for course in json {
            let addition:Course = Course.init(courseDict: course as! Dictionary<String, AnyObject>)
            courses.append(addition)
        }
        
        // searchBar
        searchController!.searchResultsUpdater = self
        searchController!.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        searchController!.searchBar.placeholder = "Search by title, code or professor"
        
        // TODO: match these colors
        //searchController!.searchBar.backgroundColor = uicolorFromHex(0x003366)
        searchController!.searchBar.tintColor = uicolorFromHex(rgbValue: 0xffffff)
        searchController!.searchBar.barTintColor = uicolorFromHex(rgbValue: 0x003366)
        tableView.tableHeaderView = searchController!.searchBar
        
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        
        filteredCourses = courses.filter{ course in
            return course.title.lowercased().contains(searchText.lowercased())
        }
        // this may not be the most efficient way...may come across as slow for now
        for course in courses {
            for prof in course.profs {
                if prof["name"]!.lowercased().contains(searchText.lowercased()) {
                    if !(filteredCourses.contains(course)) {
                        filteredCourses.append(course)
                    }
                }
            }
            for listing in course.listings {
                let courseCode = listing["dept"]! + " " + listing["number"]!
                let courseCodeWithoutSpace = listing["dept"]! + listing["number"]!
                if courseCode.lowercased().contains(searchText.lowercased()) {
                    if !(filteredCourses.contains(course)) {
                        filteredCourses.append(course)
                    }
                }
                if courseCodeWithoutSpace.lowercased().contains(searchText.lowercased()) {
                    if !(filteredCourses.contains(course)) {
                        filteredCourses.append(course)
                    }
                }
            }
        }
        
        tableView.reloadData()
    }
    
    // returns how many there are
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (searchController!.isActive && searchController!.searchBar.text != "") {
            return filteredCourses.count
        }
        
        return courses.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let myCell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath) as! CourseCell
        let course: Course
        if searchController!.isActive && searchController!.searchBar.text != "" {
            course = filteredCourses[indexPath.row]
        }
        else {
            course = courses[indexPath.row]
        }
        myCell.courseTitleLabel.text = course.title
        
        // displays only the first listing!
        let courseCode:String = course.listings[0]["dept"]! + " " + course.listings[0]["number"]!
        myCell.courseCodeLabel.text = courseCode
        
        return myCell

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Not sure if this is needed at the moment, kept it the way it is for now
    func handleLogout() {
        let actionSheetController: UIAlertController = UIAlertController(title: "Log out?", message: "Would you like to log out?", preferredStyle: .actionSheet)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            //Just dismiss the action sheet
        }
        actionSheetController.addAction(cancelAction)
        
        let yesAction: UIAlertAction = UIAlertAction(title: "Log Out", style: .default) { action -> Void in
            
            let casV = UIWebView()
            casV.loadRequest(NSURLRequest(url: NSURL(string: "https://fed.princeton.edu/cas/logout")! as URL) as URLRequest)
            self.dismiss(animated: true, completion: nil)
        }
        actionSheetController.addAction(yesAction)
        //Present the AlertController
        self.present(actionSheetController, animated: true, completion: nil)
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // passing in only the course code for now
        let course:Course
        if searchController!.isActive && searchController!.searchBar.text != "" {
            course = filteredCourses[indexPath.row]
        }
        else {
            course = courses[indexPath.row]
        }
        // let courseCode:String = course.listings[0]["dept"]! + " " + course.listings[0]["number"]!
        
        /*
        let courseViewController = CourseViewController()
        courseViewController.courseCode = courseCode
        navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        self.navigationController?.pushViewController(courseViewController, animated: true)
         */
    }
}

// custom Cell
class CourseCell: UITableViewCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //courseCode Label
    let courseCodeLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    let courseTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 10)
        return label
    }()
    
    // helper to set up all the UI elements in this view
    func setupViews() {
        addSubview(courseCodeLabel)
        addSubview(courseTitleLabel)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[v0(70)]-8-[v1]-8-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": courseCodeLabel, "v1": courseTitleLabel]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": courseCodeLabel]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": courseTitleLabel]))
    }
}

extension TableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}
