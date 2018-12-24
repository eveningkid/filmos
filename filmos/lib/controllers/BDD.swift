//
//  BDD.swift
//  filmos
//
//  Created by Arnaud DELLINGER on 12/12/2018.
//  Copyright © 2018 Arnaud DELLINGER. All rights reserved.
//

import SQLite

// Local SQLite database wrapper

class BDD {
  
  static let shared = BDD()
  
  var database: Connection!
  
  let favoritesTable = Table("favorites")
  let favoritesTmbdId = Expression<Int>("tmbdId")
  let favoritesTitle = Expression<String>("title")
  let favoritesSynopsis = Expression<String>("synopsis")
  let favoritesIsAdult = Expression<Bool>("isAdult")
  let favoritesGenres = Expression<String>("genres")
  let favoritesReleaseDate = Expression<Date>("releasedDate")
  let favoritesPosterUrl = Expression<String>("posterUrl")
  let favoritesYoutubeKey = Expression<String>("youtubeKey")
  
  private init() {
    do {
      let documentDirectory = try FileManager.default.url(
        for: .documentDirectory,
        in: .userDomainMask,
        appropriateFor: nil,
        create: true)
      
      let fileUrl = documentDirectory.appendingPathComponent("films").appendingPathExtension("sqlite3")
      database = try Connection(fileUrl.path)
      
      createTable()
    } catch {
      print(error)
    }
  }
  
  private func createTable() {
    let createTable = favoritesTable.create(ifNotExists: true) { table in
      let defaultMovie = Movie()
      table.column(favoritesTmbdId, primaryKey: true)
      table.column(favoritesTitle, defaultValue: defaultMovie.getTitle())
      table.column(favoritesSynopsis, defaultValue: defaultMovie.getSynopsis())
      table.column(favoritesIsAdult, defaultValue: defaultMovie.getIsAdult())
      table.column(favoritesGenres, defaultValue: defaultMovie.getGenresString())
      table.column(favoritesReleaseDate, defaultValue: defaultMovie.getReleaseDate())
      table.column(favoritesPosterUrl, defaultValue: defaultMovie.getPosterUrl())
      table.column(favoritesYoutubeKey, defaultValue: defaultMovie.getYoutubeKey())
    }
    
    do {
      try database.run(createTable)
    } catch {
      print("Error while creating database:", error)
    }
  }
  
  static func insertFavorite(_ movie: Movie) {
    let insertQuery = BDD.shared.favoritesTable.insert(
      BDD.shared.favoritesTmbdId <- movie.getId(),
      BDD.shared.favoritesTitle <- movie.getTitle(),
      BDD.shared.favoritesSynopsis <- movie.getSynopsis(),
      BDD.shared.favoritesIsAdult <- movie.getIsAdult(),
      BDD.shared.favoritesGenres <- movie.getGenresString(),
      BDD.shared.favoritesReleaseDate <- movie.getReleaseDate(),
      BDD.shared.favoritesPosterUrl <- movie.getPosterUrl(),
      BDD.shared.favoritesYoutubeKey <- movie.getYoutubeKey()
    )
    
    do {
      try BDD.shared.database.run(insertQuery)
    } catch {
      print("Error while inserting:", error)
    }
  }
  
  static func deleteFavorite(_ id: Int) {
    let deleteQuery = BDD.shared.favoritesTable.filter(BDD.shared.favoritesTmbdId == id)
    
    do {
      try BDD.shared.database.run(deleteQuery.delete())
    } catch {
      print("Error when deleting favorite:", error)
    }
  }
  
  static func isMovieLiked(_ id: Int) -> Bool {
    let countQuery = BDD.shared.favoritesTable.filter(BDD.shared.favoritesTmbdId == id)
    
    do {
      let count = try BDD.shared.database.scalar(countQuery.count)
      return count == 1
    } catch {
      print ("Error during isMovieLiked, for ID:", id, error)
      return false
    }
  }
  
  static func likedMovies() -> [Movie] {
    var movies: [Movie] = []
    
    do {
      let likes = try BDD.shared.database.prepare(BDD.shared.favoritesTable)
      
      for like in likes {
        var genres: [String] = []
        
        for genre in like[BDD.shared.favoritesGenres].split(separator: ",") {
          genres.append(String(genre))
        }
        
        let movie = Movie(
          tmdbId: like[BDD.shared.favoritesTmbdId],
          title: like[BDD.shared.favoritesTitle],
          synopsis: like[BDD.shared.favoritesSynopsis],
          isAdult: like[BDD.shared.favoritesIsAdult],
          genres: genres,
          releaseDate: like[BDD.shared.favoritesReleaseDate],
          posterUrl: like[BDD.shared.favoritesPosterUrl],
          youtubeKey: like[BDD.shared.favoritesYoutubeKey])
        
        movies.append(movie)
      }
    } catch {
      print("Error while fetching liked movies:", error)
    }
    
    return movies
  }
  
}
