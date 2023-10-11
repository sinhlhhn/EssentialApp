//
//  ImageCommentCellController.swift
//  EssentialFeediOS
//
//  Created by Sam on 11/10/2023.
//

import UIKit
import EssentialFeed

public class ImageCommentCellController: CellController {
    private let model: ImageCommentViewModel
    
    public init(model: ImageCommentViewModel) {
        self.model = model
    }
    
    public func view(in tableView: UITableView) -> UITableViewCell {
        let cell: ImageCommentCell = tableView.dequeueReusableCell()
        cell.dateLabel.text = model.date
        cell.messageLabel.text = model.message
        cell.usernameLabel.text = model.username
        
        return cell
    }
    
    public func cancel() {
        
    }
    
    public func preload() {
        
    }
    
    
}
