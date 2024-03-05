//
//  ShareableImage.swift
//  MagicIDR
//
//  Created by 박재우 on 2/29/24.
//

import UIKit
import LinkPresentation

final class ShareableImageProvider: NSObject {
    private let image: UIImage
    private let index: Int

    init(image: UIImage, index: Int) {
        self.image = image
        self.index = index
        super.init()
    }
}

extension ShareableImageProvider: UIActivityItemSource {
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return image
    }

    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return image
    }

    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        guard let jpgImage = image.jpegData(compressionQuality: 1.0) else { return nil }
        let metadata = LPLinkMetadata()
        metadata.title = "\(index+1)번째 이미지를 공유합니다."
        metadata.originalURL = URL(filePath: "JPEG File · \(jpgImage.fileSize())")
        metadata.imageProvider = NSItemProvider(object: image)
        return metadata
    }
}

private extension Data {
    func fileSize() -> String {
        let size = Double(self.count) // in bytes
        if size < 1024 {
            return String(format: "%.2f bytes", size)
        } else if size < 1024 * 1024 {
            return String(format: "%.2f KB", size/1024.0)
        } else {
            return String(format: "%.2f MB", size/(1024.0*1024.0))
        }
    }
}
