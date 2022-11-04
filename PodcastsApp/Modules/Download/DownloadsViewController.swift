//
//  DownloadsViewController.swift
//  PodcastsApp
//
//  Created by Bayu Yasaputro on 04/11/22.
//

import UIKit

class DownloadsViewController: BaseViewController {
    @IBOutlet weak var tableView: UITableView!
    let searchController = UISearchController(searchResultsController: nil)
    
    var viewModel: DownloadViewModel = DownloadViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setup()
        loadDownloads()
    }
    
    func setup() {
        tableView.dataSource = self
        tableView.delegate = self
        
        definesPresentationContext = true
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        searchController.searchBar.delegate = self
    }
    
    func loadDownloads() {
        viewModel.loadDownloads { [weak self] (_) in
            self?.tableView.reloadData()
        }
    }
    
    func searchEpisodes(q: String) {
        viewModel.searchEpisodes(q: q) { [weak self] (_) in
            guard let `self` = self else { return }
            self.tableView.reloadData()
        }
    }
}

// MARK: - UISearchBarDelegate
extension DownloadsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let text = searchBar.text, text.count >= 3 {
            searchEpisodes(q: text)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text, text.count >= 3 {
            searchEpisodes(q: text)
        }
    }
}

// MARK: - UITableViewDataSource
extension DownloadsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfEpisodes
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "downloadCellId", for: indexPath) as! DownloadViewCell
        
        let index = indexPath.row
        cell.dateLabel.text = viewModel.episodePubDate(at: index)
        cell.titleLabel.text = viewModel.episodeTitle(at: index)
        cell.descriptionLabel.text = viewModel.episodeDescription(at: index)
        cell.thumbImageView.kf.setImage(with: URL(string: viewModel.episodeImagUrl(at: index))) { (result) in
            switch result {
            case.success:
                cell.thumbImageView.contentMode = .scaleAspectFill
            case .failure:
                cell.thumbImageView.contentMode = .center
                cell.thumbImageView.image = UIImage(systemName: "photo")
            }
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension DownloadsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        presentPlayerViewController(episode: viewModel.episode(at: indexPath.row))
    }
}
