//
//  KHTreeGroupViewContentProvider.swift
//  Multitoc
//
//  Created by Alex Khuala on 24.04.24.
//

import UIKit

protocol KHTreeGroupViewContentProvider_Delegate: AnyObject
{
    func groupViewContentProviderDidRequestDetails(for id: String)
}

/*!
 @brief Content provider for nested 'KHGroupView'
 @discussion Number of levels is not limited and only depends on [KHMainEntry] structure. Styles provided for only 4 levels, any deeper levels will get last style by default.
 @param entries Input tree data structure
 @param level Used for styling purposes only
 @param delegate Used to notify delegate of 'details' request with selected 'id'
 */
class KHTreeGroupViewContentProvider: KHGroupView_ContentProvider
{
    init(entries: [KHMainEntry], level: Int = 0, delegate: KHTreeGroupViewContentProvider_Delegate?)
    {
        var items: [Item] = []
        for (identifier, entry) in entries.enumerated() {
            items.append(.init(identifier: identifier, entry: entry))
        }
        
        self._items = items
        self._level = level
        self._delegate = delegate
    }
    
    weak var layoutListener: KHLayout_Listener?
    
    lazy var config: KHGroupView.Config = .init { c in
        c.separatorConfig = self._separatorConfigForCurrentLevel
        c.listImageName = "b-list"
        c.deleteImageName = "b-trash"
        c.allowsEditing = self._level > 0
    }
    
    var identifiers: [Int] {
        
        var identifiers: [Int] = []
        for item in self._items {
            identifiers.append(item.identifier)
        }
        return identifiers
    }
    
    func createTitleView(with identifier: Int, editing: Bool, context: KHGroupViewContext) -> KHView
    {
        var linkID: String?
        var title: String?
        if  let entry = self._item(with: identifier)?.entry {
            switch entry.content {
            case let .link(id):
                linkID = id
            default:
                break
            }
            title = entry.label
        }
        
        return KHGroupViewTitleView(with: title ?? "Empty title", level: self._level, linkID: linkID, delegate: self)
    }
    
    func createContentView(with identifier: Int, editing: Bool, context: KHGroupViewContext) -> KHView?
    {
        guard let entry = self._item(with: identifier)?.entry else {
            return nil
        }

        switch entry.content {
        case let .children(entries):
            let contentProvider = KHTreeGroupViewContentProvider(entries: entries, level: self._level + 1, delegate: self._delegate)
            return KHGroupView(with: contentProvider, editing: editing, layoutListener: context.layoutListener)
        default:
            return nil
        }
    }
        
    func didDeleteRow(with identifier: Int)
    {
        self._items.removeAll { $0.identifier == identifier }
    }
    
    func didUpdateOrder(with identifiers: [Int])
    {
        var items: [Item] = []
        for identifier in identifiers {
            guard let item = self._item(with: identifier) else {
                return
            }
            items.append(item)
        }
        self._items = items
    }
    
    var separatorColor: UIColor? {
        self._level == 0 ? KHTheme.color.separator0 : KHTheme.color.separator
    }
    
    var buttonTintColor: UIColor? {
        KHTheme.color.button
    }
    
    var editingBackgroundColor: UIColor? {
        KHTheme.color.back
    }
        
    private func _item(with identifier: Int) -> Item?
    {
        self._items.first(where: { $0.identifier == identifier })
    }
    
    private let _level: Int
    private var _items: [Item]
    private weak var _delegate: KHTreeGroupViewContentProvider_Delegate?
    
    private weak var _groupView: KHTreeGroupViewContentProvider_Delegate?
    
    private struct Item
    {
        let identifier: Int
        let entry: KHMainEntry
    }
    
    private var _separatorConfigForCurrentLevel: KHSeparatorConfig?
    {
        switch self._level {
        case ...0:      .init(lineWidth: KHPixel, inset: .zero)
        case 1:         nil
        case 2:         .init(lineWidth: KHPixel, inset: .init(left: KHStyle.mainInset))
        default:        .init(lineWidth: KHPixel, inset: .init(left: KHStyle.mainInset + KHStyle.listInset3.left))
        }
    }
}

extension KHTreeGroupViewContentProvider: KHGroupViewTitleView_Delegate
{
    func groupViewTitleViewDidRequestDetails(for linkID: String)
    {
        self._delegate?.groupViewContentProviderDidRequestDetails(for: linkID)
    }
}

// *************************
// *************************  TITLE VIEW FOR TREE GROUP VIEW
// *************************

fileprivate protocol KHGroupViewTitleView_Delegate: AnyObject
{
    func groupViewTitleViewDidRequestDetails(for linkID: String)
}

/*!
 @brief Multi-purpose element to show 'title' label for container or button for 'link' type elemnt
 */
fileprivate class KHGroupViewTitleView: KHView, KHColor_Sensitive
{
    // MARK: - Init
    
    init(with title: String, level: Int, linkID: String?, delegate: KHGroupViewTitleView_Delegate?)
    {
        self._level = level
        self._linkID = linkID
        self._delegate = delegate
        super.init(frame: .standard)
        self._configure()
        self._populate(title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    
    func updateColors()
    {
        let textColor: UIColor
        
        switch self._level {
        case ...0:
            textColor = KHTheme.color.listText0
            self.backgroundColor = KHTheme.color.listBack0
        case 1:
            textColor = KHTheme.color.listText1
        case 2:
            textColor = KHTheme.color.listText2
        default:
            textColor = KHTheme.color.listText3
        }
        
        if  let label = self._titleLabel {
            label.textColor = textColor
        } else if let button = self._button {
            button.setTitleColor(textColor, for: .normal)
        }
        
        if  let view = self._imageView {
            view.tintColor = KHTheme.color.separator
        }
    }
    
    // MARK: - Layout
    
    override func layout(with contentInset: UIEdgeInsets, options: KHView.LayoutOptions)
    {
        guard let view = self._titleLabel ?? self._button else {
            return
        }
        
        let spacing = KHStyle.groupRowButtonSpacing
        var viewInset: UIEdgeInsets = .init(x: KHStyle.mainInset)
        var imageOffset: CGFloat = 0
        
        if  let view = self._imageView {
            imageOffset = view.width + spacing
            viewInset.right = spacing
        }
        
        let contentPadding = contentInset.expand(to: self._rowInsetForCurrentLevel + viewInset)
        let padding = contentPadding + .init(right: imageOffset)
        
        let size = Self._contentSize(for: view, width: self.bounds.width - padding.width)
        let frame = self.bounds.height(0).inframe(size, [KHAlign.top, KHAlign.left], padding)
        
        UIView.performWithoutAnimation {
            view.frame = frame
            view.layoutIfNeeded()
        }
        
        self.height = frame.bottom + padding.bottom
        
        if  let view = self._imageView {
            view.frame = self.bounds.inframe(view.size, KHAlign.right, contentPadding)
        }
    }
    
    // MARK: - Private
    
    private let _level: Int
    private let _linkID: String?
    
    private weak var _delegate: KHGroupViewTitleView_Delegate?
    
    private weak var _titleLabel: UILabel?
    private weak var _button: UIButton?
    private weak var _imageView: UIImageView?
    
    private func _configure()
    {
        //
    }
    
    private func _populate(_ title: String)
    {
        let text = self._level == 0 ? title.uppercased() : title
        
        if  let linkID = self._linkID {
            self._addImageView()
            self._addButton(text, id: linkID)
        } else {
            self._addTitleLabel(text)
        }
    }
        
    private func _addTitleLabel(_ title: String)
    {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .left
        label.font = self._labelFontForCurrentLevel
        label.text = title
        
        self.addSubview(label)
        self._titleLabel = label
    }
    
    private func _addImageView()
    {
        let view = UIImageView(image: .init(named: "b-arrow"))
        
        self.addSubview(view)
        self._imageView = view
    }
    
    private class FullSizeButton: UIButton
    {
        override func point(inside point: CGPoint, with event: UIEvent?) -> Bool
        {
            point.x < self.right
        }
    }
    
    private func _addButton(_ title: String, id: String)
    {
        let button = FullSizeButton(type: .system)
        button.setTitle(title, for: .normal)
        button.contentHorizontalAlignment = .left
        if  let label = button.titleLabel {
            label.textAlignment = .left
            label.numberOfLines = 0
            label.font = self._labelFontForCurrentLevel
        }
        button.addTarget(self, action: #selector(_didTap), for: .touchUpInside)
        
        self.addSubview(button)
        self._button = button
    }
    
    private var _labelFontForCurrentLevel: UIFont
    {
        switch self._level {
        case ...0:      KHStyle.listFont0
        case 1:         KHStyle.listFont1
        case 2:         KHStyle.listFont2
        default:        KHStyle.listFont3
        }
    }
    
    private var _rowInsetForCurrentLevel: UIEdgeInsets
    {
        switch self._level {
        case ...0:      KHStyle.listInset0
        case 1:         KHStyle.listInset1
        case 2:         KHStyle.listInset2
        default:        KHStyle.listInset3
        }
    }
    
    // MARK: - Actions
    
    @objc
    private func _didTap(_ button: UIButton)
    {
        guard let linkID = self._linkID else {
            return
        }
        self._delegate?.groupViewTitleViewDidRequestDetails(for: linkID)
    }
    
    // MARK: - Class Private
    
    private static func _contentSize(for view: UIView, width: CGFloat) -> CGSize
    {
        let view = (view as? UIButton)?.titleLabel ?? view
        return view.sizeThatFits(.init(width: width)).width(width)
    }
}
