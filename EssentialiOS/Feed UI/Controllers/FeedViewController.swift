//
//  FeedViewController.swift
//  EssentialiOS
//
//  Created by lakshman-7016 on 08/08/22.
//

import Essential
import UIKit

final public class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
    private var refeshController: FeedRefreshViewController?
    var tableModel = [FeedImageCellController]() {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    convenience init(refreshController: FeedRefreshViewController) {
        self.init()
        self.refeshController = refreshController
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        self.refreshControl = refeshController?.view
        tableView.prefetchDataSource = self
        self.refeshController?.refresh()
        
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cellController(forRowAt: indexPath).view()
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelCellControllerLoad(forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellController(forRowAt: indexPath).preload()
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelCellControllerLoad)
    }
    
    private func cellController(forRowAt indexPath: IndexPath) -> FeedImageCellController {
        return tableModel[indexPath.row]
    }
    
    private func cancelCellControllerLoad(forRowAt indexPath: IndexPath) {
        cellController(forRowAt: indexPath).cancelLoad()
    }
}
