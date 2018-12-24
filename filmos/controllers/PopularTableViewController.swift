//
//  PopularTableViewController.swift
//  filmos
//
//  Created by Arnaud DELLINGER on 27/11/2018.
//  Copyright © 2018 Arnaud DELLINGER. All rights reserved.
//

import UIKit
import TMDBSwift
import Kingfisher

class PopularTableViewController: UITableViewController {
  
  var currentPage = 1
  var movies: [Movie] = []
  var filteredMovies = [Movie]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.title = "Films Récents"
    
    fetchMoreMovies()
    
    // First Screen: Configure analytics
    if Analytics.userConsent() == nil {
      present(Analytics.userConsentAlert(), animated: true)
    } else {
      Analytics.trackScreen(screenName: Analytics.SCREEN_KEYS["POPULAR_MOVIES"]!)
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    navigationController?.navigationBar.prefersLargeTitles = true
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    navigationController?.navigationBar.prefersLargeTitles = false
  }
  
  func fetchMoreMovies() {
    API.popular(page: currentPage, completion: onNewMovies(_:newMovies:))
    
    currentPage += 1
  }
  
  func onNewMovies(_: ClientReturn, newMovies: [MovieMDB]?) {
    guard let movies = newMovies else {
      print("Could not connect to API")
      return
    }
    
    for movie in movies {
      let formattedMovie = Movie.fromTMDBMovie(movie)
      self.movies.append(formattedMovie)
      
      API.trailers(movieID: formattedMovie.getId()) { client, videos in
        if videos?.count != 0 {
          if let youtubeKey = videos![0].key {
            formattedMovie.setYoutubeKey(youtubeKey)
          }
        }
      }
    }
    
    tableView.reloadData()
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return movies.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: Configuration.IDENTIFIERS["MOVIE_CELL"]!, for: indexPath)
    
    let movie: Movie = movies[indexPath.row]
    // let url = URL(string: movie.getPosterUrl())
    
    cell.textLabel?.text = movie.getTitle()
    cell.detailTextLabel?.text = movie.getReleaseDateString()
    
    // let processor = CroppingImageProcessor(size: CGSize(width: 185, height: 185)) >> ResizingImageProcessor(referenceSize: CGSize(width: 150, height: 150))
     
    // cell.imageView?.kf.setImage(with: url) { image, error, cacheType, imageURL in
    //   cell.imageView?.image = image
    //   tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
    // }
    
    return cell
  }
  
  // Cancel async image requests
  override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    let cell = tableView.dequeueReusableCell(withIdentifier: Configuration.IDENTIFIERS["MOVIE_CELL"]!)
    cell?.imageView?.kf.cancelDownloadTask()
  }
  
  // Enable infinite scrolling
  override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    // 100 => offset
    let endScrolling = scrollView.contentOffset.y + scrollView.frame.size.height + 100
    
    if (endScrolling >= scrollView.contentSize.height){
      fetchMoreMovies()
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let controller = segue.destination as? MovieViewController {
      if let currentIndex = tableView.indexPathForSelectedRow?.row {
        controller.movie = movies[currentIndex]
      }
    }
  }
  
}
