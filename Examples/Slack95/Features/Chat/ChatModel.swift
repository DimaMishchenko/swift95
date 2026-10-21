import Foundation
import Observation

struct ChatRoom: Identifiable, Equatable {
  let id: String
  let title: String
  let topic: String
  let isDirect: Bool
  var unread: Int = 0
}

struct ChatMessage: Identifiable, Equatable {
  let id: UUID
  let author: String
  let initials: String
  let text: String
  let time: String
  var replies: [ChatMessage] = []
  var isLiked = false

  init(
    id: UUID = UUID(), author: String, initials: String, text: String,
    time: String, replies: [ChatMessage] = []
  ) {
    self.id = id
    self.author = author
    self.initials = initials
    self.text = text
    self.time = time
    self.replies = replies
  }
}

@MainActor @Observable
final class ChatModel {
  var rooms = [
    ChatRoom(
      id: "general", title: "general", topic: "A little room for the big picture.", isDirect: false),
    ChatRoom(
      id: "design", title: "design", topic: "Small details. Big feelings.", isDirect: false,
      unread: 3),
    ChatRoom(
      id: "engineering", title: "engineering", topic: "Build things that feel good to use.",
      isDirect: false),
    ChatRoom(
      id: "random", title: "random", topic: "The unofficial water cooler.", isDirect: false,
      unread: 1),
    ChatRoom(id: "maya", title: "Maya Chen", topic: "Product designer · Available", isDirect: true),
    ChatRoom(id: "leo", title: "Leo Park", topic: "Engineer · Deep in a build", isDirect: true)
  ]
  private(set) var selectedRoomID = "general"
  var search = ""
  private(set) var messages: [String: [ChatMessage]]
  private(set) var drafts: [String: String] = [:]
  private(set) var replyDrafts: [UUID: String] = [:]
  private(set) var threadID: UUID?

  init() {
    let welcome = ChatMessage(
      author: "Maya Chen", initials: "MC",
      text:
        "Morning, team! The new Fieldnotes workspace is ready. A calmer place for our ideas, work in progress, and tiny victories.",
      time: "9:41 AM",
      replies: [
        ChatMessage(
          author: "Leo Park", initials: "LP",
          text: "The little details make it. Those square buttons!", time: "9:44 AM"),
        ChatMessage(
          author: "Nora Ellis", initials: "NE",
          text: "Feels like opening my first computer, in the best possible way.", time: "9:46 AM")
      ]
    )
    messages = [
      "general": [
        welcome,
        ChatMessage(
          author: "Leo Park", initials: "LP",
          text:
            "Just shipped the first working build. Everything here works offline, so feel free to explore and leave a message.",
          time: "9:48 AM"),
        ChatMessage(
          author: "Nora Ellis", initials: "NE",
          text:
            "Today's plan\n• Polish the workspace\n• Make room for good conversations\n• Celebrate with a very long lunch",
          time: "9:52 AM"),
        ChatMessage(
          author: "Maya Chen", initials: "MC",
          text:
            "One more thing: the design sketches are in #design. I'd love your eyes on the new color palette.",
          time: "10:03 AM")
      ],
      "design": [
        ChatMessage(
          author: "Maya Chen", initials: "MC",
          text:
            "Palette exploration no. 04\nAubergine, warm paper, sea glass. A little nostalgic, a little unexpected.",
          time: "9:57 AM"),
        ChatMessage(
          author: "Nora Ellis", initials: "NE",
          text: "Love the sea glass. Let's keep the contrast strong and the edges crisp.",
          time: "10:01 AM")
      ],
      "engineering": [
        ChatMessage(
          author: "Leo Park", initials: "LP",
          text:
            "Build notes: native SwiftUI, classic Swift95 controls, and absolutely no loading spinners. A good day.",
          time: "9:32 AM")
      ],
      "random": [
        ChatMessage(
          author: "Nora Ellis", initials: "NE",
          text:
            "Important research: does the office plant need a name? Current frontrunner is Fernanda.",
          time: "9:14 AM")
      ],
      "maya": [
        ChatMessage(
          author: "Maya Chen", initials: "MC",
          text: "Hey! Welcome aboard. Pick a channel, say hello, and make yourself at home.",
          time: "9:30 AM")
      ],
      "leo": [
        ChatMessage(
          author: "Leo Park", initials: "LP",
          text:
            "If you find a rough edge, send it my way. There is always room for one more pixel of polish.",
          time: "9:35 AM")
      ]
    ]
    threadID = welcome.id
  }

  var selectedRoom: ChatRoom { rooms.first { $0.id == selectedRoomID } ?? rooms[0] }
  var currentMessages: [ChatMessage] { messages[selectedRoomID, default: []] }
  var visibleMessages: [ChatMessage] {
    let query = search.trimmingCharacters(in: .whitespacesAndNewlines)
    return query.isEmpty
      ? currentMessages
      : currentMessages.filter {
        $0.text.localizedCaseInsensitiveContains(query)
          || $0.author.localizedCaseInsensitiveContains(query)
      }
  }
  var draft: String { drafts[selectedRoomID, default: ""] }
  var canSend: Bool { !draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
  var thread: ChatMessage? { currentMessages.first { $0.id == threadID } }
  var replyDraft: String { threadID.map { replyDrafts[$0, default: ""] } ?? "" }
  var canReply: Bool { !replyDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

  func selectRoom(_ id: String) {
    guard rooms.contains(where: { $0.id == id }) else { return }
    selectedRoomID = id
    threadID = nil
    search = ""
    if let index = rooms.firstIndex(where: { $0.id == id }) { rooms[index].unread = 0 }
  }

  func updateDraft(_ value: String) { drafts[selectedRoomID] = value }
  func updateReplyDraft(_ value: String) {
    guard let threadID else { return }
    replyDrafts[threadID] = value
  }
  func openThread(_ id: UUID) { threadID = id }
  func closeThread() { threadID = nil }

  func send() {
    guard canSend else { return }
    messages[selectedRoomID, default: []].append(makeMessage(draft))
    drafts[selectedRoomID] = ""
    search = ""
  }

  func sendReply() {
    guard canReply, let threadID,
      let index = messages[selectedRoomID]?.firstIndex(where: { $0.id == threadID })
    else { return }
    messages[selectedRoomID]?[index].replies.append(makeMessage(replyDraft))
    replyDrafts[threadID] = ""
  }

  func toggleLike(_ id: UUID) {
    guard let index = messages[selectedRoomID]?.firstIndex(where: { $0.id == id }) else { return }
    messages[selectedRoomID]?[index].isLiked.toggle()
  }

  private func makeMessage(_ text: String) -> ChatMessage {
    ChatMessage(
      author: "Alex Morgan", initials: "AM",
      text: text.trimmingCharacters(in: .whitespacesAndNewlines),
      time: Date.now.formatted(date: .omitted, time: .shortened))
  }
}
