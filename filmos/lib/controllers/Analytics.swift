//
//  Analytics.swift
//  filmos
//
//  Created by Arnaud DELLINGER on 18/12/2018.
//  Copyright © 2018 Arnaud DELLINGER. All rights reserved.
//

// Google Analytics Wrapper
// NOTE: GAI is a global variable, set from the obj-c bridging header
// cf. BridgingHeader.h

class Analytics {
  
  static let CONSENT_KEY = "analytics-consent"
  static var isInitialized = false
  
  static let SCREEN_KEYS = [
    "POPULAR_MOVIES": "PopularMovies",
    "SEARCH_MOVIES": "SearchMovies",
    "MOVIE_DETAILS": "MovieDetails",
    "FAVORITE_MOVIES": "FavoriteMovies"
  ]
  
  static func initialize() {
    if !isInitialized {
      isInitialized = true
      
      guard let analytics = GAI.sharedInstance() else {
        assert(false, "Google Analytics n'a pas été instancié correctement")
      }
      
      analytics.tracker(withTrackingId: Configuration.GOOGLE_ANALYTICS["TRACKING_ID"])
      analytics.trackUncaughtExceptions = true
    }
  }
  
  static func userConsentAlert() -> UIAlertController {
    let defaults = UserDefaults.standard
    
    let alert = UIAlertController(
      title: "Consentement d'analyse des données",
      message: "Filmos enregistre des données liées à votre appareil et votre utilisation de l'application. En acceptant, vous confirmez que nous pouvons utiliser ces informations pour améliorer votre expérience utilisateur.",
      preferredStyle: .alert)
    
    let acceptAction = UIAlertAction(
      title: "Accepter",
      style: .default,
      handler: { alert in
        defaults.set(true, forKey: CONSENT_KEY)
    })
    
    let refuseAction = UIAlertAction(
      title: "Refuser",
      style: .destructive,
      handler: { _ in
        defaults.set(false, forKey: CONSENT_KEY)
    }
    )
    
    alert.addAction(refuseAction)
    alert.addAction(acceptAction)
    
    return alert
  }
  
  static func userConsent() -> Bool? {
    let defaults = UserDefaults.standard
    
    if defaults.object(forKey: CONSENT_KEY) == nil {
      return nil
    }
    
    return defaults.bool(forKey: CONSENT_KEY)
  }
  
  static func trackScreen(screenName: String) {
    initialize()
    
    guard let tracker = GAI.sharedInstance().defaultTracker else { return }
    tracker.set(kGAIScreenName, value: screenName)
     
    guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
    tracker.send(builder.build() as [NSObject : AnyObject])
  }
  
}
