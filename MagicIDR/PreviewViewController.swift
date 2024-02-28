//
//  PreviewViewController.swift
//  MagicIDR
//
//  Created by 박재우 on 2/5/24.
//

import UIKit

protocol PreviewViewControllerDelegate: NSObject {
    func previewViewControllerWillDisappear(_ previewViewController: PreviewViewController, images: ModifiedStack<UIImage>)
}

class PreviewViewController: UIViewController {

    var images = ModifiedStack<UIImage>()

    weak var delegate: PreviewViewControllerDelegate?

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

    private let deleteButton = {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 17, weight: .bold)
        let image = UIImage(systemName: "trash", withConfiguration: imageConfig)
        var buttonConfig = UIButton.Configuration.plain()
        buttonConfig.image = image
        buttonConfig.baseForegroundColor = .white
        return UIButton(configuration: buttonConfig)
    }()

    private let counterclockwiseButton = {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 17, weight: .bold)
        let image = UIImage(systemName: "arrow.counterclockwise", withConfiguration: imageConfig)
        var buttonConfig = UIButton.Configuration.plain()
        buttonConfig.image = image
        buttonConfig.baseForegroundColor = .white
        return UIButton(configuration: buttonConfig)
    }()

    private let cropButton = {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 17, weight: .bold)
        let image = UIImage(systemName: "square.and.arrow.up", withConfiguration: imageConfig)
        var buttonConfig = UIButton.Configuration.plain()
        buttonConfig.image = image
        buttonConfig.baseForegroundColor = .white
        return UIButton(configuration: buttonConfig)
    }()

    private lazy var abilitiesStackView = {
        let stackView = UIStackView()
        stackView.addArrangedSubview(deleteButton)
        stackView.addArrangedSubview(counterclockwiseButton)
        stackView.addArrangedSubview(cropButton)
        stackView.distribution = .fillEqually
        stackView.backgroundColor = .white.withAlphaComponent(0.1)
        return stackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setPageViewController()
        setUI()
        setLayout()
        setNavigationBar()

        deleteButton.addTarget(self, action: #selector(deleteImage), for: .touchUpInside)
        counterclockwiseButton.addTarget(self, action: #selector(rotatingImage), for: .touchUpInside)
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
        view.backgroundColor = .systemBackground
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        view.addSubview(abilitiesStackView)

        setTitle(withIndex: images.count - 1)
    }

    private func setLayout() {
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        abilitiesStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            pageViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            abilitiesStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            abilitiesStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            abilitiesStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            abilitiesStackView.heightAnchor.constraint(equalToConstant: 70)
        ])
    }

    private func setNavigationBar() {
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]

        self.navigationController?.navigationBar.titleTextAttributes = titleTextAttributes
        self.navigationController?.navigationBar.backgroundColor = .clear
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationItem.leftBarButtonItem = backBarButtonItem

        backBarButtonItem.action = #selector(back)
        backBarButtonItem.target = self
    }

    private func setTitle(withIndex index: Int) {
        title = "\(index + 1) / \(images.count)"
    }

    @objc private func back() {
        delegate?.previewViewControllerWillDisappear(self, images: images)
        self.navigationController?.popViewController(animated: false)
    }

    @objc private func deleteImage() {
        // 현재 content의 pageIndex 탐색
        guard let viewController =  self.pageViewController.viewControllers?.first,
              let contentController = viewController as? ContentViewController,
              let currentIndex = contentController.pageIndex else {
            return
        }

        images.remove(at: currentIndex)

        // 데이터가 없다면 촬영 모드로 돌아가기
        guard !images.isEmpty else {
            delegate?.previewViewControllerWillDisappear(self, images: images)
            navigationController?.popViewController(animated: true)
            return
        }

        // 삭제된 index가 마지막 번호였다면 index - 1로 .reverse 형태로 표현
        guard currentIndex != images.count else {
            let willAppearController = contentViewController(atIndex: currentIndex - 1)!
            pageViewController.setViewControllers([willAppearController],
                                                  direction: .reverse,
                                                  animated: true)
            setTitle(withIndex: currentIndex - 1)
            return
        }

        // 위 조건을 제외한 모든 경우의 수는 삭제된 index의 데이터로 .forward 형태로 표현
        let willAppearController = contentViewController(atIndex: currentIndex)!
        pageViewController.setViewControllers([willAppearController],
                                              direction: .forward,
                                              animated: true)

        setTitle(withIndex: currentIndex)
    }

    @objc private func rotatingImage() {
        guard let viewController =  self.pageViewController.viewControllers?.first,
              let contentController = viewController as? ContentViewController,
              let currentIndex = contentController.pageIndex else {
            return
        }

        guard let originImage = images.element(at: currentIndex),
              let rotatedImage = originImage.rotateCounterClockwise() else {
            return
        }

        images.swap(rotatedImage, at: currentIndex)

        let willAppearController = contentViewController(atIndex: currentIndex)!
        pageViewController.setViewControllers([willAppearController],
                                              direction: .forward,
                                              animated: false)
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

fileprivate extension UIImage {
    func rotateCounterClockwise() -> UIImage? {
        var newOrientation: UIImage.Orientation?

        switch self.imageOrientation {
        case .up:
            newOrientation = .left
        case .down:
            newOrientation = .right
        case .left:
            newOrientation = .down
        case .right:
            newOrientation = .up
        default:
            break
        }

        guard let newOrientation = newOrientation else {
            return nil
        }

        if let ciImage {
            return UIImage(ciImage: ciImage, scale: 1, orientation: newOrientation)
        } else if let cgImage {
            return UIImage(cgImage: cgImage, scale: 1, orientation: newOrientation)
        } else {
            return nil
        }
    }
}
