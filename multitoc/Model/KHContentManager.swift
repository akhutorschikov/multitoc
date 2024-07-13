//
//  KHContentManager.swift
//  Multitoc
//
//  Created by Alex Khuala on 24.04.24.
//

import Foundation

/*!
 @brief Allows to load data from local and remote storage, and prepare it for display in the app
 */
final class KHContentManager
{
    // MARK: - Singleton
    
    public static let shared = KHContentManager()
    
    // MARK: - Init
    
    private init()
    {
    }

    // MARK: - Public
    
    var entries: [KHMainEntry] = []
    var local: Bool = false
    
    func loadTree(completion: @escaping () -> Void)
    {
        self.load(.tree, locally: self.local) { (result: LoadResult<[KHMainEntry]>) in
            switch result {
            case .object(let entries):
                self.entries = entries
            case .error(_):
                break
            }
            completion()
        }
    }
    
    func loadDetails(_ id: String, completion: @escaping (_ details: KHDetailsEntry?) -> Void)
    {
        self.load(.detail(id), locally: self.local) { (result: LoadResult<KHDetailsEntry>) in
            var entry: KHDetailsEntry?
            switch result {
            case .object(let r):
                entry = r
            case .error(_):
                break
            }
            completion(entry)
        }
    }
    
    func load<T: Decodable>(_ type: DataType, locally: Bool, completion: @escaping (_ result: LoadResult<T>) -> Void)
    {
        self._loadData(type, locally: locally) { data, error in
            
            guard let data = data, error == nil else {
                completion(.error(.dataUnavailable))
                return
            }
            
            let result: T
            do {
                result = try JSONDecoder().decode(T.self, from: data)
            } catch {
                completion(.error(.invalidFormat))
                return
            }
            
            completion(.object(result))
        }
    }
    
    enum LoadResult<T>
    {
        case error(ParseError)
        case object(T)
    }
    
    enum ParseError: Error
    {
        case fileNotFound
        case invalidURL
        case urlError(_ error: Error)
        case dataUnavailable
        case invalidFormat
    }
    
    enum DataType
    {
        case tree
        case detail(_ id: String)
        
        fileprivate var urlString: String {
            switch self {
            case .tree:             "https://ubique.img.ly/frontend-tha/data.json"
            case .detail(let id):   "https://ubique.img.ly/frontend-tha/entries/\(id).json"
            }
        }
        
        fileprivate var localFilename: String? {
            switch self {
            case .tree:     "tree"
            default:        "details"
            }
        }
    }
    
    // MARK: - Private
    
    private func _loadData(_ dataType: DataType, locally: Bool, completion: @escaping (_ data: Data?, _ error: ParseError?) -> Void)
    {
        if  locally {
            
            // load json data from file
            
            guard let name = dataType.localFilename, let path = Bundle.main.path(forResource: name, ofType: "json") else {
                completion(nil, .fileNotFound)
                return
            }
            completion(FileManager.default.contents(atPath: path), nil)
            
        } else {
            
            // load json data from remote source
            
            guard let url = URL(string: dataType.urlString) else {
                completion(nil, .invalidURL)
                return
            }
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                
                if  let error = error {
                    completion(nil, .urlError(error))
                    return
                }
                
                // Check if data is available
                guard let data = data else {
                    completion(nil, .dataUnavailable)
                    return
                }

                // return non empty data
                completion(data, nil)
                
            }.resume()
        }
    }
}
