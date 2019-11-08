//
//  ImageHelper.swift
//  Menus
//
//  Created by Gabriel Theodoropoulos.
//  Copyright © 2019 Gabriel Theodoropoulos. All rights reserved.
//

import AppKit

class ImageHelper {
    
    // MARK: - Properties
    
    static let shared = ImageHelper()
    
    var originalImageData: Data?
    
    var imageExtension: String?
    
    
    // MARK: - Init
    
    private init() {
        
    }
    
    
    // MARK: - Custom Methods
    
    func loadImageData(fromURL url: URL?) -> Data? {
        guard let url = url else { return nil }
        
        do {
            let data = try Data(contentsOf: url)
            originalImageData = data
            imageExtension = url.pathExtension
            return data
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    
    func getImageSize() -> NSSize? {
        guard let data = originalImageData else { return nil }
        return NSImage(data: data)?.size
    }
    
    
    func save(_ imageData: Data, toURL url: URL) {
        do {
            try imageData.write(to: url)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    // MARK: - Filter Applying Methods
    
    func makeMonochrome() -> NSImage? {
        guard let imageData = originalImageData else { return nil }
        let imageFilter  = ImageFilter.filter(fromString: "mono")
        let filter = imageFilter.createFilter(forImageWithData: imageData, additionalParameters: nil)
        return filter?.outputImage?.toNSImage()
    }
    
    
    func makeSepia() -> NSImage? {
        guard let imageData = originalImageData else { return nil }
        let imageFilter  = ImageFilter.filter(fromString: "sepia")
        let filter = imageFilter.createFilter(forImageWithData: imageData, additionalParameters: ["inputIntensity": 1.0])
        return filter?.outputImage?.toNSImage()
    }
    
    
    func makeBlurry() -> NSImage? {
        guard let imageData = originalImageData else { return nil }
        let imageFilter  = ImageFilter.filter(fromString: "blur")
        let filter = imageFilter.createFilter(forImageWithData: imageData, additionalParameters: ["inputRadius": 20.0])
        return filter?.outputImage?.toNSImage()
    }
    
    
    func makeComic() -> NSImage? {
        guard let imageData = originalImageData else { return nil }
        let imageFilter  = ImageFilter.filter(fromString: "comic")
        let filter = imageFilter.createFilter(forImageWithData: imageData, additionalParameters: nil)
        return filter?.outputImage?.toNSImage()
    }
}


extension CIImage {
    func toNSImage() -> NSImage {
        let renderedImage = NSCIImageRep(ciImage: self)
        let nsImage = NSImage()
        nsImage.addRepresentation(renderedImage)
        return nsImage
    }
}
