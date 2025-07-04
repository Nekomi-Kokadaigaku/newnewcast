//
//  DetailVC.swift
//  Newcast
//

import AVFoundation
import CircularProgress
import Cocoa
import SDWebImage

var seekToPosition: Float64!

class DetailVC: NSViewController {

  @IBOutlet weak var endTime: NSTextField!
  @IBOutlet weak var startTime: NSTextField!
  @IBOutlet weak var scrollingTextView: ScrollingTextView!
  @IBOutlet weak var playerInfo: NSTextField!
  @IBOutlet weak var playPauseButton: NSButton!
  @IBOutlet weak var skip30ForwardButton: NSButton!
  @IBOutlet weak var skip30BackButton: NSButton!
  @IBOutlet weak var playerSlider: NSSlider!
  @IBOutlet weak var episodesPlaceholderField: NSTextField!
  @IBOutlet weak var podcastImageView: SDAnimatedImageView!
  @IBOutlet weak var podcastTitleField: NSTextField!
  @IBOutlet weak var collectionView: NSCollectionView!
  @IBOutlet weak var playerCustomView: NSView!
  @IBOutlet weak var backgroundImageView: NSImageView!
  var playPauseCheck: Int! = 0
  let networkIndicator = NSProgressIndicator()
  let popoverView = NSPopover()
  let circularProgress = CircularProgress(size: 60)
  var deleted: Bool!
  var area: NSTrackingArea?

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do view setup here.

    collectionView.deselectAll(Any?.self)

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(updateTitle),
      name: .updateTitle,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(updateEpisodes),
      name: .updateEpisodes,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(deletedPodcast),
      name: .deletedPodcast,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(deletedPodcast),
      name: .updateUI,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(clearPodcastEpisodes),
      name: .clearPodcastEpisodes,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(moveSlider),
      name: .moveSlider,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(playPausePass),
      name: .playPausePass,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(hideUI),
      name: .hide,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(unhideUI),
      name: .unhide,
      object: nil
    )

    setupUI()
    playPauseCheck = 0
  }

  func setupUI() {

    view.insertVibrancyView(material: .hudWindow)
    area = NSTrackingArea.init(
      rect: podcastImageView.bounds,
      options: [.mouseEnteredAndExited, .activeAlways],
      owner: self,
      userInfo: nil
    )
    podcastImageView.addTrackingArea(area!)
    networkIndicator.style = .spinning
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.wantsLayer = true
    collectionView.layer?.cornerRadius = 8
    backgroundImageView.alphaValue = 0.6
    playerCustomView.wantsLayer = true
    playerCustomView.layer?.backgroundColor = CGColor.init(
      gray: 0.9,
      alpha: 0.2
    )
    playerCustomView.layer?.cornerRadius = 8
    playerCustomView.layer?.maskedCorners = [
      .layerMaxXMaxYCorner, .layerMaxXMinYCorner,
    ]
    podcastImageView.image = nil
    podcastImageView.wantsLayer = true
    podcastImageView.layer?.cornerRadius = 8
    podcastImageView.alphaValue = 0.9
    podcastImageView.layer?.maskedCorners = [
      .layerMaxXMaxYCorner, .layerMaxXMinYCorner,
    ]
    podcastTitleField.stringValue = ""
    episodesPlaceholderField.alphaValue = 0
    if playingIndex == nil {
      playerSlider.isHidden = true
      playPauseButton.isHidden = true
      skip30BackButton.isHidden = true
      skip30ForwardButton.isHidden = true
      startTime.stringValue = ""
      endTime.stringValue = ""
      scrollingTextView.setup(string: "")
    } else {
      podcastImageView.sd_setImage(
        with: URL(string: podcastsImageURL[podcastSelecetedIndex]),
        placeholderImage: NSImage(named: "placeholder"),
        options: .init(),
        context: nil
      )
      playPauseButton.image = NSImage(named: "pause")
      scrollingTextView.setup(
        string:
          "\(podcastsTitle[podcastSelecetedIndex]) — \(episodeTitles[playingIndex])"
      )
      scrollingTextView.speed = 5
      view.addSubview(scrollingTextView)
    }
    circularProgress.isIndeterminate = true
    //        circularProgress.color = NSColor.init(red: 0.39, green: 0.82, blue: 1.0, alpha: 0.9)
    circularProgress.color = .white
    let labelXPostion: CGFloat = 350
    let labelYPostion: CGFloat = 253
    let labelWidth: CGFloat = 60
    let labelHeight: CGFloat = 60
    circularProgress.frame = CGRect(
      x: labelXPostion,
      y: labelYPostion,
      width: labelWidth,
      height: labelHeight
    )
  }

  @objc func hideUI() {
    playerSlider.isHidden = true
    playPauseButton.isHidden = true
    skip30BackButton.isHidden = true
    skip30ForwardButton.isHidden = true
    //        playerInfo.stringValue = ""
  }
  @objc func unhideUI() {
    playerSlider.isHidden = false
    playPauseButton.isHidden = false
    skip30BackButton.isHidden = false
    skip30ForwardButton.isHidden = false
    podcastImageView.isHidden = false

  }
  @objc func moveSlider() {
    if playerDuration != nil && playerSeconds != nil {
      playerSlider.maxValue = Double(playerDuration)
      playerSlider.floatValue = playerSeconds

      if !(playerDuration.isNaN || playerDuration.isInfinite) {
        if (playerDuration) >= 3600 {
          endTime.stringValue =
            String(Int(Double(playerDuration) / 60) / 60) + ":"
            + String(format: "%02d", Int(Double(playerDuration) / 60) % 60)
            + ":"
            + String(
              format: "%02d",
              Int(Double(playerDuration).truncatingRemainder(dividingBy: 60))
            )
        } else {
          endTime.stringValue =
            String(Int(Double(playerDuration) / 60) % 60) + ":"
            + String(
              format: "%02d",
              Int(Double(playerDuration).truncatingRemainder(dividingBy: 60))
            )
        }
      }
      if Double(playerSeconds) >= 3600 {
        startTime.stringValue =
          String(Int(Double(playerSeconds) / 60) / 60) + ":"
          + String(format: "%02d", Int(Double(playerSeconds) / 60) % 60) + ":"
          + String(
            format: "%02d",
            Int(Double(playerSeconds).truncatingRemainder(dividingBy: 60))
          )
      } else {
        startTime.stringValue =
          String(Int(Double(playerSeconds) / 60) % 60) + ":"
          + String(
            format: "%02d",
            Int(Double(playerSeconds).truncatingRemainder(dividingBy: 60))
          )
      }

    }
    //        if playerSlider.doubleValue == Double(playerDuration){
    //            pauseCount = 0
    //            print("Hello")
    //            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "pauseButton"), object: nil)
    //            pauseCount = nil
    //        }

  }
  @IBAction func skip30AheadClicked(_ sender: Any) {
    playerSlider.doubleValue += 30
    if playerSlider.doubleValue <= playerSlider.maxValue {
      musicSliderPositionChanged(Any?.self)
    } else {
      playerSlider.doubleValue = playerSlider.maxValue
      musicSliderPositionChanged(Any?.self)
    }
  }

  @IBAction func skip30BehindClicked(_ sender: Any) {
    playerSlider.doubleValue -= 30
    if playerSlider.doubleValue >= 0 {
      musicSliderPositionChanged(Any?.self)
    } else {
      playerSlider.doubleValue = 0
      musicSliderPositionChanged(Any?.self)
    }
  }

  @IBAction func musicSliderPositionChanged(_ sender: Any) {
    test = playerSlider.doubleValue
    sliderStop = 0
    NotificationCenter.default.post(
      name: NSNotification.Name(rawValue: "sliderChanged"),
      object: nil
    )
  }

  @objc func playPausePass() {
    if playPauseButton.image?.name() == "play" {
      scrollingTextView.setup(
        string:
          "\(podcastsTitle[podcastSelecetedIndex]) — \(episodeTitles[playingIndex])"
      )
      scrollingTextView.speed = 4
      view.addSubview(scrollingTextView)
      playPauseButton.image = NSImage(named: "pause")
    } else {
      scrollingTextView.speed = 0
      scrollingTextView.setup(
        string:
          "\(podcastsTitle[currentSelectedPodcastIndex]) — \(episodeTitles[playingIndex] )"
      )
      playPauseButton.image = NSImage(named: "play")
    }
  }

  @IBAction func playPauseButtonClicked(_ sender: Any) {
    if playPauseButton.image?.name() == "play" {
      playCount = 0
      NotificationCenter.default.post(
        name: NSNotification.Name(rawValue: "playButton"),
        object: nil
      )
    } else {
      pauseCount = 0
      NotificationCenter.default.post(
        name: NSNotification.Name(rawValue: "pauseButton"),
        object: nil
      )
    }
  }
  func highlightItems(selected: Bool, atIndexPaths: Set<NSIndexPath>) {
    for indexPath in atIndexPaths {
      guard let item = collectionView.item(at: indexPath as IndexPath) else {
        continue
      }
      (item as! EpisodeCellView).setHighlight(selected: selected)
      if selected == true {
        (item as! EpisodeCellView).showButton(atIndexPaths: indexPath.item)
        NotificationCenter.default.post(
          name: NSNotification.Name(rawValue: "podcastChanged"),
          object: nil
        )
        unhideUI()
      }
      if selected == false {
        (item as! EpisodeCellView).hideButton(atIndexPaths: indexPath.item)
      }

    }
  }

  @objc func updateEpisodes() {

    collectionView.reloadData()
    //        networkIndicator.removeFromSuperview()
    circularProgress.removeFromSuperview()
    episodesPlaceholderField.alphaValue = 1.0
    collectionView.deselectAll(Any?.self)
    collectionView.reloadData()
  }
  @objc func updateTitle() {
    if playingIndex != nil {
      unhideUI()
    }

    podcastTitleField.stringValue = "\(podcastsTitle[podcastSelecetedIndex])"
    podcastImageView.sd_setImage(
      with: URL(string: podcastsImageURL[podcastSelecetedIndex]),
      placeholderImage: NSImage(named: "placeholder"),
      options: .init(),
      context: nil
    )
    collectionView.reloadData()
    //        networkIndicator.startAnimation(Any?.self)
    //        view.addSubview(networkIndicator)
    view.addSubview(circularProgress)
  }

  @objc func deletedPodcast() {
    collectionView.deselectAll(Any?.self)
    podcastImageView.image = nil
    podcastTitleField.stringValue = ""
    episodesPlaceholderField.alphaValue = 0
    playerSlider.isHidden = true
    playPauseButton.isHidden = true
    skip30BackButton.isHidden = true
    skip30ForwardButton.isHidden = true
    episodes.removeAll()
    collectionView.reloadData()
  }

  @objc func clearPodcastEpisodes() {
    collectionView.deselectAll(Any?.self)
    episodes.removeAll()
    collectionView.reloadData()

  }

  override func mouseEntered(with event: NSEvent) {
    displayPopUp()

  }

  override func mouseExited(with event: NSEvent) {
    if popoverView.isShown {
      popoverView.close()

    }
  }

  func displayPopUp() {
    //        print(podcastDescription)
    let storyboard = NSStoryboard(name: "Main", bundle: nil)
    guard
      let vc = storyboard.instantiateController(
        withIdentifier: "PodcastDescriptionVC"
      ) as? NSViewController
    else { return }
    popoverView.contentViewController = vc
    popoverView.behavior = .transient
    popoverView.show(
      relativeTo: podcastImageView.bounds,
      of: podcastImageView,
      preferredEdge: .maxX
    )
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

}

extension DetailVC: NSCollectionViewDelegate, NSCollectionViewDataSource,
  NSCollectionViewDelegateFlowLayout
{

  func collectionView(
    _ collectionView: NSCollectionView,
    itemForRepresentedObjectAt indexPath: IndexPath
  ) -> NSCollectionViewItem {

    let forecastItem = collectionView.makeItem(
      withIdentifier: NSUserInterfaceItemIdentifier(
        rawValue: "EpisodeCellView"
      ),
      for: indexPath
    )

    guard let forecastCell = forecastItem as? EpisodeCellView else {
      return forecastItem
    }
    forecastCell.configureEpisodeCell(episodeCell: episodes[indexPath.item])

    return forecastCell
  }

  func numberOfSections(in collectionView: NSCollectionView) -> Int {
    return 1
  }
  func collectionView(
    _ collectionView: NSCollectionView,
    numberOfItemsInSection section: Int
  ) -> Int {
    return episodes.count
  }

  func collectionView(
    _ collectionView: NSCollectionView,
    layout collectionViewLayout: NSCollectionViewLayout,
    sizeForItemAt indexPath: IndexPath
  ) -> NSSize {
    return NSSize(width: 680, height: 150)
  }
  func collectionView(
    _ collectionView: NSCollectionView,
    didSelectItemsAt indexPaths: Set<IndexPath>
  ) {
    highlightItems(selected: true, atIndexPaths: indexPaths as Set<NSIndexPath>)
  }
  func collectionView(
    _ collectionView: NSCollectionView,
    didDeselectItemsAt indexPaths: Set<IndexPath>
  ) {
    collectionView.deselectAll(Any?.self)
    highlightItems(
      selected: false,
      atIndexPaths: indexPaths as Set<NSIndexPath>
    )
  }

}
