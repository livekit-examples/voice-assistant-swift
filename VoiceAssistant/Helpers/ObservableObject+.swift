//
//  ObservableObject+.swift
//  VoiceAssistant
//
//  Created by Blaze Pankowski on 26/05/2025.
//

import Combine

extension ObservableObject {
    typealias BufferedObjectWillChangePublisher = Publishers.Buffer<ObjectWillChangePublisher>

    private var bufferedObjectWillChange: BufferedObjectWillChangePublisher {
        objectWillChange
            .buffer(size: 1, prefetch: .byRequest, whenFull: .dropOldest)
    }

    var changes: AsyncPublisher<BufferedObjectWillChangePublisher> {
        bufferedObjectWillChange.values
    }
}
