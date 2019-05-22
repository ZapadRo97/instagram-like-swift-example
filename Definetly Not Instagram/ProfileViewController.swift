//
//  ProfileViewController.swift
//  Definetly Not Instagram
//
//  Created by Zapad on 21/05/2019.
//  Copyright © 2019 FMI. All rights reserved.
//

import UIKit
import FirebaseAuthUI
import FirebaseStorage
import SDWebImage

class ProfileViewController: UIViewController {

    var userUDID:String? = nil
    var listOfPosts:[PostModel]?
    
    @IBAction func onDone(_ sender: Any) {
        print("I'm out")
        self.dismiss(animated: true, completion: nil)
    }
    
    func loadData(uid:String) {
        listOfPosts = []
        
        DataManager.shared.fetchMyPosts(uid: uid) {
            [weak self] items in
            if items.count > 0 {
                self?.listOfPosts? += items
                self?.posts.reloadData()
            }
        }
        
        DataManager.shared.fetchAvatarAndUsername(uid: uid) {
            [weak self] item in
            
            self?.username.text = item?.username ?? DataManager.shared.userUID
            self?.putAvatarPicture(path: item?.avatarPhoto)
        }
    }
    
    func putAvatarPicture(path:String?) {
        guard let photoPath = path else {
            print("No picture")
            return
        }
        
        let storage = Storage.storage()
        let pathReference = storage.reference(withPath: photoPath)
        pathReference.downloadURL { url, error in
            if error != nil {
                // Handle any errors
            } else {
                self.avatarImageView.sd_setImage(with: url, completed: {
                    (image, error, cacheType, url) in
                    // your code
                })
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let cellNib = UINib(nibName: "PhotoViewCell", bundle: nil)
        posts.register(cellNib, forCellWithReuseIdentifier: photoCellReuseIdentifier)
        posts.dataSource = self
        //default avatar icon
        //todo: change
        avatarImageView.image = #imageLiteral(resourceName: "second")
        username.text = userUDID ?? DataManager.shared.userUID
        
        //some extra
        avatarImageView.isUserInteractionEnabled = true
        username.isUserInteractionEnabled = true
        
        //show exactly three items per row
        if let layout = posts.collectionViewLayout as?
            UICollectionViewFlowLayout {
            let imageWidth = (UIScreen.main.bounds.width - 36) / 3
            layout.itemSize = CGSize(width: imageWidth, height: imageWidth)
        }
        
        //can't follow youtsef
        if userUDID == nil {
            followButton.isHidden = true
        } else {
            //disable change of avatar photo
            avatarGestureRecogniser.isEnabled = false
            //disable change of username
            usernameTapGestureRecogniser.isEnabled = false
            logoutButton.isHidden = true
            //hide the follow button
            if userUDID == DataManager.shared.userUID {
                followButton.isHidden = true
            }
        }
        
        loadData(uid: userUDID ?? DataManager.shared.userUID!)

        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var posts: UICollectionView!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet var avatarGestureRecogniser: UITapGestureRecognizer!
    @IBOutlet var usernameTapGestureRecogniser: UITapGestureRecognizer!
    private let photoCellReuseIdentifier = "PhotoCell"
    private var pickedImage:UIImage?
    
    
    @IBAction func logoutHandler(_ sender: Any) {
        let authUI = FUIAuth.defaultAuthUI()
        do {
            try authUI?.signOut()
            let nc = NotificationCenter.default
            nc.post(name: Notification.Name(rawValue: "userSignedOut"),
                    object: nil,
                    userInfo: nil)
            //remove the active user
            //DataManager.shared.user = nil
            DataManager.shared.userUID = nil
        } catch let error {
            print("Error: \(error)")
        }
        
    }
    
    @IBAction func changeUsername(_ sender: Any) {
        print("Tap tap username")
        let alertController = UIAlertController(title: "Change your username", message: "Please enter a new username", preferredStyle: .alert)
        alertController.addTextField { (textField) in
            //some customization
        }
        alertController.addAction(UIAlertAction(title:"Update", style: .default, handler: {
            [weak alertController, weak self]
            (action) in
            if let textFields = alertController?.textFields! {
                if textFields.count > 0 {
                    let textField = textFields[0]
                    self?.username.text = textField.text
                    self?.updateUsername(username: textField.text)
                }
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "cancel", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func pickAvatarImage(_ sender: Any) {
        print("Tap tap image")
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = true
        present(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func follow(_ sender: Any) {
        let alertController = UIAlertController(title: "Error", message: "Not implemented yet.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title:"Dismiss", style:.default))
        self.present(alertController, animated:true, completion:nil)
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage]
            as? UIImage {
            pickedImage = self.scale(image: editedImage, toSize: CGSize(width: 100, height: 100))
        } else if let chosenImage = info[UIImagePickerController.InfoKey.originalImage]
            as? UIImage {
            pickedImage = self.scale(image: chosenImage, toSize: CGSize(width:100, height: 100))
        }
        
        picker.dismiss(animated: true, completion: nil)
        updateAvatar()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    
    
}

extension ProfileViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    
    func updateUsername(username:String?) {
        DataManager.shared.updateProfileUsername(username: username) {
            result in
            if !result {
                print("something went wrong")
            }
        }
    }
    
    
    
    func updateAvatar() {
        if pickedImage != nil {
            self.avatarImageView.image = pickedImage
        }
        DataManager.shared.updateProfile(avatar: pickedImage, progress: {
            progress in
            print("Upload avatar progress: \(progress)")
        }) { result in
            if !result {
                print("something went wrong")
            }
        }
    }
    
    func scale(image: UIImage, toSize size: CGSize) -> UIImage? {
        let imageSize = image.size
        let widthRatio = size.width / image.size.width
        let heightRatio = size.height / image.size.height
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width:imageSize.width*heightRatio, height: imageSize.height * heightRatio)
        } else {
            newSize = CGSize(width: imageSize.width * widthRatio, height: imageSize.height * widthRatio)
        }
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        image.draw(in: CGRect(origin: CGPoint.zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
}

extension ProfileViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listOfPosts?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: photoCellReuseIdentifier, for: indexPath) as? PhotoViewCell else {
            fatalError("No Cell! Abort")
        }
        
        if let photoURL = listOfPosts?[indexPath.row].photoURL {
            print(photoURL)
            let storage = Storage.storage()
            let pathReference = storage.reference(withPath: photoURL)
            pathReference.downloadURL { url, error in
                if error != nil {
                    // Handle any errors
                } else {
                    // Get the download URL for 'images/stars.jpg'
                    cell.image?.sd_setImage(with: url, completed: {
                        (image, error, cacheType, url) in
                        // your code
                        //cell.image?.image = self.resizeImage(image: image!, newWidth: 400)
                    })
                }
            }
            
        }
        
        
        return cell
        
    }
}
