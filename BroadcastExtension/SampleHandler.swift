//
//  SampleHandler.swift
//  BroadcastExtension
//
//  Created by Blaze Pankowski on 28/05/2025.
//

#if os(iOS)
import LiveKit

class SampleHandler: LKSampleHandler, @unchecked Sendable {
    override var enableLogging: Bool { true }
}
#endif
