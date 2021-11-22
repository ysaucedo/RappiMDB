//
//  ViewModelSerieList.swift
//  RappiMDB Yair
//
//  Created by Yair Saucedo on 21/11/21.
//

import UIKit
import Foundation

class ViewModelSerieList {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    //Mecanismo enlazar la vista con este modelo de la vista
    var refreshData = { () -> () in }
    var refreshDataFilter = { () -> () in }

    var lastPage:Int = 0
    var category:Category = .popular
    
    //Fuente de datos
    var dataArray: [Serie] = [] {
        didSet {
            refreshData()
        }
    }
    
    var dataArrayFilter: [Serie] = [] {
        didSet  {
            refreshDataFilter()
        }
    }

    func searchData(search:String, completion: @escaping (_ result: Error?) -> Void) {
        do{
            self.dataArrayFilter = try self.context.fetch(Serie.fetchRequestFilter(category: category, search: search))
        } catch {
            print("error  \(error.localizedDescription) ")
        }
    }

 
    func retriveData(completion: @escaping (_ result: Error?) -> Void) {
        
        lastPage+=1
        
        do{
            self.dataArray = try self.context.fetch(Serie.fetchRequest(category: category))
            //YSH Se quitó ya que al paginar ya hay datos desde que carga la primer página
            //if dataArray.count == 0 {
            if true {
                let themoviews = SerieDB()
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
                            let show: Serie! = try self?.context.fetch(Serie.fetchRequestById(id: showTheMovie.id, category: self!.category)).first

                            if (show == nil){
                                let newItem = Serie(context: self!.context)
                                newItem.backdrop_path = showTheMovie.backdrop_path
                                newItem.category = "\(self!.category)"
                                newItem.first_air_date = showTheMovie.first_air_date
                                newItem.id = showTheMovie.id
                                newItem.name = showTheMovie.name
                                newItem.original_language = showTheMovie.original_language
                                newItem.overview = showTheMovie.overview
                                newItem.popularity = showTheMovie.popularity
                                newItem.poster_path = showTheMovie.poster_path
                                newItem.vote_average = showTheMovie.vote_average
                                newItem.vote_count = showTheMovie.vote_count

                            }
                            
                        }
                        try self!.context.save()
                        self!.dataArray = try self!.context.fetch(Serie.fetchRequest(category: self!.category))
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
