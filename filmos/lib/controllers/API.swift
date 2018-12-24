//
//  API.swift
//  filmos
//
//  Created by Arnaud DELLINGER on 11/12/2018.
//  Copyright © 2018 Arnaud DELLINGER. All rights reserved.
//

import TMDBSwift

// Define our API communication schema
// TMDBSwift Wrapper

class API {
  
  static func initialize() {
    TMDBConfig.apikey = Configuration.MOVIE_API["KEY"]
  }
  
  static func popular(page: Int, completion: @escaping (ClientReturn, [MovieMDB]?) -> ()) {
    return MovieMDB.popular(
      language: Configuration.MOVIE_API["LANGUAGE_CODE"],
      page: page,
      completion: completion
    )
  }
  
  static func search(query: String, page: Int, completion: @escaping (ClientReturn, [MovieMDB]?) -> ()) {
    return SearchMDB.movie(
      query: query,
      language: Configuration.MOVIE_API["LANGUAGE_CODE"],
      page: page,
      includeAdult: false,
      year: nil,
      primaryReleaseYear: nil,
      completion: completion
    )
  }
  
  static func trailers(movieID: Int, completion: @escaping (ClientReturn, [VideosMDB]?) -> ()) {
    return MovieMDB.videos(
      movieID: movieID,
      language: Configuration.MOVIE_API["LANGUAGE_CODE"],
      completion: completion
    )
  }
  
}
