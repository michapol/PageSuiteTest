//
//  Downloader.swift
//  PageSuiteTest
//
//  Created by Mike Pollard on 06/12/2017.
//  Copyright © 2017 Mike Pollard. All rights reserved.
//

import Foundation

class Loader {
    
    public static func loadFavorites() -> [String] {
        guard let favorites = UserDefaults.standard.array(forKey: "Favorites") as? [String] else {
            let empty: [String] = []
            return empty
        }
        return favorites
    }
    
    public static func addFavorite(_ favoriteID: String) {
        var favorites = loadFavorites()
        favorites.append(favoriteID)
        saveFavorites(favorites)
    }
    
    public static func removeFavorite(_ favoriteID: String) {
        var favorites = loadFavorites()
        if let index = favorites.index(of: favoriteID) {
            favorites.remove(at: index)
        }
        saveFavorites(favorites)
    }
    
    public static func saveFavorites(_ favorites: [String]) {
        UserDefaults.standard.set(favorites as Any?, forKey: "Favorites")
    }
    
    public static func getCachedJSON() -> [String: Any]? {
        guard let cacheDirectory = FileManager().urls(for: .cachesDirectory, in: .userDomainMask).first else {
            print("Error: unable to get cache directory")
            return nil
        }
        
        let cachedJSONFile = cacheDirectory.appendingPathComponent(Constants.jsonFile)
        
        if let contentJSONFile = NSData(contentsOf: cachedJSONFile) {
            do {
                if let json = try JSONSerialization.jsonObject(with: contentJSONFile as Data, options: []) as? [String:Any] {
                    return json
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    public static func getRemoteJSON(completion: @escaping ([String: Any]?) -> ()) {
        var jsonData: [String: Any]?
        
        guard let url = URL(string: Constants.jsonURL) else {
            print("Error generating URL from String")
            return
        }
        
        let request = URLRequest(url: url)

        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                        jsonData = json
                        if !saveJSON(data) {
                            print("Failed: Unable to save JSON")
                        }
                    }
                } catch {
                    print(error.localizedDescription)
                }
                completion(jsonData)
            }
        }
        task.resume()
    }
    
    private static func saveJSON(_ json: Data) -> Bool {
        guard let cacheDirectory = FileManager().urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return false
        }
        let fileURL = cacheDirectory.appendingPathComponent(Constants.jsonFile)
        
        if NSKeyedArchiver.archiveRootObject(json, toFile: fileURL.path) {
            print("Saved JSON File")
            return true
        }
        return false
    }
    
    private static func getImage(_ urlString: String, id: String) -> NSData? {
        guard let cacheDirectory = FileManager().urls(for: .cachesDirectory, in: .userDomainMask).first else {
            print("GET-IMAGE: No Cache Directory")
            return nil
        }

        guard let url = URL(string: urlString) else {
            return nil
        }
        let file = cacheDirectory.appendingPathComponent(id)
        
        print("GET-IMAGE: \(url.path)")
        print("GET-IMAGE: \(file.path)")

        if let imageData = try? Data(contentsOf: file) {
            print("GET-IMAGE: Loaded File")
            return imageData as NSData
        } else if let imageData = try? Data(contentsOf: url) {
            try? imageData.write(to: file)
            print("GET-IMAGE: Downloaded Image")
            return imageData as NSData
        } else {
            print("GET-IMAGE: No Image")
            return nil
        }
    }
    
    public static func loadStories(_ json: [String: Any]) -> [Stories] {
        var stories: [Stories] = []
        let favorites = loadFavorites()
        
        var id: String = ""
        var title: String = ""
        var author: String = ""
        var link: String = ""
        var imageURL: String = ""
        var imageData: NSData?

        if let jsonData = json["data"] as? [[[String:Any]]] {
            if let jsonData = jsonData.first {
                for jsonStories in jsonData {
                    if let jsonID = jsonStories["id"] as? String {
                        id = jsonID
                    }
                    if let jsonTitle = jsonStories["title"] as? String {
                        title = jsonTitle
                    }
                    if let jsonAuthor = jsonStories["author"] as? [String:Any] {
                        if let jsonAuthorName = jsonAuthor["name"] as? String {
                            author = jsonAuthorName
                        }
                    }
                    if let jsonImageSection = jsonStories["image"] as? [String: Any] {
                        if let jsonImageURLString = jsonImageSection["medium"] as? String {
                            imageURL = jsonImageURLString
                            imageData = getImage(jsonImageURLString, id: id)
                        }
                    }
                    if let jsonLink = jsonStories["url"] as? String {
                        link = jsonLink
                    }
                    let story = Stories(id, newTitle: title, newAuthor: author, newURL: link, newImageURL: imageURL, newImageData: imageData)
                    if favorites.contains(id) {
                        story.favorite = true
                    }
                    stories.append(story)
                }
            }
        }
        print("LOAD-STORIES: \(stories.count)")
        return stories
    }
    
}
