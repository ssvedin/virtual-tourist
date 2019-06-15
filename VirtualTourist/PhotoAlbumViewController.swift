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
    
    var selectedPin: CLLocationCoordinate2D!
    var photos: [Photo] = []
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        showSelectedPin()
        
        let space:CGFloat = 3.0
        let width = 120.0
        let height = 120.0
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: width, height: height)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        PhotoSearch.searchPhotos(completion: { (photos, error) in
            if (photos != nil) {
                print("Photo results returned.")
                self.photos = (photos?.photo)!
                self.photoCollection.reloadData()
            } else {
                print("No photo results returned.")
            }
        })
    }
    
    // MARK: Selected pin
    
    func showSelectedPin() {
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = selectedPin
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        let cellImage = photos[indexPath.row]
        
        let url = URL(string: cellImage.url_sq)
        PhotoSearch.downloadPhoto(url: url!) { (data, error) in
            DispatchQueue.main.async {
                cell.photoImageView?.image = UIImage(data: data!)
            }
        }
        return cell
    }

}

