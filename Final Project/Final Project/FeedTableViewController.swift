//
//  FeedTableViewController.swift
//  Final Project
//
//  Created by Bethany Hsiao on 4/12/20.
//  Copyright © 2020 Bethany Hsiao. All rights reserved.
//

import UIKit
import Kingfisher

struct Data: Codable {
    let results: Result
    
    struct Result: Codable {
        let display_name: String
        let books: [Book]
        
        struct Book: Codable {
            let rank: Int
            let description: String
            let title: String
            let author: String
            let book_image: URL
            let amazon_product_url: URL
        }
    }
}

class ActualBook {
    let genre: String
    let rank: Int
    let description: String
    let title: String
    let author: String
    let book_image: URL
    let amazon: URL
    
    init(genre: String, rank: Int, description: String, title: String, author: String, book_image: URL, amazon_url: URL) {
        self.genre = genre
        self.rank = rank
        self.description = description
        self.title = title
        self.author = author
        self.book_image = book_image
        self.amazon = amazon_url
    }
}

class FeedTableViewController: UITableViewController, AddBookDelegate {
    
    var fetched = false
    var pulledBooks = Data(results: Data.Result(display_name: "", books: [Data.Result.Book]()))
    var actualBooks: [ActualBook] = []
    var filteredBooks: [ActualBook] = []
    var rowIndex: Int = 0
    let searchController = UISearchController(searchResultsController: nil)
    
    var readingList: ReadingListTableViewController = ReadingListTableViewController()
    
    override func viewWillAppear(_ animated: Bool) {
        self.refreshControl?.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
        if (!fetched) {
            fetchBooks()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Books"
        navigationItem.searchController = searchController
        definesPresentationContext = true

    }
    
    @objc func handleRefreshControl() {
        //refreshBooks()
        DispatchQueue.main.async {
            self.actualBooks.shuffle()
            self.refreshControl?.endRefreshing()
            self.tableView.reloadData()
        }
    }
    
    private func fetchBooks() {
        
        let urlStrings = ["https://api.nytimes.com/svc/books/v3/lists/current/combined-print-and-e-book-fiction.json?api-key=fYKmAmApuJ6FhOfW1sFF1bGjxjNURxAt", "https://api.nytimes.com/svc/books/v3/lists/2018-04-15/combined-print-and-e-book-fiction.json?api-key=fYKmAmApuJ6FhOfW1sFF1bGjxjNURxAt", "https://api.nytimes.com/svc/books/v3/lists/2017-04-15/combined-print-and-e-book-fiction.json?api-key=fYKmAmApuJ6FhOfW1sFF1bGjxjNURxAt", "https://api.nytimes.com/svc/books/v3/lists/2016-04-15/combined-print-and-e-book-fiction.json?api-key=fYKmAmApuJ6FhOfW1sFF1bGjxjNURxAt", "https://api.nytimes.com/svc/books/v3/lists/2020-03-15/combined-print-and-e-book-fiction.json?api-key=fYKmAmApuJ6FhOfW1sFF1bGjxjNURxAt", "https://api.nytimes.com/svc/books/v3/lists/2020-02-15/combined-print-and-e-book-fiction.json?api-key=fYKmAmApuJ6FhOfW1sFF1bGjxjNURxAt", "https://api.nytimes.com/svc/books/v3/lists/2020-01-15/combined-print-and-e-book-fiction.json?api-key=fYKmAmApuJ6FhOfW1sFF1bGjxjNURxAt", "https://api.nytimes.com/svc/books/v3/lists/2019-12-15/combined-print-and-e-book-fiction.json?api-key=fYKmAmApuJ6FhOfW1sFF1bGjxjNURxAt", "https://api.nytimes.com/svc/books/v3/lists/current/combined-print-and-e-book-nonfiction.json?api-key=fYKmAmApuJ6FhOfW1sFF1bGjxjNURxAt", "https://api.nytimes.com/svc/books/v3/lists/current/young-adult.json?api-key=fYKmAmApuJ6FhOfW1sFF1bGjxjNURxAt", "https://api.nytimes.com/svc/books/v3/lists/current/manga.json?api-key=fYKmAmApuJ6FhOfW1sFF1bGjxjNURxAt", "https://api.nytimes.com/svc/books/v3/lists/2020-03-15/combined-print-and-e-book-nonfiction.json?api-key=fYKmAmApuJ6FhOfW1sFF1bGjxjNURxAt", "https://api.nytimes.com/svc/books/v3/lists/2020-02-15/combined-print-and-e-book-nonfiction.json?api-key=fYKmAmApuJ6FhOfW1sFF1bGjxjNURxAt", "https://api.nytimes.com/svc/books/v3/lists/2020-01-15/combined-print-and-e-book-nonfiction.json?api-key=fYKmAmApuJ6FhOfW1sFF1bGjxjNURxAt", "https://api.nytimes.com/svc/books/v3/lists/2019-12-15/combined-print-and-e-book-nonfiction.json?api-key=fYKmAmApuJ6FhOfW1sFF1bGjxjNURxAt"]
        
        for urlStr in urlStrings {
            guard let url = URL(string: urlStr) else { return }
            
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let data = data {
                    
                    if let decodedBooks = try? JSONDecoder().decode(Data.self, from: data) {
                        self.pulledBooks = decodedBooks
                        
                        for book in self.pulledBooks.results.books {
                            let b = ActualBook(genre: self.pulledBooks.results.display_name, rank: book.rank, description: book.description, title: book.title, author: book.author, book_image: book.book_image, amazon_url: book.amazon_product_url)
                            if (!self.actualBooks.contains(b)) {
                                self.actualBooks.append(b)
                            }
                        }
                        
                        DispatchQueue.main.async {
                            self.actualBooks.shuffle()
                            self.tableView.reloadData()
                            self.fetched = false
                        }
                    }
                }
            }
            
            task.resume()
            fetched = true
            
        }
    }
        
    var isSearchBarEmpty: Bool {
      return searchController.searchBar.text?.isEmpty ?? true
    }

    var isFiltering: Bool {
      return searchController.isActive && !isSearchBarEmpty
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let book: ActualBook
        if (!isFiltering) {
            book = actualBooks[rowIndex]
        } else {
            book = filteredBooks[rowIndex]
        }
        
        if segue.identifier == "FeedToDetailTable" {
            if let detailVC = segue.destination as? DetailTableViewController {
                detailVC.titleStr = book.title
                detailVC.authorStr = book.author
                detailVC.descriptionText = book.description
                detailVC.category = book.genre
                detailVC.rank = book.rank
                detailVC.bookImg = book.book_image
                detailVC.amazonURL = book.amazon
                detailVC.delegate = self
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let book: ActualBook
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookCell")!
        
        if (!isFiltering) {
          book = actualBooks[indexPath.row]
        } else {
          book = filteredBooks[indexPath.row]
        }
                        
        if let img = cell.viewWithTag(3) as? UIImageView {
            img.clipsToBounds = true
            img.kf.setImage(with: book.book_image)
        }
        
        if let title = cell.viewWithTag(1) as? UILabel {
            title.adjustsFontSizeToFitWidth = true
            title.text = book.title
        }
        
        if let author = cell.viewWithTag(2) as? UILabel {
            author.text = book.author
        }
        
        if let genre = cell.viewWithTag(4) as? UILabel {
            genre.text = book.genre
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        rowIndex = indexPath.row
        performSegue(withIdentifier: "FeedToDetailTable", sender: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (isFiltering) {
          return filteredBooks.count
        }
        
        return actualBooks.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 450.0
    }
    
    func filterContentForSearchText(_ searchText: String,
                                    book: ActualBook? = nil) {
      filteredBooks = actualBooks.filter { (b: ActualBook) -> Bool in
        return b.title.lowercased().contains(searchText.lowercased()) || b.author.lowercased().contains(searchText.lowercased()) || b.genre.lowercased().contains(searchText.lowercased()) || b.description.lowercased().contains(searchText.lowercased())
      }
      
      tableView.reloadData()
    }
    
    func didAdd(_ book: ActualBook) {
        var navVC = tabBarController?.viewControllers?[1] as! UINavigationController
        var rlvc = navVC.viewControllers[0] as! ReadingListTableViewController
        if (!rlvc.books.contains(book)) {
            rlvc.books.insert(book, at: 0)
        }
        tabBarController?.selectedIndex = 1
        rlvc.tableView.reloadData()
    }

}

extension FeedTableViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    let searchBar = searchController.searchBar
    filterContentForSearchText(searchBar.text!)
  }
}

extension ActualBook: Equatable {
    static func == (lhs: ActualBook, rhs: ActualBook) -> Bool {
        return
            lhs.title == rhs.title
    }
}

