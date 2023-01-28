//
//  Attachment.swift
//  EyezonSDK
//
//  Created by Denis Borodavchenko on 02.08.2021.
//

import Foundation

enum AttachmentType: String, Codable, Hashable {
    case Video = "VIDEO"
    case Audio = "AUDIO"
    case Stream = "STREAM"
    case Photo = "PHOTO"
    case Document = "DOCUMENT"
    case Link = "LINK"
    case Good = "GOOD"
    case Geo = "GEO"
}

public class Attachment: Codable {
    
    var updatedAt: String = .empty
    var createdAt: String = .empty
    var type: AttachmentType = .Photo
    var src: URL = URL.init(fileURLWithPath: .empty)
    var thumbnail: URL?
    var message: String = .empty
    var _id: String = .empty
    
    init() {}
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        _id = try container.decode(String.self, forKey: ._id)
        updatedAt = (try? container.decode(String.self, forKey: .updatedAt)) ?? .empty
        createdAt = (try? container.decode(String.self, forKey: .createdAt)) ?? .empty
        type = (try? container.decode(AttachmentType.self, forKey: .type)) ?? .Photo
        src = try container.decode(URL.self, forKey: .src)
        thumbnail = try? container.decode(URL.self, forKey: .thumbnail)
        message = (try? container.decode(String.self, forKey: .message)) ?? .empty
    }
}
