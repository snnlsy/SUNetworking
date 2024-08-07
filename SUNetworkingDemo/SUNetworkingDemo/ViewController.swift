//
//  ViewController.swift
//  SUNetworkingDemo
//
//  Created by SUlusoy on 7.08.2024.
//

import UIKit
import SUNetworking

struct User: Codable {
    let userId: Int
    let id: Int
    let title: String
    let completed: Bool
}

struct ExampleAPIEnvironment: URLRequestable {
    let method: HTTPMethod = .get
    let path: String = "/todos/1"
    let baseURL: URL = URL(string: "https://jsonplaceholder.typicode.com")!
}

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let apiEnvironment = ExampleAPIEnvironment()
        let networkService: SUNetworkServicing = SUNetworkService()
        
        Task {
            let result: Result<User, NetworkError> = await networkService.execute(apiEnvironment)
            
            switch result {
            case .success(let user):
                print("User fetched successfully:")
                print("Title: \(user.title)")
            case .failure(let error):
                print("Error fetching user: \(error)")
            }
        }
    }
}
