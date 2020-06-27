//
//  ViewController.swift
//  Example
//
//  Created by William Boles on 27/06/2020.
//  Copyright © 2020 William Boles. All rights reserved.
//

import UIKit
import InsightfulPagination

class ScrollerViewController: UIViewController, PagingDataSource, PagingDelegate {
    
    private lazy var pages: [PageViewController] = {
        var pages = [PageViewController]()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        for index in 0..<50 {
            let pageViewController = storyboard.instantiateViewController(identifier: "PageViewController") as! PageViewController
            _ = pageViewController.view // Hacky to get the IBOutlets to connect
            pageViewController.labelPage.text = "Page: \(index)"
            pages.append(pageViewController)
        }
        
        return pages
    }()
    
    private lazy var pagingViewController: PagingViewController = {
        let pagingViewController = PagingViewController(initialPageViewController: self.pages[0], pageSize: self.view.frame.size, initialPageIsCenterPage: false)
        pagingViewController.dataSource = self
        pagingViewController.delegate = self
        
        return pagingViewController
    }()
    
    // MARK: - ViewLifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addChild(pagingViewController)
        view.addSubview(pagingViewController.view)
        pagingViewController.didMove(toParent: self)
        
        pagingViewController.beginAppearanceTransition(true, animated: true)
    }
    
    // MARK: - PagingDataSource
    
    func viewControllerBefore(viewController: UIViewController) -> UIViewController? {
        guard let pageViewController = viewController as? PageViewController,
            let index = pages.firstIndex(of: pageViewController),
            index > 0 else {
                return nil
        }
        
        let indexOfViewControllerBefore = index - 1
        return pages[indexOfViewControllerBefore]
    }
    
    func viewControllerAfter(viewController: UIViewController) -> UIViewController? {
        guard let pageViewController = viewController as? PageViewController,
            let index = pages.firstIndex(of: pageViewController),
            index < (pages.count - 1) else {
                return nil
        }
        
        let indexOfViewControllerAfter = index + 1
        return pages[indexOfViewControllerAfter]
    }
    
    // MARK: - PagingDelegate
    
    func willMove(from viewController: UIViewController) {
        guard let fromViewController = pagingViewController.focusedViewController as? PageViewController else {
            return
        }
        
        fromViewController.labelInformational.text = "Welcome back"
    }

    func didMove(to toViewController: UIViewController, from fromViewController: UIViewController) {
        guard let toPageViewController = toViewController as? PageViewController,
            let fromPageViewController = fromViewController as? PageViewController,
            let toIndex = pages.firstIndex(of: toPageViewController),
            let fromIndex = pages.firstIndex(of: fromPageViewController) else {
                return
        }
        
        let direction = toIndex > fromIndex ? "forwards" : "backwards"
        
        toPageViewController.labelInformational.text = "You moved onto this page by scrolling \(direction)"
    }
    
    func scrollingPages() {
        guard let pageViewController = pagingViewController.focusedViewController as? PageViewController else {
            return
        }
        
        pageViewController.labelInformational.text = "Goodbye"
    }
}

