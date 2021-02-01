//
//  ViewController.swift
//  ECommerce GAPSI
//
//  Created by Diego Jiménez on 01/02/21.
//

import UIKit

class ViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet var tableViewItems: UITableView!
    @IBOutlet weak var search: UISearchBar!
    
    let url =  "https://00672285.us-south.apigw.appdomain.cloud/demo-gapsi/search?"
    let apiKey = "adb8204d-d574-4394-8c1a-53226a40876e"
    
    var itemsHeader: ItemsHeader?
    
    var isCancelFlagKeyboard: Bool = false
    
    var historySearch: [String]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewItems.dataSource = self
        search.delegate = self
        
        let defaults = UserDefaults.standard
        self.historySearch = defaults.stringArray(forKey: "queryHistory") ?? [String]()
        
        print(historySearch!)
        

    }
    
    func searchByName(query: String) {
        
        if query.isEmpty { return }
        
        showWaitAlert()
        
        let param = "&query=" + query
        
        let url = URL(string: self.url + param)
        guard let requestUrl = url else { fatalError() }
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "GET"
        
        request.setValue(self.apiKey, forHTTPHeaderField: "X-IBM-Client-Id")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                print("Ocurrió un error...", error)
                return
            }
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                self.itemsHeader = try! JSONDecoder().decode(ItemsHeader.self
                                                           , from: dataString.data(using: .utf8)!)
                
                DispatchQueue.main.async {
                    self.tableViewItems.reloadData()
                    self.dismiss(animated: false, completion: nil)
                    if !self.historySearch.contains(query) {
                        self.historySearch.append(query)
                        let preferences = UserDefaults.standard
                        preferences.set(self.historySearch, forKey: "queryHistory")
                    }
                    
                    
                }
                
            }
        }
        task.resume()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = self.search.text else { return }
        if query.count <= 0  { return }
        self.search.resignFirstResponder()
        searchByName(query: query)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.dismiss(animated: false, completion: nil)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        print(self.isCancelFlagKeyboard)

        if self.isCancelFlagKeyboard {
            self.search.becomeFirstResponder()
            self.isCancelFlagKeyboard = false
        } else if self.historySearch.count > 0 {
            
            self.search.resignFirstResponder()
                                                
                        
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

            for queryHistory in self.historySearch {
                alert.addAction(UIAlertAction(title: queryHistory, style: .default) { _ in
                    self.search.text = queryHistory
                    self.search.resignFirstResponder()
                    self.searchByName(query: queryHistory)
                })
            }
            alert.addAction(UIAlertAction(title: "Borrar historial de búsqueda", style: .default) { _ in
                self.historySearch.removeAll()
                self.search.becomeFirstResponder()
                let preferences = UserDefaults.standard
                preferences.set(self.historySearch, forKey: "queryHistory")
            })
            
            alert.addAction(UIAlertAction(title: "Otra búsequeda", style: .cancel, handler: { _ in
                self.isCancelFlagKeyboard = true
                self.search.becomeFirstResponder()
            }))


            present(alert, animated: true)
        }

    }
    
    func showWaitAlert() {
        let alert = UIAlertController(title: nil, message: "Buscando...", preferredStyle: .alert)

        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating();

        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
    }
    
    
    
    

}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.itemsHeader?.items.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "item", for: indexPath) as! ItemCell
        guard let itemRow = self.itemsHeader?.items[indexPath.row] else { return cell }        
        cell.setItem(item: itemRow)
        return cell
    }
}

