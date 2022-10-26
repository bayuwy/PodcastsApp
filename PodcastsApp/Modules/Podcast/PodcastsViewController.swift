//
//  PodcastsViewController.swift
//  PodcastsApp
//
//  Created by Bayu Yasaputro on 26/10/22.
//

import UIKit

class PodcastsViewController: BaseViewController {
    @IBOutlet weak var tableView: UITableView!
    let searchController = UISearchController(searchResultsController: nil)
    var searchTime: Timer?
    
    let viewModel = PodcastsViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setup()
    }
    
    func setup() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func searchPodcasts(q: String) {
        searchTime?.invalidate()
        searchTime = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { [weak self] (timer) in
            self?.viewModel.searchPodcasts(q: q) { [weak self] (result) in
                self?.tableView.reloadData()
            }
        })
    }
}

// MARK: - UITableViewDataSource
extension PodcastsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "podcastCellId", for: indexPath) as! PodcastViewCell
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension PodcastsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
