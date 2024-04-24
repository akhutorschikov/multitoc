//
//  KHDetailsEntry.swift
//  homework-img.ly
//
//  Created by Alex Khuala on 24.04.24.
//

import Foundation

struct KHDetailsEntry
{
    let id: String
    let dateCreated: Date?
    let dateModified: Date?
    let creator: String?
    let modifier: String?
    let description: String?
    
    var dataCreatedString: String {
        return Self._dateString(self.dateCreated)
    }
    
    var dataModifiedString: String {
        return Self._dateString(self.dateModified)
    }
    
    private static func _dateString(_ date: Date?) -> String
    {
        guard let date = date else {
            return "-"
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy\nHH:mm"
        
        return dateFormatter.string(from: date)
    }
}

extension KHDetailsEntry: Codable
{
    init(from decoder: Decoder) throws
    {
        let dateFormatter = Self._dateFormatter
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        
        if  let dateString = try? container.decode(String.self, forKey: .createdAt) {
            self.dateCreated = dateFormatter.date(from: dateString)
        } else {
            self.dateCreated = nil
        }
        if  let dateString = try? container.decode(String.self, forKey: .lastModifiedAt) {
            self.dateModified = dateFormatter.date(from: dateString)
        } else {
            self.dateModified = nil
        }
        
        self.creator = try? container.decode(String.self, forKey: .createdBy)
        self.modifier = try? container.decode(String.self, forKey: .lastModifiedBy)
        self.description = try? container.decode(String.self, forKey: .description)
    }
    
    func encode(to encoder: Encoder) throws
    {
        let dateFormatter = Self._dateFormatter
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        
        if  let date = self.dateCreated {
            try container.encode(dateFormatter.string(from: date), forKey: .createdAt)
        }
        if  let date = self.dateModified {
            try container.encode(dateFormatter.string(from: date), forKey: .lastModifiedAt)
        }
        
        try container.encode(self.creator, forKey: .createdBy)
        try container.encode(self.modifier, forKey: .lastModifiedBy)
        try container.encode(self.description, forKey: .description)
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case createdAt
        case lastModifiedAt
        case createdBy
        case lastModifiedBy
        case description
    }
    
    private static var _dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        return dateFormatter
    }
}
