import UIKit
import Combine
import Foundation

struct Post: Codable {
    let title: String
    let body: String
}

func getPost() -> AnyPublisher<[Post],Error> {
    guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else {
        fatalError("InvalidURL")
    }
    
   return URLSession.shared.dataTaskPublisher(for: url).map {$0.data}
        .decode(type: [Post].self, decoder: JSONDecoder())
        .eraseToAnyPublisher()
}


let cancelable = getPost().sink(receiveCompletion: { _ in }, receiveValue: {print($0)})
