# FunKids

## Description

**FunKids**, also known as **FunPlaces2**, is an iOS application designed to help parents easily discover new and exciting places for their children to enjoy various recreational activities. Whether you’re looking for a park, a playground, or a kid-friendly museum, FunKids makes it simple to find and explore venues that offer engaging and fun experiences for children.

This app not only allows parents to search for and add their favorite spots but also to manage and organize these locations based on personal preferences. Users can include detailed descriptions, costs, addresses, and even images for each place, making it easier to plan outings and ensure a great time for the entire family.

## Features

- **Firebase Authentication:** Utilizes Firebase Authentication for user management.
  
  <img width="200" alt="Connexion" src="https://github.com/user-attachments/assets/9e23b7e2-9670-4754-bffb-f5bfcc820f0a">

- **Place Search:** Uses a search bar to filter places by title or address.
 <img width="200" alt="Search" src="https://github.com/user-attachments/assets/90741517-9baf-448e-8bf3-fa6a5d2bb6df">

- **Add New Places:** Allows adding places with a title, description, cost (integer), address, and image.
 <img width="200" alt="Add" src="https://github.com/user-attachments/assets/5bb175d7-a34d-4a08-a8f6-562acfd8ce2b">

- **Favorites Management:** Add places to favorites list.
 <img width="200" alt="Fav" src="https://github.com/user-attachments/assets/1fefe1fb-d5c6-4ac2-8dc4-4178c2e2855c">

- **Detail View:** View the details of a selected placewith a delete option.
  
 <img width="200" alt="Place1" src="https://github.com/user-attachments/assets/d59a532c-0709-4bd1-9b49-258f31c12c0f">    <img width="200" alt="Place2" src="https://github.com/user-attachments/assets/8a58b158-40b0-41a7-a54c-2386f6b04e7f">

- **Data Storage:** Stores place information in Firebase Realtime Database and images in Firebase Storage.

## Prerequisites

- Xcode 12 or later
- iOS 14 or later
- A Firebase account configured with Realtime Database, Firebase Storage, and Firebase Authentication.

## Installation

1. Clone this repository:
    ```bash
    git clone https://github.com/OdeliaTorjman/FunPlaces2.git
    ```

2. Open the project in Xcode:
    ```bash
    cd FunPlaces2
    open FunPlaces2.xcodeproj
    ```

3. Install dependencies (if using CocoaPods):
    ```bash
    pod install
    ```

4. Set up Firebase:
   - Download the `GoogleService-Info.plist` file from the Firebase console.
   - Add the `GoogleService-Info.plist` file to your Xcode project.

## Usage

- **Run the App:** Click `Run` in Xcode to start the application on a simulator or a physical device.
- **Add a Place:** Use the "Add Place" option to add a new place with a title, description, cost, address, and image.
- **Search:** Use the search bar to quickly find a specific place.
- **Manage Favorites:** Add or remove places from your favorites list.
- **View Details:** Tap on a place in the list to see its full details.

## Contribution

Contributions are welcome! Please follow the steps below to contribute:

1. Fork this repository.
2. Create a branch for your feature (`git checkout -b feature/feature-name`).
3. Commit your changes (`git commit -m 'Add feature'`).
4. Push to the branch (`git push origin feature/feature-name`).
5. Open a Pull Request.

## Authors

- **Odelia Torjman** - [Odelia Torjman on GitHub](https://github.com/OdeliaTorjman)
