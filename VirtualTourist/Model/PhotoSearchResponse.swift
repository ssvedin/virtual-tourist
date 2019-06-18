//
//  PhotoSearchResponse.swift
//  VirtualTourist
//
//  Created by Sabrina on 6/2/19.
//  Copyright © 2019 Sabrina Svedin. All rights reserved.
//

import Foundation

struct PhotoSearchResponse: Codable {
    let photos: Photos
    let stat: String
}

struct Photos: Codable {
    let page: Int
    let pages: Int
    let perpage: Int
    let total: String
    let photo: [Photo]
}

struct Photo: Codable {
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
    let title: String
    let ispublic: Int
    let isfriend: Int
    let isfamily: Int
    let url_sq: String
}

// TODO: CodingKeys
