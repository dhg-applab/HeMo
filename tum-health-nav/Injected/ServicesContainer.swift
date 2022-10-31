//
//  ServicesContainer.swift
//  tum-health-nav
//
//  Created by Nikolai Madlener on 30.01.21.
//  Copyright © 2021 TUM. All rights reserved.
//

extension DIContainer {
    struct Services {
        let tripService: TripService
        let generalSerive: GeneralService
        let navigationConstraintService: NavigationConstraintsService
        let statisticService: StatisticService
        let profileService: ProfileService
        
        init(tripService: TripService,
             generalService: GeneralService,
             navigationConstraintService: NavigationConstraintsService,
             statisticService: StatisticService,
             profileService: ProfileService) {
            self.tripService = tripService
            self.generalSerive = generalService
            self.navigationConstraintService = navigationConstraintService
            self.statisticService = statisticService
            self.profileService = profileService
        }
        
        static var stub: Self {
            .init(tripService: StubTripService(),
                  generalService: StubGeneralService(),
                  navigationConstraintService: StubNavigationConstraintsService(),
                  statisticService: StubStatisticService(),
                  profileService: StubProfileService())
        }
    }
}
