//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation

protocol CoinManagerDelegate {
    func didUpdateCoinPrice(lastPrice: Double, currency: String)
    func didFailWithError(error: Error)
}

struct CoinManager {
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "F733B0F7-F9A1-476D-8C92-4EBDDA2E6472"
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    
    
    var delegate : CoinManagerDelegate?

    func getCoinPrice(for currency: String) {
        let currencyURL = "\(baseURL)/\(currency)?apikey=\(apiKey)"
        performRequest(with: currencyURL, currency: currency)
    }
    
    func performRequest(with urlString: String, currency: String) {
        
        if let url = URL(string: urlString) {
            
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if let rate = parseJSON(safeData) {
                        delegate?.didUpdateCoinPrice(lastPrice: rate, currency: currency)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON (_ data: Data) -> Double? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(CoinData.self, from: data)
            let lastPrice = decodedData.rate
            return lastPrice
        } catch {
            delegate?.didFailWithError(error: error)
        }
        return nil
    }

}
