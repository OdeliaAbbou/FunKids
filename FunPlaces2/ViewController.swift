import UIKit
import Firebase

class ViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var FunPaces_LBL_Main: UILabel!
    @IBOutlet weak var searchBar_Main: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var FavoryBtn: UIButton!
    
    var places: [Place] = []
    var filteredPlaces: [Place] = []
    var isFiltering: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        let backgroundImageView = UIImageView(frame: UIScreen.main.bounds)
        backgroundImageView.image = UIImage(named: "pastel_balloons")
        backgroundImageView.contentMode = .scaleAspectFill
        self.view.insertSubview(backgroundImageView, at: 0)
        
        tableView.backgroundColor = .clear
        FunPaces_LBL_Main.backgroundColor = UIColor(red: 1.0, green: 0.9, blue: 0.9, alpha: 1.0)


        // Transparent SearchBar
        if let searchTextField = searchBar_Main.value(forKey: "searchField") as? UITextField {
            searchTextField.backgroundColor = .clear
            searchTextField.borderStyle = .none
        }

        searchBar_Main.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "PlaceTableViewCell", bundle: .main), forCellReuseIdentifier: PlaceTableViewCell.identifier)

        fetchPlaces()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handlePlaceAddedNotification), name: NSNotification.Name("PlaceAdded"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handlePlaceDeletedNotification), name: NSNotification.Name("PlaceDeleted"), object: nil)
    }
    
    @IBAction func ToFavPage(_ sender: UIButton) {
        performSegue(withIdentifier: "SeeFavoriesSegue", sender: nil)
    }
    
    func fetchPlaces() {
        let ref = Database.database().reference().child("places")
        ref.observeSingleEvent(of: .value) { snapshot in
            var newPlaces: [Place] = []
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot {
                    let place = Place(snapshot: snapshot)
                    newPlaces.append(place)
                }
            }
            self.places = newPlaces
            self.tableView.reloadData()
        }
    }
    
    @objc func handlePlaceAddedNotification() {
        fetchPlaces()
    }
    
    @objc func handlePlaceDeletedNotification() {
        fetchPlaces()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isFiltering = false
            filteredPlaces = []
        } else {
            isFiltering = true
            let searchTextLowercased = searchText.lowercased()
            filteredPlaces = places.filter { place in
                return (place.title?.lowercased().contains(searchTextLowercased) ?? false) ||
                       (place.address?.lowercased().contains(searchTextLowercased) ?? false)
            }
        }
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isFiltering = false
        searchBar.text = ""
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isFiltering ? filteredPlaces.count : places.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PlaceTableViewCell.identifier, for: indexPath) as? PlaceTableViewCell else {
            return UITableViewCell()
        }
        
        let place = isFiltering ? filteredPlaces[indexPath.row] : places[indexPath.row]
        
        cell.placeImageView.image = UIImage(named: "defaultImage")
        cell.configure(place: place)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let place = isFiltering ? filteredPlaces[indexPath.row] : places[indexPath.row]
        performSegue(withIdentifier: "ShowPlaceDetails", sender: place)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPlaceDetails" {
            if let destinationVC = segue.destination as? PlaceController,
               let selectedPlace = sender as? Place {
                destinationVC.place = selectedPlace
            }
        }
    }
    
    @IBAction func AddNewName(_ sender: UIButton) {
        performSegue(withIdentifier: "NavigateToAdd", sender: self)
    }
}
