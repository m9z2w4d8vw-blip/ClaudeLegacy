import Foundation

struct BridgeSnapshot: Codable {
    let pageTitle: String
    let pagePath: String
    let browserFloor: String
    let buildId: String
    let hasChatEditor: Bool
    let hasSendButton: Bool
    let hasFileUpload: Bool
    let hasModelSelector: Bool
    let hasSidebar: Bool

    var chatReady: Bool { hasChatEditor && hasSendButton }
}
