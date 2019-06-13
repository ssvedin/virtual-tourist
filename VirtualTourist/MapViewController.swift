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
    
    let annotation = MKPointAnnotation()
    var photos = [Photo]()
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleTap))
        mapView.addGestureRecognizer(gestureRecognizer)
    }
    
    // MARK: Add pin on long press
    
    @objc func handleTap(gestureReconizer: UIGestureRecognizer) {
        if gestureReconizer.state == .began {
            let location = gestureReconizer.location(in: mapView)
            let coordinate = mapView.convert(location,toCoordinateFrom: mapView)
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
            print(coordinate)
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
        let controller = storyboard?.instantiateViewController(withIdentifier: "PhotoAlbumViewController") as! PhotoAlbumViewController
        controller.selectedPin = annotation.coordinate
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
}

