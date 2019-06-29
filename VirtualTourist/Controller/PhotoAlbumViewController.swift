//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Sabrina on 6/1/19.
//  Copyright © 2019 Sabrina Svedin. All rights reserved.
//

import UIKit
import MapKit

class PhotoAlbumViewController: BaseViewController, MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    // MARK: Outlets and properties

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var photoCollection: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var noPhotosLabel: UILabel!
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    
    let annotation = MKPointAnnotation()
    var lat: Double = 0.0
    var lon: Double = 0.0
    var page: Int = 0
    var photos: [Photo] = []
    var cellsPerRow = 0
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        self.photoCollection.delegate = self
        showActivityIndicator()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showActivityIndicator()
        showSelectedPin()
        getPhotos()
    }
    
    // MARK: Load new photo collection
    
    @IBAction func loadNewCollection(_ sender: UIBarButtonItem) {
        showActivityIndicator()
        newCollectionButton.isEnabled = false
        photos = []
        getPhotos()
        photoCollection.reloadData()
    }
    
    // MARK: Get random photos for selected pin
    
    func getPhotos() {
        PhotoSearch.searchPhotos(lat: lat, lon: lon, page: page, completion: { (photos, error) in
            if (photos != nil) {
                self.photos = (photos?.photo)!
                let randomPage = Int.random(in: 1...photos!.pages)
                self.page = randomPage
                print(self.page)
                self.photoCollection.reloadData()
                self.hideActivityIndicator()
                if photos?.pages == 0 {
                    self.noPhotosLabel.isHidden = false
                    self.newCollectionButton.isEnabled = false
                }
            } else {
                self.showAlert(message: "There was an error retrieving photos", title: "Sorry")
                self.newCollectionButton.isEnabled = true
                self.hideActivityIndicator()
            }
        })
    }
    
    // MARK: Selected pin
        
    func showSelectedPin() {
        mapView.removeAnnotations(mapView.annotations)
        annotation.coordinate.latitude = lat
        annotation.coordinate.longitude = lon
        mapView.addAnnotation(annotation)
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
    
    // MARK: Map pins
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { print("no mkpointannotaions"); return nil }
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinTintColor = .red
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }

    // MARK: Collection View Data Source
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        self.newCollectionButton.isEnabled = false
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        let cellImage = photos[indexPath.row]
        cell.photoImageView?.image = UIImage(named:"ImagePlaceholder")
        
        let url = URL(string: cellImage.url_sq)
        PhotoSearch.downloadPhoto(url: url!) { (data, error) in
            if (data != nil) {
                DispatchQueue.main.async {
                    cell.photoImageView?.image = UIImage(data: data!)
                    self.newCollectionButton.isEnabled = true
                }
            } else {
                self.showAlert(message: "There was an error downloading photos", title: "Sorry")
            }

        }
        return cell
    }
    
    // MARK: Collection View Layout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
         let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
         let totalSpace = flowLayout.sectionInset.left + flowLayout.sectionInset.right + (flowLayout.minimumInteritemSpacing * CGFloat(cellsPerRow - 1))
         let size = Int((photoCollection.bounds.width - totalSpace) / CGFloat(cellsPerRow))
         return CGSize(width: size, height: size)
    }
    
    override func viewWillLayoutSubviews() {
        guard let flowLayout = photoCollection.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        if UIDevice.current.orientation == .portrait {
            cellsPerRow = 3
        } else {
            cellsPerRow = 5
        }
        
        flowLayout.invalidateLayout()
    }
    
}

