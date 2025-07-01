//
//  Notification.swift
//  newnewCast
//
//  Created by Iris on 2025-07-01.
//

import Foundation

extension Notification.Name {
  static let updateTitle = Notification.Name("updateTitle")
  static let updateEpisodes = Notification.Name("updateEpisodes")
  static let deletedPodcast = Notification.Name("deletedPodcast")
  static let updateUI = Notification.Name("updateUI")
  static let clearPodcastEpisodes = Notification.Name("clearPodcastEpisodes")
  static let moveSlider = Notification.Name("moveSlider")
  static let playPausePass = Notification.Name("playPausePass")
  static let hide = Notification.Name("hide")
  static let unhide = Notification.Name("unhide")
  static let updateSearchUI = Notification.Name("updateSearchUI")
}
