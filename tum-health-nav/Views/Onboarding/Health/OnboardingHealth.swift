//
//  OnboardingHealthPoints.swift
//  tum-health-nav
//
//  Created by Nikolai Madlener on 30.05.21.
//  Copyright © 2021 TUM. All rights reserved.
//

import SwiftUI

// MARK: - View

struct OnboardingHealthView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            viewModel.getGoalTypeIcon(for: viewModel.type)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
            Text(viewModel.type.rawValue)
                .font(.system(size: 32, weight: .bold))
                .multilineTextAlignment(.center)
            
            viewModel.getExplanation(for: viewModel.type).font(.callout)
            
            CircularSlider(viewModel: .init(container: viewModel.container, type: viewModel.type, factor: viewModel.getFactor()))
        }
    }
}

// MARK: - ViewModel

extension OnboardingHealthView {
    class ViewModel: ObservableObject {
        
        // Misc
        let container: DIContainer
        var type: GoalType
        
        init(container: DIContainer, type: GoalType) {
            self.container = container
            self.type = type
        }
        
        func getFactor() -> CGFloat {
            switch type {
            case GoalType.met:
                return 60
            case GoalType.steps:
                return 20000
            case GoalType.calories:
                return 1200
            case GoalType.walkDistance:
                return 15000
            case GoalType.bikeDistance:
                return 16000
            }
        }
        
        func getExplanation(for type: GoalType) -> Text {
            switch type {
            case GoalType.met:
                return Text("A Health Point is one minute of movement that equals or exeeds the intensity of a brisk walk.")
            default:
                return Text("")
            }
        }
        
        func getGoalTypeIcon(for type: GoalType) -> Image {
            switch type {
            case GoalType.met:
                return Image(systemName: "heart.fill")
            case GoalType.steps:
                return Image(systemName: "figure.walk")
            case GoalType.calories:
                return Image(systemName: "flame.fill")
            case GoalType.walkDistance:
                return Image(systemName: "figure.walk")
            case GoalType.bikeDistance:
                return Image(systemName: "bicycle")
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct OnboardingHealthView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingHealthView(viewModel: .init(container: .preview, type: .met))
    }
}
#endif
