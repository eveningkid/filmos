//
//  SearchTableViewController.swift
//  filmos
//
//  Created by Arnaud DELLINGER on 07/12/2018.
//  Copyright © 2018 Arnaud DELLINGER. All rights reserved.
//

import UIKit
import Kingfisher
import TMDBSwift

class SearchTableViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {
  
  var resultSearchController: UISearchController!
  var movies: [Movie] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    resultSearchController = ({
      let controller = UISearchController(searchResultsController: nil)
      controller.searchResultsUpdater = self
      controller.dimsBackgroundDuringPresentation = false
      controller.hidesNavigationBarDuringPresentation = false
      
      controller.searchBar.placeholder = "Rechercher un film"
      controller.searchBar.sizeToFit()
      controller.searchBar.autocapitalizationType = .none
      controller.searchBar.delegate = self
      
      tableView.tableHeaderView = controller.searchBar
      
      definesPresentationContext = true
      extendedLayoutIncludesOpaqueBars = true
      
      return controller
    })()
    
    Analytics.trackScreen(screenName: Analytics.SCREEN_KEYS["SEARCH_MOVIES"]!)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    navigationController?.setNavigationBarHidden(true, animated: animated)
    super.viewWillAppear(animated)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    navigationController?.setNavigationBarHidden(false, animated: animated)
    super.viewWillDisappear(animated)
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return movies.count
  }
  
  func updateSearchResults(for searchController: UISearchController) {
  }
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    let keywords: String = searchBar.text!
    movies = []
    
    if keywords.count != 0 {
      API.search(query: keywords, page: 1) { data, movies in
        guard let searchedMovies = movies else {
          return
        }
        
        var newMovies: [Movie] = []
        
        for movie in searchedMovies {
          let formattedMovie = Movie.fromTMDBMovie(movie)
          newMovies.append(formattedMovie)
          
          MovieMDB.videos(
            movieID: formattedMovie.getId(),
            language: Configuration.MOVIE_API["LANGUAGE_CODE"]) { client, videos in
            if videos?.count != 0 {
              if let youtubeKey = videos![0].key {
                formattedMovie.setYoutubeKey(youtubeKey)
              }
            }
          }
        }
        
        self.movies = newMovies
        self.tableView.reloadData()
      }
    } else {
      tableView.reloadData()
    }
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: Configuration.IDENTIFIERS["MOVIE_CELL"]!, for: indexPath)
  
    let movie: Movie = self.movies[indexPath.row]
    cell.textLabel?.text = movie.getTitle()
    cell.detailTextLabel?.text = movie.getReleaseDateString()
    
    // let url = URL(string: movie.getPosterUrl())
    // let processor = CroppingImageProcessor(size: CGSize(width: 185, height: 185)) >> ResizingImageProcessor(referenceSize: CGSize(width: 150, height: 150))
    // cell.imageView?.kf.setImage(with: url, options: [.processor(processor)]) { image, error, cacheType, imageURL in
    // tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
    // }
    
    return cell
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let controller = segue.destination as? MovieViewController {
      if let currentIndexPath = tableView.indexPathForSelectedRow {
        controller.movie = movies[currentIndexPath.row]
      }
    }
  }
  
}
