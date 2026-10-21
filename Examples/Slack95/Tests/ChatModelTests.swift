import Testing

@testable import Slack95

@MainActor
struct ChatModelTests {
  @Test func draftsStayWithTheirConversation() {
    let model = ChatModel()
    model.updateDraft("For general")
    model.selectRoom("design")
    #expect(model.draft.isEmpty)
    model.updateDraft("For design")
    model.send()
    #expect(model.currentMessages.last?.text == "For design")
    #expect(model.draft.isEmpty)
    model.selectRoom("general")
    #expect(model.draft == "For general")
    #expect(!model.currentMessages.contains { $0.text == "For design" })
  }

  @Test func whitespaceDoesNotSend() {
    let model = ChatModel()
    let count = model.currentMessages.count
    model.updateDraft(" \n ")
    model.send()
    #expect(!model.canSend)
    #expect(model.currentMessages.count == count)
  }

  @Test func repliesBelongToTheirThread() throws {
    let model = ChatModel()
    let original = try #require(model.thread)
    model.updateReplyDraft("First draft")
    let other = try #require(model.currentMessages.last)
    model.openThread(other.id)
    #expect(model.replyDraft.isEmpty)
    model.updateReplyDraft("A different reply")
    model.sendReply()
    #expect(model.thread?.replies.last?.text == "A different reply")
    model.openThread(original.id)
    #expect(model.replyDraft == "First draft")
    #expect(model.thread?.replies.count == original.replies.count)
  }

  @Test func navigationClearsSearchThreadAndUnread() {
    let model = ChatModel()
    model.search = "ready"
    #expect(model.visibleMessages.count == 1)
    model.selectRoom("design")
    #expect(model.search.isEmpty)
    #expect(model.thread == nil)
    #expect(model.selectedRoom.unread == 0)
    model.selectRoom("missing")
    #expect(model.selectedRoomID == "design")
  }

  @Test func likingTogglesOnlyTheSelectedMessage() throws {
    let model = ChatModel()
    let message = try #require(model.currentMessages.first)
    model.toggleLike(message.id)
    #expect(model.currentMessages.first?.isLiked == true)
    model.toggleLike(message.id)
    #expect(model.currentMessages.first?.isLiked == false)
  }
}
