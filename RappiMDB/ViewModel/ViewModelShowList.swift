//
//  ViewModelShowList.swift
//  RappiMDB Yair
//
//  Created by Yair Saucedo on 21/11/21.
//

import UIKit
import Foundation

class ViewModelShowList {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    //Mecanismo enlazar la vista con este modelo de la vista
    var refreshData = { () -> () in }
    var refreshDataFilter = { () -> () in }

    var lastPage:Int = 0
    var category:Category = .popular
    
    //Fuente de datos
    var dataArray: [Show] = [] {
        didSet {
            refreshData()
        }
    }
    
    var dataArrayFilter: [Show] = [] {
        didSet  {
            refreshDataFilter()
        }
    }

    func searchData(search:String, completion: @escaping (_ result: Error?) -> Void) {
        do{
            self.dataArrayFilter = try self.context.fetch(Show.fetchRequestFilter(category: category, search: search))
        } catch {
            print("error  \(error.localizedDescription) ")
        }
    }

 
    func retriveData(completion: @escaping (_ result: Error?) -> Void) {
        
        lastPage+=1
        
        do{
            self.dataArray = try self.context.fetch(Show.fetchRequest(category: category))
            //YSH Se quitó ya que al paginar ya hay datos desde que carga la primer página
            //if dataArray.count == 0 {
            if true {
                let themoviews = TheMovieDB()
                themoviews.retriveData(lastPage: lastPage, category: category, completion: {
                    (respuesta) in
                    if (respuesta != nil) {
                        print(respuesta!.localizedDescription)
                        completion(respuesta)
                    }
                })
                themoviews.refreshData = { [weak self] () in
                    do{

                        for showTheMovie in themoviews.dataArray {
                            //Revisar si ya se encuentra la película en la base de datos
                            let show: Show! = try self?.context.fetch(Show.fetchRequestById(id: showTheMovie.id, category: self!.category)).first

                            if (show == nil){
                                let newItem = Show(context: self!.context)
                                newItem.adult = false
                                //newItem.genre_ids
                                newItem.backdrop_path = showTheMovie.backdrop_path
                                newItem.id = showTheMovie.id
                                newItem.original_language = showTheMovie.original_language
                                newItem.overview = showTheMovie.overview
                                newItem.popularity = showTheMovie.popularity
                                newItem.poster_path = showTheMovie.poster_path
                                newItem.release_date = showTheMovie.release_date
                                newItem.title = showTheMovie.title
                                newItem.video = showTheMovie.video
                                newItem.vote_average = showTheMovie.vote_average
                                newItem.vote_count = showTheMovie.vote_count
                                newItem.category = "\(self!.category)"

                            }
                            
                        }
                        try self!.context.save()
                        self!.dataArray = try self!.context.fetch(Show.fetchRequest(category: self!.category))
                    } catch {
                        print("error  \(error.localizedDescription) ")
                    }
                }
                
            }
            
        } catch {
            print("error  \(error.localizedDescription) ")
        }
    }
}
