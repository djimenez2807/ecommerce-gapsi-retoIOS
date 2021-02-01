//
//  ItemCell.swift
//  ECommerce GAPSI
//
//  Created by Diego Jiménez on 01/02/21.
//

import UIKit

class ItemCell: UITableViewCell {

    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var itemTitleLabel: UILabel!
    @IBOutlet weak var itemPriceLabel: UILabel!
    
    
    func setItem(item: Item) {
        itemTitleLabel.text = item.title
        itemPriceLabel.text = "$" + String(format: "%.2f", item.price)
        let url = URL(string: item.image)!
        itemImage.image = UIImage(named: "no-img.png")
        downloadImage(from: url)
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadImage(from url: URL) {
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.itemImage.image = UIImage(data: data)
            }
        }
    }

}
