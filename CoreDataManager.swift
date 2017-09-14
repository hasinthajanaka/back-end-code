//
//  CoreDataManager.swift
//  Yaalu
//
//  Created by Platinum Lanka Pvt Ltd on 2/23/17.
//  Copyright © 2017 Platinum Lanka Pvt Ltd. All rights reserved.
//

import UIKit

class CoreDataManager: DataManager {
    
    static let sharedManager = CoreDataManager()
    
    let managedObjectContext = (UIApplication.shared.delegate
        as! AppDelegate).persistentContainer.viewContext
    
    func sync(completion:@escaping (_ result: Bool) -> Void) -> Void {
        let manager = ServiceManager()
        manager.getDataWithCompletion { (response: [AnyHashable : Any]?) in
           var (valid, result) =  self.validateAndGetResult(resultData: response as! Dictionary<String, Any>)
            
            var data = result as! Dictionary<String, Any>
            if valid {
                result = data["result"] as! Dictionary<String, Any>
                self.exctacResult(response: result as! Dictionary<String, Any>)
            }
            completion(true)
        }
    }
    
    // MARK: - Extract Data
    func exctacResult(response:Dictionary<String, Any>) {
        let blockUsers = response["userStatus"]
        self.syncBlockUsers(response: blockUsers as! Dictionary<String, Any>)
        print("Added Block users")
        
        let callerTunes = response["calllerTunes"]
        self.syncCallerTunes(response: callerTunes as! Dictionary<String, Any>)
        print("Added Caller Tunes")
        
        let wallpapers = response["wallpapers"]
        self.syncWallPapers(response: wallpapers as! Dictionary<String, Any>)
        print("Added Wall papers")
        
        let ringtone = response["ringtone"]
        self.syncRingTones(response: ringtone as! Dictionary<String, Any>)
        print("Added Ring Tones")
        
        let promotions = response["promotions"]
        self.syncPromotion(response: promotions as! Dictionary<String, Any>)
        print("Added Promotion")
        
        let lastUpdatedTime = response["last_updated_time"] as! Int?
       self.updateLastUpdateDate(response: lastUpdatedTime!)
         print("Update last update date")
    }
    
    func extractData(data:Dictionary<String, Any>) -> (Any, Any, Any) {
        let add = data["add"]
        let update = data["update"]
        let delete = data["delete"]
        
        return ((add as! NSArray), update as! NSArray, delete as! NSArray)
    }
    
    //MARK: - Common
    func inserEntity(entityName:String) -> NSManagedObject {
        let entity = NSEntityDescription.entity(forEntityName: entityName,
                                                in: managedObjectContext)!
        
        return NSManagedObject(entity: entity,
                               insertInto: managedObjectContext)
        
    }
    
    func fetchEntity(entityName:String, condition:String, arg:String) ->[Any]? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        if condition != "" {
            let predicate = NSPredicate(format: condition, arg)
            fetchRequest.predicate = predicate
        }
        

        
        do {
            return  try managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]
        } catch let error as NSError {
            // failure
            print("Error: \(error.debugDescription)")
            return nil

        }
        
    }
    
    func countEntity(entityName:String, condition:String, arg:String) ->Int{
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.includesSubentities = false
        
        if condition != "" {
            let predicate = NSPredicate(format: condition, arg)
            fetchRequest.predicate = predicate
        }
        
        return try! managedObjectContext.count(for: fetchRequest)
    }
    
    func save() -> Void {
        do {
            try managedObjectContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    //Mark:- Block Users
    func syncBlockUsers(response:Dictionary<String, Any>) {
        let (add, update, delete) = self.extractData(data: response)
        
        self.deleteBlockUsers(response: delete)
        self.updateBlockUsers(response: update)
        self.addBlockUsers(response: add)
    }
    
    func addBlockUsers(response:Any) {
        for item in (response as! NSArray) {
            let data = item as! NSDictionary
            
            let user = data["name"]
            
            
            let blockUser = self.inserEntity(entityName: "BlockUser") as! BlockUser
            
            blockUser.user = (user as! String).lowercased()
            
        }
        self.save()
    }
    
    func updateBlockUsers(response:Any) {
        for item in (response as! NSArray) {
            let data = item as! Dictionary<String, Any>
            
            let user = (data["name"] as! String).lowercased()
          
            
            
            var blockUser = self.inserEntity(entityName: "BlockUser") as? BlockUser
            
            
            blockUser?.user = user
            
            
        }
        self.save()
    }
    
    func deleteBlockUsers(response:Any) {
        
        for item in (response as! NSArray) {
            let data = item as! NSDictionary
            let id = data["id"] as! Int16
            let blockUser:BlockUser? = self.fetchEntity(entityName:"BlockUser", condition:"user = %@", arg:String(id))?.first as! BlockUser?
            if (blockUser != nil) {
                managedObjectContext.delete((blockUser)!)
            }
        }
        self.save()
    }
    
    func  blockUsers() -> Array<String> {
        let user = self.fetchEntity(entityName: "BlockUser", condition: "", arg: "") as! Array<BlockUser>
        return user.map{$0.user! }
    }
    

    
    // MARK: - Caller Tunes
    func syncCallerTunes(response:Dictionary<String, Any>) {
        let (add, update, delete) = self.extractData(data: response)
        
        self.deleteCallerTunes(response: delete)
        self.updateCallerTunes(response: update)
        self.addCallerTunes(response: add)
    }
    
    func addCallerTunes(response:Any) {
        for item in (response as! NSArray) {
            let data = item as! NSDictionary
            
            let id = data["id"]
            let name = data["name"];
            let singer = data["singer"];
            let status = data["status"];
            let url = data["stream_url"];
            let duration = data["duration"]
            let code = data["sms_format"]
            let send = data["send_to"]
            
            let callerTuner = self.inserEntity(entityName: "Callertune") as! Callertune
            
            callerTuner.id = id as! Int16
            callerTuner.name = name as! String?
            callerTuner.singer = singer as! String?
            callerTuner.status = status as! String?
            callerTuner.url = url as! String?
            callerTuner.duration = duration as! Int16
            callerTuner.song_code = code as! String?
            callerTuner.send = send as! Int16
        }
        self.save()
    }
    
    func updateCallerTunes(response:Any) {
        for item in (response as! NSArray) {
            let data = item as! Dictionary<String, Any>
            
            let id = data["id"] as! Int16
            let name = data["name"]
            let singer = data["singer"]
            let status = data["status"]
            let url = data["stream_url"]
            let duration = data["duration"]
            

            var callertune:Callertune? = self.fetchEntity(entityName:"Callertune", condition:"id = %@", arg:String(id))?.first as! Callertune?
            
            
            if callertune != nil {
                managedObjectContext.delete(callertune!)
            } else {
                callertune = self.inserEntity(entityName: "Callertune") as? Callertune
            }
            
            callertune?.id = id
            callertune?.name = name as! String?
            callertune?.singer = singer as! String?
            callertune?.status = status as! String?
            callertune?.url = url as! String?
            callertune?.duration = duration as! Int16
        
        }
        self.save()
    }
    
    func deleteCallerTunes(response:Any) {
        
        for item in (response as! NSArray) {
            let data = item as! NSDictionary
            let id = data["id"] as! Int16
            let callertune:Callertune? = self.fetchEntity(entityName:"Callertune", condition:"id = %@", arg:String(id))?.first as! Callertune?
            if (callertune != nil) {
                managedObjectContext.delete((callertune)!)
            }
        }
        self.save()
    }
    
    func  calerTunes() -> Array<Callertune> {
        return self.fetchEntity(entityName: "Callertune", condition: "", arg: "") as! Array<Callertune>
    }
    
    //MARK: - Wallpapers
    func syncWallPapers(response:Dictionary<String, Any>) {
        let (add, update, delete) = self.extractData(data: response)
        self.deleteWallPapers(response: delete)
        self.updateWallPapers(response: update)
        self.addWallPapers(response: add)
    }
    
    func addWallPapers(response:Any) {
        for item in (response as! NSArray) {
            let data = item as! NSDictionary
            
            let id = data["id"]
            let name = data["name"]
            let category = data["category_name"]
            let url = data["image_url"]
            
            let wallpaper = self.inserEntity(entityName: "Wallpaper") as! Wallpaper
            
            wallpaper.id = id as! Int16
            wallpaper.name = name as! String?
            wallpaper.categoryName = category as! String?
            wallpaper.url = url as! String?
        }
        self.save()
    }
    
    func updateWallPapers(response:Any) {
        for item in (response as! NSArray) {
            let data = item as! NSDictionary
            
            let id = data["id"] as! Int16
            let name = data["name"];
            let category = data["category_name"];
            let url = data["image_url"];
            
            var wallpaper:Wallpaper? = self.fetchEntity(entityName:"Wallpaper", condition:"id = %@", arg:String(id))?.first as! Wallpaper?
            if wallpaper != nil {
                managedObjectContext.delete((wallpaper)!)
            } else {
                wallpaper = self.inserEntity(entityName: "Wallpaper") as? Wallpaper
            }
            
            wallpaper?.id = id
            wallpaper?.name = name as! String?
            wallpaper?.categoryName = category as! String?
            wallpaper?.url = url as! String?
            
        }
        self.save()
    }
    
    func deleteWallPapers(response:Any) {
        for item in (response as! NSArray) {
            let data = item as! NSDictionary
            let id = data["id"] as! Int16
            let wallpaper:Wallpaper? = self.fetchEntity(entityName:"Wallpaper", condition:"id = %@", arg:String(id))?.first as! Wallpaper?
            if(wallpaper != nil) {
                managedObjectContext.delete((wallpaper)!)
            }
        }
        self.save()
    }
    
    func  wallpapers() -> Array<Wallpaper> {
        return self.fetchEntity(entityName: "Wallpaper", condition: "", arg: "") as! Array<Wallpaper>
    }
    
    func wallpapers(in category:String) ->Array<Wallpaper> {
        return self.fetchEntity(entityName: "Wallpaper", condition: "categoryName == %@", arg: category) as! Array<Wallpaper>
    }
    
    func wallpaperCount(in category:String) -> Int {
        if category == "" {
            return self.countEntity(entityName: "Wallpaper", condition: "", arg: "")
        } else {
            return self.countEntity(entityName: "Wallpaper", condition: "categoryName == %@", arg: category)
        }
    }
    
    func wallpaperCategoryCount(in categories:Array<String>) -> Array<String>{
        var count:Array<String> = []
        
        for item in categories {
            var value = 0
            if (item == "All") {
                value = self.wallpaperCount(in: "")
            } else {
                value = self.wallpaperCount(in: item)
            }
            
            if(value != 0) {
                let valueString = "\(item) (\(value))"
                count.append(valueString)
            } else {
                count.append(item)
            }
        }
        return count
    }
    
    //MARK: - Ring Tones
    func syncRingTones(response:Dictionary<String, Any>) {
        let (add, update, delete) = self.extractData(data: response)
        self.deleteRingTones(respons: delete)
        self.updateRingTones(response: update)
        self.addRingTones(response: add)
    }
    
    func addRingTones(response:Any) {
        for item in (response as! NSArray) {
            let data = item as! NSDictionary
            
            let id = data["id"]
            let name = data["name"]
            let singer = data["singer"]
            let status = data["status"]
            let duration = data["duration"]
            let url = data["stream_url"]
            
            let ringTone = self.inserEntity(entityName: "Ringtone") as! Ringtone
            
            ringTone.id = id as! Int16
            ringTone.name = name as! String?
            ringTone.singer = singer as! String?
            ringTone.status = status as! String?
            ringTone.url = url as! String?
            ringTone.duration = (duration as! Int16?)!
        }
        self.save()
    }
    
    func updateRingTones(response:Any) {
        for item in (response as! NSArray) {
            let data = item as! NSDictionary
            
            let id = data["id"] as! Int16
            let name = data["name"]
            let singer = data["singer"]
            let status = data["status"]
            let url = data["stream_url"]
            let duration = data["duration"]
            
            var ringTone:Ringtone? = self.fetchEntity(entityName:"Ringtone", condition:"id = %@", arg:String(id))?.first as! Ringtone?
           
            if ringTone != nil {
                managedObjectContext.delete(ringTone!)
            } else {
                ringTone = self.inserEntity(entityName: "Ringtone") as? Ringtone
            }
            
            ringTone?.id = id
            ringTone?.name = name as! String?
            ringTone?.singer = singer as! String?
            ringTone?.status = status as! String?
            ringTone?.url = url as! String?
            ringTone?.duration = (duration as! Int16?)!
        }
        self.save()
    }
    
    func deleteRingTones(respons:Any) {
        for item in (respons as! NSArray) {
            let data = item as! NSDictionary
            let id = data["id"] as! Int16
            let ringTone:Ringtone? = self.fetchEntity(entityName:"Ringtone", condition:"id = %@", arg:String(id))?.first as? Ringtone
            if(ringTone != nil) {
                managedObjectContext.delete(ringTone!)
            }
        }
        self.save()
    }
    
    public func RingingTones() -> Array<Ringtone> {
        return self.fetchEntity(entityName: "Ringtone", condition: "", arg: "") as! Array<Ringtone>
    }
    
    //MARK: - Promotion
    func syncPromotion(response:Dictionary<String, Any>) {
        let (add, update, delete) = self.extractData(data: response)
        self.deletePromotion(response: delete)
        self.updatePromotion(response: update)
        self.addPromotion(response: add)
    }
    
    func addPromotion(response:Any) {
        for item in (response as! NSArray) {
            let data = item as! NSDictionary
            
            let id = data["id"]
            let name = data["name"]
            let pageNo = data["page_no"]
            let descript = data["description"]
            let bannerImage = data["banner_image"]
            
            let promotion = self.inserEntity(entityName: "Promotion") as! Promotion
            
            promotion.id = id as! Int16
            promotion.name = name as! String?
            promotion.pageNo = pageNo as! String?
            promotion.descript = descript as! String?
            promotion.bannerImage = bannerImage as! String?
        }
        self.save()
    }
    
    func updatePromotion(response:Any) {
        for item in (response as! NSArray) {
            let data = item as! NSDictionary
            
            let id = data["id"] as! Int16
            let name = data["name"]
            let pageNo = data["page_no"]
            let status = data["status"]
            let bannerImage = data["banner_image"]
            let descript = data["description"]
            
            var promotion:Promotion? = self.fetchEntity(entityName:"Promotion", condition:"id = %@", arg:String(id))?.first as! Promotion?
            if(promotion != nil) {
                managedObjectContext.delete(promotion!)
            } else {
                promotion = self.inserEntity(entityName: "Promotion") as? Promotion
            }
            
            promotion?.id = id
            promotion?.name = name as! String?
            promotion?.pageNo = pageNo as! String?
            promotion?.bannerImage = bannerImage as! String?
            promotion?.status = status as! String?
            promotion?.descript = descript as! String?
          
        }
        self.save()
    }
    
    func deletePromotion(response:Any) {
        for item in (response as! NSArray) {
            let data = item as! NSDictionary
            let id = data["id"] as! Int16
            let promotion:Promotion? = self.fetchEntity(entityName:"Promotion", condition:"id = %@", arg:String(id))?.first as? Promotion
            if(promotion != nil) {
                managedObjectContext.delete(promotion!)
            }
        }
        self.save()
    }
    
    func  promotion(page:String) -> Array<Promotion> {
        return self.fetchEntity(entityName: "Promotion", condition: "pageNo == %@", arg: page) as! Array<Promotion>
    }
    
    func promotionForRingTone() -> Array<Promotion> {
        return promotion(page: "1")
    }
    
    func promotionForCallerTune() -> Array<Promotion> {
        return promotion(page: "2")
    }
    
    func promotionForWallpaper() -> Array<Promotion> {
        return promotion(page: "3")
    }
    
    func promotionForSms() -> Array<Promotion> {
        return promotion(page: "4")
    }
    
    //MARK: - lastdate
    func updateLastUpdateDate(response:Int) {
       Constants.sharedInstance.setLastUpdateDate(date: response)
    }
}
