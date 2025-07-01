//
//  AlertVC.swift
//  Newcast
//

import Cocoa

class AlertVC: NSViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do view setup here.
    view.wantsLayer = true
    view.layer?.backgroundColor = .clear
    view.layer?.cornerRadius = 4
  }
}
