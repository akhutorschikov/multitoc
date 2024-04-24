//
//  DetailsView.swift
//  homework-img.ly
//
//  Created by Alex Khuala on 24.04.24.
//

import SwiftUI

/*!
 @brief Details view to show 'KHDetailsEntry' for 'id'
 */
struct DetailsView: View {
    
    let id: String
    @State private var details: KHDetailsEntry?
    @State private var loaded: Bool = false
    private let _title: String = "Details"
    
    var body: some View {
        if  self.loaded {
            if  let details = self.details {
                ScrollView {
                    VStack(spacing: 0) {
                        VStack {
                            Text("IDENTIFIER")
                                .font(.init(KHStyle.listFont0))
                                .foregroundStyle(Color(KHTheme.color.listText0))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.bottom, 2)
                            
                            Text(details.id)
                                .font(.init(KHStyle.listFont2))
                                .foregroundStyle(Color(KHTheme.color.listText2))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal, KHStyle.mainInset)
                        .padding(.vertical, KHStyle.bodyInset)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(KHTheme.color.listBack0))
                        
                        Text(details.description ?? "No description")
                            .font(.init(KHStyle.bodyFont))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(Color(KHTheme.color.text))
                            .padding(KHStyle.mainInset)
                        
                        VStack(spacing: 0) {
                            HStack(alignment: .top, spacing: 0) {
                                Text(details.dataCreatedString)
                                    .frame(width: KHStyle.dateWidth, alignment: .leading)
                                    .font(.init(KHStyle.infoFont))
                                    .foregroundStyle(Color(KHTheme.color.info))
                                    .padding(.top, KHStyle.infoInset)
                                    .padding(.trailing, KHStyle.bodyInset)
                                    
                                VStack(spacing: 0) {
                                    Text("CREATED BY")
                                        .font(.init(KHStyle.infoBoldFont))
                                        .foregroundStyle(Color(KHTheme.color.listText0))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.leading, KHStyle.bodyInset)
                                        .padding(.bottom, KHStyle.detailEmailSpacing)
                                    Text(verbatim: details.creator ?? "Unknown")
                                        .font(.init(KHStyle.emailFont))
                                        .foregroundStyle(Color(KHTheme.color.listText2))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.leading, KHStyle.bodyInset)
                                        .padding(.bottom, KHStyle.bodyInset)
                                }
                                .padding(.top, KHStyle.infoInset)
                                .border(width: KHPixel, edges: [.leading], color: Color(KHTheme.color.separator))
                            }
                            .padding(.top, KHStyle.bodyInset)
                            .padding(.horizontal, KHStyle.mainInset)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(KHTheme.color.listBack0))
                            
                            HStack(alignment: .top, spacing: 0) {
                                Text(details.dataModifiedString)
                                    .frame(width: KHStyle.dateWidth, alignment: .leading)
                                    .font(.init(KHStyle.infoFont))
                                    .foregroundStyle(Color(KHTheme.color.info))
                                    .padding(.top, KHStyle.bodyInset)
                                    .padding(.trailing, KHStyle.bodyInset)
                                    
                                VStack(spacing: 0) {
                                    Text("MODIFIED BY")
                                        .font(.init(KHStyle.infoBoldFont))
                                        .foregroundStyle(Color(KHTheme.color.listText0))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.top, KHStyle.bodyInset)
                                        .padding(.leading, KHStyle.bodyInset)
                                        .padding(.bottom, KHStyle.detailEmailSpacing)
                                    Text(verbatim: details.modifier ?? "Unknown")
                                        .font(.init(KHStyle.emailFont))
                                        .foregroundStyle(Color(KHTheme.color.listText2))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.leading, KHStyle.bodyInset)
                                        .padding(.bottom, KHStyle.infoInset)
                                        
                                }
                                .border(width: KHPixel, edges: [.leading], color: Color(KHTheme.color.separator))
                            }
                            .padding(.bottom, KHStyle.bodyInset)
                            .padding(.horizontal, KHStyle.mainInset)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                    }
                }
                .navigationTitle(self._title)
                .navigationBarTitleDisplayMode(.inline)
            } else {
                Text("No details")
                .navigationTitle(self._title)
                .navigationBarTitleDisplayMode(.inline)
            }
        } else {
            ProgressView("Loading...")
            .progressViewStyle(CircularProgressViewStyle())
            .navigationTitle(self._title)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                KHContentManager.shared.loadDetails(self.id) { details in
                    self.details = details
                    self.loaded = true
                }
            }
        }
    }
}

extension View {
    func border(width: CGFloat, edges: [Edge], color: Color) -> some View {
        overlay(EdgeBorder(width: width, edges: edges).foregroundColor(color))
    }
}

struct EdgeBorder: Shape {
    var width: CGFloat
    var edges: [Edge]

    func path(in rect: CGRect) -> Path {
        edges.map { edge -> Path in
            switch edge {
            case .top: return Path(.init(x: rect.minX, y: rect.minY, width: rect.width, height: width))
            case .bottom: return Path(.init(x: rect.minX, y: rect.maxY - width, width: rect.width, height: width))
            case .leading: return Path(.init(x: rect.minX, y: rect.minY, width: width, height: rect.height))
            case .trailing: return Path(.init(x: rect.maxX - width, y: rect.minY, width: width, height: rect.height))
            }
        }.reduce(into: Path()) { $0.addPath($1) }
    }
}

#Preview {
    DetailsView(id: "id_0")
}
