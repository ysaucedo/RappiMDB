//
//  SerieVC.swift
//  RappiMDB Yair
//
//  Created by Yair Saucedo on 20/11/21.
//

import UIKit
import Kingfisher

class SerieVC: UIViewController {
    
    var viewModel = ViewModelSerieList()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var categorySegment: UISegmentedControl!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLbl: UILabel!
    
    var searching:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureView()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
        
    private func configureView() {
        tableView.delegate = self
        tableView.dataSource = self
        activityIndicator.style = .whiteLarge
        activityIndicator.isHidden = true
        activityIndicator.startAnimating()
        searchBar.placeholder = "Search movie"
        searchBar.delegate = self
        getNextPage()
    }
    
    private func getNextPage() {
        viewModel.retriveData(completion: {
            (respuesta) in
            if (respuesta != nil) {
                let shareMenu = UIAlertController(title: nil, message: "Ocurrió un error al consultar el servicio. ¿Quieres intentar nuevamente?", preferredStyle: .alert)
                let aceptAction = UIAlertAction(title: "Reintentar", style: .default, handler:  { action in
                    self.configureView()
                })
                let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
                shareMenu.addAction(aceptAction)
                shareMenu.addAction(cancelAction)
                DispatchQueue.main.async {
                    self.present(shareMenu, animated: true, completion: nil)
                }
            }
        })

    }
    
    private func bind() {
 
        viewModel.refreshData = { [weak self] () in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.activityIndicator.stopAnimating()
                self?.activityIndicator.isHidden = true
            }
        }
        
        viewModel.refreshDataFilter = { [weak self] () in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.activityIndicator.stopAnimating()
                self?.activityIndicator.isHidden = true
            }
            
        }
        
    }
    
    @IBAction func categorySegment(_ sender: UISegmentedControl) {
        self.viewModel.lastPage = 0
        
        searchBar.text = ""
        searching = false
        switch sender.selectedSegmentIndex {
        case 0:
            self.viewModel.category = Category.popular
        case 1:
            self.viewModel.category = Category.top_rated
        case 2:
            self.viewModel.category = Category.upcoming
        default:
            break
        }
        
        getNextPage()
    }
    
}

extension SerieVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (searching){
            return viewModel.dataArrayFilter.count
        }else{
            return viewModel.dataArray.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ShowTableViewCell
        
        let object:Serie
        if (searching){
             object = viewModel.dataArrayFilter[indexPath.row]
        }else{
            object = viewModel.dataArray[indexPath.row]
        }
        
        cell.titleLbl?.text = object.name

        if let poster_path = object.poster_path {
            let url = URL(string: "https://image.tmdb.org/t/p/w342/\(poster_path)")
            cell.imageShow?.kf.setImage(with: url)
        }else {
            if #available(iOS 13.0, *) {
                cell.imageShow.image = UIImage(systemName: "nosign")
            } else {
                // Fallback on earlier versions
            }
        }
                        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == viewModel.dataArray.count - 7 {
            getNextPage()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc: SerieDetailVC = SerieDetailVC.instantiate(appStoryboard: .main)
        let object:Serie
        if (searching){
             object = viewModel.dataArrayFilter[indexPath.row]
        }else{
            object = viewModel.dataArray[indexPath.row]
        }
        //vc.show = viewModel.dataArray[indexPath.row]
        vc.show = object
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    
}

extension SerieVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        searchBar.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //Filtrar hasta que se tengan 2 caracteres
        if searchText.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                searchBar.resignFirstResponder()
            }
            searchBar.endEditing(true)
            searching = false
            tableView.reloadData()
        }else if searchText.count >= 2 {
            viewModel.searchData(search: searchText.lowercased(), completion: {
                (respuesta) in
            })
            searching = true
        }
    }
    
}
