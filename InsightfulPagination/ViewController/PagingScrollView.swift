//
//  PagingScrollView.swift
//  InsightfulPagination
//
//  Created by William Boles on 26/06/2020.
//  Copyright © 2020 William Boles. All rights reserved.
//

import UIKit

class PagingScrollView: UIView {

    private(set) var scrollViewContent: UIScrollView
    
    // MARK: - Init
    
    init(frame: CGRect, pageSize: CGSize, pagePadding: CGFloat, centerPage: Bool) {
        let contentFrame: CGRect
        if centerPage {
            let x = (frame.size.width - (pageSize.width + pagePadding))/2
            let y = (frame.size.height - pageSize.height)/4
            let width = pageSize.width + pagePadding
            let height = pageSize.height
            
            contentFrame = CGRect(x: x, y: y, width: width, height: height)
        } else {
            contentFrame = CGRect(x: 0, y: 0, width: pageSize.width, height: pageSize.height)
        }
        scrollViewContent = UIScrollView(frame: contentFrame)
        
        scrollViewContent.isPagingEnabled = true
        scrollViewContent.showsHorizontalScrollIndicator = false
        scrollViewContent.showsHorizontalScrollIndicator = false
        scrollViewContent.bounces = false
        scrollViewContent.isDirectionalLockEnabled = true
        scrollViewContent.clipsToBounds = false
        
        super.init(frame: frame)
        
        addSubview(scrollViewContent)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Hit
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard self.point(inside: point, with: event),
         let hitView = super.hitTest(point, with: event) else {
            return nil
        }
        
        guard hitView == self else {
            return hitView
        }
        
        return scrollViewContent
    }
}
