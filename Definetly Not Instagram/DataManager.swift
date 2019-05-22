//
//  DataManager.swift
//  Definetly Not Instagram
//
//  Created by Zapad on 01/05/2019.
//  Copyright © 2019 FMI. All rights reserved.
//
import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class PostModel {
    var photoURL:String?
    var description:String
    var author:String
    var avatarURL:String = ""
    var width = 0
    var height = 0
    init(photoURL:String, description:String, author:String, width:Int, height:Int) {
        self.photoURL = photoURL
        self.description = description
        self.author = author
        self.width = width
        self.height = height
    }
    
    init(description:String, author:String) {
        self.description = description
        self.author = author
    }
    
    init(snapshot:DataSnapshot) {
        
        let value = snapshot.value as? NSDictionary
        self.description = value?["description"] as! String
        self.author = value?["author"] as! String
        self.photoURL = value?["photo"] as? String
        self.width = value?["width"] as! Int
        self.height = value?["height"] as! Int
    }
    
    var toDict:[String:Any] {
        var dict:[String:Any] = [:]
        dict["description"] = description
        dict["author"] = author
        dict["width"] = width
        dict["height"] = height
        if let photoURL = self.photoURL {
            dict["photo"] = photoURL
        }
        return dict
    }
}

class UserModel {
    var avatarPhoto: String?
    var username: String?
    init() {
        
    }
    
    init?(snapshot:DataSnapshot) {
        if let dict = snapshot.value as? [String:Any] {
            if dict["photo"] != nil {
                self.avatarPhoto = dict["photo"] as? String
            }
            if dict["username"] != nil {
                self.username = dict["username"] as? String
            }
        } else {
            return nil
        }
    }
}

//the mighty singleton
final class DataManager {
    static let shared = DataManager()
    var databaseRef: DatabaseReference!
    private init() {
        databaseRef = Database.database().reference()
        userUID = Auth.auth().currentUser?.uid
    }
    
    func updateProfileUsername(username newUsername:String?, callback:
        @escaping (Bool) -> () ) {
        
        guard let userID = userUID else {
            callback(false)
            return
        }
        
        guard let username = newUsername else {
            callback(false)
            return
        }
        
        let dbKey = "profile/\(userID)/username"
        let childUpdates = [dbKey: username]
        databaseRef.updateChildValues(childUpdates)
        callback(true)
    }
    
    func updateProfile(avatar:UIImage?, progress:
        @escaping (Double)->(), callback: @escaping (Bool)-> ()) {
        
        guard let userID = userUID else {
            print("Very bad user id")
            callback(false)
            return
        }
        let dbKey = "profile/\(userID)/photo"
        let storageRef = Storage.storage().reference()
        let photoPath = "profile/\(userID)/avatar.jpg"
        
        let imageRef = storageRef.child(photoPath)
        //create file metadata including the content type
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        metadata.customMetadata = ["userId" : userID]
        let data = avatar?.jpegData(compressionQuality: 0.9)
        let uploadTask = imageRef.putData(data!, metadata:metadata)
        
        //let us observe
        uploadTask.observe(.progress) { snapshot in
            let complete = 100.0 * Double(snapshot.progress!.completedUnitCount)/Double(snapshot.progress!.totalUnitCount)
            progress(complete)
        }
        
        //let us conclude
        uploadTask.observe(.success) {
            [unowned uploadTask, weak self] snapshot in
            print("Nice avatar")
            uploadTask.removeAllObservers()
            let childUpdates = [dbKey:photoPath]
            self?.databaseRef.updateChildValues(childUpdates)
            callback(true)
        }
        
        //let us fail
        uploadTask.observe(.failure) {
            [unowned uploadTask] snapshot in
            uploadTask.removeAllObservers()
            callback(false)
            if let error = snapshot.error as NSError? {
                print (error) //silently die
            }
        }
    }
    
    var userUID:String?
    func createPost(post:PostModel, image:UIImage, progress:
        @escaping (Double)->(), callback: @escaping (Bool)-> ()) {
        //kinda like if let but else
        guard let userID = userUID else {
            print("Very bad user id")
            callback(false)
            return
        }
        
        print("User: \(userID)")
        
        let key = databaseRef.child("posts").childByAutoId().key!
        let storageRef = Storage.storage().reference()
        //location of the image for a particular post
        let photoPath = "posts/\(userID)/\(key)/photo.jpg"
        let imageRef = storageRef.child(photoPath)
        //create file metadata including the content type
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        metadata.customMetadata = ["userId" : userID]
        let data = image.jpegData(compressionQuality: 0.9)
        let uploadTask = imageRef.putData(data!, metadata:metadata)
        
        //let us observe
        uploadTask.observe(.progress) { snapshot in
            let complete = 100.0 * Double(snapshot.progress!.completedUnitCount)/Double(snapshot.progress!.totalUnitCount)
            progress(complete)
        }
        
        //let us conclude
        uploadTask.observe(.success) {
            [unowned uploadTask, weak self] snapshot in
            uploadTask.removeAllObservers()
            post.photoURL = photoPath
            post.width = Int(image.size.width)
            post.height = Int(image.size.height)
            let postData = post.toDict
            let childUpdates = ["/posts/\(key)":postData,
                                "myposts/\(userID)/\(key)":postData]
            self?.databaseRef.updateChildValues(childUpdates)
            callback(true)
        }
        
        //let us fail
        uploadTask.observe(.failure) {
            [unowned uploadTask] snapshot in
            uploadTask.removeAllObservers()
            callback(false)
            
            if let error = snapshot.error as NSError? {
                print (error) //silently die
            }
        }
    }
    
    func fetchHomeFeed(callback: @escaping ([PostModel])->() ) {
        let ref = databaseRef.child("posts")
        ref.observeSingleEvent(of: .value, with: {
            snapshot in
            let items: [PostModel] = snapshot.children.compactMap {
                child in
                guard let child = child as? DataSnapshot else {
                    return nil
                }
                return PostModel.init(snapshot: child)
            }
            DispatchQueue.main.async {
                //we want the new on top
                callback(items.reversed())
            }
        })
    }
    
    func fetchMyPosts(uid: String, callback: @escaping ([PostModel])->() ) {
        let ref = databaseRef.child("myposts/\(uid)")
        ref.observeSingleEvent(of: .value, with: {
            snapshot in
            let items: [PostModel] = snapshot.children.compactMap {
                child in
                guard let child = child as? DataSnapshot else {
                    return nil
                }
                return PostModel.init(snapshot: child)
            }
            DispatchQueue.main.async {
                //we want the new on top
                callback(items.reversed())
            }
        })
    }
    
    func fetchAvatarAndUsername(uid: String, callback: @escaping (UserModel?)->()) {
        let ref = databaseRef.child("profile/\(uid)")
        ref.observeSingleEvent(of: .value, with: {
            snapshot in
            let userModel:UserModel? = UserModel.init(snapshot: snapshot)
            DispatchQueue.main.async {
                //we want the new on top
                callback(userModel)
            }
        })
    }
    
    func search(for searchText: String, callback: @escaping ([PostModel]) -> ()) {
        let key = "description"
        databaseRef
            .child("posts")
            .queryOrdered(byChild: key)
            .queryStarting(atValue: searchText, childKey: key)
            .queryEnding(atValue: searchText + "\u{f8ff}", childKey:key)
            .observeSingleEvent(of: .value, with: {
                snapshot in
                let items: [PostModel] = snapshot.children.compactMap {
                    child in
                    guard let child = child as? DataSnapshot else {
                        return nil
                    }
                    return PostModel.init(snapshot: child)
                }
                DispatchQueue.main.async {
                    callback(items)
                }
            })
    }
    
    
}
