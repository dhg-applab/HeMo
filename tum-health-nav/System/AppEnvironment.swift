//
//  AppEnvironment.swift
//  tum-health-nav
//
//  Created by Nikolai Madlener on 30.01.21.
//  Copyright © 2021 TUM. All rights reserved.
//

import Combine

struct AppEnvironment {
    let container: DIContainer
}

extension AppEnvironment {
    
    func save() {
        AppState.saveToFile(container.appState.value)
    }
    
    static func bootstrap() -> AppEnvironment {
        let appState: Store<AppState>
        if let loadedAppState = AppState.loadFromFile() {
            appState = Store<AppState>(loadedAppState)
        } else {
            appState = Store<AppState>(AppState())
        }
        let repositories = configuredRepositories(appState: appState)
        let services = configuredServices(appState: appState, repositories: repositories)
        let diContainer = DIContainer(appState: appState, services: services)

        return AppEnvironment(container: diContainer)
    }
    
    private static func configuredRepositories(appState: Store<AppState>) -> DIContainer.Repositories {
//        let persistentStore = CoreDataStack(version: CoreDataStack.Version.actual)
        let healthKitRepository = RealHealthKitRepository()
        let otpRepository = RealOTPRepository()
        return .init(healthKitRepository: healthKitRepository, otpRepository: otpRepository)
    }

    private static func configuredServices(appState: Store<AppState>,
                                           repositories: DIContainer.Repositories) -> DIContainer.Services {

        let tripService = RealTripService(appState: appState, otpRepository: repositories.otpRepository)
        let generalService = RealGeneralService(appState: appState)
        let navigationConstraintService = RealNavigationConstraintsService(appState: appState)
        let statisticService = RealStatisticService(appState: appState, healthKitRepository: repositories.healthKitRepository)
        let profileService = RealProfileService(appState: appState, healthKitRepository: repositories.healthKitRepository)
        
        return .init(tripService: tripService,
                     generalService: generalService,
                     navigationConstraintService: navigationConstraintService,
                     statisticService: statisticService,
                     profileService: profileService)
    }
}

extension AppState: LocalFileStorable {
    static var fileName = "AppState"
}
    
extension DIContainer {
    struct Repositories {
        let healthKitRepository: HealthKitRepository
        let otpRepository: OTPRepository
    }
}
