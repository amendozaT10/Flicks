//
//  MoviesViewController.swift
//  Flicks
//
//  Created by Mendoza, Alejandro on 3/30/17.
//  Copyright © 2017 Alejandro Mendoza. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var networkIssueView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    var movies: [NSDictionary]?
    var filteredMovies: [NSDictionary]?
    
    var endpoint: String!
    var showSearchResults = false
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        searchBar.placeholder = "Search Movies Here!"
        searchBar.delegate = self
        
        

        // Do any additional setup after loading the view.
        let url = createURL()
        
        // Initialize a UIRefreshControl
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector (refreshControlAction(refreshControl:) ), for: UIControlEvents.valueChanged)
//        // add refresh control to table view
        tableView.insertSubview(refreshControl, at: 0)
        
    
        
        // Populate our array of dictionaries
        fetchMovies(url: url)
        
    }
    
    // Makes a network request to get updated data
    // Updates the tableView with the new data
    // Hides the RefreshControl
    func refreshControlAction(refreshControl: UIRefreshControl) {
        
        let url = createURL()
        
        // ... Create the URLRequest `myRequest` ...
        let request = URLRequest(url: url, timeoutInterval: 7)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate: nil,
            delegateQueue: OperationQueue.main)
        
        // Display HUD right before the request is made
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            // Hide HUD once the network request comes back (must be done on main UI thread)
            MBProgressHUD.hide(for: self.view, animated: true)
            
            // Reload the tableView now that there is new data
            self.fetchData(data: data, response: response, error: error)
            
            // Tell the refreshControl to stop spinning
            refreshControl.endRefreshing()
        }
        task.resume()
    }
    
    func createURL() -> URL {
        let apiKey = "9d4c95bb11ea30dd2b02cdd51c9f782c"
        let urlEndpoint = self.endpoint as String
        let urlString = "https://api.themoviedb.org/3/movie/\(urlEndpoint)?api_key=\(apiKey)"
        let url = URL(string: urlString)
        return url!
    }
    
    func fetchMovies(url: URL) {
        
        let request = URLRequest(url: url, timeoutInterval: 7)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        // Display HUD right before the request is made
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        let task : URLSessionDataTask = session.dataTask(
            with: request as URLRequest,
            completionHandler: { (data, response, error) in
                
                // Hide HUD once the network request comes back (must be done on main UI thread)
                MBProgressHUD.hide(for: self.view, animated: true)
                
                self.fetchData(data: data, response: response, error: error)
        });
        task.resume()
    }
    
    func fetchData( data: Data?, response: URLResponse?, error: Error?)
    {
        
        if let data = data {
            if let responseDictionary = try! JSONSerialization.jsonObject(
                with: data, options:[]) as? NSDictionary {
                
                // Recall there are two fields in the response dictionary, 'meta' and 'response'.
                // This is how we get the 'response' field
                //let responseFieldDictionary = responseDictionary["response"] as! NSDictionary
                self.movies = responseDictionary["results"] as! [NSDictionary]
                self.tableView.reloadData()
                
                // Hide network issue view when refresh call works
                self.networkIssueView.alpha = 0.0
            }
        } else if let error = error {
            self.networkIssueView.alpha = 1.0
            
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.contentInset.top = topLayoutGuide.length
        tableView.contentInset.bottom = bottomLayoutGuide.length
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = movies {
            if showSearchResults
            {
                return (filteredMovies?.count)!
            }
            else {
                return movies.count
            }
        } else {
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated:true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        
        if showSearchResults
        {
            let movie = filteredMovies![indexPath.row]
            let title = movie["title"] as! String
            let overview = movie["overview"] as! String
            let baseUrl = "https://image.tmdb.org/t/p/w500"
            
            
            if let posterPath = movie["poster_path"] as? String {
                
                let imageUrl = URL(string: baseUrl + posterPath)
                cell.posterView.setImageWith(imageUrl!)
                
            }
            
            cell.titleLabal.text = title
            cell.overviewLabel.text = overview
        }
        else
        {
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
        }
        
        return cell
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (showSearchResults)
        {
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPath(for: cell)
            let movie = filteredMovies![indexPath!.row]
            
            let detailViewController = segue.destination as! DetailViewController
            
            detailViewController.movie = movie
        }
        else
        {
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPath(for: cell)
            let movie = movies![indexPath!.row]
            
            let detailViewController = segue.destination as! DetailViewController
            
            detailViewController.movie = movie
        }
    }
    
    @IBAction func onTap(_ sender: Any) {
        
        searchBar.endEditing(true)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        showSearchResults = true
        searchBar.endEditing(true)
        self.tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.filteredMovies = self.movies?.filter({ (movieDict: NSDictionary) -> Bool in
            
            let movieTitle = movieDict["title"] as! String
            return movieTitle.lowercased().range(of: searchText, options: .caseInsensitive) != nil
        })
        
        if (searchText != "")
        {
            showSearchResults = true
            self.tableView.reloadData()
        }
        else
        {
            showSearchResults = false
            self.tableView.reloadData()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        searchBar.endEditing(true)
    }
    
    

}
