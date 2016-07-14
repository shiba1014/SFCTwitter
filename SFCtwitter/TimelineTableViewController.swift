//
//  TimelineTableViewController.swift
//  SFCtwitter
//
//  Created by Paul McCartney on 2016/07/11.
//  Copyright © 2016年 shiba. All rights reserved.
//

import UIKit
import Social
import TwitterKit
import SwiftyJSON

class TimelineTableViewController: UITableViewController {
    
    var tweetArray: [JSON] = []
    var queryHashtag: String = ""
    var className: String = ""
    var indicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        let nib:UINib = UINib.init(nibName: "TweetCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "TweetCell")
        
        indicator  = UIActivityIndicatorView()
        indicator.frame = CGRectMake(0, 0, 50, 50)
        indicator.center = self.view.center
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.White
        indicator.addSubview(self.view)
        indicator.startAnimating()
        getSchedule()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tappedTwitter() {
        let cv = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        cv.setInitialText(queryHashtag)
        self.presentViewController(cv, animated: true, completion: nil)
    }
    
    func getTimeline() {
        let url = "https://api.twitter.com/1.1/search/tweets.json"
        let params = [
            "q": queryHashtag + " exclude:retweets ",
            "lang": "ja",
            "count": "100",
            ]
        
        let request = TWTRAPIClient().URLRequestWithMethod("GET", URL: url, parameters: params, error: nil)
        TWTRAPIClient().sendTwitterRequest(request, completion: {
            response, data, err in
            if err == nil {
                let json = JSON(data: data!)
                for tweet in json["statuses"].array! {
                    self.tweetArray.append(tweet)
                }
                
                self.tableView.reloadData()
            } else {
                print(err)
            }
            self.indicator.stopAnimating()
        })
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tweetArray.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TweetCell", forIndexPath: indexPath) as! TweetCell
        let tweet = tweetArray[indexPath.row]
        cell.usernameLabel?.text = tweet["user"]["name"].string
        cell.userIdLabel?.text = "@" + tweet["user"]["screen_name"].string!
        cell.tweetLabel?.text = tweet["text"].string
        let profileImageURL = tweet["user"]["profile_image_url"].string
        let url = NSURL(string: profileImageURL!)
        let req = NSURLRequest(URL: url!)
        NSURLConnection.sendAsynchronousRequest(req, queue: NSOperationQueue.mainQueue()){(res,data,err) in
            let profileImage = UIImage(data:data!)
            cell.profileImageView?.image = profileImage
        }
        cell.layoutIfNeeded()
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(className == ""){
            return "現在の授業：なし #SFC"
        }
        return "現在の授業：" + className + " " + queryHashtag
    }
 
    func getSchedule() {
        let date: NSDate = NSDate()
        let cal: NSCalendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
        let comp: NSDateComponents = cal.components(
            [NSCalendarUnit.Weekday],
            fromDate: date
        )
        let weekday: Int = comp.weekday
        let weekdaySymbolIndex: Int = weekday - 1
        let formatter: NSDateFormatter = NSDateFormatter()
        
        formatter.locale = NSLocale(localeIdentifier: "ja")
        
        var schedule = formatter.shortWeekdaySymbols[weekdaySymbolIndex]
        print(schedule)
        
        let firstStart = cal.dateBySettingHour(9, minute: 25, second: 0, ofDate: date, options: NSCalendarOptions())!
        let secondStart = cal.dateBySettingHour(11, minute: 10, second: 0, ofDate: date, options: NSCalendarOptions())!
        let thirdStart = cal.dateBySettingHour(13, minute: 0, second: 0, ofDate: date, options: NSCalendarOptions())!
        let fourthStart = cal.dateBySettingHour(14, minute: 45, second: 0, ofDate: date, options: NSCalendarOptions())!
        let fifthStart = cal.dateBySettingHour(16, minute: 30, second: 0, ofDate: date, options: NSCalendarOptions())!
        let sixthStart = cal.dateBySettingHour(18, minute: 15, second: 0, ofDate: date, options: NSCalendarOptions())!
        
        if(date.compare(firstStart) == NSComparisonResult.OrderedDescending && date.compare(secondStart) == NSComparisonResult.OrderedAscending){
            print("1限")
            schedule = schedule.stringByAppendingString("1限")
        } else if(date.compare(secondStart) == NSComparisonResult.OrderedDescending && date.compare(thirdStart) == NSComparisonResult.OrderedAscending){
            print("2限")
            schedule = schedule.stringByAppendingString("2限")
        } else if(date.compare(thirdStart) == NSComparisonResult.OrderedDescending && date.compare(fourthStart) == NSComparisonResult.OrderedAscending){
            schedule = schedule.stringByAppendingString("3限")
        } else if(date.compare(fourthStart) == NSComparisonResult.OrderedDescending && date.compare(fifthStart) == NSComparisonResult.OrderedAscending){
            schedule = schedule.stringByAppendingString("4限")
        } else if(date.compare(fifthStart) == NSComparisonResult.OrderedDescending && date.compare(sixthStart) == NSComparisonResult.OrderedAscending){
            schedule = schedule.stringByAppendingString("5限")
        } else {
            queryHashtag = "#SFC"
            getTimeline()
            return
        }
        
        print(schedule)
        getHashtag(schedule)
    }
    
    func getHashtag(schedule:String) {
        let ud: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var myScheduleArray: [NSDictionary] = []
        
        if(ud.arrayForKey("myScheduleArray") != nil){
            myScheduleArray = ud.arrayForKey("myScheduleArray") as! [NSDictionary]
        }
        
        let predicate = NSPredicate(format:"%K == %@","schedule",schedule)
        if((myScheduleArray as NSArray).filteredArrayUsingPredicate(predicate).count != 0){
            let dic:NSDictionary = (myScheduleArray as NSArray).filteredArrayUsingPredicate(predicate).first as! NSDictionary
            queryHashtag = dic["hashtag"] as! String
            className = dic["class"] as! String
        }else{
            queryHashtag = "#SFC"
        }
        
        getTimeline()
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
