//
//  DetailTableViewController.swift
//  FInal Project
//
//  Created by Bethany Hsiao on 4/20/20.
//  Copyright © 2020 Bethany Hsiao. All rights reserved.
//

import UIKit
import Kingfisher

protocol AddBookDelegate: class {
    func didAdd(_ book: ActualBook)
}

class DetailTableViewController: UITableViewController {
    var titleStr: String?
    var authorStr: String?
    var descriptionText: String?
    var category: String?
    var rank: Int?
    var bookImg: URL?
    var amazonURL: URL?
    
    weak var delegate: AddBookDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
    }
    
    @IBAction func saveBook() {
        let b: ActualBook? = getBook()
        if let newBook = b as? ActualBook {
            self.delegate?.didAdd(newBook)
        }
        
    }
    
    func getBook() -> ActualBook? {
        if let t = titleStr as? String, let a = authorStr as? String, let d = descriptionText as? String, let c = category as? String, let r = rank as? Int, let b = bookImg as? URL, let am = amazonURL as? URL {
            return ActualBook(genre: c, rank: r, description: d, title: t, author: a, book_image: b, amazon_url: am)
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell")!
                        
        if let img = cell.viewWithTag(1) as? UIImageView {
            img.clipsToBounds = true
            img.kf.setImage(with: bookImg)
        }
        
        if let title = cell.viewWithTag(2) as? UILabel {
            title.adjustsFontSizeToFitWidth = true
            title.text = titleStr
        }
        
        if let author = cell.viewWithTag(3) as? UILabel {
            author.text = authorStr
        }
        
        if let genre = cell.viewWithTag(4) as? UILabel {
            genre.text = category
        }
        
        if let rankLabel = cell.viewWithTag(5) as? UILabel, let r = rank as? Int {
            rankLabel.text = "Ranked #\(r)"
        }
        
        if let description = cell.viewWithTag(6) as? UITextView {
            description.text = descriptionText
            description.translatesAutoresizingMaskIntoConstraints = true
            description.sizeToFit()
        }
        
        if let url = cell.viewWithTag(7) as? UITextView, let a = amazonURL as? URL {
            url.isEditable = false
            url.dataDetectorTypes = .link
            url.text = "Where to buy:\n\(a)"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 700.0
    }
    
}
