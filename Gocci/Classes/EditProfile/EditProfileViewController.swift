//
//  EditProfileViewController.swift
//  Gocci
//
//  Created by Ma Wa on 15.02.16.
//  Copyright © 2016 Massara. All rights reserved.
//

import Foundation
import UIKit


class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate

{
    
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var userNameEditFiled: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var bgView: UIView!
    
    var newProfileImageURL: NSURL?
    var userImageChanged: Bool = false
    
    let tmpNewImageFilePathRelative = "Documents/new_profile_image.png"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        sendButton.layer.cornerRadius = 3.0
        sendButton.clipsToBounds = true
        
        bgView.layer.borderColor = UIColor.grayColor().CGColor
        bgView.layer.borderWidth = 2
        
        userNameEditFiled.delegate = self
        
        userProfileImageView.userInteractionEnabled = true
        userProfileImageView.tag = 333
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        userImageChanged = false
        
        userNameEditFiled.text = Persistent.user_name
        
        let imageURL = NSURL(string : Persistent.user_profile_image_url)
        
        if let imageData = NSData(contentsOfURL: imageURL!) {
            userProfileImageView.image = UIImage(data: imageData)
        }
        else {
            userProfileImageView.image = UIImage(named: "warning")!
        }
    }
    
    // TODO TRANS needs translation
    func changeUsernameUpstream(newName: String) {
        
        SVProgressHUD.show()
        
        let req = API4.set.username()
        req.parameters.username = newName
        
        req.onAnyAPIError {
            SVProgressHUD.dismiss()
            Toast.失敗("ERROR", "Profile image upload failed failed") // TODO TRANSLATION
        }
        
        req.on_ERROR_USERNAME_ALREADY_REGISTERD { (code, msg) -> () in
            self.simplePopup("Username already registerd", "Sorry the username '\(newName)' is already in use by another user :(", "OK")
        }
        
        req.perform { (payload) -> () in
            SVProgressHUD.dismiss()
            Persistent.user_name = newName
            Toast.情報("Success", "Your new username is: '\(newName)'")  // TODO TRANSLATION
        }
    }
    
    func changeUserProfileImageUpstream(imageFileURL: NSURL) {
        
        SVProgressHUD.show()
        
        let req = API4.set.profile_img()
        
        req.parameters.profile_img = Persistent.user_id + "_" + Util.timestampUTC() + "_img"
        
        req.onAnyAPIError {
            SVProgressHUD.dismiss()
            Toast.失敗("ERROR", "Profile image upload failed failed") // TODO TRANSLATION
        }
        
        req.perform { payload in
            
            // TODO would be better to set this after the AWS# upload is complete
            Persistent.user_profile_image_url = payload.profile_img
            
            let awsFileName = NSURL(string: payload.profile_img)!.lastPathComponent ?? req.parameters.profile_img! + ".png"
            
            print("New profile image URL: " + payload.profile_img)
            print("AWS file name \(awsFileName)")
            
            AWSS3ProfileImageUploadTask(filePath: self.tmpNewImageFilePathRelative, s3FileName: awsFileName).schedule()
            
            self.newProfileImageURL = nil
            
            SVProgressHUD.dismiss()
        }
        
    }
    
    @IBAction func uploadDataClicked(sender: AnyObject) {
        if userNameEditFiled.text?.length > 0 && userNameEditFiled.text != Persistent.user_name {
            // username has to be changed. you have to check if the name is still availible
            changeUsernameUpstream(userNameEditFiled.text!)
        }
        else {
            // reset the name if the user cleared the edot view
            userNameEditFiled.text = Persistent.user_name
        }
        
        if let imageURL = newProfileImageURL {
            // user has set choosen a new profile image
            changeUserProfileImageUpstream(imageURL)
        }
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if event?.allTouches()?.first?.view?.tag == userProfileImageView.tag {
            print("user avatar clicked")
            
            if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
                let ipc = UIImagePickerController()
                ipc.sourceType = .PhotoLibrary
                ipc.allowsEditing = true
                ipc.delegate = self
                self.presentViewController(ipc, animated: true, completion: nil)
            }
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?)
    {
        newProfileImageURL = Util.absolutify(tmpNewImageFilePathRelative)
        
        let imageScaled = image.scaleToNewImage(CGSize(width: PROFILE_IMAGE_UPLOAD_RESOLUTION, height: PROFILE_IMAGE_UPLOAD_RESOLUTION))
        
        let imageData = UIImagePNGRepresentation(imageScaled)
        imageData?.writeToURL(newProfileImageURL!, atomically: true)
        userProfileImageView.image = imageScaled
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        guard userNameEditFiled.text != Persistent.user_name else {
            // user did not change the username
            userNameEditFiled.resignFirstResponder()
            return true
        }
        
        if userNameEditFiled.text?.length > 0 {
            print("New Username: \(userNameEditFiled.text)")
            userNameEditFiled.resignFirstResponder()
        }
        
        return true
    }
    
    
    
}



/*
guard let editingInfo = editingInfo else {
print("no edit info")
return
}

//        if let typ = editingInfo[UIImagePickerControllerMediaType] as? String {
//            if typ == "public.image" {
//                if let image = editingInfo[UIImagePickerControllerEditedImage] as? UIImage {

newProfileImageURL = NSFileManager.documentsDirectory().URLByAppendingPathComponent("latest_photo.png")

let imageData = UIImagePNGRepresentation(image)
imageData?.writeToURL(newProfileImageURL!, atomically: true)
userProfileImageView.image = image

self.dismissViewControllerAnimated(true, completion: nil)
//                }
//            }
//        }


*/
