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
import EmptyDataSet_Swift

class PopularTableViewController: UITableViewController, EmptyDataSetSource,  EmptyDataSetDelegate {
  
  var currentPage = 1
  var movies: [Movie] = []
  var filteredMovies = [Movie]()
  var hasConnectionError = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.title = "Populaires"
    
    tableView.tableFooterView = UIView()
    tableView.emptyDataSetSource = self
    tableView.emptyDataSetDelegate = self
    
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
    API.popular(page: currentPage, completion: onNewMovies(client:newMovies:))
  }
  
  func onNewMovies(client: ClientReturn, newMovies: [MovieMDB]?) {
    if (client.error != nil) {
      hasConnectionError = true
      tableView.reloadData()
      return
    } else {
      hasConnectionError = false
    }
    
    guard let movies = newMovies else {
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
    
    currentPage += 1
    
    tableView.reloadData()
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return movies.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: Configuration.IDENTIFIERS["MOVIE_CELL"]!, for: indexPath)
    
    let movie: Movie = movies[indexPath.row]
    let url = URL(string: movie.getPosterUrl())
    
    cell.textLabel?.text = movie.getTitle()
    cell.detailTextLabel?.text = movie.getReleaseDateString()
    
    let processor = ResizingImageProcessor(referenceSize: CGSize(width: 100, height: 150))

    cell.imageView?.kf.indicatorType = .activity
    cell.imageView?.kf.setImage(with: url, options: [.processor(processor)]) { image, error, cacheType, imageURL in
      cell.setNeedsLayout()
    }
    
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
  
  // Data for empty list state: when to display, title, description and image
  
  func emptyDataSetShouldDisplay(_ scrollView: UIScrollView) -> Bool {
    return hasConnectionError
  }
  
  func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
    return NSAttributedString(string: "Problème de connexion")
  }
  
  func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
    return NSAttributedString(string: "Un problème est survenu lors de la récupération des films. Veuillez vérifier votre connexion Internet.")
  }
  
  func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
    return nil
  }
  
  func buttonTitle(forEmptyDataSet scrollView: UIScrollView, for state: UIControl.State) -> NSAttributedString? {
    return NSAttributedString(string: "Réessayer")
  }
  
  func emptyDataSet(_ scrollView: UIScrollView, didTapButton button: UIButton) {
    fetchMoreMovies()
  }
  
}
