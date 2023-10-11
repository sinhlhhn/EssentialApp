//
//  CellController.swift
//  EssentialFeediOS
//
//  Created by Sam on 11/10/2023.
//

import UIKit

public struct CellController {
    let datasource: UITableViewDataSource
    let delegate: UITableViewDelegate?
    let prefetching: UITableViewDataSourcePrefetching?
    
    public init(_ datasource: UITableViewDataSource & UITableViewDelegate & UITableViewDataSourcePrefetching) {
        self.datasource = datasource
        self.delegate = datasource
        self.prefetching = datasource
    }
    
    public init(_ datasource: UITableViewDataSource) {
        self.datasource = datasource
        self.delegate = nil
        self.prefetching = nil
    }

}
