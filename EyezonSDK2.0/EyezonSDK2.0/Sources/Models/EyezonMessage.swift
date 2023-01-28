//
//  EyezonMessage.swift
//  EyezonSDK
//
//  Created by Denis Borodavchenko on 02.08.2021.
//

import Foundation

public enum MessageType: String, Codable, Hashable {
    case Dialog = "DIALOG"
    case Stream = "STREAM"
}

public class EyezonMessage: Codable {
    var _id: String = .empty
    let createdAt: String
    let user: String
    var messageText: String?
    let attachment: Attachment?
    let type: MessageType
    let dialog: String

    var isLoading: Bool?
    var isRead: Bool
    var isDeleted: Bool
    
}
