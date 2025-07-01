//
//  Episodes.swift
//  Newcast
//

import Cocoa

class Episodes {

  var title = ""
  var podcastDescription = ""
  var audioURL = ""
  var episodeDuration = ""
  var pubDate = Date()

  static let formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"

    return formatter
  }()
}
