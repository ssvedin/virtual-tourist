//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Sabrina on 6/1/19.
//  Copyright © 2019 Sabrina Svedin. All rights reserved.
//

import UIKit
import MapKit
import CoreData

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
    var cellsPerRow = 0
    var photos: [Photo] = []
    var flickrPhotos: [FlickrPhoto] = []
    var pin: Pin!
    var dataController: DataController!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        self.photoCollection.delegate = self
        showActivityIndicator()
        
        guard pin != nil else {
            return
        }
        
        flickrPhotos = fetchFlickrPhotos()        
        if flickrPhotos.count > 0 {
            for flickrPhoto in flickrPhotos {
                flickrPhotos.append(flickrPhoto)
            }
        }
        
        if flickrPhotos.isEmpty {
            getPhotos()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showActivityIndicator()
        showSelectedPin()
        getPhotos()
    }
    
    func fetchFlickrPhotos() -> [FlickrPhoto] {
        let fetchRequest: NSFetchRequest<FlickrPhoto> = FlickrPhoto.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        do {
            let result = try dataController.viewContext.fetch(fetchRequest)
            flickrPhotos = result
            hideActivityIndicator()
        } catch {
            showAlert(message: "There was an error retrieving photos", title: "Sorry")
            hideActivityIndicator()
        }
        return flickrPhotos
    }
    
    // MARK: Load new photo collection
    
    @IBAction func loadNewCollection(_ sender: UIBarButtonItem) {
        showActivityIndicator()
        newCollectionButton.isEnabled = false
        clearPhotos()
        photos = []
        flickrPhotos = []
        getPhotos()
        photoCollection.reloadData()
    }
    
    // MARK: Get random photos for selected pin
    
    func getPhotos() {
        PhotoSearch.searchPhotos(lat: lat, lon: lon, page: page, completion: { (photos, error) in
            if (photos != nil) {
                if photos?.pages == 0 {
                    self.noPhotosLabel.isHidden = false
                    self.newCollectionButton.isEnabled = false
                    self.hideActivityIndicator()
                } else {
                    self.photos = (photos?.photo)!
                    let randomPage = Int.random(in: 1...photos!.pages)
                    self.page = randomPage
                    print(self.page)
                    self.getImageURL()
                    //self.photoCollection.reloadData()
                    self.hideActivityIndicator()
                }
            } else {
                self.showAlert(message: "There was an error retrieving photos", title: "Sorry")
                self.newCollectionButton.isEnabled = true
                self.hideActivityIndicator()
            }
        })
    }
    
    func getImageURL() {
        for photo in photos {
            let flickrPhoto = FlickrPhoto(context: dataController.viewContext)
            flickrPhoto.imageUrl = photo.url_sq
            flickrPhoto.pin = pin
            flickrPhotos.append(flickrPhoto)
        }
        DispatchQueue.main.async {
            try? self.dataController.viewContext.save()
            self.photoCollection.reloadData()
        }
    }
    
    // MARK: Delete photo collection
    
    func clearPhotos() {
        for flickrPhoto in flickrPhotos {
            dataController.viewContext.delete(flickrPhoto)
            try? self.dataController.viewContext.save()
        }
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
        let cellImage = flickrPhotos[indexPath.row]
        
        if cellImage.image != nil {
            cell.photoImageView.image = UIImage(data: cellImage.image!)
            self.newCollectionButton.isEnabled = true
        } else {
           cell.photoImageView.image = UIImage(named: "ImagePlaceholder")
            
            if cellImage.imageUrl != nil {
                let url = URL(string: cellImage.imageUrl ?? "")
                PhotoSearch.downloadPhoto(url: url!) { (data, error) in
                    if (data != nil) {
                        DispatchQueue.main.async {
                            cellImage.image = data
                            cellImage.pin = self.pin
                            try? self.dataController.viewContext.save()
                            cell.photoImageView?.image = UIImage(data: data!)
                            self.newCollectionButton.isEnabled = true
                        }
                    } else {
                        self.showAlert(message: "There was an error downloading photos", title: "Sorry")
                    }
                }
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

