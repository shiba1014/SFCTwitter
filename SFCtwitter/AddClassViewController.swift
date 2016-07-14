//
//  AddClassViewController.swift
//  SFCtwitter
//
//  Created by Paul McCartney on 2016/07/13.
//  Copyright © 2016年 shiba. All rights reserved.
//

import UIKit

class AddClassViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var picker:UIPickerView? = UIPickerView()
    @IBOutlet var table:UITableView? = UITableView()
    var weekdayArray: NSArray = ["月","火","水","木","金"]
    var scheduleArray: NSArray = ["1限","2限","3限","4限","5限"]
    var resultArray: [NSDictionary] = []
    var myScheduleArray: [NSDictionary] = []
    let dataArray:[NSDictionary] = [["schedule":"月4限","class":"ネットワーク産業論","hashtag":"#ni2016"],["schedule":"火3限","class":"インターネット","hashtag":"#inet16s"],["schedule":"水1限","class":"経営戦略","hashtag":"#sfcsm16"],["schedule":"水2限","class":"経営戦略","hashtag":"#sfcsm16"],["schedule":"水4限","class":"リーガルマインド","hashtag":"#sfclm16"],["schedule":"木1限","class":"環境情報学","hashtag":"#sfckj16"]]
    let ud: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        table?.delegate = self
        table?.dataSource = self
        table?.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        if(ud.arrayForKey("myScheduleArray") != nil){
            myScheduleArray = ud.arrayForKey("myScheduleArray") as! [NSDictionary]
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        picker?.delegate = self
        picker?.dataSource = self
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(component == 0){
            return weekdayArray.count
        }
        return scheduleArray.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(component == 0){
            return weekdayArray[row] as? String
        }
        
        return scheduleArray[row] as? String
    }
    
    @IBAction func tappedQuery() {
        var queryStr:String = ""
        queryStr = queryStr.stringByAppendingString(weekdayArray[(picker?.selectedRowInComponent(0))!] as! String)
        queryStr = queryStr.stringByAppendingString(scheduleArray[(picker?.selectedRowInComponent(1))!] as! String)
        print(queryStr)
        let predicate = NSPredicate(format:"%K == %@","schedule",queryStr)
        if((dataArray as NSArray).filteredArrayUsingPredicate(predicate).count != 0){
            resultArray = (dataArray as NSArray).filteredArrayUsingPredicate(predicate) as! [NSDictionary]
            table?.reloadData()
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return resultArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        let dic = resultArray[indexPath.section] 
        cell.textLabel?.text = (dic["class"] as? String)! + " " + (dic["hashtag"] as? String)!
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let dic = resultArray[indexPath.section]
        let alert = UIAlertController(title: nil, message: (dic["class"] as? String)! + "を追加しますか？", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default) { action in
            let predicate = NSPredicate(format:"%K == %@","schedule",dic["schedule"] as! String)
            if((self.myScheduleArray as NSArray).filteredArrayUsingPredicate(predicate).count != 0){
                let index = (self.myScheduleArray as NSArray).valueForKey("schedule").indexOfObject(dic["schedule"] as! String)
                self.myScheduleArray[index] = dic
            } else {
                self.myScheduleArray.append(dic)
            }
            self.ud.setObject(self.myScheduleArray, forKey: "myScheduleArray")
            self.ud.synchronize()
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .Cancel, handler: nil)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
