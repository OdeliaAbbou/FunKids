import UIKit
import Firebase
import FirebaseStorage
import FirebaseAuth

class PlaceController: UIViewController {
    @IBOutlet weak var AddPlaceLabel: UILabel!
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var PriceLabel: UILabel!
    @IBOutlet weak var Cost: UILabel!
    @IBOutlet weak var DescriptionLabel: UILabel!
    @IBOutlet weak var Roller: UIScrollView!
    @IBOutlet weak var ImageView: UIImageView!
    
    @IBOutlet weak var FavoriteBtn: UIButton!
    @IBOutlet weak var DescriptionTXT: UILabel!
    @IBOutlet weak var Delete: UIButton!
    
    var place: Place?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backgroundImageView = UIImageView(frame: UIScreen.main.bounds)
        backgroundImageView.image = UIImage(named: "pastel")
        backgroundImageView.contentMode = .scaleAspectFill
        self.view.addSubview(backgroundImageView)
        
        self.view.sendSubviewToBack(backgroundImageView)
        
        AddPlaceLabel.backgroundColor = UIColor(red: 1.0, green: 0.9, blue: 0.9, alpha: 1.0)
        
        if let place = place {
            TitleLabel.text = place.title
            Cost.text = "\(place.cost ?? 0) ₪"
            DescriptionTXT.text = place.description
            if let url = place.imageUrl {
                ImageView.loadImage(from: url)
            }
        }
    }
    
    @IBAction func AddFavoriteItem(_ sender: UIButton) {
        guard let place = place,
              let user = Auth.auth().currentUser,
              let email = user.email else { return }

        let emailKey = email.replacingOccurrences(of: ".", with: "_").replacingOccurrences(of: "@", with: "_")
        let titleKey = place.title?.lowercased().replacingOccurrences(of: " ", with: "_") ?? UUID().uuidString

        let ref = Database.database().reference().child("users").child(emailKey).child("favorites").child(titleKey)
        
        var placeData: [String: Any] = [
            "title": place.title ?? "",
            "description": place.description ?? "",
            "cost": place.cost ?? 0,
            "address": place.address ?? ""
        ]
        
        if let imageUrl = place.imageUrl?.absoluteString {
            placeData["imageURL"] = imageUrl
        }
        
        ref.setValue(placeData) { error, _ in
            if let error = error {
                self.showAlert(message: "Error adding to favorites: \(error.localizedDescription)")
            } else {
                self.showAlert(message: "Added to favorites successfully!")
            }
        }
    }
    
    @IBAction func DeleteItemFromDB(_ sender: UIButton) {
        guard let place = place else { return }
        
        let placeKey = place.title?.lowercased().replacingOccurrences(of: " ", with: "_") ?? ""
        let placesRef = Database.database().reference().child("places").child(placeKey)
        let usersRef = Database.database().reference().child("users")
        
        placesRef.removeValue { error, _ in
            if let error = error {
                let alert = UIAlertController(title: "Error", message: "Error deleting place: \(error.localizedDescription)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            if let imageUrl = place.imageUrl {
                let storageRef = Storage.storage().reference(forURL: imageUrl.absoluteString)
                
                storageRef.delete { error in
                    if let error = error {
                        let alert = UIAlertController(title: "Error", message: "Error deleting image: \(error.localizedDescription)", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    } else {
                        self.deletePlaceFromFavorites(usersRef: usersRef, placeKey: placeKey)
                    }
                }
            } else {
                self.deletePlaceFromFavorites(usersRef: usersRef, placeKey: placeKey)
            }
        }
    }
    
    func deletePlaceFromFavorites(usersRef: DatabaseReference, placeKey: String) {
        usersRef.observeSingleEvent(of: .value) { snapshot in
            for child in snapshot.children {
                if let userSnapshot = child as? DataSnapshot {
                    let favoritesRef = userSnapshot.childSnapshot(forPath: "favorites").childSnapshot(forPath: placeKey)
                    if favoritesRef.exists() {
                        usersRef.child(userSnapshot.key).child("favorites").child(placeKey).removeValue { error, _ in
                            if let error = error {
                                print("Error deleting place from favorites: \(error.localizedDescription)")
                            } else {
                                print("Place successfully deleted from favorites of user \(userSnapshot.key)")
                            }
                        }
                    }
                }
            }
            self.confirmAndDismiss()
        }
    }
    
    func confirmAndDismiss() {
        let alert = UIAlertController(title: "Success", message: "Place has been successfully deleted.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.dismiss(animated: true) {
                NotificationCenter.default.post(name: NSNotification.Name("PlaceDeleted"), object: nil)
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }

    func showAlert(message: String) {
        let alert = UIAlertController(title: "Info", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
