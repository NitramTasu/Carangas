//
//  REST.swift
//  Carangas
//
//  Created by Usuário Convidado on 13/03/19.
//  Copyright © 2019 Eric Brito. All rights reserved.
//

import Foundation

class REST {
    private static let basePath = "https://carangas.herokuapp.com/cars"
    
    private static let configuration: URLSessionConfiguration = {
        let config = URLSessionConfiguration.default
        config.allowsCellularAccess = false
        config.httpAdditionalHeaders = ["Content-Type":"application/json"]
        config.timeoutIntervalForRequest = 30.0
        config.httpMaximumConnectionsPerHost = 3
        return config
    }()
    
    private static let session = URLSession(configuration: configuration)
    
    
    class func loadCars(onComplete: @escaping ([Car])->Void) {
        guard let url: URL = URL(string: basePath) else {
            print("Erro ao montar URL")
            return
        }
        
        let task = session.dataTask(with: url){(data, response, error) in
            if error != nil {
                print("Deu erro", error!)
                return
            }
            guard let response = response as? HTTPURLResponse else{
                print("Response nulo")
                return
            }
            
            if response.statusCode != 200 {
                print("Erro de status code", response.statusCode)
            }
            
            guard let data = data else{
                print("Dados inválidos!")
                return
            }
            
            do{
                let cars = try JSONDecoder().decode([Car].self, from: data)
                print("Total de carros:", cars.count)
                onComplete(cars)
            }catch{
                print("Erro ao tratar JSON")
            }
        }
        task.resume()
    }
    
    public class func applyOperation(_ operation: RESTOperation, car: Car, onComplete: @escaping (Bool)->Void){
        let urlString = basePath + "/" + (car._id ?? "")
        var httpMethod: String = ""
        switch operation {
        case .delete:
            httpMethod = "DELETE"
        case .save:
            httpMethod = "POST"
        case .update:
            httpMethod = "PUT"
        }
        
        guard let url = URL(string: urlString) else{
            onComplete(false)
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = httpMethod
        urlRequest.httpBody = try!JSONEncoder().encode(car)
        
        let task = session.dataTask(with: urlRequest){ (data, _, _) in
            guard let _ = data else{
                onComplete(false)
                return
            }
            onComplete(true)
        }
        task.resume()
    }

}

enum RESTOperation{
    case update
    case delete
    case save
}
