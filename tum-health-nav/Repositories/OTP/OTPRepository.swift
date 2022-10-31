//
//  OTPClient.swift
//  tum-health-nav
//
//  Created by Sven Andabaka on 12.06.20.
//  Copyright © 2020 TUM. All rights reserved.
//

import Foundation
import Combine

// MARK: - RepositoryProtocol

protocol OTPRepository {
    func getOTPResponse(otpRequest: OTPRequest) -> AnyPublisher<OTPPlan, Error>
}

// MARK: - RealRepository

struct RealOTPRepository: OTPRepository {
    
    let bgQueue = DispatchQueue(label: "bg_parse_queue")
    var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .millisecondsSince1970
        return decoder
    }()
    
    func getOTPResponse(otpRequest: OTPRequest) -> AnyPublisher<OTPPlan, Error> {
        guard let url = getOTPUrl(otpRequest: otpRequest) else {
            return Fail<OTPPlan, Error>(error: Errors.requestURLWrong).eraseToAnyPublisher()
        }
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 300.0
        sessionConfig.timeoutIntervalForResource = 300.0
        let session = URLSession(configuration: sessionConfig)
        
        return session.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: OTPPlan.self, decoder: decoder)
            .mapError({ err in
                print("OTP Request error: \(err)")
                return Errors.otpRequestFailed
            })
            .subscribe(on: bgQueue)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    private func getOTPUrl(otpRequest: OTPRequest) -> URL? {
        var urlComponents = URLComponents()
        
        urlComponents.scheme = Config.scheme
        urlComponents.host = Config.host
        urlComponents.port = Config.port
        urlComponents.path = Config.path
        
        urlComponents.queryItems = [
            URLQueryItem(name: Config.dateParam, value: otpRequest.getDate()),
            URLQueryItem(name: Config.timeParam, value: otpRequest.getTime()),
            URLQueryItem(name: Config.toParam, value: otpRequest.getStringForPlace(place: otpRequest.toPlace)),
            URLQueryItem(name: Config.fromParam, value: otpRequest.getStringForPlace(place: otpRequest.fromPlace)),
            URLQueryItem(name: Config.modeParam, value: otpRequest.getMode())
        ]
        
        if otpRequest.bikeLocation != nil {
            urlComponents.queryItems?.append(
                URLQueryItem(name: Config.bikeLocationParam, value: otpRequest.getBikeLocation())
            )
        }
        
        if otpRequest.constraints != nil {
            urlComponents.queryItems?.append(
                URLQueryItem(name: Config.constraintsParam, value: otpRequest.getConstraints())
            )
        }
        
        debugPrint(urlComponents.url ?? "")
        
        return urlComponents.url
    }
}

// MARK: - StubRepository

struct StubOTPRepository: OTPRepository {
    func getOTPResponse(otpRequest: OTPRequest) -> AnyPublisher<OTPPlan, Error> {
        Fail<OTPPlan, Error>(error: Errors.otpRequestFailed).eraseToAnyPublisher()
    }
}
