//
//  UserTableViewController.swift
//  ParseStarterProject
//
//  Created by Yung Dai on 2015-06-01.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class UserTableViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    var userArray: [String] = []
    var activeUser = 0
    var messageCount = 0
    
    // timer variable
    var timer = NSTimer()
    
    @IBOutlet weak var logOutButton: UIBarButtonItem!

    @IBAction func logoutBarButtonPressed(sender: UIBarButtonItem) {
        println("You pressed this button")
        timer.invalidate()
        PFUser.logOut()
    }

    

    // image picker controller
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        // create a parse class object to upload to parse
        var imageSend = PFObject(className: "Image")
        // column name "image"
        imageSend["image"] = PFFile(name: "image.jpg", data: UIImageJPEGRepresentation(image, 0.5))
        // this is the user that sent the message out
        imageSend["sender"] = PFUser.currentUser()?.username
        // receiver
        imageSend["receiver"] = userArray[activeUser]
        imageSend.save()
    }
    

    
    func pickImage(sender:AnyObject) {
        var image = UIImagePickerController()
        image.delegate = self
        // choose and image from the Photolibrary
        image.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        image.allowsEditing = false
        // this is thoose the image var because it's an UIImagePickerControllerSourceType.Photolibrary
        self.presentViewController(image, animated: true, completion: nil)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        var query = PFUser.query()
        
        // make sure that the username is not the current user's username
        query?.whereKey("username", notEqualTo: PFUser.currentUser()!.username!)
        
        var users = query?.findObjects()
        if let testUsers = users {
            for user in users! {
                println(user.username!)
                
                // reload the tableView
                userArray.append(user.username!!)
                tableView.reloadData()
            }
        }
        
        // set up a timer to run the checkForMessages function
        timer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: Selector("checkForMessages"), userInfo: nil, repeats: true)
    }
    

    func checkForMessages() {
        println("Checking for messages")
        // set up a query on Image class
        var query = PFQuery(className: "Image")
        // get the user
        query.whereKey("receiver", equalTo: PFUser.currentUser()!.username!)
        
        // grab the images from the list
        var images:Void = query.findObjectsInBackgroundWithBlock { (photo, error) -> Void in
            if (error == nil) {
                var done = false
                if let myPhotoObject = photo {
                    var imageView:PFImageView = PFImageView()
                    for image in myPhotoObject {
                        if let imageFile = image["image"] as? PFFile {
                            imageView.file = imageFile
                            imageView.loadInBackground()
                            println(imageView.file)
                            
                            imageView.loadInBackground({ (photo, error) -> Void in
                                if error == nil {
                                    var senderUsername = ""
                                    if image["sender"] != nil {
                                        senderUsername = image["sender"] as! String
                                    } else {
                                        senderUsername = "unknown user"
                                    }
                                    // create an alert view
                                    var alert = UIAlertController(title: "You have a message", message: "Message from \(senderUsername)", preferredStyle: UIAlertControllerStyle.Alert)
                                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                                        var backgroundView = UIImageView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
                                        backgroundView.backgroundColor = UIColor.blackColor()
                                        backgroundView.alpha = 0.8
                                        backgroundView.tag = 3
                                        self.view.addSubview(backgroundView)
                                        
                                        // var for diplayed image
                                        var displayedImage = UIImageView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
                                        displayedImage.image = photo
                                        println(displayedImage.image)
                                        displayedImage.tag = 3
                                        displayedImage.contentMode = UIViewContentMode.ScaleAspectFill
                                        self.view.addSubview(displayedImage)
                                        // delete image
                                        image.delete()
                                        // hide message
                                        self.timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: Selector("hideMessage"), userInfo: nil, repeats: false)
                                        
                                    }))
                                    if self.messageCount == 0 {
                                        self.presentViewController(alert, animated: true, completion: nil)
                                        self.messageCount++
                                    }
                                }
                            })
                            done = true
                        }
                    }
                }
            }
        }
    }
    
    func hideMessage() {
        for subView in self.view.subviews {
            if subView.tag == 3 {
                subView.removeFromSuperview()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return  userArray.count
        
        
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...
        cell.textLabel?.text = userArray[indexPath.row]

        return cell
    }


    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.

        return true
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        activeUser = indexPath.row
        println("cell selected")
        pickImage(self)

    }
    
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
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        timer.invalidate()
        println("Timer Stopped from the prepareForSeque ")
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }


}
