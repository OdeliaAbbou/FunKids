import UIKit
import Firebase
import FirebaseStorage

class AddController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var Add_TXT: UILabel!
    @IBOutlet weak var Title_TXT: UILabel!
    @IBOutlet weak var Des_TXT: UILabel!
    @IBOutlet weak var Cost_TXT: UILabel!
    @IBOutlet weak var Address_TXT: UILabel!
    @IBOutlet weak var TitleField: UITextField!
    @IBOutlet weak var CostField: UITextField!
    @IBOutlet weak var AddField: UITextField!
    @IBOutlet weak var DescriptionTxt: UITextView!
    @IBOutlet weak var ImageBTN: UIButton!
    @IBOutlet weak var AddPlaceBTN: UIButton!
    
    var selectedImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()

        let backgroundImageView = UIImageView(frame: UIScreen.main.bounds)
        backgroundImageView.image = UIImage(named: "pastel_balloons")
        backgroundImageView.contentMode = .scaleAspectFill
        self.view.insertSubview(backgroundImageView, at: 0)
        Add_TXT.backgroundColor = UIColor(red: 1.0, green: 0.9, blue: 0.9, alpha: 1.0)


        Title_TXT.textColor = .black
        Des_TXT.textColor = .black
        Cost_TXT.textColor = .black
        Address_TXT.textColor = .black

        TitleField.backgroundColor = .gray
        CostField.backgroundColor = .gray
        AddField.backgroundColor = .gray
        DescriptionTxt.backgroundColor = .gray
        
        CostField.keyboardType = .numberPad
        CostField.delegate = self
    }
    
    @IBAction func UploadImage(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true

        let alert = UIAlertController(title: "Choose an Image", message: "Please choose a source", preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true, completion: nil)
        }))

        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImage = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImage = originalImage
        }
        dismiss(animated: true, completion: nil)
    }

    @IBAction func AddPlace(_ sender: UIButton) {
        guard let title = TitleField.text,
              let description = DescriptionTxt.text,
              let cost = CostField.text,
              let address = AddField.text,
              !title.isEmpty, !description.isEmpty, !cost.isEmpty, !address.isEmpty else {
            showAlert(message: "All fields must be filled.")
            return
        }

        checkIfTitleExists(title: title) { [weak self] exists in
            guard let self = self else { return }
            if exists {
                self.showAlert(message: "A place with this title already exists. Please choose a different title.")
            } else {
                if let image = self.selectedImage {
                    self.uploadImage(image) { imageUrl in
                        self.savePlaceData(title: title, description: description, cost: cost, address: address, imageUrl: imageUrl)
                    }
                } else {
                    self.savePlaceData(title: title, description: description, cost: cost, address: address, imageUrl: nil)
                }
            }
        }
    }

    func checkIfTitleExists(title: String, completion: @escaping (Bool) -> Void) {
        let placeKey = title.lowercased().replacingOccurrences(of: " ", with: "_")
        let ref = Database.database().reference().child("places").child(placeKey)
        
        ref.observeSingleEvent(of: .value) { snapshot in
            completion(snapshot.exists())
        }
    }

    func uploadImage(_ image: UIImage, completion: @escaping (String?) -> Void) {
        let storageRef = Storage.storage().reference().child("places/\(UUID().uuidString).jpg")
        if let imageData = image.jpegData(compressionQuality: 0.75) {
            storageRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    print("Error uploading image: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                storageRef.downloadURL { url, error in
                    if let error = error {
                        print("Error getting download URL: \(error.localizedDescription)")
                        completion(nil)
                        return
                    }
                    completion(url?.absoluteString)
                }
            }
        } else {
            completion(nil)
        }
    }

    func savePlaceData(title: String, description: String, cost: String, address: String, imageUrl: String?) {
        let ref = Database.database().reference()
        let placeKey = title.lowercased().replacingOccurrences(of: " ", with: "_")

        guard let costInt = Int(cost) else { 
            showAlert(message: "Cost must be a valid number.")
            return
        }

        var placeData: [String: Any] = [
            "title": title,
            "description": description,
            "cost": costInt,
            "address": address
        ]


        if let imageUrl = imageUrl {
            placeData["imageURL"] = imageUrl
        }

        ref.child("places").child(placeKey).setValue(placeData) { (error, ref) in
            if let error = error {
                self.showAlert(message: "Error adding place: \(error.localizedDescription)")
            } else {
                self.showSuccessAndDismiss()
            }
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == CostField {
            let allowedCharacters = CharacterSet.decimalDigits
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        }
        return true
    }

    func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showSuccessAndDismiss() {
        let alert = UIAlertController(title: "Success", message: "The place has been successfully added.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.dismiss(animated: true) {
                NotificationCenter.default.post(name: NSNotification.Name("PlaceAdded"), object: nil)
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
