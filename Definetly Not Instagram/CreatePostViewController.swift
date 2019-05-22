//
//  CreatePostViewController.swift
//  Definetly Not Instagram
//
//  Created by Zapad on 01/05/2019.
//  Copyright © 2019 FMI. All rights reserved.
//

import UIKit

class CreatePostViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        textView.delegate = self
        photo.image = image
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Share", style: .done, target: self,
            action: #selector(createPost))
    }
    
    //available to objective c
    //maybe for using #selector?
    @objc func createPost() {
        //fancy way of checking not nil
        guard let image = self.image else {
            return
        }
        
        //?? if nil
        let description = (textView.text != placeholderText ? textView.text : "") ?? ""
        let post = PostModel(description: description, author: DataManager.shared.userUID ?? "no user id")
        DataManager.shared.createPost(post: post, image: image, progress: {
            (progress) in
            //maybe show a nice loading bar
            print("Upload \(progress)")
        }, callback: {
            (success) in
            //maybe let the user know too
            if success {
                print("Successful upload")
            } else {
                print("unable to create post")
            }
        })
        
        
        self.dismiss(animated: true, completion: nil)
    }
    
    private let placeholderText = "Write a caption..."
    public var image:UIImage?
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var textView: UITextView! {
        didSet {
            textView.textColor = .gray
            textView.text = placeholderText
            textView.selectedRange = NSRange()
        }
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

extension CreatePostViewController : UITextViewDelegate {
    //make textView to behave more like TextInput
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if textView.text == placeholderText {
            textView.selectedRange = NSRange()
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if textView.text == placeholderText && !text.isEmpty {
            textView.text = nil
            textView.textColor = .black
            textView.selectedRange = NSRange()
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.textColor = .gray
            textView.text = placeholderText
        }
    }
}
