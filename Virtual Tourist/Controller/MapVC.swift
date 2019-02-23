//
//  MapVC.swift
//  Virtual Tourist
//
//  Created by Yousef Almassad on 20/02/2019.
//  Copyright © 2019 Yousef Almassad. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapVC: UIViewController, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var map: MKMapView!
    var fetchedResultsController:NSFetchedResultsController<Pin>!
    var selectedPin: Pin!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupPressGesture()
        fetchPins()
    }
    
    func deleteAllPins(){
        
        for pin in fetchedResultsController.fetchedObjects ?? [] {
            DataController.shared.viewContext.delete(pin)
        }
        try? DataController.shared.viewContext.save()
    }
    
    func fetchPins(){
        
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataController.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            
            try fetchedResultsController.performFetch()
            if let pins = fetchedResultsController.fetchedObjects{
                displayPinsOnMap(pins)
            }
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    fileprivate func displayPinsOnMap(_ pins: [Pin]) {
        for pin in pins {
            
            let cordination = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
            let pinAnnotaion = self.constructPin(pointCordination: cordination, pin: pin)
            map.addAnnotation(pinAnnotaion)
        }
    }
    
    func constructPin(pointCordination: CLLocationCoordinate2D, pin: Pin?) -> PinAnnotation{
        
        let latitude = pointCordination.latitude
        let longitude = pointCordination.longitude
        
        let pinA = PinAnnotation()
        pinA.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        guard let pin = pin else {
            pinA.pinObject = Pin(context: DataController.shared.viewContext)
            pinA.pinObject.latitude = latitude
            pinA.pinObject.longitude = longitude
            pinA.pinObject.createdAt = Date()
            return pinA
        }
        pinA.pinObject = pin
        
        return pinA
    }
    
    @objc func longPressSelector(_ gesture: UIGestureRecognizer){
      
        if gesture.state != .began {return}
        
        let pressedPoint = gesture.location(in: map)
        let pointCordination = map.convert(pressedPoint, toCoordinateFrom: map)
        let pinAnnotation = constructPin(pointCordination: pointCordination, pin: nil)

        try? DataController.shared.viewContext.save()
        map.addAnnotation(pinAnnotation)
    }
    
    fileprivate func setupPressGesture() {
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.longPressSelector(_:)))
        longPressRecognizer.minimumPressDuration = 0.5
        map.addGestureRecognizer(longPressRecognizer)
    }
    
    fileprivate func setupUI() {
        
        title = "Map"
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
        // Initial Coordinates for Saudi Arabia
        map.camera.centerCoordinate.latitude = 24.7
        map.camera.centerCoordinate.longitude = 46.68
        
        map.camera.altitude = 111111
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == Constant.segue {
            
            if segue.destination is CollectionVC {
                
                let collectionVC = segue.destination as! CollectionVC
                
                collectionVC.injectedPin = selectedPin
            }
        }
        
    }
    

}

extension MapVC: MKMapViewDelegate {
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if let annotation = annotation as? PinAnnotation {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
                dequeuedView.tintColor = .orange
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = false
            }
            
            return view
        }
        
        return nil
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        let annotation = (view.annotation) as! PinAnnotation
        
        if let pin = annotation.pinObject {
            selectedPin = pin
            performSegue(withIdentifier: Constant.segue, sender: self)
        }
        mapView.deselectAnnotation(annotation, animated: true)
    }
}
