//
//  ViewController.swift
//  NationalParks
//
//  Created by Bethany Hsiao on 3/27/20.
//  Copyright © 2020 Bethany Hsiao. All rights reserved.
//

import UIKit

class ReadingListTableViewController: UITableViewController {
    
    var books: [ActualBook] = []
    var filteredBooks: [ActualBook] = []
    var rowIndex: Int = 0
    
    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search List"
        navigationItem.searchController = searchController
        definesPresentationContext = true

        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let book: ActualBook
        if (!isFiltering) {
            book = books[rowIndex]
        } else {
            book = filteredBooks[rowIndex]
        }
        
        if segue.identifier == "ListToDetail" {
            if let detailVC = segue.destination as? DetailTableViewController {
                detailVC.titleStr = book.title
                detailVC.authorStr = book.author
                detailVC.descriptionText = book.description
                detailVC.category = book.genre
                detailVC.rank = book.rank
                detailVC.bookImg = book.book_image
                detailVC.amazonURL = book.amazon
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let book: ActualBook
        if isFiltering {
          book = filteredBooks[indexPath.row]
        } else {
          book = books[indexPath.row]
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell")!
        if let label = cell.viewWithTag(1) as? UILabel {
            label.adjustsFontSizeToFitWidth = true
            label.text = book.title
        }
        
        if let label = cell.viewWithTag(2) as? UILabel {
            label.text = book.author
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        rowIndex = indexPath.row
        performSegue(withIdentifier: "ListToDetail", sender: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
          return filteredBooks.count
        }
        return books.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            books.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    var isSearchBarEmpty: Bool {
      return searchController.searchBar.text?.isEmpty ?? true
    }
    
    var isFiltering: Bool {
      return searchController.isActive && !isSearchBarEmpty
    }

    func filterContentForSearchText(_ searchText: String,
                                    book: ActualBook? = nil) {
      filteredBooks = books.filter { (b: ActualBook) -> Bool in
        return b.title.lowercased().contains(searchText.lowercased()) || b.author.lowercased().contains(searchText.lowercased()) || b.genre.lowercased().contains(searchText.lowercased()) || b.description.lowercased().contains(searchText.lowercased())
      }
      
      tableView.reloadData()
    }


}

extension ReadingListTableViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text!)
  }
}

