//
//  TheMovieDB.swift
//  RappiMDB
//
//  Created by Yair Saucedo on 20/11/21.
//

import Foundation

class TheMovieDB {
    
    var refreshData = { () -> () in }
    
    //Fuente de datos
    var dataArray: [ShowTheMovie] = [] {
        didSet {
            refreshData()
        }
    }
    
    func retriveData(lastPage:Int, category:Category, completion: @escaping (_ result: Error?) -> Void) {
        //let url = URL(string: "https://api.themoviedb.org/3/search/movie?api_key=356016d8da514101815ff58c16ef4639&language=en-US&query=spiderman&page=1&include_adult=false")
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(category)?api_key=356016d8da514101815ff58c16ef4639&language=en-US&page=\(lastPage)")

        let tarea:URLSessionDataTask = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            do {
                if (data == nil) {
                    completion(Network.errorDomainCFNetwork)
                }
                guard let json = data else { return }
                
                let responseString = NSString(data: json, encoding: String.Encoding.utf8.rawValue)
                print("****** response data = \(responseString!)")

                let decoder = JSONDecoder()
                let result:Result = try decoder.decode(Result.self, from: json)
                //self.dataArray = try decoder.decode([ShowTheMovie].self, from: json)
                self.dataArray = result.results
            } catch let error {
                print(String(describing: error))
                //print("error  \(error.localizedDescription) ")
            }
        }
        tarea.resume()
    }
    
}
