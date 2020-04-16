//
//  MoviesDetailsVC.swift
//  MOVIES
//
//  Created by AhmedSaeed on 1/1/20.
//  Copyright © 2020 none. All rights reserved.
//

import UIKit
import Cosmos
import CircleProgressView
import Alamofire
import SwiftyJSON
import CoreData


class MoviesDetailsVC: UIViewController , UITableViewDataSource , UITableViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath)as! collectionVeiwCell
        cell.label.text = "\(indexPath.row)"
        
        return cell
        
    }
    
    
    
   
    var movieDetails:[String:Any] = [String: Any]()
    var movieFavourite:[NSManagedObject] = [NSManagedObject]()
    var ArrayOfMovieTrailer:[String] = [String]()
    var imageStartLink = "https://image.tmdb.org/t/p/w185/"
    var recivedFlag = 0
    
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var movTitle: UILabel!
    @IBOutlet weak var movImage: UIImageView!
    @IBOutlet weak var movOverView: UITextView!
    @IBOutlet weak var movReleaseYear: UILabel!
    @IBOutlet weak var cosmos: CosmosView!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var favouiteBut: UIButton!
    
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableview.dataSource = self
        tableview.delegate = self
        tableview.separatorStyle = .none
       
        cosmos.settings.fillMode = .precise
        fetchFavoutiteMovies()
      
        if(recivedFlag == 0)
        {
            favouiteBut.tag = 0
            favouiteBut.setImage(UIImage(named: "11.png"), for: .normal)
        }else{
            favouiteBut.tag = 1
            favouiteBut.setImage(UIImage(named: "00.png"), for: .normal)
        }

    }

    
    override func viewWillAppear(_ animated: Bool)
    {
        print(movieDetails["id"] as! Int)
        updateUI()
        getTrailersDetails(id:movieDetails["id"] as! Int)
        
    }
    
    
    
    // MARK: -REQUEST FOR TRAILERS
    /***************************************************************/
    
    //Write the requesForTraliers method here:
    
    func getTrailersDetails(id:Int)
    {
     
        let url = "https://api.themoviedb.org/3/movie/\(id)/videos?api_key=faa470bd22f3e292607925249e812532&language=en-US"
        Alamofire.request(url, method: .get).responseJSON { (response) in
            
            if response.result.isSuccess
            {
                let resultData:JSON = JSON(response.result.value!)
                self.updateMoviesTrailers(json: resultData)
            }else{
                print(response.result.error!)
            }
        }
    }
    
    // MARK: -REQUEST FOR TRAILERS
    /***************************************************************/
    
    //Write the requesForTraliers method here:
    
    func updateMoviesTrailers(json:JSON) {
        
        for i in json["results"].array!
        {
            if let x = i["key"].string
            {
                ArrayOfMovieTrailer.append(x)
            }
        }
      tableview.reloadData()
    }
    
    
    // MARK: -UPDATE UERINTERFACE
    /***************************************************************/
    
    //Write the UpdateUI method here:
    
    func updateUI()
    {
        if let realimage = movieDetails["poster_path"]as? String
        {
            backgroundImage.sd_setImage(with: URL(string: imageStartLink + realimage))
            backgroundImage.alpha = 0.222222222
        }
        movTitle.text = movieDetails["title"] as? String
        movOverView.text = movieDetails["overview"]as? String
        let x = movieDetails["release_date"]as? String
        let t = x!.split(separator: "-")
        movReleaseYear.text = String(t[0])
        if let realimage = movieDetails["poster_path"]as? String
        {
            movImage.sd_setImage(with: URL(string: imageStartLink + realimage))
        }
        cosmos.rating = (movieDetails["vote_average"] as! Double) / 2.0
    }
    
    
    @IBAction func bacClickButton(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    //MARK: - SELECT FAVOURUTE MOVIES
    /************************************************/
    
    @IBAction func didSelectFav(_ sender: UIButton)
    {
        if sender.tag == 0
        {
            sender.tag = 1
            sender.setImage(UIImage(named: "00.png"), for: .normal)
            saveFavouriteMovies()
        }else{
            sender.tag = 0
            sender.setImage(UIImage(named: "11.png"), for: .normal)
            deleteFavouriteMovies()
        }
    }
    
    
    
    func saveFavouriteMovies()
    {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        let context = delegate?.persistentContainer.viewContext // return   ns mange object context

        do{
            let Entity = NSEntityDescription.entity(forEntityName: "MoviesCoreData", in: context!)
            let movie = NSManagedObject(entity: Entity!, insertInto: context)
            
            
            
            if let realimage = movieDetails["poster_path"]as? String
            {
                movie.setValue(realimage, forKey: "image")
            }
            
            let title = movieDetails["title"] as? String
            movie.setValue(title, forKey: "title")
            
            
            let overview = movieDetails["overview"]as? String
            movie.setValue(overview, forKey: "overview")
            
            let year = movieDetails["release_date"]as? String
            movie.setValue(year, forKey: "year")
            
            
            let rating = (movieDetails["vote_average"] as! Double) / 2.0
            movie.setValue(rating, forKey: "rate")
            
            
            let id = movieDetails["id"] as! Int
            movie.setValue(id, forKey: "id")
            
            
            let arrayAsString = ArrayOfMovieTrailer.description
            let stringAsData:Data = arrayAsString.data(using: String.Encoding.utf16)!
            movie.setValue(stringAsData, forKey: "trailers")
    
            movieFavourite.append(movie)
            
            try! context?.save()
        
    }
        
        
}
    
    func deleteFavouriteMovies()
    {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        let context = delegate?.persistentContainer.viewContext
        
        context?.delete(movieFavourite[0])
        movieFavourite.remove(at: 0)
        
        try! context!.save()
        print( "move favaourite \( movieFavourite.count)")
        
    }
    
    
    
    func fetchFavoutiteMovies()
    {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        let context = delegate?.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "MoviesCoreData")
        
        do {
            movieFavourite = try context!.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
 
    }
    
    
    
    
    
    
    
    //MARK: -Trailers
    /******************************************/
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return ArrayOfMovieTrailer.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableview.dequeueReusableCell(withIdentifier: "mycell", for: indexPath)
        cell.imageView?.image = UIImage(named: "play.png")
        cell.textLabel?.text = "trailler \(indexPath.row + 1) "
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return "Trailers"
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let key = ArrayOfMovieTrailer[indexPath.row]
        let url = URL(string: "https://www.youtube.com/watch?v=\(key)")
        UIApplication.shared.open(url!, options: [:], completionHandler: nil)
    }
        
        
    
}
