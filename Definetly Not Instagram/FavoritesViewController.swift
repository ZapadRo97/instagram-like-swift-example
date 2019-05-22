//
//  FavoritesViewController.swift
//  Definetly Not Instagram
//
//  Created by Zapad on 23/05/2019.
//  Copyright © 2019 FMI. All rights reserved.
//

import UIKit

//we want to use this on all view
protocol EmptyCollectionView {
    func showCollectionView()
    func showEmptyView()
    var collectionView:UICollectionView! {get}
    var emptyView: UIView? {get}
}

//default implementation
extension EmptyCollectionView {
    func showCollectionView() {
        self.emptyView?.isHidden = true
        self.collectionView.isHidden = false
    }
    
    func showEmptyView() {
        if self.emptyView != nil {
            self.emptyView?.isHidden = false
            self.collectionView.isHidden = true
        }
    }
}

extension FavoritesViewController: EmptyCollectionView {
    var emptyView: UIView? {
        return noItems
    }
    /*have it already
    var collectionView:UICollectionView! {
        return collectionView
    }*/
}

class FavoritesViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noItems: UIView!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        showEmptyView()
        loadData()

        // Do any additional setup after loading the view.
    }
    
    func loadData() {
        //todo
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
