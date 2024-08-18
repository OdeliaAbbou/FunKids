import UIKit

class PlaceTableViewCell: UITableViewCell {
    static let identifier = "PlaceTableViewCell"

    @IBOutlet weak var placeImageView: UIImageView!
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        placeImageView.layer.cornerRadius = 8
        placeImageView.clipsToBounds = true
        self.backgroundColor = UIColor(red: 1.0, green: 0.9, blue: 0.9, alpha: 1.0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(place: Place) {
        placeNameLabel.text = place.title
        addressLabel.text = place.address
        costLabel.text = String(place.cost ?? 0) + " ₪"

        placeImageView.image = UIImage(named: "defaultImage")

        if let imageUrl = place.imageUrl {
            placeImageView.loadImage(from: imageUrl)
        } else {
            placeImageView.image = UIImage(named: "defaultImage")
        }
    }
}
