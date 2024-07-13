//
//  HomeView.swift
//  Multitoc
//
//  Created by Alex Khuala on 24.04.24.
//

import SwiftUI

/*!
 @brief Home screen, contains 'TreeView'
 */
struct HomeView: View {
    
    enum Path: Equatable, Hashable
    {
        case details(_ id: String)
    }
    @State private var navigationPath: [Path] = []
    
    @State private var loaded: Bool = false
    private let _title: String = "Home"
    
    var body: some View {
        NavigationStack(path: self.$navigationPath) {
            if  self.loaded {
                TreeView(viewModel: KHTreeViewModel()) { id in
                    self.navigationPath.append(.details(id))
                }
                .navigationTitle(self._title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Theme") {
                            KHTheme.toggle()
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                }
                .navigationDestination(for: Path.self) { path in
                    switch path {
                    case let .details(id):
                        DetailsView(id: id)
                    }
                }
            } else {
                ProgressView("Loading...")
                .progressViewStyle(CircularProgressViewStyle())
                .navigationTitle(self._title)
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .onAppear {
            KHContentManager.shared.loadTree {
                self.loaded = true
            }
        }
    }
}

/*!
 @brief SwiftUI representation of multilevel 'KHTreeView'
 */
fileprivate struct TreeView: UIViewRepresentable
{
    @Environment(\.editMode) private var _editMode
    private var _editing: Bool {
        self._editMode?.wrappedValue == .active
    }
    
    let viewModel: KHTree_ViewModel
    let onSelect: (_ id: String) -> Void
    
    func makeUIView(context: Context) -> UIView
    {
        KHTreeView(with: self.viewModel, editing: self._editing, onSelect: self.onSelect)
    }
    
    func updateUIView(_ uiView: UIView, context: Context)
    {
        guard let view = uiView as? KHTreeView else {
            return
        }
        view.editing = self._editing
        view.layoutIfNeeded()
    }
}

#Preview {
    HomeView()
}
