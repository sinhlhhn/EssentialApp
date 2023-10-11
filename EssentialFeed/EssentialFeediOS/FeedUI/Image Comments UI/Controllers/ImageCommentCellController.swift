//
//  ImageCommentCellController.swift
//  EssentialFeediOS
//
//  Created by Sam on 11/10/2023.
//

import UIKit
import EssentialFeed

public class ImageCommentCellController: NSObject, CellController {
    private let model: ImageCommentViewModel
    
    public init(model: ImageCommentViewModel) {
        self.model = model
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ImageCommentCell = tableView.dequeueReusableCell()
        cell.dateLabel.text = model.date
        cell.messageLabel.text = model.message
        cell.usernameLabel.text = model.username
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        
    }
}
