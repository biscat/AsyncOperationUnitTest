//
//  ThumbnailManager.swift
//  AsyncUnitTest
//
//  Created by william wong on 10/08/2016.
//  Copyright © 2016 William Wong. All rights reserved.
//

import Foundation
import AVFoundation
import ImageIO
import UIKit

public class ThumbnailManager: NSObject {
    
    static let concurrentOperationCount = 4
    
    var workQueue: NSOperationQueue
    
    override init() {
        workQueue = {
            let queue = NSOperationQueue()
            queue.name = "com.williamwong.thumbnailcache.workqueue"
            queue.maxConcurrentOperationCount = ThumbnailManager.concurrentOperationCount
            return queue
        }()
    }
    
    deinit {
        workQueue.cancelAllOperations()
    }
    
    func compress(originalPhotoData: NSData, targetRect: CGRect, completion: (thumbnail: UIImage?)-> Void) {
        let compressionOperation = ImageCompression(photoRecord: originalPhotoData, targetRect: targetRect)
        compressionOperation.completionBlock = {
            completion(thumbnail: compressionOperation.thumbnail)
        }
        workQueue.addOperation(compressionOperation)
    }
}

class ImageCompression: NSOperation {
    var photoRecord: NSData
    var targetRect: CGRect
    var thumbnail: UIImage?
    
    init(photoRecord: NSData, targetRect: CGRect) {
        self.photoRecord = photoRecord
        self.targetRect = targetRect
    }
    
    override func main () {
        if self.cancelled {
            return
        }
        
        if let originalPhoto = UIImage(data: photoRecord) {
            
            let rect = AVMakeRectWithAspectRatioInsideRect(originalPhoto.size, targetRect)
            
            if let imageSource = CGImageSourceCreateWithData(UIImageJPEGRepresentation(originalPhoto, 0.7)!, nil) {
                let options: [NSString: NSObject] = [
                    kCGImageSourceThumbnailMaxPixelSize: max(rect.width, rect.height),
                    kCGImageSourceCreateThumbnailFromImageAlways: true
                ]
                
                self.thumbnail = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options).flatMap { UIImage(CGImage: $0) }
            }
        }
    }
}
