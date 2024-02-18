//
//  File.swift
//  Oculife
//
//  Created by Taeuk on 2/17/24.
//  Copyright © 2024 Taeuk Kang. All rights reserved.
//

import Foundation

// MARK: - Welcome
struct AssistResponseWrapper: Codable {
    let data: AssistResponsePayload
    let status: String
}

// MARK: - DataClass
struct AssistResponsePayload: Codable {
    let condition, instructions: String
    let videoUrl: String?
    let videoTimestamps: VideoTimestamps?
}

// MARK: - VideoTimestamps
struct VideoTimestamp: Codable {
    let start, end: Int
    let text: String
}

typealias VideoTimestamps = [VideoTimestamp]
