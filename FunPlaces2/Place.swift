import Foundation
import Firebase

class Place {
    var title: String?
    var description: String?
    var cost: Int?
    var address: String?
    var imageUrl: URL?
    
    init(title: String? = nil, description: String? = nil, cost: Int? = nil, address: String? = nil, imageUrl: URL? = nil) {
        self.title = title
        self.description = description
        self.cost = cost
        self.address = address
        self.imageUrl = imageUrl
    }
    
    init(snapshot: DataSnapshot) {
        let value = snapshot.value as? [String: Any] ?? [:]
        self.title = value["title"] as? String
        self.description = value["description"] as? String
        if let costValue = value["cost"] as? Int {
            self.cost = costValue
        } else if let costString = value["cost"] as? String, let costInt = Int(costString) {
            self.cost = costInt
        } else {
            self.cost = 0
        }

        self.address = value["address"] as? String
        if let imageUrlString = value["imageURL"] as? String {
            self.imageUrl = URL(string: imageUrlString)
        } else {
            self.imageUrl = nil
        }
    }
}
