//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Sabrina on 6/1/19.
//  Copyright © 2019 Sabrina Svedin. All rights reserved.
//

import UIKit
import MapKit

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: Outlets and properties

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var photoCollection: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var noPhotosLabel: UILabel!
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    
    let annotation = MKPointAnnotation()
    var selectedPin: CLLocationCoordinate2D!
    var myIndicator: UIActivityIndicatorView!
    var lat: Double = 0.0
    var lon: Double = 0.0
    var page: Int = 0
    var photos: [Photo] = []
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        let space:CGFloat = 3.0
        let width = 120.0
        let height = 120.0
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: width, height: height)
        
        myIndicator = UIActivityIndicatorView (style: UIActivityIndicatorView.Style.gray)
        self.view.addSubview(myIndicator)
        myIndicator.bringSubviewToFront(self.view)
        myIndicator.center = self.view.center
        showActivityIndicator()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
                print("Photo results returned.")
                self.photos = (photos?.photo)!
                let randomPage = Int.random(in: 0...photos!.pages)
                self.page = randomPage
                print(self.page)
                self.photoCollection.reloadData()
                self.hideActivityIndicator()
                if photos?.pages == 0 {
                    print("There are no photos for this location.")
                    self.noPhotosLabel.isHidden = false
                    self.newCollectionButton.isEnabled = false
                }
            } else {
                print("There was an error retrieving photos.")
                self.newCollectionButton.isEnabled = true
                self.hideActivityIndicator()
            }
        })
    }
    
    // MARK: Selected pin
        
    func showSelectedPin() {
        mapView.removeAnnotations(mapView.annotations)
        annotation.coordinate = selectedPin
        mapView.addAnnotation(annotation)
        lat = selectedPin.latitude
        lon = selectedPin.longitude
        print(selectedPin.latitude)
        print(selectedPin.longitude)
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
            DispatchQueue.main.async {
                cell.photoImageView?.image = UIImage(data: data!)
                self.newCollectionButton.isEnabled = true
            }
        }
        return cell
    }
    
    func showActivityIndicator() {
        myIndicator.isHidden = false
        myIndicator.startAnimating()
    }
    
    func hideActivityIndicator() {
        myIndicator.stopAnimating()
        myIndicator.isHidden = true
    }

}

