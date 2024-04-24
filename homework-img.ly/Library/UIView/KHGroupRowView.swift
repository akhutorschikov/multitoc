//
//  KHGroupRowView.swift
//  Homework
//
//  Created by Alex Khuala on 24.04.24.
//

import UIKit

protocol KHGroupRowView_Delegate: AnyObject
{
    func groupRowViewDidRequestDeletion(_ view: KHGroupRowView)
    
    func groupRowViewWillPickUpView(_ view: KHGroupRowView)
    func groupRowViewDidDropOffView(_ view: KHGroupRowView)
    
    func groupRowViewWillBeginMoving(_ view: KHGroupRowView)
    func groupRowViewDidFinishMoving(_ view: KHGroupRowView)
    func groupRowView(_ view: KHGroupRowView, didMoveWith delta: CGFloat)
}

/*!
 @brief Provides content for 'KHGroupViewRow'
 */
protocol KHGroupRowView_ContentProvider
{
    var identifier: Int { get }
    var config: KHGroupRowView.Config { get }
    
    func createTitleView(editing: Bool, context: KHGroupRowViewContent) -> KHView
    func createContentView(editing: Bool, context: KHGroupRowViewContent) -> KHView? // optional
    
    var buttonTintColor: UIColor? { get } // optional
}

extension KHGroupRowView_ContentProvider
{
    func createContentView(editing: Bool, context: KHGroupRowViewContent) -> KHView? { nil }
    
    var buttonTintColor: UIColor? { nil }
}

struct KHGroupRowViewContent
{
    weak var layoutListener: KHLayout_Listener?
}

/*!
 @brief Editable row for 'KHGroupView'. Content and style depends on KHGroupRowView_ContentProvider
 */
class KHGroupRowView: KHView, KHColor_Sensitive, KHView_Editable
{
    // MARK: - Init
    
    init(with contentProvider: KHGroupRowView_ContentProvider, editing: Bool, delegate: KHGroupRowView_Delegate, layoutListener: KHLayout_Listener? = nil)
    {
        self._config = contentProvider.config
        self._contentProvider = contentProvider
        self._delegate = delegate
        self._layoutListener = layoutListener
        self.editing = editing
        super.init(frame: .standard)
        self._configure()
        self._populate()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    
    var identifier: Int {
        self._contentProvider.identifier
    }
    
    var editing: Bool
    {
        didSet {
            guard self.editing != oldValue else {
                return
            }
            
            self._panGestureRecognizer?.isEnabled = self._editingActive
            self._longPressGestureRecognizer?.isEnabled = self._editingActive
            
            if  let view = self._titleView as? KHView_Editable {
                view.editing = self.editing
            }
            if  let view = self._contentView as? KHView_Editable {
                view.editing = self.editing
            }
        }
    }
    
    var translation: CGFloat
    {
        get {
            self._translation
        }
        set {
            self.setTranslation(newValue, animated: false)
        }
    }
    
    private var _translation: CGFloat = 0
    
    func setTranslation(_ translation: CGFloat, animated: Bool)
    {
        guard self._translation != translation else {
            return
        }
        
        self._translation = translation
        
        let transform: CGAffineTransform = translation == 0 ? .identity : .init(translationX: 0, y: translation)
        
        guard animated else {
            self.transform = transform
            return
        }
        
        UIView.animate(withDuration: self._config.animationDuration, delay: 0, options: [.beginFromCurrentState]) { [weak self] in
            self?.transform = transform
        }
    }
    
    func commitTranslation()
    {
        let offset = self.translation
        self.translation = 0
        self.frame = self.frame.offset(0, offset)
    }
    
    func updateColors()
    {
        KHColorSensitiveTools.updateColors(of: self._titleView)
        KHColorSensitiveTools.updateColors(of: self._contentView)
        
        let tintColor = self._contentProvider.buttonTintColor
        
        self._listIconView?.tintColor = tintColor
        self._deleteButton?.tintColor = tintColor
    }
    
    struct Config: KHConfig_Protocol
    {
        var listImageName: String?
        var deleteImageName: String?
        
        var allowsEditing: Bool = true
        
        var animationDuration: TimeInterval = 0.25
        var longPressMinimumPressDuration: TimeInterval = 0.3
        
        var buttonSpacing: CGFloat = 10
        
        var minEventSize: CGSize = .init(44)
    }
    
    // MARK: - Layout
    
    override func layout(with contentInset: UIEdgeInsets, options: KHView.LayoutOptions)
    {
        let bounds = self.bounds.inset(contentInset.top(0))
        let spacing = self._config.buttonSpacing
        var viewInset: UIEdgeInsets = .init(top: contentInset.top)
        
        var titleFrame: CGRect?
        var rightWidth: CGFloat = 0
        
        if  self._editingActive {
            rightWidth = spacing
            if  let button = self._deleteButton {
                rightWidth += button.width + spacing
            }
            
            if  let view = self._listIconView {
                rightWidth += view.width + spacing
            }
        }

        if  let view = self._titleView {
            view.frame = bounds.inframe(.init(height: 1), KHAlign.top, viewInset)
            view.layoutIfNeeded(.init(right: rightWidth))
            viewInset.top = view.bottom
            titleFrame = view.frame
        }
        
        if  let view = self._contentView {
            view.frame = bounds.inframe(.init(height: 1), KHAlign.top, viewInset)
            view.layoutIfNeeded()
            viewInset.top = view.bottom
        }
        
        self.height = viewInset.top + contentInset.bottom
        
        // ------ update buttons alpha
        
        let alpha: CGFloat = self._editingActive ? 1 : 0
        
        self._listIconView?.alpha = alpha
        self._deleteButton?.alpha = alpha
        
        // ------ update buttons frame
        
        guard let titleFrame = titleFrame else {
            return
        }
        
        if  self._editingActive {
            var rightOffset: CGFloat = spacing
            if  let button = self._deleteButton {
                button.frame = titleFrame.inframe(button.size, KHAlign.right, .init(right: rightOffset))
                rightOffset = button.leftInverted + spacing
            }
            if  let view = self._listIconView {
                view.frame = titleFrame.inframe(view.size, KHAlign.right, .init(right: rightOffset))
            }
        } else {
            if  let button = self._deleteButton {
                button.frame = titleFrame.inframe(button.size, KHAlign.rightOutside)
            }
            if  let view = self._listIconView {
                view.frame = titleFrame.inframe(view.size, KHAlign.rightOutside)
            }
        }
    }
    
    // MARK: - Private
        
    private let _config: Config
    private let _contentProvider: KHGroupRowView_ContentProvider
    private weak var _delegate: KHGroupRowView_Delegate?
    private weak var _layoutListener: KHLayout_Listener?
    
    private weak var _titleView: KHView?
    private weak var _contentView: KHView?
    
    private weak var _listIconView: UIImageView?
    private weak var _deleteButton: UIButton?
    
    private weak var _longPressGestureRecognizer: UILongPressGestureRecognizer?
    private weak var _panGestureRecognizer: UIPanGestureRecognizer?
    
    private var _editingActive: Bool {
        self.editing && self._config.allowsEditing
    }
    
    private func _configure()
    {
        //
    }
    
    private func _populate()
    {
        let context: KHGroupRowViewContent = .init(layoutListener: self)
        
        let titleView = self._contentProvider.createTitleView(editing: self.editing, context: context)
        
        self.addSubview(titleView)
        self._titleView = titleView
        
        self._addLongPressGestureRecognizer(to: titleView)
        self._addPanGestureRecognizer(to: titleView)
        
        self._addDeleteButton()
        self._addListIconView()
        
        guard let view = self._contentProvider.createContentView(editing: self.editing, context: context) else {
            return
        }
        
        self.addSubview(view)
        self._contentView = view
    }
    
    private func _addListIconView()
    {
        let image: UIImage?
        if  let name = self._config.listImageName {
            image = .init(named: name)
        } else {
            image = .init(systemName: "line.3.horizontal")
        }
        
        let imageView = UIImageView(image: image)
        
        self.addSubview(imageView)
        self._listIconView = imageView
    }
    
    private class DeleteButton: UIButton
    {
        override func point(inside point: CGPoint, with event: UIEvent?) -> Bool 
        {
            self.alpha > 0.01 && point.x >= 0
        }
    }
    
    private func _addDeleteButton()
    {
        let image: UIImage?
        if  let name = self._config.deleteImageName {
            image = .init(named: name)
        } else {
            image = .init(systemName: "trash")
        }
        
        let button = DeleteButton(type: .custom)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(_didTapDeleteButton), for: .touchUpInside)
        button.sizeToFit()
                
        self.addSubview(button)
        self._deleteButton = button
    }
    
    // MARK: - Gestures
    
    private var _hanging: Bool = false
    private var _moving: Bool = false
    private var _movingHanging: Bool = false
    
    private func _addLongPressGestureRecognizer(to view: UIView)
    {
        let gr = UILongPressGestureRecognizer(target: self, action: #selector(_didLongPress(_:)))
        gr.minimumPressDuration = self._config.longPressMinimumPressDuration
        gr.isEnabled = false
        
        view.addGestureRecognizer(gr)
        self._longPressGestureRecognizer = gr
    }
    
    private func _addPanGestureRecognizer(to view: UIView)
    {
        let gr = UIPanGestureRecognizer(target: self, action: #selector(_didPan(_:)))
        gr.delegate = self
        gr.isEnabled = false
        
        view.addGestureRecognizer(gr)
        self._panGestureRecognizer = gr
    }
    
    @objc
    private func _didLongPress(_ gr: UILongPressGestureRecognizer)
    {
        switch gr.state {
        case .began:
            self._hanging = true
            self._delegate?.groupRowViewWillPickUpView(self)
        case .cancelled, .ended:
            self._hanging = false
            self._delegate?.groupRowViewDidDropOffView(self)
        default:
            break
        }
    }
    
    @objc
    private func _didPan(_ gr: UIPanGestureRecognizer)
    {
        switch gr.state {
        case .began:
            
            if !self._movingHanging, !self._hanging {
                self._movingHanging = true
                self._delegate?.groupRowViewWillPickUpView(self)
            }
            
            self._moving = true
            self._delegate?.groupRowViewWillBeginMoving(self)
            
        case .changed:
            
            self._delegate?.groupRowView(self, didMoveWith: gr.translation(in: self).y)
            
        case .cancelled, .ended:
            
            self._moving = false
            self._delegate?.groupRowViewDidFinishMoving(self)
            
            if  self._movingHanging, !self._hanging {
                self._movingHanging = false
                self._delegate?.groupRowViewDidDropOffView(self)
            }
            
        default:
            break
        }
    }
    
    // MARK: - Actions
    
    @objc
    private func _didTapDeleteButton(_ button: UIButton)
    {
        self._delegate?.groupRowViewDidRequestDeletion(self)
    }
}

extension KHGroupRowView: KHLayout_Listener
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

extension KHGroupRowView: UIGestureRecognizerDelegate
{
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool
    {
        if  let view = self._listIconView {
            let point = gestureRecognizer.location(in: self).x
            let delta = self._config.minEventSize.width / 2
            let center = view.center.x
            if  point > center - delta, point < center + delta {
                return true
            }
        }
        
        return self._hanging
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool 
    {
        otherGestureRecognizer is UIPanGestureRecognizer
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
    {
        true
    }
}
