//
//  MoviesVC.swift
//  MOVIES
//
//  Created by AhmedSaeed on 1/1/20.
//  Copyright © 2020 none. All rights reserved.
//

import UIKit
import SDWebImage
import Alamofire
import SwiftyJSON
import RevealingSplashView
import CoreData


class MoviesVC: UIViewController , UICollectionViewDataSource , UICollectionViewDelegate {
   
    let MOVIE_URL_POP = "https://api.themoviedb.org/3/movie/popular?api_key=faa470bd22f3e292607925249e812532&language=en-US&page=1"
    
    let MOVIE_URL_TOPRATE = "https://api.themoviedb.org/3/movie/top_rated?api_key=faa470bd22f3e292607925249e812532&language=en-US&page=1"
    
    let imageStartLink = "https://image.tmdb.org/t/p/w185/"
    
    var ArrayOfMovieInfo:[Dictionary<String,Any>] = [Dictionary<String,Any>]()
    
    var arrayMovieFavourite:[NSManagedObject] = [NSManagedObject]()
  
    
    @IBOutlet weak var stackview: UIStackView!
    @IBOutlet weak var topRateBtn: UIButton!
    @IBOutlet weak var mostPopBtn: UIButton!
    @IBOutlet weak var collectionview: UICollectionView!
    @IBOutlet weak var navItem: UINavigationItem!
    
    var selectedImg :Int!
    var flag = 0
    var flageForFav = 0
 
    override func viewDidLoad()
    {
        super.viewDidLoad()
        collectionview.delegate = self
        collectionview.dataSource = self
        animation()
        navItem.title = "Most Populaer"
       registerCellOfCollectionView()
        
        
        if Reachability.isConnectedToNetwork ()
        {
            getMoviesData(url: MOVIE_URL_POP)
        }
        else{
            print("helooooooo")
            let alert = UIAlertController(title: "NoConnection", message: "This App Need The Enternet", preferredStyle: .alert)
            let connection = UIAlertAction(title: "ok", style: .cancel, handler: nil)
            alert.addAction(connection)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    
    //MARK: -MAKE ANIMATION
    /*****************************************/
    // MAKE animationmethod here:
    
    func animation()
    {
        //Initialize a revealing Splash with with the iconImage, the initial size and the background color
        let revealingSplashView = RevealingSplashView(iconImage: UIImage(named: "movies")!,iconInitialSize: CGSize(width: 70, height: 70), backgroundColor: UIColor(red:0, green:0, blue:0, alpha:1.0))
        
        self.view.addSubview(revealingSplashView)
        
        revealingSplashView.startAnimation(){
            
            print("Completed")
        }
    }
    
    
    //MARK: - API CALLING
    /***************************************************************/
    
    //Write the getmoviesdata method here:
    func getMoviesData(url:String)
    {
        Alamofire.request(url, method: .get).responseJSON { (response) in
            //print(response)
            
            if response.result.isSuccess{
                let JsonMoviesData:JSON = JSON(response.result.value!)
                self.updateMoviesData(json: JsonMoviesData)
            }
            else{
                print(response.result.error!)
            }
        }
        
    }
    
    //MARK: - JSON Parsing
    /***************************************************************/

    //Write the updateWeatherData method here:
    
    func updateMoviesData(json: JSON)
    {
        for i in json["results"].array!
        {
              if let x = i.dictionaryObject
              {
                    ArrayOfMovieInfo.append(x)
              }
        }
        collectionview.reloadData()
    }
    
    //MARK: - register Cell
    /***************************************************************/
    
    
    //Write the registercellofcolletioncview method here:
    

    func registerCellOfCollectionView()
    {
        
        var collectionViewFlowLayout:UICollectionViewFlowLayout!
        if collectionViewFlowLayout == nil
        {
            let numberOfItemPerRow :CGFloat = 2
            let minimunLineSpacing :CGFloat = 0
            let minimunInteritemSpacing :CGFloat = 0

            let width = (UIScreen.main.bounds.size.width / numberOfItemPerRow)
            let height = ((UIScreen.main.bounds.size.height - 170) / numberOfItemPerRow)
            
            
            collectionViewFlowLayout = UICollectionViewFlowLayout()
            collectionViewFlowLayout.itemSize = CGSize(width: width, height: height)
            collectionViewFlowLayout.scrollDirection = .vertical
            collectionViewFlowLayout.sectionInset = UIEdgeInsets.zero
            collectionViewFlowLayout.minimumLineSpacing = minimunLineSpacing
            collectionViewFlowLayout.minimumInteritemSpacing = minimunInteritemSpacing

            collectionview.setCollectionViewLayout(collectionViewFlowLayout, animated: true)
        }
    }
    
    
    //MARK: - MENUE TOGGLE
    /***************************************************************/
    
    //Write the updataDataFromMenuemethod here:
    
    func dropMenue()
    {
        if flag == 0
        {
            mostPopBtn.isHidden = false;
            topRateBtn.isHidden = false;
            flag = 1
        }else{
            mostPopBtn.isHidden = true;
            topRateBtn.isHidden = true;
            flag = 0 ;
        }
    }
 
    @IBAction func menueClickButton(_ sender: Any) {
        dropMenue()
    }
    
    
    
    
    @IBAction func mostPopBtnClick(_ sender: UIButton) {
        if sender.tag == 0{
            navItem.title = "Most Popular"
            ArrayOfMovieInfo.removeAll()
            getMoviesData(url: MOVIE_URL_POP)
            flag = 1
            dropMenue()
            
        }
        else if sender.tag == 1{
            navItem.title = "Top Rate"
            ArrayOfMovieInfo.removeAll()
            getMoviesData(url: MOVIE_URL_TOPRATE)
            flag = 1
            dropMenue()
        }
    }
    
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ArrayOfMovieInfo.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionview.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)as! CellMovieImage
        
        if let realimage = ArrayOfMovieInfo[indexPath.row]["poster_path"] as? String
        {
            cell.imageview.sd_setImage(with: URL(string: imageStartLink + realimage))
        }
        return cell
    }
    
    
    
 
  
    
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if Reachability.isConnectedToNetwork()
        {
            flag = 1
            dropMenue()
            selectedImg = indexPath.row
            
            flageForFav = fetchFavoutiteMovies(id:ArrayOfMovieInfo[indexPath.row]["id"]as! Int)
            print("flageForFav \(flageForFav)")
            
            performSegue(withIdentifier: "gotomoviesDescribtion", sender: self)
        }else{
            let alert = UIAlertController(title: "NoConnection", message: "This App Need The Enternet", preferredStyle: .alert)
            let connection = UIAlertAction(title: "ok", style: .cancel, handler: nil)
            alert.addAction(connection)
            
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gotomoviesDescribtion"
        {
            let distination = segue.destination as! MoviesDetailsVC
            distination.movieDetails = ArrayOfMovieInfo[selectedImg]
            distination.recivedFlag = flageForFav

        }
    }
    
    

    //MARK: -FETCHING
    /********************************/
    
    
    func fetchFavoutiteMovies(id : Int)->Int
    {
        var f = 0
        let delegate = UIApplication.shared.delegate as? AppDelegate
        let context = delegate?.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "MoviesCoreData")
        
        do {
            arrayMovieFavourite = try context!.fetch(fetchRequest)
            for i in arrayMovieFavourite
            {
                if let x = i.value(forKey: "id")
                {
                    if x as! Int == id
                    {
                        f = 1
                        break
                    }else{
                        f = 0
                    }
                }

            }
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
       
        return f
    }
    
    

}
