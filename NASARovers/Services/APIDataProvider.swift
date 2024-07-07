//
//  APIDataProvider.swift
//  NASARovers
//
//  Created by Viktor Prikolota on 03.07.2024.
//

import Foundation
import Alamofire

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

    func getData<T: Decodable>(for endpoint: Endpount,
                               completionHandler: @escaping (T) -> Void,
                               errorHandler: @escaping (AppError) -> Void) {
        DispatchQueue.global(qos: .background).async { [self] in
            let request = URLRequest(url: endpointProvider.getURL(for: endpoint))

            AF.request(endpointProvider.getURL(for: endpoint))
                .response { response in
                    DispatchQueue.main.async {
                        switch response.result {
                        case .success(let data):
                            guard let data,
                                  let statusCode = response.response?.statusCode else {
                                errorHandler(.networkError)
                                return
                            }

                            let decoder = JSONDecoder()
                            decoder.keyDecodingStrategy = .convertFromSnakeCase
                            print("Request URL", request.url!)
                            if (200...299) ~= statusCode {
                                do {
                                    let object = try decoder.decode(T.self, from: data)
                                    completionHandler(object)
                                } catch {
                                    errorHandler(.decodeJSONfailed)
                                }
                            } else {
                                do {
                                    let errorResponse = try decoder.decode(APIErrorResponse.self, from: data)
                                    errorHandler(.apiError(errorResponse.error))
                                } catch {
                                    errorHandler(.unknown)
                                }
                            }
                        case .failure(let error):
                            errorHandler(.other(error.localizedDescription))
                        }
                    }
                }
        }
    }
}
