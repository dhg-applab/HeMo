//
//  ModeCell.swift
//  tum-health-nav
//
//  Created by Sven Andabaka on 07.07.20.
//  Copyright © 2020 TUM. All rights reserved.
//

import SwiftUI

// MARK: - View

struct ModeCell: View {

    var modePreference: ModePreference
    
    var body: some View {
        Image(systemName: modePreference.mode.image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(minWidth: 26, maxWidth: 40, minHeight: 26, maxHeight: 40)
            .aspectRatio(1, contentMode: .fit)
            .padding()
            .foregroundColor(Color.white)
            .colorMultiply(Color.white)
            .background(modePreference.value ? modePreference.mode.color : Color.white.opacity(0.1))
            .cornerRadius(90)
            .padding(5)
    }
}

// MARK: - Preview

#if DEBUG
struct ModeCell_Previews: PreviewProvider {
    static var previews: some View {
        ModeCell(modePreference: ModePreference(value: true, mode: .bicycle))
    }
}
#endif
