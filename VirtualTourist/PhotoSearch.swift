//
//  PhotoSearch.swift
//  VirtualTourist
//
//  Created by Sabrina on 6/2/19.
//  Copyright © 2019 Sabrina Svedin. All rights reserved.
//

import Foundation
//import UIKit
//import MapKit

class PhotoSearch {
    
    enum Endpoints {
        static let base = "https://api.flickr.com/services/rest"
        static let photoSearch = "?method=flickr.photos.search"
        static let apiKey = "49a1e77aa399c3a23a9fca742e91480d"
        
        case getPhotos
        
        var stringValue: String {
            switch self {
            case .getPhotos:
                return Endpoints.base + Endpoints.photoSearch + "&extras=url_sq" + "&api_key=\(Endpoints.apiKey)" + "&lat=40.7128&lon=74.0060" + "&per_page=21" + "&format=json&nojsoncallback=1"// TODO: change lat long hardcoded to NY
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func searchPhotos(completion: @escaping (Photos?, Error?) -> Void) {
        var request = URLRequest(url: Endpoints.getPhotos.url)
        print(request)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                completion(nil, error)
                print("Error != nil")
            }
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                    print("No data.")
                }
                return
            }
            do {
                let response = try JSONDecoder().decode(PhotoSearchResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(response.photos, nil)
                    print(response.photos)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                    print("Error decoding data.")
                }
            }
        }
        task.resume()
    }
    
    class func downloadPhoto(url: URL, completion: @escaping (Data?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                completion(nil, error)
                print("no data, or there was an error")
                return
            }
            completion(data, nil)
        }
        task.resume()
    }    
    
}
