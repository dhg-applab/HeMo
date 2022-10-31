//
//  ModeratePaceView.swift
//  tum-health-nav
//
//  Created by Joe Yu on 19.01.22.
//  Copyright © 2022 TUM. All rights reserved.
//

import SwiftUI
import CoreLocation

// MARK: - View
// swiftlint:disable all

struct ModeratePaceView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "figure.walk")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
            Text("Walking Speed Test")
                .font(.system(size: 32, weight: .bold))
                .multilineTextAlignment(.center)
            Text("Walk in your personal moderate pace for one Minute without stopping.").font(.callout)
            HStack {
                Image(systemName: "info.circle")
                Text("This helps us providing you with custom tailored routes later.").font(.caption)
            }
            
            Spacer().frame(height: 32)
            HStack {
                Text("Timer: ")
                    .font(.system(size: 30, weight: .heavy))
                Text(viewModel.printSecondsToHoursMinutesSeconds(seconds: viewModel.timeRemaining))
                    .font(.system(size: 30, weight: .heavy))
                    .frame(minWidth: 100)
            }.padding(.bottom, 20)
            Text(viewModel.locationPermission ? "" : "Location permissions disabled. Go to settings.").font(.caption).foregroundColor(.red)
            getTimerView()
            Spacer()
        }.onDisappear {
            if viewModel.isTimerRunning {
                viewModel.resetTest()
            }
        }.onAppear {
            viewModel.requestLocationPermission()
        }
    }
    
    func getTimerView() -> AnyView {
        if(!viewModel.isTimerRunning && !viewModel.isTimerFinished){
            return AnyView(Button(action: {
                viewModel.requestLocationPermission()
                viewModel.locationPermissionEnabled()
                if viewModel.locationPermission {
                    viewModel.startTimer()
                }
            }) {
                ZStack {
                    Circle()
                        .fill(Color.green)
                        .frame(width:100, height: 100)
                    Text("Go!")
                        .foregroundColor(Color.white)
                        .font(.system(size: 18, weight: .heavy))
                }
            })
        } else if viewModel.isTimerFinished {
            return AnyView(
                VStack {
                    Text("Your normal walking speed is: ").padding()
                    HStack {
                        Text("\(viewModel.getWalkingSpeed())").font(.system(size: 30, weight: .heavy))
                        Text("km/h")
                    }.padding()
                    HStack {
                        Text("Something went wrong? ").font(.caption)
                        Button(action: {
                            viewModel.isTimerFinished = false
                            viewModel.timeRemaining = 60
                        }) {
                            Text("Repeat test")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                }
            )
        } else {
            return AnyView(Text("Keep walking!"))
        }
    }
}


// MARK: - ViewModel
extension ModeratePaceView {
    class ViewModel: ObservableObject{
        
        private var distanceKit = WalkingSpeedService()
        
        // State
        @Published var timeRemaining = 60
        @Published var isTimerRunning = false
        @Published var timer: Timer?
        @Published var isTimerFinished = false
        @Published var locationPermission = true
        
        var speed: Double = 0.0
        
        // Misc
        let container: DIContainer
        
        init(container: DIContainer) {
            self.container = container
        }
        
        func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
            return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
        }
        
        func printSecondsToHoursMinutesSeconds (seconds:Int) -> String {
            let (_, m, s) = secondsToHoursMinutesSeconds (seconds: seconds)
            return ("\(m):\(String(format: "%02d", s))")
        }
        
        func getWalkingSpeed() -> String {
            String(format: "%.1f", self.speed)
        }
        
        func startTimer() {
            let startTime = Date()
            self.distanceKit.start()
            self.isTimerRunning = true
            self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                self.timeRemaining -= 1
                if self.timeRemaining <= 0 {
                    timer.invalidate()
                    self.isTimerRunning = false
                    
                    self.distanceKit.stop()
                    let distanceData = DistanceData(startTime: self.distanceKit.dateFormatting(date: startTime), endTime: self.distanceKit.dateFormatting(date: Date()), distanceTravel: self.distanceKit.distanceTraveled, intensityType: .moderate, walkingSpeed: self.distanceKit.getWalkingSpeed(distance: self.distanceKit.distanceTraveled, start: startTime, end: Date()), gpsLogs: self.distanceKit.gpsLogs)
                    self.speed = distanceData.walkingSpeed
                    self.isTimerFinished = true
                    
                    // save the walking speed on local storage of device for future sessions
                    let defaults = UserDefaults.standard
                    defaults.set(self.speed, forKey: "walkingSpeed")
                }
            }
        }
        
        func requestLocationPermission() {
            UserLocation().locationManager.requestLocation()
        }
        
        func locationPermissionEnabled() {
            if CLLocationManager.locationServicesEnabled() {
                switch CLLocationManager.authorizationStatus() {
                case .notDetermined, .restricted, .denied:
                    self.locationPermission = false
                case .authorizedAlways, .authorizedWhenInUse:
                    self.locationPermission = true
                @unknown default:
                    self.locationPermission = false
                }
            }
        }
        
        func resetTest() {
            self.timer?.invalidate()
            self.isTimerRunning = false
            self.timeRemaining = 60
            self.isTimerFinished = false
            self.distanceKit.stop()
        }
    }
}

// MARK: - Preview

#if DEBUG
struct ModeratePaceView_Previews: PreviewProvider {
    static var previews: some View {
        ModeratePaceView(viewModel:  .init(container: .preview))
    }
}
#endif
