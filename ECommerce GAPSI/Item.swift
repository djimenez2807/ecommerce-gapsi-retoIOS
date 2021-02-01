//
//  Product.swift
//  ECommerce GAPSI
//
//  Created by Diego Jiménez on 01/02/21.
//

import Foundation

struct ItemsHeader: Decodable {
    let totalResults, page: Int
    let items: [Item]
}

struct Item: Decodable {
    let id: String
    let rating: Double?
    let price: Double
    let image: String
    let title: String
}
