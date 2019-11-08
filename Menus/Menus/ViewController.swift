//
//  ViewController.swift
//  Menus
//
//  Created by Gabriel Theodoropoulos.
//  Copyright © 2019 AppCoda. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    // MARK: - IBOutlet Properties
    
    @IBOutlet weak var scrollView: NSScrollView!
    
    @IBOutlet weak var imageView: NSImageView!
    
    
    // MARK: - Properties To Declare From Tutorial
    
    var didSetFilterItemOptions = false
    
    
    // MARK: - VC Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        configureScrollView()
        setupContextMenu()
        
        setupFiltersMenu()
    }

    
    override func viewDidAppear() {
        super.viewDidAppear()

        if !didSetFilterItemOptions {
            setFilterItemOptions()
            didSetFilterItemOptions = true
        }
    }
    
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


    // MARK: - Methods Implementation
    
    func configureScrollView() {
        scrollView.allowsMagnification = true
        scrollView.magnification = 1.0
        scrollView.maxMagnification = 5.0
        scrollView.minMagnification = 0.25
    }
    
    
    // MARK: - Action Methods
    
    @objc func removeAppliedFilter() {
        guard let imageData = ImageHelper.shared.originalImageData else { return }
        imageView.image = NSImage(data: imageData)
    }
    
    
    @objc func dismissImage() {
        imageView.image = nil
        ImageHelper.shared.originalImageData = nil
        setupContextMenu()
    }
    
    
    // MARK: - IBAction Methods
    
    @IBAction func openImage(_ sender: Any) {
            guard let window = self.view.window else { return }
            let panel = NSOpenPanel()
            panel.canChooseFiles = true
            panel.canChooseDirectories = false
            panel.allowsMultipleSelection = false
            panel.allowedFileTypes = ["png", "jpg", "jpeg"]
            panel.beginSheetModal(for: window) { (response) in
                if response == NSApplication.ModalResponse.OK {
                    guard let data = ImageHelper.shared.loadImageData(fromURL: panel.url) else { return }
                    self.imageView.image = NSImage(data: data)
                    self.scrollView.magnify(toFit: self.imageView.frame)
                    self.setupContextMenu()
                }
            }
        }
    
    
    @IBAction func saveImage(_ sender: Any) {
            guard let imageData = imageView.image?.tiffRepresentation, let imageExtension = ImageHelper.shared.imageExtension, let window = self.view.window else { return }
                    
            let savePanel = NSSavePanel()
            savePanel.allowedFileTypes = [imageExtension]
            savePanel.canCreateDirectories = true
            savePanel.isExtensionHidden = false
            
            savePanel.beginSheetModal(for: window) { (response) in
                if response == NSApplication.ModalResponse.OK {
                    guard let targetURL = savePanel.url else { return }
                    ImageHelper.shared.save(imageData, toURL: targetURL)
                }
            }
        }
    
    
    // MARK: - Methods To Implement From Tutorial
    
    func setupContextMenu() {
        let contextMenu = NSMenu()
        
        if imageView.image == nil {
            let open = NSMenuItem(title: "Open image...", action: #selector(openImage(_:)), keyEquivalent: "")
            contextMenu.addItem(open)
        } else {
            let items = createContextMenuItems()
            items.forEach { contextMenu.addItem($0) }
        }
        
        imageView.menu = contextMenu
    }
    
    
    func createFiltersMenuItems() -> [NSMenuItem] {
        let mono = NSMenuItem(title: "Monochrome", action: #selector(applyImageFilter(_:)), keyEquivalent: "")
        mono.identifier = NSUserInterfaceItemIdentifier(rawValue: "mono")
        
        let sepia = NSMenuItem(title: "Sepia", action:  #selector(applyImageFilter(_:)), keyEquivalent: "")
        sepia.identifier = NSUserInterfaceItemIdentifier(rawValue: "sepia")

        let blur = NSMenuItem(title: "Blur", action:  #selector(applyImageFilter(_:)), keyEquivalent: "")
        blur.identifier = NSUserInterfaceItemIdentifier(rawValue: "blur")

        let comic = NSMenuItem(title: "Comic", action:  #selector(applyImageFilter(_:)), keyEquivalent: "")
        comic.identifier = NSUserInterfaceItemIdentifier(rawValue: "comic")
        
        let separator = NSMenuItem.separator()
        let removeFilter = NSMenuItem(title: "Remove Filter", action: #selector(removeAppliedFilter), keyEquivalent: "")
        
        return [mono, sepia, blur, comic, separator, removeFilter]
    }
    
    
    func setupFiltersMenu() {
        guard let mainMenu = (NSApp.delegate as? AppDelegate)?.mainMenu, let filtersMenuItem = mainMenu.item(withTitle: "Filters") else { return }
        filtersMenuItem.submenu?.removeAllItems()
        let filterItems = createFiltersMenuItems()
        filterItems.forEach { filtersMenuItem.submenu?.addItem($0) }
    }
    
    
    func createContextMenuItems() -> [NSMenuItem] {
        let zoomIn = NSMenuItem(title: "Zoom In", action: #selector(zoomIn(_:)), keyEquivalent: "")
        let zooumOut = NSMenuItem(title: "Zoom Out", action: #selector(zoomOut(_:)), keyEquivalent: "")
        let separator = NSMenuItem.separator()
        let fit = NSMenuItem(title: "Fit", action: #selector(zoomToFit(_:)), keyEquivalent: "")
        
        let zoomSubmenu = NSMenu()
        zoomSubmenu.addItem(zoomIn)
        zoomSubmenu.addItem(zooumOut)
        zoomSubmenu.addItem(separator)
        zoomSubmenu.addItem(fit)
        
        let zoomItem = NSMenuItem(title: "Zoom", action: nil, keyEquivalent: "")
        zoomItem.submenu = zoomSubmenu
        
        
        let filtersSubmenu = NSMenu()
        let filterItems = createFiltersMenuItems()
        filterItems.forEach { filtersSubmenu.addItem($0) }
        let filtersItem = NSMenuItem(title: "Filters", action: nil, keyEquivalent: "")
        filtersItem.submenu = filtersSubmenu
        
        
        let dismiss = NSMenuItem(title: "Remove Image", action: #selector(dismissImage), keyEquivalent: "")
        
        return [zoomItem, filtersItem, dismiss]
    }
    
    
    
    func setFilterItemOptions() {
        let filterItem = self.view.window?.toolbar?.items.filter { $0.itemIdentifier.rawValue == "filterItem" }.first
        
        guard let popup = filterItem?.view as? NSPopUpButton else { return }
        popup.removeItem(at: 2)
        popup.removeItem(at: 1)
        
        let filterMenuItems = createFiltersMenuItems()
        filterMenuItems.forEach { popup.menu?.addItem($0) }
    }
        
    
    
    // MARK: - Action Methods To Implement From Tutorial
    
    @objc func applyImageFilter(_ sender: NSMenuItem) {
        guard let menuIdentifier = sender.identifier else { return }
        
        var filteredImage: NSImage?

        switch menuIdentifier.rawValue {
        case "mono": filteredImage = ImageHelper.shared.makeMonochrome()
        case "sepia": filteredImage = ImageHelper.shared.makeSepia()
        case "blur": filteredImage = ImageHelper.shared.makeBlurry()
        case "comic": filteredImage = ImageHelper.shared.makeComic()
        default: break
        }
        
        guard let image = filteredImage else { return }
        imageView.image = image
    }
    
    
    @IBAction func zoomIn(_ sender: Any) {
        scrollView.magnification += 0.25
    }

    @IBAction func zoomOut(_ sender: Any) {
        scrollView.magnification -= 0.25
    }

    @IBAction func zoomToFit(_ sender: Any) {
        scrollView.magnify(toFit: imageView.frame)
    }
    
    
    @IBAction func quickZoom(_ sender: Any) {
        guard let menuItem = sender as? NSMenuItem, let menuIdentifier = menuItem.identifier else { return }

        switch menuIdentifier.rawValue {
            case "zoomX4": scrollView.magnification *= 4.0
            case "zoomX2": scrollView.magnification *= 2.0
            case "zoomX0.5": scrollView.magnification *= 0.5
            case "zoomX0.25": scrollView.magnification *= 0.25
            default: break
        }
    }
    
    
    @IBAction func handleZoomItem(_ sender: Any) {
        guard let segmentedControl = sender as? NSSegmentedControl else { return }
        
        switch segmentedControl.selectedSegment {
        case 0: zoomOut(self)
        case 1: zoomToFit(self)
        case 2: zoomIn(self)
        default: break
        }
    }
}

