//
//  ConstraintCell.swift
//  tum-health-nav
//
//  Created by Sven Andabaka on 07.07.20.
//  Copyright © 2020 TUM. All rights reserved.
//

import SwiftUI
import Sliders

// MARK: - View

struct ConstraintCell: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        VStack {
            HStack {
                Text("\(viewModel.constraint.upperBound.mode.rawValue)").bold()
                Spacer()
                Text("\(viewModel.constraint.stringforRange)").bold().padding(.horizontal)
            }
            HStack {
                Image(systemName: "minus.circle.fill")
                RangeSlider(range: $viewModel.constraint.range)
                    .rangeSliderStyle(
                        HorizontalRangeSliderStyle(
                            track:
                                HorizontalRangeTrack(
                                    view: Capsule().foregroundColor(viewModel.constraint.upperBound.mode.color)
                                )
                                .background(Capsule().foregroundColor(viewModel.constraint.upperBound.mode.color.opacity(0.25)))
                                .frame(height: 8),
                            lowerThumbSize: CGSize(width: 20, height: 20),
                            upperThumbSize: CGSize(width: 20, height: 20)
                        )
                    )
                    .frame(height: 40)
                Image(systemName: "plus.circle.fill")
            }
        }
    }
}

// MARK: - ViewModel

extension ConstraintCell {
    class ViewModel: ObservableObject {
        
        // State
        @Published var constraint: RangeDistanceConstraintPreference
        
        // Misc
        let container: DIContainer
        private var cancelBag = CancelBag()
        
        init(container: DIContainer, constraint: RangeDistanceConstraintPreference) {
            let appState = container.appState
            self.container = container
            _constraint = .init(initialValue: constraint)
            
            if let index = appState.value.navigationConstraints.constraintPreferences
                .firstIndex(where: { constraint.lowerBound.mode == $0.lowerBound.mode }) {
                cancelBag.collect {
                    $constraint
                        .sink { appState[\.navigationConstraints.constraintPreferences][index] = $0 }
                }
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct ConstraintCell_Previews: PreviewProvider {
    static var previews: some View {
//        ConstraintCell()
        Text("")
    }
}
#endif
