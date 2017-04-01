//
//  MoviesViewController.swift
//  Flicks
//
//  Created by Mendoza, Alejandro on 3/30/17.
//  Copyright © 2017 Alejandro Mendoza. All rights reserved.
//

import UIKit
import AFNetworking

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var movies: [NSDictionary]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self

        // Do any additional setup after loading the view.
        
        let apiKey = "9d4c95bb11ea30dd2b02cdd51c9f782c"
        let url = URL(string:"https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        
        let request = URLRequest(url: url!)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        let task : URLSessionDataTask = session.dataTask(
            with: request as URLRequest,
            completionHandler: { (data, response, error) in
                if let data = data {
                    if let responseDictionary = try! JSONSerialization.jsonObject(
                        with: data, options:[]) as? NSDictionary {
                        print("responseDictionary: \(responseDictionary)")
                        
                        // Recall there are two fields in the response dictionary, 'meta' and 'response'.
                        // This is how we get the 'response' field
                        //let responseFieldDictionary = responseDictionary["response"] as! NSDictionary
                        self.movies = responseDictionary["results"] as! [NSDictionary]
                        self.tableView.reloadData()
                        
                        // This is where you will store the returned array of posts in your posts property
                        // self.feeds = responseFieldDictionary["posts"] as! [NSDictionary]
                    }
                }
        });
        task.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        
        let movie = movies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        let baseUrl = "https://image.tmdb.org/t/p/w500"
        
        
        if let posterPath = movie["poster_path"] as? String {
            
            let imageUrl = URL(string: baseUrl + posterPath)
            cell.posterView.setImageWith(imageUrl!)
        
        }
        
        cell.titleLabal.text = title
        cell.overviewLabel.text = overview
        
        
        print("row \(indexPath.row)")
        return cell
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPath(for: cell)
        let movie = movies![indexPath!.row]
        
        let detailViewController = segue.destination as! DetailViewController
        
        detailViewController.movie = movie
        
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
