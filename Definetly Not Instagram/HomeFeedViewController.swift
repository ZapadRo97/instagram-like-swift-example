//
//  FirstViewController.swift
//  Definetly Not Instagram
//
//  Created by Zapad on 01/05/2019.
//  Copyright © 2019 FMI. All rights reserved.
//

import UIKit
import SDWebImage
import FirebaseStorage

class HomeFeedViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let model = model {
            print("Number of items: \(model.count)")
            return model.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? FeedViewCell else {
            fatalError("No Cell! Abort")
        }
        // if we're still here it means we got a PersonCell, so we can return it
        if let photoURL = model?[indexPath.row].photoURL {
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
                        cell.image?.image = self.resizeImage(image: image!, newWidth: 400)
                    })
                }
            }
            
        }
        
        //that '!' may be a bad idea
        let post = model![indexPath.row]
        //cell.avatarName.text = name
        cell.avatarImage.image = #imageLiteral(resourceName: "second")
        
        if let user = self.users[post.author] {
            cell.avatarName.text = user?.username ?? post.author
            //very important
            cell.delegate = self
            if let avatarPath = user?.avatarPhoto {
                //let imgRef = Storage.storage().reference().child(avatarPath)
                let storage = Storage.storage()
                let pathReference = storage.reference(withPath: avatarPath)
                pathReference.downloadURL { url, error in
                    if error != nil {
                        // Handle any errors
                    } else {
                        cell.avatarImage.sd_setImage(with: url, completed: {
                            (image, error, cacheType, url) in
                            //some code
                        })
                    }
                }
            }
            
        }
        
        return cell
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // This is just for example, for the scenario Step-I -> 1
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else {
            fatalError("Never ever")
        }
        
        return CGSize(width: view.frame.width, height: flowLayout.itemSize.height)
    }
    
    private let reuseIdentifier = "FeedCell"
    @IBOutlet weak var collectionView: UICollectionView!
    
    var model:[PostModel]?
    var users = [String: UserModel?]()
    var refreshControl:UIRefreshControl?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.collectionView.register(UINib(nibName: "FeedViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView.delegate = self
        loadData()
        
        self.collectionView.alwaysBounceVertical = true
        let refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(refreshStream), for: .valueChanged)
        
        refreshControl = refresher
        collectionView!.addSubview(refreshControl!)
    }
    
    @objc func refreshStream() {
        
        print("refresh")
        loadData()
        
        
        refreshControl?.endRefreshing()
    }

    func loadData() {
        model = []
        DataManager.shared.fetchHomeFeed {
            [weak self] items in
            if items.count > 0 {
                self?.model? += items
                self?.loadAllUsers()
                self?.collectionView.reloadData()
            }
        }
    }
    
    func loadAllUsers() {
        var usersInfoToLoad = 0
        var usersInfoLoaded = 0
        if let model = self.model {
            for item in model {
                let userId = item.author
                if users[userId] == nil {
                    usersInfoToLoad += 1
                    users[userId] = UserModel()
                }
            }
            //a function
            let reloadView = {
                [weak self] in
                if usersInfoLoaded == usersInfoToLoad {
                    self?.collectionView.reloadData()
                }
            }
            
            for author in users.keys {
                let userId = author
                DataManager.shared.fetchAvatarAndUsername(uid: userId) {
                    [weak self] userModel in
                    if let userModel = userModel {
                        self?.users[userId] = userModel
                        usersInfoLoaded += 1
                        reloadView()
                    }
                }
            }
        }
    }

}

extension HomeFeedViewController : ProfileHandler {
    //gets called before segue trigger
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openProfile" {
            if let navController = segue.destination as? UINavigationController {
                if let profileVC = navController.topViewController as? ProfileViewController {
                    profileVC.userUDID = sender as? String
                }
            }
        }
    }
    
    func openProfile(cell: UICollectionViewCell) {
        guard let indexPath = self.collectionView.indexPath(for: cell),
            let post = model?[indexPath.row] else {
                return
        }
        performSegue(withIdentifier: "openProfile", sender: post.author)
    }
}

