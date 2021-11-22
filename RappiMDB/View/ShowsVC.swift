//
//  ShowsVC.swift
//  RappiMDB Yair
//
//  Created by Yair Saucedo on 20/11/21.
//

import UIKit
import Kingfisher

class ShowsVC: UIViewController {
    
    var viewModel = ViewModelShowList()
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

extension ShowsVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (searching){
            return viewModel.dataArrayFilter.count
        }else{
            return viewModel.dataArray.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ShowTableViewCell
        
        let object:Show
        if (searching){
            object = viewModel.dataArrayFilter[indexPath.row]
        }else{
            object = viewModel.dataArray[indexPath.row]
        }
        
        cell.titleLbl?.text = object.title

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
        let vc: ShowDetailVC = ShowDetailVC.instantiate(appStoryboard: .main)
        let object:Show
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
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if  viewModel.dataArray[indexPath.row].adult {
            let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete" , handler: { (action:UITableViewRowAction, indexPath: IndexPath) -> Void in
                // 2
                let shareMenu = UIAlertController(title: nil, message: "Delete favorite", preferredStyle: .actionSheet)
                let aceptAction = UIAlertAction(title: "Acept", style: .destructive, handler:  { action in
                    self.setFavorite(show: self.viewModel.dataArray[indexPath.row])
                    tableView.reloadRows(at: [indexPath], with: .fade)
                })
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                shareMenu.addAction(aceptAction)
                shareMenu.addAction(cancelAction)
                
                self.present(shareMenu, animated: true, completion: nil)
            })
            return [deleteAction]
        }else{
            let addAction = UITableViewRowAction(style: .normal, title: "Favorite" , handler: { (action:UITableViewRowAction, indexPath: IndexPath) -> Void in
                self.setFavorite(show: self.viewModel.dataArray[indexPath.row])
                tableView.reloadRows(at: [indexPath], with: .fade)
            })
            addAction.backgroundColor = UIColor.green
            return [addAction]
        }
    }
    
    func setFavorite(show:Show){
        show.adult = !show.adult
        do{
            try self.context.save()
        } catch {
            print("error  \(error.localizedDescription) ")
        }
    }
    
}

extension ShowsVC: UISearchBarDelegate {
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
