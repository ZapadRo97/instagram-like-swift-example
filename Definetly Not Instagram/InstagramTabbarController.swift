//
//  InstagramTabbarController.swift
//  Definetly Not Instagram
//
//  Created by Zapad on 01/05/2019.
//  Copyright © 2019 FMI. All rights reserved.
//

import UIKit
import ESTabBarController_swift
import YPImagePicker

class InstagramTabbarController: ESTabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        //we want custom behaviour on middle icon
        self.shouldHijackHandler = {
            tabBarController, viewController, index in
            if index == 2 {
                return true
            }
            return false
        }
        
        self.didHijackHandler = {
            [weak self] tabBarController, viewController, index in
            DispatchQueue.main.async {
                self?.presentPicker()
            }
        }
        
        //todo:update the middle icon
    }
    
    func presentPicker() {
        print("Special Action")
        var config = YPImagePickerConfiguration()
        config.library.onlySquare = false
        config.onlySquareImagesFromCamera = true
        config.targetImageSize = .original
        config.usesFrontCamera = true
        config.showsPhotoFilters = true
        config.shouldSaveNewPicturesToAlbum = false
        config.albumName = "DefinetlyNotInstagramImages"
        config.startOnScreen = .library
        
        let picker = YPImagePicker(configuration: config)
        picker.didFinishPicking { [unowned picker, weak self] items, _ in
            
            if let viewController = self?.storyboard?
            .instantiateViewController(withIdentifier: "CreatePostViewController")
            as? CreatePostViewController {
                if let photo = items.singlePhoto {
                    viewController.image = photo.image
                    let transition = CATransition()
                    transition.duration = 0.3
                    transition.timingFunction = CAMediaTimingFunction(
                        name: CAMediaTimingFunctionName.easeInEaseOut)
                    transition.type = CATransitionType.fade
                    picker.view.layer.add(transition, forKey: nil)
                    picker.pushViewController(viewController, animated: false)
                    
                }
            }
            
            
            //picker.dismiss(animated: true, completion: nil)
        }
        
        present(picker, animated: true, completion: nil)
    }
}
