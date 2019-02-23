//
//  CollectionVC.swift
//  Virtual Tourist
//
//  Created by Yousef Almassad on 20/02/2019.
//  Copyright © 2019 Yousef Almassad. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class CollectionVC: UIViewController {

    @IBOutlet weak var albumCollection: UICollectionView!
    @IBOutlet weak var map: MKMapView!
    var fetchedResultsController:NSFetchedResultsController<Photo>!

    var injectedPin: Pin!
    var pageToLoad: Int = 1
    var URLs: [String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        fetchPhotos()
    }
    
    func loadNewPageOfPhotos(){
        
        Client.getPhoto(latitude: injectedPin.latitude, longitude: injectedPin.longitude, page: pageToLoad, invoker: self) { (stringURLs) in
            
            self.pageToLoad += 1
            self.URLs = stringURLs
            
            for url in self.URLs! {
                self.savePhoto(url: url)
            }
            try? DataController.shared.viewContext.save()
        }
    }
    
    
    func fetchPhotos(){
        
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let predicate = NSPredicate(format: "pin == %@", injectedPin)
        fetchRequest.predicate = predicate
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataController.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            
            if fetchedResultsController.fetchedObjects?.count == 0 {
                self.loadNewPageOfPhotos()
            }
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    func deleteCurrentPhotos(currentPhotos: [Photo]?){
        
        if let photos = currentPhotos {
            for  photo in photos {
                DataController.shared.viewContext.delete(photo)
            }
        }
        try? DataController.shared.viewContext.save()
    }
    
    func savePhoto(url: String){
        
        let photo = Photo(context: DataController.shared.viewContext)
        
        photo.createdAt = Date()
        photo.imageURL = url
        photo.pin = injectedPin
    }
    
    
    func setMapRegion(){
      
        //Zooming in on region
        let coordinate:CLLocationCoordinate2D = CLLocationCoordinate2DMake(injectedPin.latitude, injectedPin.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        map.setRegion(region, animated: true)
        
        let annotation = PinAnnotation(pin: injectedPin)
        annotation.coordinate = coordinate
        map.addAnnotation(annotation)
    }
    
    @IBAction func newCollectionButtenPressed(_ sender: Any) {


        deleteCurrentPhotos(currentPhotos: fetchedResultsController.fetchedObjects)

        self.loadNewPageOfPhotos()
        self.pageToLoad += 1
    }
    
    func setupUI(){
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        setMapRegion()
    }
    
}

extension CollectionVC: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let photo = fetchedResultsController.object(at: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.reuserID, for: indexPath) as! PhotoCell
        
        cell.photo = photo
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return fetchedResultsController?.fetchedObjects?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let photoToBeDeleted = fetchedResultsController.object(at: indexPath)
        DataController.shared.viewContext.delete(photoToBeDeleted)
        try? DataController.shared.viewContext.save()
    }
    
}

extension CollectionVC: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            albumCollection.reloadData()
        case .delete:
            albumCollection.reloadData()

        default:
            break
        }
    }
    
}

extension CollectionVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 40) / 3
        return CGSize(width: width, height: width)
    }
}
