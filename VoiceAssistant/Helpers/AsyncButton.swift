//
//  AsyncButton.swift
//  VoiceAssistant
//
//  Created by Blaze Pankowski on 23/05/2025.
//

import SwiftUI

struct AsyncButton<Label: View, BusyLabel: View>: View {
    private let action: () async -> Void
    private let label: () -> Label
    private let busyLabel: () -> BusyLabel

    @State private var isBusy = false

    public init(
        action: @escaping () async -> Void,
        @ViewBuilder label: @escaping () -> Label,
        @ViewBuilder busyLabel: @escaping () -> BusyLabel = { EmptyView() }
    ) {
        self.action = action
        self.label = label
        self.busyLabel = busyLabel
    }

    public var body: some View {
        Button {
            isBusy = true
            Task {
                await action()
                isBusy = false
            }
        } label: {
            if isBusy {
                let busyLabel = busyLabel()
                if busyLabel is EmptyView {
                    label()
                } else {
                    busyLabel
                }
            } else {
                label()
            }
        }
        .disabled(isBusy)
    }
}
