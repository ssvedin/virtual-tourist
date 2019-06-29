//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Sabrina on 5/29/19.
//  Copyright © 2019 Sabrina Svedin. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: BaseViewController, MKMapViewDelegate {
    
    // MARK: Outlets and Properties
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var deletePinsLabel: UILabel!
    
    var annotations = [MKPointAnnotation]() // added to use in viewWillAppear
    var annotation = MKPointAnnotation()
    //var selectedLatitude: Double = 0.0
    //var selectedLongitude: Double = 0.0
    var pins: [Pin] = []
    
    var dataController: DataController!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleTap))
        mapView.addGestureRecognizer(gestureRecognizer)
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.navigationItem.rightBarButtonItem!.title = "Edit"
        showActivityIndicator()
        
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        // TODO: need sortDescriptors?
        do {
            let result = try dataController.viewContext.fetch(fetchRequest)
            pins = result
            mapView.addAnnotation(annotation)
            hideActivityIndicator()
        } catch {
            showAlert(message: "There was an error retrieving pins", title: "Sorry")
            hideActivityIndicator()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showActivityIndicator()
        mapView.deselectAnnotation(annotations as? MKAnnotation, animated: false)
        hideActivityIndicator()
    }
    
    // MARK: Add pin on long press
    
    @objc func handleTap(gestureReconizer: UIGestureRecognizer) {
        if gestureReconizer.state == .began {
            let location = gestureReconizer.location(in: mapView)
            let coordinate = mapView.convert(location,toCoordinateFrom: mapView)
            let pin = Pin(context: dataController.viewContext)
            pin.latitude = coordinate.latitude
            pin.longitude = coordinate.longitude
            //print(coordinate.latitude)
            //print(coordinate.longitude)
            print(pin.latitude)
            print(pin.longitude)
            //try? dataController.viewContext.save()
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
            //selectedLatitude = coordinate.latitude
            //selectedLongitude = coordinate.longitude
            print(annotation.coordinate)
            mapView.addAnnotation(annotation)
            try? dataController.viewContext.save()
            pins.append(pin)
            mapView.reloadInputViews()//addAnnotation(annotation)
            //self.annotations.append(annotation)
            hideActivityIndicator()
            
        }
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
    
    // MARK: Segue to Photo Album on pin tap
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if isEditing, let viewAnnotation = view.annotation {
            //let pinToDelete = pin(at: IndexPath)
            //dataController.viewContext.delete(pinToDelete)
            mapView.removeAnnotation(viewAnnotation)
            //try? dataController.viewContext.save()
            return
        }
        let controller = storyboard?.instantiateViewController(withIdentifier: "PhotoAlbumViewController") as! PhotoAlbumViewController
        controller.lat = view.annotation?.coordinate.latitude ?? 0.0
        controller.lon = view.annotation?.coordinate.longitude ?? 0.0
        self.navigationController?.pushViewController(controller, animated: true)
    }
 
    // MARK: Edit button
    
    override func setEditing(_ editing:Bool, animated:Bool) {
        super.setEditing(editing, animated: animated)
        if (self.isEditing) {
            toolBar.isHidden = false
            deletePinsLabel.isHidden = false
            self.editButtonItem.title = "Done"
        } else {
            toolBar.isHidden = true
            deletePinsLabel.isHidden = true
            self.editButtonItem.title = "Edit"
        }
    }
    
}

