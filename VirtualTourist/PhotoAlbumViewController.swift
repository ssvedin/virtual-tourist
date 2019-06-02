//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Sabrina on 6/1/19.
//  Copyright © 2019 Sabrina Svedin. All rights reserved.
//

import UIKit
import MapKit

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var selectedPin: CLLocationCoordinate2D!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        showSlectedPin()
    }
    
    // MARK: Selected pin
    
    func showSlectedPin() {
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

}
