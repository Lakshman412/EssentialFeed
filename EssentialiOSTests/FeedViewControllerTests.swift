//
//  FeedViewControllerTests.swift
//  EssentialiOSTests
//
//  Created by lakshman-7016 on 01/08/22.
//

import XCTest
import UIKit
import Essential

class FeedViewController: UITableViewController {
	private var loader: FeedLoader?

	convenience init(loader: FeedLoader) {
		self.init()
        self.loader = loader
	}

	override func viewDidLoad() {
		super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        refreshControl?.beginRefreshing()
        load()
	}
    
    @objc private func load() {
        loader?.load() { [weak self] _ in
            self?.refreshControl?.endRefreshing()
        }
    }
}

final class FeedViewControllerTests: XCTestCase {
    
	func test_init_doesNotLoadFeed() {
        let (_, loader) = self.makeSUT()

		XCTAssertEqual(loader.loadCallCount, 0)
	}

	func test_viewDidLoad_loadsFeed() {
        let (sut, loader) = self.makeSUT()

		sut.loadViewIfNeeded()

		XCTAssertEqual(loader.loadCallCount, 1)
	}
    
    func test_userInitiatedFeedReload_loadsFeed() {
        let (sut, loader) = self.makeSUT()
        sut.loadViewIfNeeded()
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCallCount, 2)
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCallCount, 3)
    }
    
    func test_viewDidLoad_showsLoadingIndicator() {
        let (sut, _) = self.makeSUT()

        sut.loadViewIfNeeded()

        XCTAssertTrue(sut.isShowingLoadingIndicator)
    }
    
    func test_viewDidLoad_hidesIndicatorOnLoaderCompletion() {
        let (sut, loader) = self.makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFeedLoading()

        XCTAssertFalse(sut.isShowingLoadingIndicator)
    }
    
    func test_userInitiatedFeedReload_showsLoadingIndicator() {
        let (sut, _) = self.makeSUT()

        sut.simulateUserInitiatedFeedReload()

        XCTAssertTrue(sut.isShowingLoadingIndicator)
    }
    
    func test_userInitiatedFeedReload_hidesIndicatorOnLoaderCompletion() {
        let (sut, loader) = self.makeSUT()

        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoading()

        XCTAssertFalse(sut.isShowingLoadingIndicator)
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        return (sut, loader)
    }

	class LoaderSpy: FeedLoader {
		private(set) var loadCallCount = 0
        private var completions = [(FeedLoader.Result) -> Void]()

        func load(completion: @escaping (FeedLoader.Result) -> Void) {
			loadCallCount += 1
            self.completions.append(completion)
		}
        
        func completeFeedLoading() {
            self.completions[0](.success([]))
        }
	}
}

private extension FeedViewController {
    func simulateUserInitiatedFeedReload() {
        self.refreshControl?.simulatePullToRefresh()
    }
    
    var isShowingLoadingIndicator: Bool {
        refreshControl?.isRefreshing ?? false
    }
}

private extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
