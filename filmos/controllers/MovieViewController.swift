//
//  MovieViewController.swift
//  filmos
//
//  Created by Arnaud DELLINGER on 07/12/2018.
//  Copyright © 2018 Arnaud DELLINGER. All rights reserved.
//

import UIKit
import YoutubeKit
import Kingfisher

class MovieViewController: UIViewController, YTSwiftyPlayerDelegate {
  
  var movie = Movie()
  var trailerPlayer: YTSwiftyPlayer?
  var isLiked = false
  
  @IBOutlet weak var moviePosterImageView: UIImageView!
  @IBOutlet weak var movieDetailsLabel: UILabel!
  @IBOutlet weak var movieTrailerView: UIView!
  @IBOutlet weak var movieSynopsisText: UITextView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      title: "",
      style: .plain,
      target: self,
      action: #selector(onToggleLikeMovie))
    
    navigationItem.title = movie.getTitle()
    movieSynopsisText.text = movie.getSynopsis()
    movieDetailsLabel.text = getMovieDetailsString()
    
    isLiked = BDD.isMovieLiked(movie.getId())
    updateRightBarLikeButtonText()
    
    let processor = RoundCornerImageProcessor(cornerRadius: 4)
    let posterURL = URL(string: movie.getPosterUrl())
    
    moviePosterImageView.kf.indicatorType = .activity
    moviePosterImageView.kf.setImage(
      with: posterURL,
      options: [.transition(.fade(0.2)), .processor(processor), .fromMemoryCacheOrRefresh]
    )
    
    if movie.getYoutubeKey() != "" {
      trailerPlayer = YTSwiftyPlayer(
        frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 240),
        playerVars: [.videoID(movie.getYoutubeKey())])
      
      trailerPlayer!.delegate = self
      movieTrailerView.addSubview(trailerPlayer!)
      trailerPlayer!.loadPlayer()
    }
    
    Analytics.trackScreen(screenName: Analytics.SCREEN_KEYS["MOVIE_DETAILS"]!)
  }
  
  func getMovieDetailsString() -> String {
    var details = ""
    
    details.append(movie.getReleaseDateString() + "\n")
    
    if movie.getIsAdult() {
      details.append("Film déconseillé aux plus jeunes")
    } else {
      details.append("Tout public")
    }
    
    if movie.getGenres().count > 0 {
      details.append("\n")
      details.append(movie.getGenresString())
    }
    
    return details
  }
  
  @objc func onToggleLikeMovie() {
    if isLiked {
      BDD.deleteFavorite(movie.getId())
    } else {
      BDD.insertFavorite(movie)
    }
    
    isLiked = !isLiked
    updateRightBarLikeButtonText()
  }
  
  func updateRightBarLikeButtonText() {
    navigationItem.rightBarButtonItem?.title = isLiked ? "Retirer" : "Aimer"
  }

}
