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
        runCombine()
    }
    
    func runTask() {
        Task {
            let result: Result<User, SUNetworkError> = await networkService.execute(req)
            
            switch result {
            case .success(let user):
                print("TASK: Request completed successfully")
                print("TASK: Received response: \(user)")
            case .failure(let error):
                print("TASK: Request failed with error: \(error)")
            }
        }
    }
    
    func runCombine() {
        networkService.execute(req)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("COMBINE: Request completed successfully")
                case .failure(let error):
                    print("COMBINE: Request failed with error: \(error)")
                }
            }, receiveValue: { (user: User) in
                print("COMBINE: Received response: \(user)")
            })
            .store(in: &cancellables)
    }
}
