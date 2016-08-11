//
//  ThumbnailManagerTests.swift
//  AsyncUnitTest
//
//  Created by william wong on 10/08/2016.
//  Copyright © 2016 William Wong. All rights reserved.
//

import XCTest
@testable import AsyncUnitTest

class ThumbnailManagerTests: XCTestCase {
    
    let bundle = NSBundle(forClass: ThumbnailManagerTests.self)
    let thumbnailRect = CGRect(x: 0, y: 0, width: 200, height: 300)
    
    func testCompress() {
        let imagePath = bundle.pathForResource("test", ofType: "jpeg")
        XCTAssertNotNil(imagePath)
        let image = UIImage(contentsOfFile: imagePath!)
        XCTAssertNotNil(image)
        
        let originalData = UIImageJPEGRepresentation(image!, 0.7)
        let thumbnailManager = ThumbnailManager()
        var thumbnailPhoto: UIImage?
        let expectation = expectationWithDescription("Complete")
        thumbnailManager.compress(originalData!, targetRect: thumbnailRect) { (thumbnail) in
            thumbnailPhoto = thumbnail
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(10, handler: nil)
        
        let ratio = (image?.size.width)! / (image?.size.height)!
        let targetHeight = floor(thumbnailRect.size.width / ratio)
        XCTAssert(thumbnailPhoto?.size.height == targetHeight)
        XCTAssert(thumbnailPhoto?.size.width == thumbnailRect.size.width)
        
    }
}