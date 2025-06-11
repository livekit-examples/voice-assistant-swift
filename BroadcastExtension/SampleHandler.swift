#if os(iOS)
import LiveKit

class SampleHandler: LKSampleHandler, @unchecked Sendable {
    override var enableLogging: Bool { true }
}
#endif
