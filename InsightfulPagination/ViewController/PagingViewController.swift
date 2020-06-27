//
//  PagingViewController.swift
//  InsightfulPagination
//
//  Created by William Boles on 26/06/2020.
//  Copyright © 2020 William Boles. All rights reserved.
//

import UIKit

public protocol PagingDataSource: class {
    func viewControllerBefore(viewController: UIViewController) -> UIViewController?
    func viewControllerAfter(viewController: UIViewController) -> UIViewController?
}

public protocol PagingDelegate: class {
    func willMove(from viewController: UIViewController)
    func didMove(to toViewController: UIViewController, from fromViewController: UIViewController)
    func scrollingPages()
}

private enum ChildViewControllerPosition {
    case left
    case middle
    case right
}

public class PagingViewController: UIViewController, UIScrollViewDelegate {
    public weak var delegate: PagingDelegate?
    public weak var dataSource: PagingDataSource?
    
    public private(set) var pageSize: CGSize
    public var isDragging: Bool {
        viewLimited?.scrollViewContent.isDragging ?? false
    }
    
    public var focusedViewController: UIViewController? {
        switch position {
        case .left:
            return pageOneViewController
        case .middle:
            return pageTwoViewController
        case .right:
            if let pageThreeViewController = pageThreeViewController {
                return pageThreeViewController
            } else {
                return pageTwoViewController
            }
        }
    }
    
    private var initialPageViewController: UIViewController
    
    private var centerPage: Bool
    
    private var viewPageOne: UIView?
    private var viewPageTwo: UIView?
    private var viewPageThree: UIView?
    
    private var pageOneViewController: UIViewController? {
        didSet {
            pageOneViewController?.view.frame = CGRect(x: pagePadding/2, y: 0, width: pageSize.width, height: pageSize.height)
        }
    }
    
    private var pageTwoViewController: UIViewController? {
        didSet {
            pageTwoViewController?.view.frame = CGRect(x: pagePadding/2, y: 0, width: pageSize.width, height: pageSize.height)
        }
    }
    private var pageThreeViewController: UIViewController? {
        didSet {
            pageThreeViewController?.view.frame = CGRect(x: pagePadding/2, y: 0, width: pageSize.width, height: pageSize.height)
        }
    }
    
    private var pagePadding: CGFloat {
        (view.frame.size.width - pageSize.width)/4
    }
    
    private var position: ChildViewControllerPosition = .middle
    
    private var viewLimited: PagingScrollView?
    
    // MARK: - Init
    
    public init(initialPageViewController: UIViewController, pageSize: CGSize, initialPageIsCenterPage: Bool) {
        self.pageSize = pageSize
        self.initialPageViewController = initialPageViewController
        self.centerPage = initialPageIsCenterPage
        super.init(nibName: nil, bundle: nil)
    }
    
    convenience init(initialPageViewController: UIViewController) {
        self.init(initialPageViewController: initialPageViewController, pageSize: CGSize.zero, initialPageIsCenterPage: false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - ViewLifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpPages()
    }
    
    // MARK: - SetUp
    
    private func setUpPages() {
        if pageSize == CGSize.zero {
            pageSize = view.frame.size
        }
        
        /*------------------------*/
        
        if let dataSource = dataSource {
            if let beforeViewController = dataSource.viewControllerBefore(viewController: initialPageViewController) {
                if let nextViewController = dataSource.viewControllerAfter(viewController: initialPageViewController) {
                    pageOneViewController = beforeViewController
                    pageTwoViewController = initialPageViewController
                    pageThreeViewController = nextViewController
                    
                    position = .middle
                } else {
                    //Why do we need this?
                    if let beforeBeforeViewController = dataSource.viewControllerBefore(viewController: beforeViewController) {
                        pageOneViewController = beforeBeforeViewController
                        pageTwoViewController = beforeBeforeViewController
                        pageThreeViewController = initialPageViewController
                    } else {
                        pageOneViewController = beforeViewController
                        pageTwoViewController = initialPageViewController
                    }
                    
                    position = .right
                }
            } else {
                if let nextViewController = dataSource.viewControllerAfter(viewController: initialPageViewController) {
                    //Why do we need this?
                    if let nextNextViewController = dataSource.viewControllerAfter(viewController: nextViewController) {
                        pageOneViewController = initialPageViewController
                        pageTwoViewController = nextViewController
                        pageThreeViewController = nextNextViewController
                    } else {
                        pageOneViewController = initialPageViewController
                        pageTwoViewController = nextViewController
                    }
                    
                    position = .left
                } else {
                    pageOneViewController = initialPageViewController
                    
                    position = .left
                }
            }
        } else {
            pageOneViewController = initialPageViewController
            
            position = .left
        }
        
        /*------------------------------*/
        
        //TODO: Could this be created elsewhere?
        let viewLimited = PagingScrollView(frame: view.bounds, pageSize: pageSize, pagePadding: pagePadding, centerPage: centerPage)
        viewLimited.scrollViewContent.delegate = self
        
        view.addSubview(viewLimited)
        self.viewLimited = viewLimited
        
        /*------------------------------*/
        
        var numberOfPages = 0
        
        if pageOneViewController != nil {
            let viewPageOneRect = CGRect(origin: .zero, size: viewLimited.scrollViewContent.frame.size)
            let viewPageOne = UIView(frame: viewPageOneRect)
            self.viewPageOne = viewPageOne
            
            viewLimited.scrollViewContent.addSubview(viewPageOne)
            
            numberOfPages += 1
            
            if pageTwoViewController != nil {
                let viewPageTwoPoint = CGPoint(x: viewPageOne.frame.size.width + viewPageOne.frame.origin.x, y: 0)
                let viewPageTwoRect = CGRect(origin: viewPageTwoPoint, size: viewLimited.scrollViewContent.frame.size)
                let viewPageTwo = UIView(frame: viewPageTwoRect)
                self.viewPageTwo = viewPageTwo
                
                viewLimited.scrollViewContent.addSubview(viewPageTwo)
                    
                numberOfPages += 1
                
                if pageThreeViewController != nil {
                    let viewPageThreePoint = CGPoint(x: viewPageTwo.frame.size.width + viewPageTwo.frame.origin.x, y: 0)
                    let viewPageThreeRect = CGRect(origin: viewPageThreePoint, size: viewLimited.scrollViewContent.frame.size)
                    let viewPageThree = UIView(frame: viewPageThreeRect)
                    self.viewPageThree = viewPageThree
                    
                    viewLimited.scrollViewContent.addSubview(viewPageThree)
                        
                    numberOfPages += 1
                }
            }
        }
        
        /*------------------------*/
        
        switch position {
        case .left:
            if let pageOneViewController = pageOneViewController {
                addChild(pageOneViewController)
                viewPageOne?.addSubview(pageOneViewController.view)
                pageOneViewController.beginAppearanceTransition(true, animated: true)
                
                if let pageTwoViewController = pageTwoViewController {
                    addChild(pageTwoViewController)
                    viewPageTwo?.addSubview(pageTwoViewController.view)
                    pageTwoViewController.beginAppearanceTransition(true, animated: true)
                    
                    if let pageThreeViewController = pageThreeViewController {
                        addChild(pageThreeViewController)
                        viewPageThree?.addSubview(pageThreeViewController.view)
                        pageThreeViewController.beginAppearanceTransition(true, animated: true)
                    }
                }
                
                DispatchQueue.main.async {
                    self.viewLimited?.scrollViewContent .scrollRectToVisible(self.viewPageOne?.frame ?? CGRect.zero, animated: false)
                }
            }
        case .middle:
            if let pageOneViewController = pageOneViewController {
                addChild(pageOneViewController)
                viewPageOne?.addSubview(pageOneViewController.view)
                pageOneViewController.beginAppearanceTransition(true, animated: true)
            }
            
            if let pageTwoViewController = pageTwoViewController {
                addChild(pageTwoViewController)
                viewPageTwo?.addSubview(pageTwoViewController.view)
                pageTwoViewController.beginAppearanceTransition(true, animated: true)
            }
            
            if let pageThreeViewController = pageThreeViewController {
                addChild(pageThreeViewController)
                viewPageThree?.addSubview(pageThreeViewController.view)
                pageThreeViewController.beginAppearanceTransition(true, animated: true)
            }
            
            DispatchQueue.main.async {
                self.viewLimited?.scrollViewContent .scrollRectToVisible(self.viewPageTwo?.frame ?? CGRect.zero, animated: false)
            }
        case .right:
            if let pageThreeViewController = pageThreeViewController {
                if let pageOneViewController = pageOneViewController {
                    addChild(pageOneViewController)
                    viewPageOne?.addSubview(pageOneViewController.view)
                    pageOneViewController.beginAppearanceTransition(true, animated: true)
                }
                
                if let pageTwoViewController = pageTwoViewController {
                    addChild(pageTwoViewController)
                    viewPageTwo?.addSubview(pageTwoViewController.view)
                    pageTwoViewController.beginAppearanceTransition(true, animated: true)
                }
                
                addChild(pageThreeViewController)
                viewPageThree?.addSubview(pageThreeViewController.view)
                pageThreeViewController.beginAppearanceTransition(true, animated: true)
                
                DispatchQueue.main.async {
                    self.viewLimited?.scrollViewContent .scrollRectToVisible(self.viewPageThree?.frame ?? CGRect.zero, animated: false)
                }
            } else {
                if let pageOneViewController = pageOneViewController {
                    addChild(pageOneViewController)
                    viewPageOne?.addSubview(pageOneViewController.view)
                    pageOneViewController.beginAppearanceTransition(true, animated: true)
                }
                
                if let pageTwoViewController = pageTwoViewController {
                    addChild(pageTwoViewController)
                    viewPageTwo?.addSubview(pageTwoViewController.view)
                    pageTwoViewController.beginAppearanceTransition(true, animated: true)
                }
                
                DispatchQueue.main.async {
                    self.viewLimited?.scrollViewContent .scrollRectToVisible(self.viewPageTwo?.frame ?? CGRect.zero, animated: false)
                }
            }
        }
        
        /*------------------------*/
        
        let width = viewLimited.scrollViewContent.frame.size.width * CGFloat(numberOfPages)
        //TODO: Discover why 100?
        let height = viewLimited.scrollViewContent.frame.size.height - 100
        viewLimited.scrollViewContent.contentSize = CGSize(width: width, height: height)
        
        /*------------------------*/
    }
    
    // MARK: - Reload
    
    public func reloadPages(withFocusOn focusedViewController: UIViewController) {
        children.forEach { childViewController in
            childViewController.view.removeFromSuperview()
            childViewController.removeFromParent()
        }
        
        initialPageViewController = focusedViewController
        
        setUpPages()
    }
    
    // MARK: - UIScrollViewDelegate
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.scrollingPages()
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if ((scrollView.contentOffset.x > scrollView.frame.size.width) ||
            (scrollView.contentOffset.x == scrollView.frame.size.width && position == .left)) &&
            (position != .right) {
            
            switch position {
            case .left:
                //TODO: Undo this force unwrap
                delegate?.willMove(from: pageOneViewController!)
                
                if pageThreeViewController != nil {
                    position = .middle
                } else {
                    position = .right
                }
                
                if scrollView.contentOffset.x > scrollView.frame.size.width {
                    //TODO: Undo this force unwrap
                    delegate?.didMove(to: pageThreeViewController!, from: pageOneViewController!)
                } else {
                    //TODO: Undo this force unwrap
                    delegate?.didMove(to: pageTwoViewController!, from: pageOneViewController!)
                }
            case .middle:
                //TODO: Undo this force unwrap
                if let thirdViewController = dataSource?.viewControllerAfter(viewController: pageThreeViewController!) {
                    //TODO: Undo this force unwrap
                    delegate?.willMove(from: pageTwoViewController!)
                    
                    /*------------------------*/
                    
                    pageOneViewController?.view.removeFromSuperview()
                    pageOneViewController?.removeFromParent()
                    
                    /*------------------------*/
                    
                    pageOneViewController = pageTwoViewController
                    
                    //TODO: Undo this force unwrap
                    addChild(pageOneViewController!)
                    viewPageOne?.addSubview(pageOneViewController!.view)
                    pageOneViewController?.beginAppearanceTransition(true, animated: true)
                    
                    /*------------------------*/
                    
                    pageTwoViewController = pageThreeViewController
                    
                    //TODO: Undo this force unwrap
                    addChild(pageTwoViewController!)
                    viewPageTwo?.addSubview(pageTwoViewController!.view)
                    pageTwoViewController?.beginAppearanceTransition(true, animated: true)
                    
                    /*------------------------*/
                    
                    pageThreeViewController = thirdViewController
                    
                    //TODO: Undo this force unwrap
                    addChild(pageThreeViewController!)
                    viewPageThree?.addSubview(pageThreeViewController!.view)
                    pageThreeViewController?.beginAppearanceTransition(true, animated: true)
                    
                    /*------------------------*/
                    
                    //TODO: Undo this force unwrap
                    viewLimited?.scrollViewContent.scrollRectToVisible(viewPageTwo!.frame, animated: false)
                    
                    //TODO: Undo this force unwrap
                    delegate?.didMove(to: pageTwoViewController!, from: pageOneViewController!)
                    
                } else {
                    position = .right
                    
                    //TODO: Undo this force unwrap
                    viewLimited?.scrollViewContent.scrollRectToVisible(viewPageThree!.frame, animated: false)
                    
                    //TODO: Undo this force unwrap
                    delegate?.didMove(to: pageThreeViewController!, from: pageTwoViewController!)
                }
            case .right:
                break
            }
        } else if (scrollView.contentOffset.x < scrollView.frame.size.width) ||
                  (scrollView.contentOffset.x == scrollView.frame.size.width && position == .right) {
            
            switch position {
            case .right:
                if scrollView.contentOffset.x != scrollView.frame.size.width {
                    if let pageThreeViewController = pageThreeViewController {
                        delegate?.willMove(from: pageThreeViewController)
                        
                        position = .left
                        
                        //TODO: Undo this force unwrap
                        delegate?.didMove(to: pageOneViewController!, from: pageThreeViewController)
                    }
                    else { //To catch when there is only two pages and the user scrolls forward on the last page
                        //TODO: Undo this force unwrap
                        delegate?.willMove(from: pageTwoViewController!)
                        
                        position = .left
                        
                        //TODO: Undo this force unwrap
                        delegate?.didMove(to: pageOneViewController!, from: pageTwoViewController!)
                    }
                } else {
                    if let pageThreeViewController = pageThreeViewController {
                        delegate?.willMove(from: pageThreeViewController)
                        
                        position = .middle
                        
                        //TODO: Undo this force unwrap
                        delegate?.didMove(to: pageTwoViewController!, from: pageThreeViewController)
                    }
                }
            case .middle:
                //TODO: Undo this force unwrap
                if let firstViewController = dataSource?.viewControllerBefore(viewController: pageOneViewController!) {
                    //TODO: Undo this force unwrap
                    delegate?.willMove(from: pageTwoViewController!)
                    
                    /*------------------------*/
                    
                    pageThreeViewController?.view.removeFromSuperview()
                    pageThreeViewController?.removeFromParent()
                    
                    /*------------------------*/
                    
                    pageThreeViewController = pageTwoViewController
                    
                    //TODO: Undo this force unwrap
                    addChild(pageThreeViewController!)
                    viewPageThree?.addSubview(pageThreeViewController!.view)
                    pageThreeViewController?.beginAppearanceTransition(true, animated: true)
                    
                    /*------------------------*/
                    
                    pageTwoViewController = pageOneViewController
                    
                    //TODO: Undo this force unwrap
                    addChild(pageTwoViewController!)
                    viewPageTwo?.addSubview(pageTwoViewController!.view)
                    pageTwoViewController?.beginAppearanceTransition(true, animated: true)
                    
                    /*------------------------*/
                    
                    pageOneViewController = firstViewController
                    
                    //TODO: Undo this force unwrap
                    addChild(pageOneViewController!)
                    viewPageOne?.addSubview(pageOneViewController!.view)
                    pageOneViewController?.beginAppearanceTransition(true, animated: true)
                    
                    /*------------------------*/
                    
                    //TODO: Undo this force unwrap
                    viewLimited?.scrollViewContent.scrollRectToVisible(viewPageTwo!.frame, animated: false)
                    
                    //TODO: Undo this force unwrap
                    delegate?.didMove(to: pageTwoViewController!, from: pageThreeViewController!)//this pageTwoViewController used to pageOneViewController before the move (above)
                    
                } else {
                    position = .left
                    
                    //TODO: Undo this force unwrap
                    viewLimited?.scrollViewContent.scrollRectToVisible(viewPageOne!.frame, animated: false)
                    
                    //TODO: Undo this force unwrap
                    delegate?.didMove(to: pageOneViewController!, from: pageTwoViewController!)
                }
            case .left:
                break
            }
        } else {
            switch position {
            case .left:
                //TODO: Undo this force unwrap
                viewLimited?.scrollViewContent.scrollRectToVisible(viewPageOne!.frame, animated: false)
            case .middle:
                //TODO: Undo this force unwrap
                viewLimited?.scrollViewContent.scrollRectToVisible(viewPageTwo!.frame, animated: false)
            case .right:
                //TODO: Undo this force unwrap
                viewLimited?.scrollViewContent.scrollRectToVisible(viewPageThree!.frame, animated: false)
            }
        }
    }
}
