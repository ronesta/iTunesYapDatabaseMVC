//
//  ViewController.swift
//  iTunesYapDatabaseMVC
//
//  Created by Ибрагим Габибли on 30.12.2024.
//

import UIKit
import SnapKit

final class SearchViewController: UIViewController {
    lazy var searchView: SearchView = {
        let view = SearchView(frame: .zero)
        view.searchViewController = self
        return view
    }()

    let searchCollectionViewDataSource = SearchCollectionViewDataSource()

    override func loadView() {
        super.loadView()
        view = searchView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
    }

    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        searchView.configureCollectionView(dataSource: searchCollectionViewDataSource)
        searchView.configureSearchBar(delegate: self)
    }

    private func setupNavigationBar() {
        navigationItem.titleView = searchView.searchBar
    }

    func searchAlbums(with term: String) {
        let savedAlbums = DatabaseManager.shared.loadAllAlbums(forTerm: term)
        if !savedAlbums.isEmpty {
            self.searchCollectionViewDataSource.albums = savedAlbums
            self.searchView.collectionView.reloadData()
        } else {
            NetworkManager.shared.fetchAlbums(albumName: term) { [weak self] result in
                switch result {
                case .success(let albums):
                    DispatchQueue.main.async {
                        let sortedAlbums = albums.sorted { $0.collectionName < $1.collectionName }
                        self?.searchCollectionViewDataSource.albums = sortedAlbums
                        self?.searchView.collectionView.reloadData()
                        DatabaseManager.shared.saveAlbums(sortedAlbums)
                        DatabaseManager.shared.saveAlbumsForSearchQuery(albums: sortedAlbums, term)
                        print("Successfully loaded \(albums.count) albums.")
                    }
                case .failure(let error):
                    print("Failed to load images with error: \(error.localizedDescription)")
                }
            }
        }
    }
}

// MARK: - UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        guard let searchTerm = searchBar.text, !searchTerm.isEmpty else {
            return
        }
        DatabaseManager.shared.saveSearchTerm(searchTerm)
        searchAlbums(with: searchTerm)
    }
}

