//
//  Modal.swift
//  tum-health-nav
//
//  Created by Nikolai Madlener on 04.01.21.
//  Copyright © 2021 TUM. All rights reserved.
//

import SwiftUI

enum ModalState: CGFloat {
    
    case closed, open
    
    func offsetFromTop() -> CGFloat {
        switch self {
        case .closed:
            return Config.hasTopNotch ? (UIScreen.main.bounds.height - 160) : (UIScreen.main.bounds.height - 120)
        case .open:
            return UIScreen.main.bounds.height * 0.1
        }
    }
}

struct Modal {
    var position: ModalState  = .closed
    var content: AnyView?
}
