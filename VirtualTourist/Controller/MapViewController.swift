//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Sabrina on 5/29/19.
//  Copyright © 2019 Sabrina Svedin. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    // MARK: Outlets and Properties
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var deletePinsLabel: UILabel!
    
    var annotations = [MKPointAnnotation]()
    //var selectedPinCoordinate: CLLocationCoordinate2D!
    var selectedLatitude: Double = 0.0
    var selectedLongitude: Double = 0.0
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleTap))
        mapView.addGestureRecognizer(gestureRecognizer)
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.navigationItem.rightBarButtonItem!.title = "Edit"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mapView.deselectAnnotation(annotations as? MKAnnotation, animated: false)
    }
    
    // MARK: Add pin on long press
    
    @objc func handleTap(gestureReconizer: UIGestureRecognizer) {
        if gestureReconizer.state == .began {
            let location = gestureReconizer.location(in: mapView)
            let coordinate = mapView.convert(location,toCoordinateFrom: mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            selectedLatitude = coordinate.latitude
            selectedLongitude = coordinate.longitude
            self.annotations.append(annotation)
            mapView.addAnnotation(annotation as MKAnnotation)
            print(coordinate.latitude)
            print(coordinate.longitude)
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
        let annotation = MKPointAnnotation()
        annotation.coordinate.latitude = selectedLatitude
        annotation.coordinate.longitude = selectedLongitude
        if isEditing {
            mapView.removeAnnotation(annotation as MKAnnotation)
            return
        }
        let controller = storyboard?.instantiateViewController(withIdentifier: "PhotoAlbumViewController") as! PhotoAlbumViewController
        //controller.selectedPin = annotation.coordinate
        controller.lat = selectedLatitude
        controller.lon = selectedLongitude
        print(annotation.coordinate)
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

