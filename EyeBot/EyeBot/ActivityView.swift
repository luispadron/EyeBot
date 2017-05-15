//
//  ActivityView.swift
//  EyeBot
//
//  Created by Luis Padron on 5/15/17.
//  Copyright © 2017 com.eyebot. All rights reserved.
//

import UIKit

class ActivityView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        visualEffectView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        indicator.center = visualEffectView.center
    }
    
    
    private func initialize() {
        self.addSubview(visualEffectView)
        self.addSubview(indicator)
    }
    
    /// Stops the indicator
    public func stop() {
        self.visualEffectView.isHidden = true
        indicator.stopAnimating()
    }
    
    public func start() {
        self.visualEffectView.isHidden = false
        indicator.startAnimating()
    }
    
    public var isAnimating: Bool {
        return self.indicator.isAnimating
    }
    
    // MARK: Subviews
    
    private lazy var visualEffectView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blur)
        
        let vibrancy = UIVibrancyEffect(blurEffect: blur)
        let vibrancyView = UIVisualEffectView(effect: vibrancy)
        
        blurView.contentView.addSubview(vibrancyView)
        
        blurView.layer.cornerRadius = 5
        blurView.layer.masksToBounds = true
        
        return blurView
    }()
    
    private lazy var indicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        view.hidesWhenStopped = true
        return view
    }()
}
