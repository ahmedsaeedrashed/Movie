//
//  MoviesFavVC.swift
//  MOVIES
//
//  Created by AhmedSaeed on 1/1/20.
//  Copyright © 2020 none. All rights reserved.
//

import UIKit
import CoreData
import  SDWebImage
import Alamofire
import SwiftyJSON

class MoviesFavVC: UIViewController , UICollectionViewDataSource , UICollectionViewDelegate{
    
    
  
    
    @IBOutlet weak var collectionview: UICollectionView!
    var arrayMovieFavourite:[NSManagedObject] = [NSManagedObject]()
    let imageStartLink = "https://image.tmdb.org/t/p/w185/"
    var DictionaryRec:[String:Any]=[String:Any]()
    var collectionViewFlowLayout:UICollectionViewFlowLayout!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Do any additional setup after loading the view.
        collectionview.delegate = self
        collectionview.dataSource = self
        registerCellOfCollectionView()
        title = "Movies"
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchFavoutiteMovies()
        
    }
    
    
    func fetchFavoutiteMovies()
    {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        let context = delegate?.persistentContainer.viewContext
        
        let fetching = NSFetchRequest<NSManagedObject>(entityName: "MoviesCoreData")
        
        do
        {
            let myfetching = try context!.fetch(fetching)
            arrayMovieFavourite = myfetching
        }
        catch
        {
            print("Errrorrrr")
        }
        collectionview.reloadData()
        
    }
    
    
    
    func registerCellOfCollectionView()
    {
        if collectionViewFlowLayout == nil
        {
            let numberOfItemPerRow :CGFloat = 2
            let minimunLineSpacing :CGFloat = 0
            let minimunInteritemSpacing :CGFloat = 0
            
            let width = (UIScreen.main.bounds.width / numberOfItemPerRow)
            let height = ((UIScreen.main.bounds.height-170) / numberOfItemPerRow)
            
            collectionViewFlowLayout = UICollectionViewFlowLayout()
            collectionViewFlowLayout.itemSize = CGSize(width: width, height: height)
            collectionViewFlowLayout.scrollDirection = .vertical
            collectionViewFlowLayout.sectionInset = UIEdgeInsets.zero
            collectionViewFlowLayout.minimumLineSpacing = minimunLineSpacing
            collectionViewFlowLayout.minimumInteritemSpacing = minimunInteritemSpacing
            collectionview.setCollectionViewLayout(collectionViewFlowLayout, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayMovieFavourite.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionview.dequeueReusableCell(withReuseIdentifier: "favcell", for: indexPath)as! CellMovieImage
        let realImage = arrayMovieFavourite[indexPath.row].value(forKey: "image")as? String
        cell.imageview.sd_setImage(with: URL(string: imageStartLink + realImage! ))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(arrayMovieFavourite[indexPath.row])
        performSegue(withIdentifier: "fromFav", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "fromFav"
        {
            let id = arrayMovieFavourite[0].value(forKey: "id") as! Int
            let image = arrayMovieFavourite[0].value(forKey: "image") as! String
            let overview = arrayMovieFavourite[0].value(forKey: "overview") as! String
            let rate = arrayMovieFavourite[0].value(forKey: "rate")as! Double
            let title = arrayMovieFavourite[0].value(forKey: "title") as! String
            let year = arrayMovieFavourite[0].value(forKey: "year") as! String
            
            let mytrailers = arrayMovieFavourite[0].value(forKey: "trailers") as! Data
            let trailers = try! JSONDecoder().decode([String].self, from: mytrailers)
            
            
            DictionaryRec["id"] = id
            DictionaryRec["poster_path"] = image
            DictionaryRec["overview"] = overview
            DictionaryRec["vote_average"] = rate
            DictionaryRec["title"] = title
            DictionaryRec["release_date"] = year
//            DictionaryRec["trailers"] = trailers
            

            
            let distination = segue.destination as! MoviesDetailsVC
            
            distination.movieDetails = DictionaryRec
            distination.ArrayOfMovieTrailer = trailers
            distination.recivedFlag = 1
            
            
        }
    }
    
    
    

}
