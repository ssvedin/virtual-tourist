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
}

struct Photos: Codable {
    let page: Int
    let pages: Int
    let perpage: Int
    let total: Int
    let photo: [Photo]
    let stat: String
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
}

// TODO: CodingKeys
