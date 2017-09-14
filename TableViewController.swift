//
//  RingToneViewController.swift
//  Yaalu
//
//  Created by Platinum Lanka Pvt Ltd on 2/21/17.
//  Copyright © 2017 Platinum Lanka Pvt Ltd. All rights reserved.
//
import UIKit
import AVFoundation


class RingToneViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, KASlideShowDataSource, AudioPlayerManagerDelegate, SWRevealViewControllerDelegate {
    
    @IBOutlet weak var menu: UIBarButtonItem!
    
    var ringtones:Array<Ringtone> = []
    
    var fileredRingTones:Array<Ringtone> = []
    
    var selectedRingTone:Ringtone? = nil
    
    var selectedRow = -1
    
    var playing = false
    
    var searchActive = false
    
    let audioPlayManager = AudioPlayManager.sharedManager

    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var songTitle: UILabel!
    
    @IBOutlet weak var singer: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var promotion: KASlideShow!
    
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var previousButton: UIButton!
    
    var promotionData:Array<Promotion> = []
    
    var timer: Timer?
    
    // Progress View
    let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
    var strLabel = UILabel()
    
    var activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            menu.target = self.revealViewController()
            menu.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            revealViewController().delegate = self
        }
        
        let manager = CoreDataManager.sharedManager
        
//        CoreDataManager.sharedManager.sync { (completion:Bool) in
//            self.ringtones = manager.RingingTones()
//            self.promotionData = manager.promotionForRingTone()
//            self.tableView.reloadData()
//            self.promotion.reloadData()
//        }
        
        ringtones = manager.RingingTones()
        promotionData = manager.promotionForRingTone()
        
        self.navigationItem.title = "Ringtones"
        self.navigationController?.navigationBar.titleTextAttributes =  [NSForegroundColorAttributeName: UIColor.white]
        
        promotion.datasource = self
        promotion.delay = 5
        promotion.transitionDuration = 0.5
        promotion.transitionType = KASlideShowTransitionType.fade
        promotion.imagesContentMode = UIViewContentMode.scaleAspectFill
        
        audioPlayManager.mDelegate = self
        
        playButton.isEnabled = true
    }

    override func viewWillAppear(_ animated: Bool) {
        promotion.start()
        
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        promotion.stop()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - SWRevealViewControllerDelegate
    func revealController(_ revealController: SWRevealViewController!, willMoveTo position: FrontViewPosition) {
        
       self.audioPlayManager.stop()
    }
    
    //MARK: - Tableview datasource and delegate
    private func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchActive {
            return fileredRingTones.count
        } else {
            return ringtones.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "RingToneCell"
        
        var ringTone:Ringtone? =  nil
        
        if searchActive {
            ringTone = fileredRingTones[indexPath.row]
        } else {
            ringTone = ringtones[indexPath.row]
        }
        
        let cell:RingToneCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! RingToneCell
        
        cell.title.text = ringTone?.name
        cell.albumTitle.text = ringTone?.singer
        cell.duration.text = Utility.shared.secToMin(val: (ringTone?.duration)!)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(!self.ringtones.isEmpty) {
            
            if !self.playButton.isEnabled {
                self.playButton.isEnabled = true
            }
            
            selectedRow = indexPath.row
            self.endAudio(isPlaying: playing)
            
            if searchActive {
                if(!fileredRingTones.isEmpty) {
                    selectedRingTone = fileredRingTones[indexPath.row]
                }
            } else {
                selectedRingTone = ringtones[indexPath.row]
            }
            
            selectedRingTone = ringtones[selectedRow]
            songTitle.text = selectedRingTone?.name
            singer.text = selectedRingTone?.singer
            
            if playing == false {
                self.playAudio()
            } else {
                endAudio(isPlaying: playing)
            }
            
            self.changeStatusOfPlayerControl()
        }

    }
    
    //MARK: - Events
    @IBAction func tappedPlayButton(_ sender: UIButton) {
        
        if(!self.ringtones.isEmpty) {
            
            if(selectedRow < 0) {
                selectedRow = 0
                selectedRingTone = ringtones[selectedRow]
                self.select(row: selectedRow)
            }
            
            if playing == false {
                self.playAudio()
            } else {
                endAudio(isPlaying: playing)
            }
            
            self.changeStatusOfPlayerControl()
        }
    }
    
    func updateProgressView() -> Void {
        let timeInterval: TimeInterval = self.audioPlayManager.currentTime()
        let progress = Float(timeInterval) / Float((selectedRingTone?.duration)!)
        
        var animate:Bool = true
        
        if progress == 0 {
            animate = false
        }
        
        self.progressView?.setProgress(progress, animated: animate)
        
        if(self.progressView.progress > 0.01 && self.progressView.progress < 0.03) {
             self.effectView.removeFromSuperview()
        }
        
        if(self.progressView.progress >= 1.0) {
            playButton.setImage(UIImage(named:"btn_play"), for: .normal)
        }
    }
    
    @IBAction func tapedPrevButton(_ sender: Any) {
        
        if(!ringtones.isEmpty) {
            
            let shouldPlay = self.playing
            
            self.endAudio(isPlaying: playing)
            
            self.selectedRow = self.selectedRow - 1
            
            self.select(row: self.selectedRow)
            
            if(shouldPlay) {
                self.playAudio()
            }
            
            self.changeStatusOfPlayerControl()
        }
    }
    
    func playAudio() {
        playButton.setImage(UIImage(named:"btn_pause"), for: .normal)
        
       
        self.progressView.progress = 0
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        
        if(!delegate.isReachable) {
            self.present(Utility.shared.dialogBox(Title: "Alert", Message: "Internet not available. Please enable internet and try again.."),
                         animated: true,
                         completion: nil)
            return
            
        } else {
            activityIndicator("Buffering ringtone...")
            
            DispatchQueue.global(qos: .background).async {
                
                self.audioPlayManager.setup(urlString: (self.selectedRingTone?.url)!, duration: Int((self.selectedRingTone?.duration)!), progressView: self.progressView)
                self.audioPlayManager.play()
                
                self.playing = true
                DispatchQueue.main.async {
                    
                    self.timer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(self.updateProgressView), userInfo: nil, repeats: true)
                }
            }
        }
    }
    
    @IBAction func tapedNextButton(_ sender: Any) {

        let shouldPlay = self.playing
        
        self.endAudio(isPlaying: playing)
        
        self.selectedRow = self.selectedRow + 1
       
        self.select(row: self.selectedRow)
        
        if(shouldPlay) {
            self.playAudio()
        }
        
        self.changeStatusOfPlayerControl()
    }
    
    // MARK: AudioPlayerManagerDelegate
    func playerDidFinishedPlaying(player: AVAudioPlayer, succfully: Bool) {
        playing = false
        self.endAudio(isPlaying: playing)
    }
    
    func endAudio(isPlaying:Bool) {
        DispatchQueue.global(qos: .background).async {
            
            DispatchQueue.main.async {
                self.progressView.setProgress(0.0, animated: false)
            }
        }

        playButton.setImage(UIImage(named:"btn_play"), for: .normal)
        if playing == true {
            audioPlayManager.stop()
            playing = false
        }
        
        self.progressView.progress = 0
    }

    @IBAction func download(_ sender: Any) {
        var url = ""
        
        if(self.selectedRingTone != nil) {
            url = (self.selectedRingTone?.url)!
        }
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        
        if(!delegate.isReachable) {
            self.present(Utility.shared.dialogBox(Title: "Alert", Message: "Internet not available. Please enable internet and try again.."),
                         animated: true,
                         completion: nil)
            return
            
        } else {
            audioPlayManager.download(Url: url, completion: { (result:Bool, message: String) in
                if result {
                    
                    if(message == "") {
                        self.present(Utility.shared.dialogBox(Title: Dialog.DownloadSuccess.title, Message: Dialog.DownloadSuccess.message),
                                     animated: true,
                                     completion: nil)
                    } else {
                        self.present(Utility.shared.dialogBox(Title: Dialog.DownloadSuccess.title, Message: message),
                                     animated: true,
                                     completion: nil)
                    }
                    
                } else {
                    
                    if(message == "") {
                        self.present(Utility.shared.dialogBox(Title: Dialog.DownloadError.title, Message: Dialog.DownloadError.message),
                                     animated: true,
                                     completion: nil)
                    } else {
                        self.present(Utility.shared.dialogBox(Title: Dialog.DownloadError.title, Message: message),
                                     animated: true,
                                     completion: nil)
                    }
                }
            })
        }
    }
    
    // MARK: - Search Bar delegate
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
        searchBar.resignFirstResponder()
        tableView.reloadData()
        
        searchBar.text = ""
        searchBar.showsCancelButton = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        self.fileredRingTones = self.ringtones.filter({( tone: Ringtone) -> Bool in
            return tone.name!.lowercased().range(of: searchText.lowercased()) != nil
        })
 
        if(ringtones.count == 0){
            searchActive = false;
        } else {
            searchActive = true;
        }
        self.tableView.reloadData()
    }
    
    // MARK: - KASlideShow Data Source
    func slideShow(_ slideShow: KASlideShow!, objectAt index: UInt) -> NSObject! {
        
        let promotion:Promotion = promotionData[Int(index)]
        return NSURL(string: promotion.bannerImage!)
    }
    
    func slideShowImagesNumber(_ slideShow: KASlideShow!) -> UInt {
        return UInt(Int(promotionData.count))
    }
    
    func changeStatusOfPlayerControl() {
        
        if !self.playButton.isEnabled {
            self.playButton.isEnabled = true
            
        }
        
        if(self.selectedRow == (ringtones.count - 1)) {
            self.nextButton.isEnabled = false
        } else {
            self.nextButton.isEnabled = true
        }
        
        if(self.selectedRow == 0) {
            self.previousButton.isEnabled = false
        } else {
            self.previousButton.isEnabled = true
        }
    }
    
    func select(row index:Int) {
        let path = IndexPath(row: index, section: 0)
        
        tableView(tableView, didSelectRowAt: path)
        
        tableView.selectRow(at: path, animated: true, scrollPosition: UITableViewScrollPosition.none)
        
        tableView.scrollToRow(at: path, at: UITableViewScrollPosition.top, animated: true)
    }
    
    func activityIndicator(_ title: String) {
        
        strLabel.removeFromSuperview()
        activityIndicator.removeFromSuperview()
        effectView.removeFromSuperview()
        
        strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 240, height: 46))
        strLabel.text = title
        strLabel.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightMedium)
        strLabel.textColor = UIColor(white: 0.9, alpha: 0.7)
        
        effectView.frame = CGRect(x: view.frame.midX - strLabel.frame.width/2, y: view.frame.height/3  , width: 240, height: 46)
        effectView.layer.cornerRadius = 15
        effectView.layer.masksToBounds = true
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 46, height: 46)
        activityIndicator.startAnimating()
        
        effectView.addSubview(activityIndicator)
        effectView.addSubview(strLabel)
        view.addSubview(effectView)
    }
}


