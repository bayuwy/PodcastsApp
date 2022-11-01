//
//  EpisodesViewController.swift
//  PodcastsApp
//
//  Created by Bayu Yasaputro on 01/11/22.
//

import UIKit

class EpisodesViewController: BaseViewController {
    @IBOutlet weak var tableView: UITableView!
    let searchController = UISearchController(searchResultsController: nil)
    
    var viewModel: EpisodesViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setup()
    }
    
    func setup() {
        title = viewModel.title
        
        tableView.dataSource = self
        tableView.delegate = self
        
        definesPresentationContext = true
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        searchController.searchBar.delegate = self
    }
    
    func searchEpisodes(q: String) {
        viewModel.searchEpisodes(q: q) { [weak self] (_) in
            guard let `self` = self else { return }
            self.tableView.reloadData()
        }
    }
    
    func downloadEposode(at index: Int) {
        viewModel.downloadEpisode(at: index) { [weak self] (result) in
            guard let `self` = self else { return }
            
        }
    }
}

// MARK: - UISearchBarDelegate
extension EpisodesViewController: UISearchBarDelegate {
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
extension EpisodesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfEpisodes
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "episodeCellId", for: indexPath) as! EpisodeViewCell
        
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
extension EpisodesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let favorite = UIContextualAction(style: .normal, title: "Download", handler: { (_, _, completion) in
            self.downloadEposode(at: indexPath.row)
            completion(true)
        })
        favorite.image = UIImage(systemName: "icloud.and.arrow.down.fill")
        favorite.backgroundColor = UIColor.systemGreen
        
        let actions = UISwipeActionsConfiguration(actions: [favorite])
        return actions
    }
}
