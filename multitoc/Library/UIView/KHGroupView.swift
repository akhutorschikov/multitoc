//
//  KHGroupView.swift
//  Multitoc
//
//  Created by Alex Khuala on 24.04.24.
//

import UIKit

/*!
 @brief Provides content for 'KHGroupView'
 */
protocol KHGroupView_ContentProvider
{
    var layoutListener: KHLayout_Listener? { get set }
    
    var config: KHGroupView.Config { get }
    var identifiers: [Int] { get }
    
    func createTitleView(with identifier: Int, editing: Bool, context: KHGroupViewContext) -> KHView
    func createContentView(with identifier: Int, editing: Bool, context: KHGroupViewContext) -> KHView? // optional
    
    var separatorColor: UIColor? { get } // optional
    var buttonTintColor: UIColor? { get } // optional
    var editingBackgroundColor: UIColor? { get } // optional
    
    func didDeleteRow(with identifier: Int)
    func didUpdateOrder(with identifiers: [Int])
}

extension KHGroupView_ContentProvider
{
    var separatorColor: UIColor? { nil }
    var buttonTintColor: UIColor? { nil }
    var editingBackgroundColor: UIColor? { nil }
    
    func createContentView(with identifier: Int, editing: Bool, context: KHGroupViewContext) -> KHView? { nil }
}

struct KHGroupViewContext
{
    weak var layoutListener: KHLayout_Listener?
}

// *************************
// *************************  GROUP VIEW
// *************************

/*!
 @brief Editable view to show 'title' and 'content' (optional). Content and style depends on KHGroupView_ContentProvider
 */
final class KHGroupView: KHView, KHColor_Sensitive, KHView_Editable
{
    // MARK: - Init
    
    init(with contentProvider: KHGroupView_ContentProvider, editing: Bool, layoutListener: KHLayout_Listener? = nil)
    {
        self.editing = editing
        self._config = contentProvider.config
        self._contentProvider = contentProvider
        self._layoutListener = layoutListener
        super.init(frame: .standard)
        self._configure()
        self._populate()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    
    var editing: Bool
    {
        didSet {
            guard self.editing != oldValue else {
                return
            }
            self._entries.forEach { $0.view?.editing = self.editing }
            self.setNeedsLayout()
        }
    }
    
    func updateColors()
    {
        // ------ prepare separator colors
        
        var separatorColor: UIColor?
        if  self._hasSeparators {
            separatorColor = self._contentProvider.separatorColor ?? .lightGray
        }
        
        // ------ update entries colors
        
        for entry in self._entries {
            entry.view?.updateColors()
            
            guard let separatorView = entry.nextSeparatorView else {
                continue
            }
            separatorView.backgroundColor = separatorColor
        }
    }
    
    struct Config: KHConfig_Protocol
    {
        var listImageName: String?
        var deleteImageName: String?
        
        var separatorConfig: KHSeparatorConfig?
        
        var animationDuration: TimeInterval = 0.25
        var hiddenScale: CGFloat = 0.2
        
        var hangingAlpha: CGFloat = 0.9
        
        var allowsEditing: Bool = true
        
        fileprivate func needsSeparator() -> Bool
        {
            guard let config = self.separatorConfig, config.lineWidth > 0 else {
                return false
            }
            return true
        }
    }
    
    // MARK: - Layout
    
    override func layout(with contentInset: UIEdgeInsets, options: KHView.LayoutOptions)
    {
        let bounds = self.bounds.inset(contentInset.vertical)
        let padding = contentInset.y(0)
        
        var top: CGFloat = 0
        let separatorConfig = self._config.separatorConfig ?? .standard
        
        for entry in self._entries {
            guard let view = entry.view else {
                continue
            }
            view.transform = .identity
            view.frame = bounds.top(top)
            view.layoutIfNeeded(padding)
            view.alpha = 1
            
            top = view.bottom - contentInset.top
            
            // layout separator
            guard let separatorView = entry.nextSeparatorView else {
                continue
            }
                
            let inset = separatorConfig.inset
            let frame = view.bounds.inframe(.init(height: separatorConfig.lineWidth), KHAlign.bottom, inset)
            
            separatorView.frame = frame.pixelRoundPosition()
        }
        
        self.height = top > 0.01 ? top + contentInset.height : 0
        self._contentPadding = padding
        
        // ------ removing
        
        guard !self._removingEntries.isEmpty else {
            return
        }
        
        let scale = self._config.hiddenScale
        let transform: CGAffineTransform = .init(scaleX: scale, y: scale)
        
        for entry in self._removingEntries {
            guard let view = entry.view else {
                continue
            }
            view.transform = transform
            view.alpha = 0
        }
        
        let duration = UIView.inheritedAnimationDuration
        if  duration > 0 {
            let removingEntries = self._removingEntries
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                removingEntries.forEach { $0.view?.removeFromSuperview() }
            }
        } else {
            self._removingEntries.forEach { $0.view?.removeFromSuperview() }
        }
        self._removingEntries = []
     }
    
    // MARK: - Private
    
    private let _config: Config
    private let _contentProvider: KHGroupView_ContentProvider
    private weak var _layoutListener: KHLayout_Listener?
    
    private var _hasSeparators: Bool = false
    
    private var _entries: [Entry] = []
    private var _removingEntries: [Entry] = []
    
    private var _contentPadding: UIEdgeInsets = .zero
        
    private func _configure()
    {
        
    }
    
    private func _populate()
    {
        var entries: [Entry] = []
        let config = self._config
        
        var hasSeparators: Bool = false
        let needsSeparator = config.needsSeparator()
        
        for identifier in self._contentProvider.identifiers {
            
            let view = self._addRowView(with: identifier)
            var entry: Entry = .init(identifier: identifier, view: view)
            
            // ------ create separator view and append to tmp array
            
            if  needsSeparator {
                let separatorView = UIView(.line)
                
                view.addSubview(separatorView)
                entry.nextSeparatorView = separatorView
                
                hasSeparators = true
            }
            
            entries.append(entry)
        }
                
        self._hasSeparators = hasSeparators
        self._entries = entries
    }
    
    private func _addRowView(with identifier: Int) -> KHGroupRowView
    {
        let contentProvider = KHGroupRowViewContentProvider(with: self._contentProvider, identifier: identifier)
        let view = KHGroupRowView(with: contentProvider, editing: self.editing, delegate: self, layoutListener: self)
        
        self.addSubview(view)
        return view
    }
    
    private struct Entry
    {
        init(identifier: Int, view: KHGroupRowView)
        {
            self.identifier = identifier
            self.view = view
        }
        
        let identifier: Int
        private(set) weak var view: KHGroupRowView?
        
        weak var nextSeparatorView: UIView?
        
        func beginEditing()
        {
            self.nextSeparatorView?.alpha = 0
        }
        
        func endEditing()
        {
            self.nextSeparatorView?.alpha = 1
        }
    }
    
    // MARK: - Moving
    
    private var _moving: Moving?
    private var _targetIndex: Int?
    
    private struct Moving
    {
        let index: Int
        let frame: CGRect
        let minDelta: CGFloat
        let maxDelta: CGFloat
        let entry: Entry
    }
    
    private var _shadowConfig: KHShadowConfig {
        .init(in: { cc in
            cc.radius  = 25.0
            cc.opacity = 0.40
            cc.color   = .black
        })
    }
}

extension KHGroupView: KHLayout_Listener
{
    func subviewDidRequestLayoutUpdate()
    {
        self.setNeedsLayout()
        self._layoutListener?.subviewDidRequestLayoutUpdate()
    }
    
    func subviewDidRequestBringToFront() 
    {
        self.superview?.bringSubviewToFront(self)
        self._layoutListener?.subviewDidRequestBringToFront()
    }
}

extension KHGroupView: KHGroupRowView_Delegate
{
    func groupRowViewDidRequestDeletion(_ view: KHGroupRowView)
    {
        let identifier = view.identifier
            
        var entries: [Entry] = []
        var entriesToRemove: [Entry] = []
        for entry in self._entries {
            if  entry.identifier == identifier {
                entriesToRemove.append(entry)
                if  let view = entry.view {
                    let top = view.top
                    view.anchorPoint.y = 0
                    view.top = top
                    view.superview?.sendSubviewToBack(view)
                }
            } else {
                entries.append(entry)
            }
        }
        
        guard !entriesToRemove.isEmpty else {
            return
        }
        
        self._entries = entries
        self._removingEntries += entriesToRemove
        
        self.setNeedsLayout()
        self._contentProvider.didDeleteRow(with: identifier)
        self._layoutListener?.subviewDidRequestLayoutUpdate()
    }
    
    func groupRowViewWillPickUpView(_ view: KHGroupRowView)
    {
        var index: Int?
        var entry: Entry?
        var minTop: CGFloat = 0
        var maxBottom: CGFloat = 0
        
        let firstIndex = 0
        let lastIndex = self._entries.count - 1
        
        for (i, e) in self._entries.enumerated() {
            guard let v = e.view else {
                continue
            }
            if  view === v {
                index = i
                entry = e
            } else {
                v.isUserInteractionEnabled = false
            }
            if  i == firstIndex {
                minTop = v.top
            }
            if  i == lastIndex {
                maxBottom = v.bottom
            }
        }
        
        guard let index = index, let entry = entry else {
            return
        }
        
        self._moving = .init(index: index,
                             frame: view.frame,
                             minDelta: minTop - view.top,
                             maxDelta: maxBottom - view.bottom,
                             entry: entry)
        
        // ------ bring subview to front
        
        self.bringSubviewToFront(view)
        self._layoutListener?.subviewDidRequestBringToFront()
        
        // ------ update view state for editing
        
        entry.beginEditing()
        view.alpha = self._config.hangingAlpha
        view.backgroundColor = self._contentProvider.editingBackgroundColor
                
        // ------ add shadow
        
        self._shadowConfig.apply(to: view)
        
        // ------ device feedback
        
        KHViewHelper.triggerImpactDeviceFeedback()
    }
    
    func groupRowViewDidDropOffView(_ view: KHGroupRowView)
    {
        guard let moving = self._moving else {
            return
        }
        
        self._moving = nil
        
        // ------ build new entries array
        
        let movingCenter = view.frame.center.y
        
        var entries: [Entry] = []
        var position: CGFloat = 0
        var positionFound: Bool = false
        var oldIdentifiers: [Int] = []
        for entry in self._entries {
            
            oldIdentifiers.append(entry.identifier)
            
            guard let v = entry.view, v !== view else {
                continue
            }
            
            v.isUserInteractionEnabled = true
            
            if !positionFound {
                
                if  movingCenter < v.frame.center.y {
                    positionFound = true
                    entries.append(moving.entry)
                } else {
                    position = v.bottom
                }
            }
            
            entries.append(entry)
        }
        
        if !positionFound {
            entries.append(moving.entry)
        }
        
        self._entries = entries
        
        // ------ change remove button image back
        
        var newIdentifiers: [Int] = []
        
        self._entries.forEach {
            newIdentifiers.append($0.identifier)
        }
        
        // ------ end editing for entry
        
        moving.entry.endEditing()
        
        // ------ apply changes to manager
        
        if  oldIdentifiers != newIdentifiers {
            self._contentProvider.didUpdateOrder(with: newIdentifiers)
        }
        
        // ------ remove shadow with animation
        
        UIView.animate(withDuration: self._config.animationDuration, delay: 0, options: .allowUserInteraction) { [weak view] in
            guard let view = view else {
                return
            }
            
            view.translation = 0
            view.top = position
            
            KHViewHelper.updateLayerShadowOpacity(view.layer, 0)
            
        } completion: { [weak self, weak view] _ in
            guard let self = self, let view = view else {
                return
            }
            
            view.alpha = 1
            view.backgroundColor = nil
            KHShadowConfig.removeShadow(of: view)
            
            // ------ commit translation for each entry
            
            self._entries.forEach { $0.view?.commitTranslation() }
        }
    }
    
    func groupRowViewWillBeginMoving(_ view: KHGroupRowView)
    {
        print("begin moving")
    }
    
    func groupRowViewDidFinishMoving(_ view: KHGroupRowView)
    {
        print("finish moving")
    }
    
    func groupRowView(_ view: KHGroupRowView, didMoveWith delta: CGFloat)
    {
        guard let moving = self._moving else {
            return
        }
        
        let delta = max(moving.minDelta, min(moving.maxDelta, delta))
        let distance = view.height / 2
        
        view.translation = delta
        
        let movingCenter = view.frame.center.y
        
        for (index, entry) in self._entries.enumerated() {
            guard let v = entry.view, v !== view else {
                continue
            }
            
            let c = v.center.y
            let translation: CGFloat
            
            if  index < moving.index {
                translation = movingCenter < c + distance ? view.height : 0
            } else {
                translation = movingCenter > c - distance ? -view.height : 0
            }
            
            v.setTranslation(translation, animated: true)
        }
    }
}


// *************************
// *************************   CONTENT PROVIDER FOR ROW
// *************************

fileprivate class KHGroupRowViewContentProvider: KHGroupRowView_ContentProvider
{
    lazy var config: KHGroupRowView.Config = .init { c in
        c.animationDuration = self._groupContentProvider.config.animationDuration
        c.listImageName = self._groupContentProvider.config.listImageName
        c.deleteImageName = self._groupContentProvider.config.deleteImageName
        c.allowsEditing = self._groupContentProvider.config.allowsEditing
    }
        
    init(with contentProvider: KHGroupView_ContentProvider, identifier: Int)
    {
        self.identifier = identifier
        self._groupContentProvider = contentProvider
    }
    
    func createTitleView(editing: Bool, context: KHGroupRowViewContent) -> KHView
    {
        self._groupContentProvider.createTitleView(with: self.identifier, editing: editing, context: .init(layoutListener: context.layoutListener))
    }

    func createContentView(editing: Bool, context: KHGroupRowViewContent) -> KHView?
    {
        self._groupContentProvider.createContentView(with: self.identifier, editing: editing, context: .init(layoutListener: context.layoutListener))
    }
    
    var buttonTintColor: UIColor? {
        self._groupContentProvider.buttonTintColor
    }
    
    let identifier: Int
    private let _groupContentProvider: KHGroupView_ContentProvider
}

