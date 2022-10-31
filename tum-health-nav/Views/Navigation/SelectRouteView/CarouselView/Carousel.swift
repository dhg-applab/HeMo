//
//  Carousel.swift
//  tum-health-nav
//
//  Created by Nikolai Madlener on 15.10.20.
//  Copyright © 2020 TUM. All rights reserved.
//

import SwiftUI

// MARK: - View

struct Carousel<Items: View>: View {
    let items: Items
    let numberOfItems: CGFloat
    let spacing: CGFloat
    let widthOfHiddenCards: CGFloat
    let totalSpacing: CGFloat
    let cardWidth: CGFloat
    
    @GestureState var isDetectingLongPress = false
    @GestureState var dragState: DragState = .inactive
    
    @ObservedObject var viewModel: CarouselViewModel
        
    @inlinable public init(
        numberOfItems: CGFloat,
        spacing: CGFloat,
        widthOfHiddenCards: CGFloat,
        viewModel: CarouselViewModel,
        @ViewBuilder _ items: () -> Items) {
        
        self.items = items()
        self.numberOfItems = numberOfItems
        self.spacing = spacing
        self.widthOfHiddenCards = widthOfHiddenCards
        self.totalSpacing = (numberOfItems - 1) * spacing
        self.cardWidth = UIScreen.main.bounds.width - (widthOfHiddenCards * 2) - (spacing * 2)
        self.viewModel = viewModel
    }
    
    var body: some View {
        let totalCanvasWidth: CGFloat = (cardWidth * numberOfItems) + totalSpacing
        let xOffsetToShift = (totalCanvasWidth - UIScreen.main.bounds.width) / 2
        let leftPadding = widthOfHiddenCards + spacing
        let totalMovement = cardWidth + spacing
                
        let activeOffset = xOffsetToShift + (leftPadding) - (totalMovement * CGFloat(viewModel.activeCard))
        let nextOffset = xOffsetToShift + (leftPadding) - (totalMovement * CGFloat(viewModel.activeCard) + 1)

        var calcOffset = Float(activeOffset)
        
        if calcOffset != Float(nextOffset) {
            calcOffset = Float(activeOffset) + viewModel.screenDrag
        }
        
        return HStack(alignment: .center, spacing: spacing) {
            items
        }
        .offset(x: CGFloat(calcOffset), y: 0)
        .frame(width: UIScreen.main.bounds.size.width)
        .clipped()
        .highPriorityGesture(DragGesture()
        .updating($dragState) { drag, state, _ in
            state = .dragging(translation: drag.translation)
        }
        .onChanged {
            self.viewModel.screenDrag = Float($0.translation.width)
        }
        .onEnded { value in
            viewModel.screenDrag = 0
            
            if value.translation.width < -50 && self.viewModel.activeCard < Int(numberOfItems) - 1 {
                self.viewModel.activeCard += 1
                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                impactMed.impactOccurred()
            }
            
            if value.translation.width > 50 && self.viewModel.activeCard > 0 {
                self.viewModel.activeCard -= 1
                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                impactMed.impactOccurred()
            }
        })
        .animation(self.dragState.isDragging ? nil : Animation.spring())
    }
}

struct Canvas<Content: View>: View {
    let content: Content
    
    @inlinable init(@ViewBuilder _ content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
            .background(Color.clear.edgesIgnoringSafeArea(.all))
    }
}

struct Item<Content: View>: View {
    
    @ObservedObject var viewModel: CarouselViewModel
    let cardWidth: CGFloat
    let cardHeight: CGFloat
    
    var contentId: Int
    var content: Content
    
    @inlinable public init(
        viewModel: CarouselViewModel,
        contentId: Int,
        spacing: CGFloat,
        widthOfHiddenCards: CGFloat,
        cardHeight: CGFloat,
        @ViewBuilder _ content: () -> Content
    ) {
        self.viewModel = viewModel
        self.content = content()
        self.cardWidth = UIScreen.main.bounds.width - (widthOfHiddenCards * 2) - (spacing * 2)
        self.cardHeight = cardHeight
        self.contentId = contentId
    }
    
    var body: some View {
        content
            .frame(width: cardWidth, height: contentId == viewModel.activeCard ? cardHeight : cardHeight - 60, alignment: .center)
    }
}
