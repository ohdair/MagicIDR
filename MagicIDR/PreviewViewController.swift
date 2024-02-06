//
//  PreviewViewController.swift
//  MagicIDR
//
//  Created by 박재우 on 2/5/24.
//

import UIKit

class PreviewViewController: UIViewController {

    var images = ModifiedStack<UIImage>()

    private var pageViewController = UIPageViewController(
        transitionStyle: .scroll,
        navigationOrientation: .horizontal
    )

    private let backBarButtonItem = {
        let buttonItem = UIBarButtonItem()
        buttonItem.tintColor = .white
        buttonItem.image = UIImage(systemName: "chevron.backward")
        return buttonItem
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setPageViewController()
        setUI()
        setLayout()
        setNavigationBar()
    }

    private func setPageViewController() {
        pageViewController.dataSource = self
        pageViewController.delegate = self
        pageViewController.didMove(toParent: self)

        if let initialViewController = contentViewController(atIndex: images.count - 1) {
            pageViewController.setViewControllers([initialViewController],
                                                  direction: .forward,
                                                  animated: true)
        }
    }

    private func setUI() {
        view.backgroundColor = .white
        addChild(pageViewController)
        view.addSubview(pageViewController.view)

        setTitle(withIndex: images.count - 1)
    }

    private func setLayout() {
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            pageViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func setNavigationBar() {
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]

        self.navigationController?.navigationBar.titleTextAttributes = titleTextAttributes
        self.navigationController?.navigationBar.backgroundColor = UIColor.main
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationItem.leftBarButtonItem = backBarButtonItem

        backBarButtonItem.action = #selector(back)
        backBarButtonItem.target = self
    }

    private func setTitle(withIndex index: Int) {
        title = "\(index + 1) / \(images.count)"
    }

    @objc private func back() {
        self.navigationController?.popViewController(animated: false)
    }
}

extension PreviewViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    private func contentViewController(atIndex index: Int) -> ContentViewController? {
        guard index >= 0 && index < images.count,
              let image = images.element(at: index) else {
            return nil
        }

        let contentViewController = ContentViewController()
        contentViewController.pageIndex = index
        contentViewController.setImage(image)

        return contentViewController
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = (viewController as? ContentViewController)?.pageIndex,
           currentIndex > 0 else {
            return nil
        }

        return contentViewController(atIndex: currentIndex - 1)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = (viewController as? ContentViewController)?.pageIndex,
              currentIndex < images.count else {
            return nil
        }

        return contentViewController(atIndex: currentIndex + 1)
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed,
           let index = (pageViewController.viewControllers?.first as? ContentViewController)?.pageIndex {
            self.setTitle(withIndex: index)
        }
    }
}
