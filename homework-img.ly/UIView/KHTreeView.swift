//
//  KHTreeView.swift
//  homework-img.ly
//
//  Created by Alex Khuala on 24.04.24.
//

import UIKit

/*!
 @brief Container for multilevel list
 @discussion Provides scrolling. Contains root 'KHGroupView' based on 'KHTreeGroupViewContentProvider'. This view listens for KHTheme updates and triggers the 'updateColors' sequence.
 */
class KHTreeView: KHView, KHColor_Sensitive
{
    // MARK: - Init
    
    init(with viewModel: KHTree_ViewModel, editing: Bool, config: Config = .init(), onSelect: @escaping (_ id: String) -> Void)
    {
        self._config = config
        self._viewModel = viewModel
        self._onSelect = onSelect
        self.editing = editing
        super.init(frame: .standard)
        self._configure()
        self._populate()
        
        self._viewModel.addListener(self)
        self.registerForThemeUpdates()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self._viewModel.removeListener(self)
        self.unregisterForThemeUpdates()
    }
    
    // MARK: - Public
    
    var editing: Bool
    {
        didSet {
            guard self.editing != oldValue else {
                return
            }
            self._contentView?.editing = self.editing
            self._updateLayout(animated: true)
        }
    }
    
    func updateColors()
    {
        self._contentView?.updateColors()
    }
    
    struct Config: KHConfig_Protocol
    {
        //
    }
    
    // MARK: - Layout
    
    override func layout(with contentInset: UIEdgeInsets, options: KHView.LayoutOptions)
    {
        guard let scrollView = self._scrollView else {
            return
        }
        scrollView.frame = self.bounds
        
        guard let contentView = self._contentView else {
            scrollView.contentSize = .zero
            return
        }
        
        contentView.width = scrollView.width
        contentView.layoutIfNeeded()
        
        scrollView.contentSize = contentView.size
    }
    
    // MARK: - Private
    
    private let _config: Config
    private let _viewModel: KHTree_ViewModel
    private let _onSelect: (_ id: String) -> Void
    
    private weak var _scrollView: UIScrollView?
    private weak var _contentView: KHGroupView?
    
    private func _configure()
    {
        
    }
    
    private func _populate()
    {
        self._addScrollView()
        self._addContentView()
    }
    
    private class TableScrollView: UIScrollView
    {
        override func touchesShouldCancel(in view: UIView) -> Bool
        {
            if view is UIButton {
                return true
            }
            return super.touchesShouldCancel(in: view)
        }
    }
    
    private func _addScrollView()
    {
        let view = TableScrollView(.standard)
        view.showsHorizontalScrollIndicator = false
        view.alwaysBounceVertical = true
        view.delaysContentTouches = false
        
        self.addSubview(view)
        self._scrollView = view
    }
    
    private func _addContentView(initialize: Bool = false)
    {
        guard self._contentView == nil, let scrollView = self._scrollView else {
            return
        }
        
        let contentProvider = KHTreeGroupViewContentProvider(entries: self._viewModel.entries, delegate: self)
        let view = KHGroupView(with: contentProvider, editing: self.editing, layoutListener: self)
        
        scrollView.addSubview(view)
        self._contentView = view
        
        if  initialize {
            view.updateColors()
            self.setNeedsLayout()
        }
    }
    
    private func _updateLayout(animated: Bool = false)
    {
        self.setNeedsLayout()
        
        guard animated else {
            return
        }
        
        UIView.animate(withDuration: KHViewHelper.animationDuration) {
            self.layoutSubviews()
        }
    }
}

extension KHTreeView: KHTree_ViewModelListener
{
}

extension KHTreeView: KHLayout_Listener
{
    func subviewDidRequestLayoutUpdate()
    {
        self._updateLayout(animated: true)
    }
}

extension KHTreeView: KHTheme_Sensitive
{
    typealias Theme = KHTheme
    
    func didChangeTheme()
    {
        self.updateColors()
    }
}

extension KHTreeView: KHTreeGroupViewContentProvider_Delegate
{
    func groupViewContentProviderDidRequestDetails(for id: String)
    {
        self._onSelect(id)
    }
}
