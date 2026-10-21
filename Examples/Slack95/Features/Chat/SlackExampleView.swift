import Swift95
import SwiftUI

struct SlackExampleView: View {
  @Environment(\.theme95) private var theme
  @State private var model = ChatModel()
  @State private var showsSidebar = false
  @State private var showsInfo = false

  private let plum = Color(red: 0.23, green: 0.12, blue: 0.28)
  private let sidebarColor = Color(red: 0.30, green: 0.19, blue: 0.35)
  private let ink = Color(red: 0.17, green: 0.16, blue: 0.18)

  var body: some View {
    GeometryReader { geometry in
      let compact = geometry.size.width < 650
      let wide = geometry.size.width >= 1050
      VStack(spacing: 0) {
        titleBar(compact: compact)
        if compact {
          if showsSidebar {
            sidebar.accessibilityIdentifier("slack.channels.screen")
          } else if model.thread != nil {
            threadPanel
          } else {
            VStack(spacing: 0) {
              channelHeader
              conversation
            }
            .safeAreaInset(edge: .bottom, spacing: 0) { composer }
            .background(Color.white)
          }
        } else {
          HStack(spacing: 0) {
            workspaceRail
            sidebar.frame(width: 202)
            VStack(spacing: 0) {
              channelHeader
              conversation
              composer
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            if model.thread != nil {
              threadPanel.frame(width: wide ? 292 : 260)
            }
          }
        }
        statusBar
      }
      .font(theme.fonts.font(size: compact ? 17 : 15, relativeTo: .body))
      .foregroundStyle(ink)
      .bevel95(.raised)
      .onAppear {
        if !wide { model.closeThread() }
      }
      .sheet(isPresented: $showsInfo) { channelInfo }
    }
    .background(Color(red: 0.97, green: 0.96, blue: 0.94).ignoresSafeArea())
    .preferredColorScheme(.light)
  }

  private func titleBar(compact: Bool) -> some View {
    HStack(spacing: 12) {
      if compact && !showsSidebar && model.thread == nil {
        Button {
          showsSidebar = true
        } label: {
          Text("← Channels")
            .font(theme.fonts.font(size: 17))
            .frame(minHeight: 44)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("slack.navigation.channels")
      } else {
        Text("▦").font(theme.fonts.font(size: 22))
        Text("Fieldnotes").font(theme.fonts.font(size: 17, weight: .bold))
      }
      if !compact {
        Text("/  a place to make things together").foregroundStyle(.white.opacity(0.65))
      }
      Spacer(minLength: 0)
      Text("Slack95").foregroundStyle(.white.opacity(0.8))
    }
    .foregroundStyle(.white)
    .padding(.horizontal, 14)
    .frame(height: compact ? 48 : 43)
    .background(plum, ignoresSafeAreaEdges: [])
    .overlay(alignment: .bottom) { Color.white.opacity(0.2).frame(height: 1) }
  }

  private var workspaceRail: some View {
    VStack(spacing: 18) {
      Text("F").font(theme.fonts.font(size: 24, weight: .bold))
        .frame(width: 35, height: 35)
        .bevel95(.raised, background: Color(red: 0.79, green: 0.87, blue: 0.72))
        .foregroundStyle(plum)
        .accessibilityLabel("Fieldnotes workspace")
      Image(systemName: "bubble.left.and.bubble.right.fill")
        .foregroundStyle(.white)
      Text("HOME").font(theme.fonts.font(size: 10)).foregroundStyle(.white.opacity(0.65))
      Spacer()
      avatar("AM", size: 31)
    }
    .padding(.vertical, 18)
    .frame(width: 54)
    .background(plum)
  }

  private var sidebar: some View {
    VStack(alignment: .leading, spacing: 0) {
      VStack(alignment: .leading, spacing: 7) {
        Text("Fieldnotes").font(theme.fonts.font(size: 23, weight: .bold))
        HStack(spacing: 5) {
          Rectangle().fill(Color(red: 0.56, green: 0.81, blue: 0.65)).frame(width: 7, height: 7)
          Text("Alex Morgan").foregroundStyle(.white.opacity(0.75))
        }
      }
      .padding(18)
      Rectangle().fill(.white.opacity(0.15)).frame(height: 1)
      ScrollView {
        VStack(alignment: .leading, spacing: 6) {
          Text("YOUR WORKSPACE").font(theme.fonts.font(size: 11)).opacity(0.6)
            .padding(.horizontal, 15).padding(.top, 22).padding(.bottom, 9)
          Text("Channels").font(theme.fonts.font(size: 16, weight: .bold))
            .padding(.horizontal, 15).padding(.bottom, 4)
          ForEach(model.rooms.filter { !$0.isDirect }) { room in roomRow(room) }
          Text("Direct messages").font(theme.fonts.font(size: 16, weight: .bold))
            .padding(.horizontal, 15).padding(.top, 28).padding(.bottom, 5)
          ForEach(model.rooms.filter(\.isDirect)) { room in roomRow(room) }
        }
      }
      VStack(alignment: .leading, spacing: 6) {
        Text("A quieter kind of teamwork.")
        Text("Local workspace · 6 people").font(theme.fonts.font(size: 12)).opacity(0.6)
      }
      .padding(16)
    }
    .foregroundStyle(.white)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .background(sidebarColor)
  }

  private func roomRow(_ room: ChatRoom) -> some View {
    Button {
      model.selectRoom(room.id)
      showsSidebar = false
    } label: {
      HStack(spacing: 9) {
        Text(room.isDirect ? "●" : "#")
          .foregroundStyle(
            room.isDirect ? Color(red: 0.56, green: 0.81, blue: 0.65) : .white.opacity(0.6))
        Text(room.title)
        Spacer(minLength: 0)
        if room.unread > 0 {
          Text("\(room.unread)").font(theme.fonts.font(size: 12, weight: .bold))
            .padding(.horizontal, 5).padding(.vertical, 2)
            .background(Color(red: 0.76, green: 0.34, blue: 0.29))
        }
      }
      .padding(.horizontal, 16).frame(minHeight: 48)
      .background(
        model.selectedRoomID == room.id ? Color(red: 0.22, green: 0.48, blue: 0.48) : .clear
      )
      .contentShape(.rect)
    }
    .buttonStyle(.plain)
    .accessibilityIdentifier("slack.channel.\(room.id)")
    .accessibilityAddTraits(model.selectedRoomID == room.id ? .isSelected : [])
  }

  private var channelHeader: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack(spacing: 10) {
        VStack(alignment: .leading, spacing: 5) {
          Text("\(model.selectedRoom.isDirect ? "" : "# ")\(model.selectedRoom.title)")
            .font(theme.fonts.font(size: 23, weight: .bold)).lineLimit(1)
          Text(model.selectedRoom.topic).font(theme.fonts.font(size: 13))
            .foregroundStyle(.secondary)
            .lineLimit(1)
        }
        Spacer(minLength: 0)
        Button95(action: { showsInfo = true }) {
          Text("Info").frame(minHeight: 32)
        }
        .accessibilityIdentifier("slack.channelInfo")
      }
      TextField95("Search this conversation", text: $model.search)
        .swiftUI { field in field.frame(minHeight: 32) }
        .accessibilityIdentifier("slack.search")
    }
    .padding(16)
    .background(Color(red: 0.97, green: 0.96, blue: 0.94))
    .overlay(alignment: .bottom) { Color.gray.opacity(0.3).frame(height: 1) }
  }

  private var conversation: some View {
    ScrollViewReader { proxy in
      ScrollView95 {
        VStack(alignment: .leading, spacing: 23) {
          HStack {
            Rectangle().fill(.gray.opacity(0.3)).frame(height: 1)
            Text("Wednesday, October 21").font(theme.fonts.font(size: 12)).fixedSize()
            Rectangle().fill(.gray.opacity(0.3)).frame(height: 1)
          }
          .padding(.top, 5)
          if model.visibleMessages.isEmpty {
            Text("No messages match “\(model.search)”.")
              .foregroundStyle(.secondary).padding(.vertical, 30)
          }
          ForEach(model.visibleMessages) { message in
            messageRow(message, actions: true).id(message.id)
          }
          Color.clear.frame(height: 1).id("latest")
        }
        .padding(17)
      }
      .swiftUI { scroll in scroll.scrollDismissesKeyboard(.interactively) }
      .onChange(of: model.currentMessages.count) { _, _ in
        proxy.scrollTo("latest", anchor: .bottom)
      }
    }
  }

  private func messageRow(_ message: ChatMessage, actions: Bool) -> some View {
    HStack(alignment: .top, spacing: 11) {
      avatar(message.initials, size: 35)
      VStack(alignment: .leading, spacing: 7) {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
          Text(message.author).font(theme.fonts.font(size: 16, weight: .bold))
          Text(message.time).font(theme.fonts.font(size: 11)).foregroundStyle(.secondary)
        }
        Text(message.text).lineSpacing(4).fixedSize(horizontal: false, vertical: true)
          .textSelection(.enabled)
        if actions {
          HStack(spacing: 12) {
            Button {
              model.toggleLike(message.id)
            } label: {
              Text(message.isLiked ? "♥  1" : "♡  Like")
                .font(theme.fonts.font(size: 12))
                .padding(.horizontal, 9).frame(minHeight: 44)
                .bevel95(
                  .raised,
                  background: message.isLiked
                    ? Color(red: 0.96, green: 0.87, blue: 0.83)
                    : Color(red: 0.95, green: 0.94, blue: 0.91))
            }
            .buttonStyle(.plain)
            .accessibilityLabel(message.isLiked ? "Remove like" : "Like message")
            Button {
              model.openThread(message.id)
            } label: {
              Text(
                message.replies.isEmpty ? "Reply in thread" : "\(message.replies.count) replies →"
              )
              .font(theme.fonts.font(size: 12, weight: .bold))
              .foregroundStyle(Color(red: 0.12, green: 0.40, blue: 0.48))
              .frame(minHeight: 44)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier(
              message.id == model.currentMessages.first?.id
                ? "slack.thread.open.first" : "slack.thread.\(message.id)")
          }
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
  }

  private var composer: some View {
    VStack(alignment: .leading, spacing: 7) {
      Text("Message \(model.selectedRoom.isDirect ? "" : "#")\(model.selectedRoom.title)")
        .font(theme.fonts.font(size: 12)).foregroundStyle(.secondary)
      TextEditor95(text: Binding(get: { model.draft }, set: { model.updateDraft($0) }))
        .frame(height: 65)
        .accessibilityLabel("Message composer")
        .accessibilityIdentifier("slack.composer")
      HStack {
        Text("A good conversation starts here.").font(theme.fonts.font(size: 11))
          .foregroundStyle(.secondary)
        Spacer(minLength: 0)
        Button95(action: { model.send() }) {
          Text("Send →").frame(minHeight: 32)
        }
        .disabled(!model.canSend)
        .accessibilityIdentifier("slack.send")
      }
    }
    .padding(13)
    .background(Color(red: 0.97, green: 0.96, blue: 0.94))
  }

  private var threadPanel: some View {
    VStack(alignment: .leading, spacing: 0) {
      HStack {
        Button95(action: { model.closeThread() }) {
          Text("← Back").frame(minHeight: 32)
        }
        .accessibilityLabel("Back to conversation")
        .accessibilityIdentifier("slack.thread.close")
        Text("Thread").font(theme.fonts.font(size: 21, weight: .bold))
        Spacer()
      }
      .padding(15)
      Divider95()
      if let thread = model.thread {
        ScrollView95 {
          VStack(alignment: .leading, spacing: 19) {
            messageRow(thread, actions: false)
            HStack {
              Text("\(thread.replies.count) replies").font(theme.fonts.font(size: 12))
                .foregroundStyle(.secondary)
              Rectangle().fill(.gray.opacity(0.3)).frame(height: 1)
            }
            ForEach(thread.replies) { reply in messageRow(reply, actions: false) }
          }
          .padding(15)
        }
        .swiftUI { scroll in scroll.scrollDismissesKeyboard(.interactively) }
        .safeAreaInset(edge: .bottom, spacing: 0) { replyComposer }
      }
    }
    .foregroundStyle(ink)
    .background(Color(red: 0.98, green: 0.97, blue: 0.95))
    .overlay(alignment: .leading) { Color.gray.opacity(0.4).frame(width: 1) }
    .accessibilityIdentifier("slack.thread.panel")
  }

  private var replyComposer: some View {
    VStack(alignment: .leading, spacing: 9) {
      Text("Keep the conversation going").font(theme.fonts.font(size: 12))
        .foregroundStyle(.secondary)
      TextEditor95(
        text: Binding(get: { model.replyDraft }, set: { model.updateReplyDraft($0) })
      )
      .frame(height: 72).accessibilityLabel("Thread reply")
      .accessibilityIdentifier("slack.thread.composer")
      HStack {
        Spacer()
        Button95(action: { model.sendReply() }) {
          Text("Reply →").frame(minHeight: 32)
        }
        .disabled(!model.canReply)
        .accessibilityIdentifier("slack.thread.send")
      }
    }
    .padding(13)
    .background(Color(red: 0.97, green: 0.96, blue: 0.94))
  }

  private var channelInfo: some View {
    VStack(alignment: .leading, spacing: 20) {
      Text(model.selectedRoom.title).font(theme.fonts.title)
      Text(model.selectedRoom.topic).font(theme.fonts.body)
      Divider95()
      Text(model.selectedRoom.isDirect ? "Direct conversation" : "6 members · Public channel")
      Text(
        "Fieldnotes is a fictional, offline workspace. Messages and drafts stay in this app session."
      )
      .foregroundStyle(.secondary)
      Button95("Done") { showsInfo = false }
    }
    .padding(28).frame(maxWidth: 460)
    .presentationDetents([.medium])
  }

  private var statusBar: some View {
    HStack(spacing: 7) {
      Rectangle().fill(Color(red: 0.18, green: 0.52, blue: 0.38)).frame(width: 6, height: 6)
      Text("All caught up")
      Spacer()
      Text("Offline workspace · Swift95")
    }
    .font(theme.fonts.font(size: 11))
    .padding(.horizontal, 11).frame(height: 26)
    .bevel95(.sunken)
  }

  private func avatar(_ initials: String, size: CGFloat) -> some View {
    let color: Color =
      switch initials {
      case "MC": Color(red: 0.84, green: 0.65, blue: 0.48)
      case "LP": Color(red: 0.61, green: 0.75, blue: 0.69)
      case "NE": Color(red: 0.76, green: 0.68, blue: 0.83)
      default: Color(red: 0.68, green: 0.77, blue: 0.88)
      }
    return Text(initials)
      .font(theme.fonts.font(size: 14, weight: .bold))
      .foregroundStyle(ink)
      .frame(width: size, height: size)
      .bevel95(.raised, background: color)
      .accessibilityHidden(true)
  }
}
