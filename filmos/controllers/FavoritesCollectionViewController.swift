//
//  FavoritesCollectionViewController.swift
//  filmos
//
//  Created by Arnaud DELLINGER on 12/12/2018.
//  Copyright © 2018 Arnaud DELLINGER. All rights reserved.
//

import UIKit
import EmptyDataSet_Swift

class FavoritesCollectionViewController: UICollectionViewController, EmptyDataSetSource,  EmptyDataSetDelegate {
  
  var movies: [Movie] = []
  var currentItemTappedIndexPath: IndexPath!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Necessary when the stacked view shows a "back" item
    navigationItem.title = "Favoris"
    
    collectionView.emptyDataSetSource = self
    collectionView.emptyDataSetDelegate = self
    
    Analytics.trackScreen(screenName: Analytics.SCREEN_KEYS["FAVORITE_MOVIES"]!)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    // Hide the navigation bar as we only want it to appear when a movie is tapped
    navigationController?.setNavigationBarHidden(true, animated: animated)
    
    // Fetch local liked movies
    movies = BDD.likedMovies()
    
    super.viewWillAppear(animated)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    navigationController?.setNavigationBarHidden(false, animated: animated)
    super.viewWillDisappear(animated)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    collectionView.reloadData()
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let controller = segue.destination as? MovieViewController {
      if let currentIndexPath = currentItemTappedIndexPath {
        controller.movie = movies[currentIndexPath.row]
      }
    }
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return movies.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "favoriteCell", for: indexPath) as! FavoriteCollectionViewCell
    
    let movie = movies[indexPath.row]
    cell.setPoster(movie.getPosterUrl())
    
    let tap = UITapGestureRecognizer(target: self, action: #selector(onTapMovie))
    tap.numberOfTapsRequired = 1
    cell.addGestureRecognizer(tap)
    
    return cell
  }
  
  @objc func onTapMovie(sender: UITapGestureRecognizer) {
    let tapLocation = sender.location(in: collectionView)
    currentItemTappedIndexPath = collectionView.indexPathForItem(at: tapLocation)
    performSegue(withIdentifier: "movieDetailsSegue", sender: self)
  }
  
  
  // Data for empty list state: when to display, title, description and image
  
  func emptyDataSetShouldDisplay(_ scrollView: UIScrollView) -> Bool {
    return movies.count == 0
  }
  
  func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
    return NSAttributedString(string: "Aucun film favori")
  }
  
  func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
    return NSAttributedString(string: "Aimez un film pour le voir apparaître dans votre collection")
  }
  
  func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
    return nil
  }
  
}
