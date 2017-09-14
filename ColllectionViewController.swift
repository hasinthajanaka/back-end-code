//
//  WallpaperViewController.swift
//  Yaalu
//
//  Created by Platinum Lanka Pvt Ltd on 2/21/17.
//  Copyright © 2017 Platinum Lanka Pvt Ltd. All rights reserved.
//

import UIKit

class WallpaperViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, KASlideShowDataSource {
    
    
    @IBOutlet weak var menu: UIBarButtonItem!
    
    var wallpapers:Array<Wallpaper> = []
    
    var selectedWallpaper:Wallpaper? = nil
    
    var coreDataManager:CoreDataManager?
    
    @IBOutlet weak var promotion: KASlideShow!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var containerView: UIView!
    
    var promotionData:Array<Promotion> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if self.revealViewController() != nil {
            menu.target = self.revealViewController()
            menu.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        coreDataManager = CoreDataManager.sharedManager
        
        wallpapers = (coreDataManager?.wallpapers())!
        
        promotionData = (coreDataManager?.promotionForWallpaper())!
        
        setupNaviagtionView()
        
        promotion.datasource = self
        promotion.delay = 5
        promotion.transitionDuration = 0.5
        promotion.transitionType = KASlideShowTransitionType.fade
        promotion.imagesContentMode = UIViewContentMode.scaleAspectFill
    }
    
    override func viewWillAppear(_ animated: Bool) {
        promotion.start()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        promotion.stop()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupNaviagtionView() {
        let items:[String] = Constants.sharedInstance.getWallPaperCatagories() as! [String]
        let itemsWithCount = coreDataManager?.wallpaperCategoryCount(in: items)
        
        let rect = CGRect(
            origin: CGPoint(x: 0, y: 0),
            size:  CGSize(width: 220, height: 44)
        )
        
        let menuView = PFNavigationDropdownMenu(frame:rect, title: items.first, items: itemsWithCount, containerView: self.containerView)
        menuView?.cellBackgroundColor = Constants.sharedInstance.getNavBarColor()
        menuView?.cellTextLabelColor = UIColor.white
        menuView?.maskBackgroundColor = UIColor.white
        
        menuView?.didSelectItemAtIndexHandler = {(indexPath: UInt) -> Void in
           print(indexPath)
            let categoryName = items[Int(indexPath)]
            if( categoryName == "All") {
                self.wallpapers = (self.coreDataManager?.wallpapers())!
            } else {
                self.wallpapers = (self.coreDataManager?.wallpapers(in: categoryName))!
            }
            
            self.collectionView.reloadData()
        }
        
        navigationItem.titleView = menuView
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let detailWallpaer = segue.destination as! WallPaperDetailController
        detailWallpaer.wallpaper = selectedWallpaper
    }
    
    //MARK: UICollection Delegate and DataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return wallpapers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width:(self.view.frame.width - 10)/3, height: (self.view.frame.width - 10)/3)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let identifier = "ImageCell"
        
        let wallapaper = wallpapers[indexPath.row] 
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! WallpaperCell
        cell.wallpaper.sd_setImage(with: URL(string: wallapaper.url!), placeholderImage: UIImage(named: "gallery_placeholder_small"))
        return cell;
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedWallpaper = wallpapers[indexPath.row]
        
        let cell = collectionView.cellForItem(at: indexPath)
        self.performSegue(withIdentifier: "showWallpaperSegue", sender: cell)
    }
    
    // MARK: - KASlideShow Data Source
    func slideShow(_ slideShow: KASlideShow!, objectAt index: UInt) -> NSObject! {
        let promotion:Promotion = promotionData[Int(index)]
        return NSURL(string: promotion.bannerImage!)
    }
    
    func slideShowImagesNumber(_ slideShow: KASlideShow!) -> UInt {
        return UInt(Int(promotionData.count))
    }
}
