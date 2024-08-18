import UIKit
import Firebase
import FirebaseAuth

class FavoriesController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var Title_Fav: UILabel!
    @IBOutlet weak var FunPlaces_Fav: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var allPlaces: [Place] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
           let backgroundImageView = UIImageView(frame: UIScreen.main.bounds)
            backgroundImageView.image = UIImage(named: "pastel_balloons")
           backgroundImageView.contentMode = .scaleAspectFill
           
           self.view.insertSubview(backgroundImageView, at: 0)
        tableView.backgroundColor = .clear
        FunPlaces_Fav.backgroundColor = UIColor(red: 1.0, green: 0.9, blue: 0.9, alpha: 1.0)
        Title_Fav.backgroundColor = UIColor(red: 1.0, green: 0.9, blue: 0.9, alpha: 1.0)


        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "PlaceTableViewCell", bundle: .main), forCellReuseIdentifier: PlaceTableViewCell.identifier)

        fetchAllPlaces()
    }

    func fetchAllPlaces() {
        guard let user = Auth.auth().currentUser else {
            print("User not authenticated")
            return
        }

        let emailKey = user.email?.replacingOccurrences(of: ".", with: "_").replacingOccurrences(of: "@", with: "_") ?? ""

        let ref = Database.database().reference().child("users").child(emailKey).child("favorites")
        
        ref.observeSingleEvent(of: .value) { snapshot in
            var newAllPlaces: [Place] = []
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot {
                    let place = Place(snapshot: snapshot)
                    newAllPlaces.append(place)
                }
            }
            self.allPlaces = newAllPlaces
            self.tableView.reloadData()
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allPlaces.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PlaceTableViewCell.identifier, for: indexPath) as? PlaceTableViewCell else {
            return UITableViewCell()
        }
        let place = allPlaces[indexPath.row]
        cell.configure(place: place)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPlace = allPlaces[indexPath.row]
        performSegue(withIdentifier: "ShowPlaceDetailsFromFavorites", sender: selectedPlace)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPlaceDetailsFromFavorites" {
            if let destinationVC = segue.destination as? PlaceController,
               let selectedPlace = sender as? Place {
                destinationVC.place = selectedPlace
            }
        }
    }
}
