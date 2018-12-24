//
//  Movie.swift
//  filmos
//
//  Created by Arnaud DELLINGER on 27/11/2018.
//  Copyright © 2018 Arnaud DELLINGER. All rights reserved.
//

import TMDBSwift

class Movie {
  
  private var tmdbId = 0
  private var title = "Sans titre"
  private var synopsis = "Aucun synopsis"
  private var releaseDate = Date()
  private var isAdult = false
  private var genres: [String] = []
  private var posterUrl = "https://i.stack.imgur.com/xJj2c.png?s=48&g=1"
  private var youtubeKey = ""
  
  // Convert TMDB date string to a Date instance
  static func convertTMDBReleaseDateToDate(_ releaseDate: String) -> Date {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "fr")
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.date(from: releaseDate)!
  }
  
  // Convert a MovieMDB instance to Movie
  // Useful as the API returns API-formatted movie instances
  static func fromTMDBMovie(_ movie: MovieMDB) -> Movie {
    let resultMovie = Movie()
    
    if let id = movie.id {
      resultMovie.setId(id)
    }
    
    if let title = movie.title {
      resultMovie.setTitle(title)
    }
    
    if let releaseDate = movie.release_date, releaseDate.count > 0 {
      resultMovie.setReleaseDate(releaseDate)
    }
    
    if let posterUrl = movie.poster_path {
      resultMovie.setPosterUrl(posterUrl)
    }
    
    if let synopsis = movie.overview {
      resultMovie.setSynopsis(synopsis)
    }
    
    if let isAdult = movie.adult {
      resultMovie.setIsAdult(isAdult)
      if isAdult {
        print(resultMovie.getTitle())
      }
    }
    
    var genres: [String] = []
    
    for genre in movie.genres {
      if let genreName = genre.name {
        genres.append(genreName)
      }
    }
    
    resultMovie.setGenres(genres)
    
    return resultMovie
  }
  
  init() {
  }
  
  init(
    tmdbId: Int,
    title: String,
    synopsis: String,
    isAdult: Bool,
    genres: [String],
    releaseDate: Date,
    posterUrl: String,
    youtubeKey: String
  ) {
    self.tmdbId = tmdbId
    self.title = title
    self.synopsis = synopsis
    self.isAdult = isAdult
    self.genres = genres
    self.releaseDate = releaseDate
    self.posterUrl = posterUrl
    self.youtubeKey = youtubeKey
  }
  
  func getId() -> Int {
    return tmdbId
  }
  
  func setId(_ tmdbId: Int) -> Void {
    self.tmdbId = tmdbId
  }
  
  func getTitle() -> String {
    return title
  }
  
  func setTitle(_ title: String) {
    self.title = title
  }
  
  func getSynopsis() -> String {
    return synopsis
  }
  
  func setSynopsis(_ synopsis: String) {
    self.synopsis = synopsis
  }
  
  func getIsAdult() -> Bool {
    return isAdult
  }
  
  func setIsAdult(_ isAdult: Bool) {
    self.isAdult = isAdult
  }
  
  func getGenres() -> [String] {
    return genres
  }
  
  func getGenresString() -> String {
    return getGenres().joined(separator: ",")
  }
  
  func setGenres(_ genres: [String]) {
    self.genres = genres
  }
  
  func getReleaseDate() -> Date {
    return releaseDate
  }
  
  func setReleaseDate(_ releaseDate: Date) {
    self.releaseDate = releaseDate
  }
  
  func setReleaseDate(_ releaseDate: String) {
    self.releaseDate = Movie.convertTMDBReleaseDateToDate(releaseDate)
  }
  
  func getReleaseDateString() -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "fr")
    formatter.dateFormat = "dd MMMM yyyy"
    return formatter.string(from: self.getReleaseDate())
  }
  
  func getPosterUrl() -> String {
    return posterUrl
  }
  
  func setPosterUrl(_ posterUrl: String) {
    self.posterUrl = "\(Configuration.MOVIE_API["POSTER_BASE_URL"]!)\(posterUrl)"
  }
  
  func getYoutubeKey() -> String {
    return youtubeKey
  }
  
  func setYoutubeKey(_ youtubeKey: String) {
    self.youtubeKey = youtubeKey
  }
  
}
