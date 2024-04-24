//
//  KHMainEntry.swift
//  homework-img.ly
//
//  Created by Alex Khuala on 24.04.24.
//

import Foundation

/*!
 @brief Model for each Tree element
 */
struct KHMainEntry
{
    var label: String
    var content: Content
    
    enum Content
    {
        case link(_ id: String)
        case children(_ entries: [KHMainEntry])
    }
}

extension KHMainEntry: Codable
{
    init(from decoder: Decoder) throws
    {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.label = try container.decode(String.self, forKey: .label)
        
        if  let id = try? container.decode(String.self, forKey: .id) {
            self.content = .link(id)
        } else if let entries = try? container.decode([KHMainEntry].self, forKey: .children) {
            self.content = .children(entries)
        } else {
            self.content = .children([])
        }
    }
    
    func encode(to encoder: Encoder) throws
    {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.label, forKey: .label)
        
        switch self.content {
        case let .link(id):
            try container.encode(id, forKey: .id)
        case let .children(entries):
            try container.encode(entries, forKey: .children)
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case label
        case id
        case children
    }
}
