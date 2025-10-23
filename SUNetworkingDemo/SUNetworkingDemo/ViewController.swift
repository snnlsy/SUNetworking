//
//  ViewController.swift
//  SUNetworkingDemo
//
//  Created by SUlusoy on 7.08.2024.
//

import UIKit
import SUNetworking
import Combine

struct User: Codable {
    let userId: Int
    let id: Int
    let title: String
    let completed: Bool
}

struct ExampleRequest: SUURLRequestable {
    let method: SUHTTPMethod = .get
    let path: String = "/todos/1"
    let baseURL: URL = URL(string: "https://jsonplaceholder.typicode.com")!
}

class ViewController: UIViewController {
    let req = ExampleRequest()
    let networkService: SUNetworkServicing = SUNetworkService()
    var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        runTask()
    }
    
    func runTask() {
        Task {
            let result: Result<User, SUNetworkError> = await networkService.execute(req)
            
            switch result {
            case .success(let user):
                print("✅ Success: \(user.title)")
            case .failure(let error):
                print("\(error.icon) \(error)")
            }
        }
    }
    
    func runCombine() {
        networkService.execute(req)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("\(error.icon) \(error)")
                }
            }, receiveValue: { (user: User) in
                print("✅ Success: \(user.title)")
            })
            .store(in: &cancellables)
    }
}
