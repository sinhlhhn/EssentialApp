//
//  HTTPURLResponse+StatusCode.swift
//  EssentialFeed
//
//  Created by Sam on 19/09/2023.
//

import Foundation

extension HTTPURLResponse {
    private static let OK_200: Int = 200
    
    var isOK: Bool {
        statusCode == HTTPURLResponse.OK_200
    }
}
