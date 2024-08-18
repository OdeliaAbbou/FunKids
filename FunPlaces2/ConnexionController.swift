import UIKit
import FirebaseAuth

class ConnexionController: UIViewController {

    @IBOutlet weak var PasswordTxt: UITextField!
    @IBOutlet weak var EmailTxt: UITextField!
    @IBOutlet weak var PasswordLbl: UILabel!
    @IBOutlet weak var EmailLbl: UILabel!
    @IBOutlet weak var LoginLbl: UILabel!
    @IBOutlet weak var FunPlace_conn: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

           let backgroundImageView = UIImageView(frame: UIScreen.main.bounds)
            backgroundImageView.image = UIImage(named: "pastel_balloons")
           
           backgroundImageView.contentMode = .scaleAspectFill
           
           self.view.insertSubview(backgroundImageView, at: 0)
        
        print("EmailTxt frame: \(EmailTxt.frame)")
        print("PasswordTxt frame: \(PasswordTxt.frame)")
        FunPlace_conn.backgroundColor = UIColor(red: 1.0, green: 0.9, blue: 0.9, alpha: 1.0)




    }

    @IBAction func loginButtonTapped(_ sender: UIButton) {
        guard let email = EmailTxt.text, !email.isEmpty,
              let password = PasswordTxt.text, !password.isEmpty else {
            showAlert(message: "Please enter both email and password.")
            return
        }

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error as NSError? {
                if error.code == AuthErrorCode.userNotFound.rawValue {
                    self?.createAccount(email: email, password: password)
                } else if error.code == AuthErrorCode.invalidCredential.rawValue {
                    self?.createAccount(email: email, password: password)
                } else {
                    self?.showAlert(message: "Error: \(error.localizedDescription)")
                }
            } else {
                self?.performSegue(withIdentifier: "ShowMainScreen", sender: nil)
            }
        }
    }

    func createAccount(email: String, password: String) {
        print("Creating account with Email: \(email), Password: \(password)")

        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error as NSError? {
                switch AuthErrorCode(rawValue: error.code) {
                case .emailAlreadyInUse:
                    self?.showAlert(message: "The email is already in use with another account.")
                case .invalidEmail:
                    self?.showAlert(message: "Please enter a valid email address.")
                case .weakPassword:
                    self?.showAlert(message: "The password is too weak.")
                default:
                    self?.showAlert(message: "Error: \(error.localizedDescription)")
                }
            } else {
                DispatchQueue.main.async {
                    self?.resetUIValues()
                    self?.performSegue(withIdentifier: "ShowMainScreen", sender: nil)
                }
            }
        }
    }

    func resetUIValues() {
        self.EmailTxt.text = ""
        self.PasswordTxt.text = ""
    }

    func showAlert(message: String) {
        let alert = UIAlertController(title: "Authentication Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
