//
//  APIDataProvider.swift
//  NASARovers
//
//  Created by Viktor Prikolota on 03.07.2024.
//

import Foundation
import Alamofire
import Combine

enum AppError: Error {
    case connectivityError
    case decodeJSONfailed
    case apiError(APIError)
    case networkError
    case other(_ error: String? = nil)

    case unknown

    var description: String {
        switch self {
        case .connectivityError: return "Connectivity Error"
        case .decodeJSONfailed: return "Decode JSON failed"
        case .apiError(let apiError): return apiError.message
        case .networkError: return "Network Error"
        case .other(let error): return error ?? "Unknown Error"
        case .unknown: return "Unknown Error"
        }
    }
}

final class APIDataProvider {
    private let endpointProvider = APIEndpointProvider()

    func request<T: Decodable>(with endpoint: Endpount) -> AnyPublisher<T, AppError> {
        print(endpointProvider.getURL(for: endpoint))
        return URLSession.shared
            .dataTaskPublisher(for: endpointProvider.getURL(for: endpoint))
            .subscribe(on: DispatchQueue.global(qos: .background))
            .receive(on: DispatchQueue.main)
            .mapError { _ in .connectivityError }
            .flatMap { data, response -> AnyPublisher<T, AppError> in
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase

                if let response = response as? HTTPURLResponse {
                    if (200...299).contains(response.statusCode) {
                        return Just(data)
                            .decode(type: T.self, decoder: decoder)
                            .mapError {_ in .decodeJSONfailed}
                            .eraseToAnyPublisher()

                    } else {
                        do {
                            let errorResponse = try decoder.decode(APIErrorResponse.self, from: data)
                            return Fail(error: .apiError(errorResponse.error))
                                .eraseToAnyPublisher()
                        } catch {
                            return Fail(error: .decodeJSONfailed)
                                .eraseToAnyPublisher()
                        }
                    }
                }
                return Fail(error: .unknown)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
