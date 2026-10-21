import Swift95
import Swift95Icons
import SwiftUI

struct FinderExampleView: View {
  @State private var model = FinderModel()
  @Environment(\.theme95) private var theme

  var body: some View {
    GeometryReader { geometry in
      let compact = geometry.size.width < 700
      VStack(spacing: 0) {
        titleBar
        toolbar(compact: compact)
        breadcrumbs
        HStack(spacing: 0) {
          if !compact { sidebar.frame(width: 170) }
          fileArea
          if model.showsInfo, !compact {
            inspector.frame(width: geometry.size.width < 950 ? 235 : 280)
          }
        }
        statusBar
      }
      .onAppear {
        if compact { model.showsInfo = false }
      }
      .padding(5)
      .bevel95(.raised)
      .padding(compact ? 8 : 24)
      .background(theme.colors.workspaceBackground)
      .sheet(
        isPresented: Binding(
          get: { compact && model.showsInfo && model.selected != nil },
          set: { model.showsInfo = $0 }
        )
      ) {
        inspector.padding(12).background(theme.colors.background)
      }
    }
    .font(theme.fonts.body)
    .foregroundStyle(theme.colors.text)
    .preferredColorScheme(.light)
  }

  private var titleBar: some View {
    HStack(spacing: 8) {
      Icon95(.folderOpen, size: .small)
      Text("Finder95 — \(model.folder.name)").bold().lineLimit(1)
      Spacer()
      Text("THE LITTLE STUDIO").font(.system(size: 10, weight: .bold, design: .monospaced))
    }
    .padding(.horizontal, 9)
    .frame(height: 31)
    .foregroundStyle(.white)
    .background(theme.colors.accent)
  }

  private func toolbar(compact: Bool) -> some View {
    VStack(spacing: 8) {
      HStack(spacing: 6) {
        tool("Back", symbol: "←", action: model.back)
          .disabled(model.backHistory.isEmpty)
          .accessibilityIdentifier("finder.back")
        tool("Forward", symbol: "→", action: model.forward)
          .disabled(model.forwardHistory.isEmpty)
          .accessibilityIdentifier("finder.forward")
        tool("Up", symbol: "↑", action: model.up)
          .disabled(model.folder.parentID == nil)
          .accessibilityIdentifier("finder.up")
        if !compact {
          Divider95(.vertical).frame(height: 32)
          Button95(action: model.newFolder) {
            HStack {
              Icon95(.folder, size: .small); Text("New folder")
            }
          }
          .accessibilityIdentifier("finder.newFolder")
        }
        Spacer(minLength: 0)
        Button95(model.isGrid ? "▦ Icons" : "☷ List") { model.isGrid.toggle() }
          .accessibilityIdentifier("finder.viewMode")
        if !compact {
          Button95("Info") { model.showsInfo.toggle() }
            .accessibilityIdentifier("finder.info")
        }
      }
      HStack(spacing: 8) {
        Icon95(.fileFind, size: .small)
        TextField95("Search this folder", text: $model.search)
          .accessibilityIdentifier("finder.search")
        if !model.search.isEmpty {
          Button95("Clear") { model.search = "" }
        }
        if compact {
          Button95("New folder", action: model.newFolder)
            .accessibilityIdentifier("finder.newFolder")
        }
      }
    }
    .padding(10)
  }

  private func tool(_ name: String, symbol: String, action: @escaping () -> Void) -> some View {
    Button95(action: action) { Text(symbol).font(.system(size: 20)).frame(width: 16) }
      .accessibilityLabel(name)
      .help(name)
  }

  private var breadcrumbs: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 5) {
        Text("Address").foregroundStyle(.secondary).padding(.trailing, 6)
        ForEach(model.breadcrumbs) { item in
          if item.id != "home" { Text("›").foregroundStyle(.secondary) }
          Button {
            model.navigate(to: item.id)
          } label: {
            HStack(spacing: 4) {
              Icon95(item.id == "home" ? .computer : .folder, size: .small)
              Text(item.name)
            }
          }
          .buttonStyle(.plain)
          .accessibilityIdentifier("finder.path.\(item.id)")
        }
      }
      .padding(8)
    }
    .bevel95(.input)
    .padding(.horizontal, 4)
    .padding(.bottom, 6)
  }

  private var sidebar: some View {
    VStack(alignment: .leading, spacing: 0) {
      Text("PLACES").font(.system(size: 10, weight: .bold, design: .monospaced))
        .foregroundStyle(.secondary).padding(14)
      ForEach(
        model.folders.filter { ["home", "projects", "documents", "pictures"].contains($0.id) }
      ) { item in
        Button {
          model.navigate(to: item.id)
        } label: {
          HStack(spacing: 9) {
            Icon95(item.id == "home" ? .computer : .folder, size: .small)
            Text(item.name).lineLimit(1)
            Spacer(minLength: 0)
          }
          .padding(.horizontal, 12).padding(.vertical, 11)
          .foregroundStyle(item.id == model.folderID ? .white : .black)
          .background(item.id == model.folderID ? theme.colors.accent : .clear)
          .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("finder.place.\(item.id)")
      }
      Spacer()
      Icon95(.computer, size: .large).padding(.horizontal, 14)
      Text("A place for everything.")
        .foregroundStyle(.secondary).padding(14)
      Text("OFFLINE DEMO DISK").font(.system(size: 9, design: .monospaced))
        .padding(14)
    }
    .frame(maxHeight: .infinity)
    .background(Color(red: 0.9, green: 0.9, blue: 0.87))
    .bevel95(.sunken)
  }

  private var fileArea: some View {
    VStack(spacing: 0) {
      HStack {
        Text(model.folder.name).bold()
        Spacer()
        Text(model.search.isEmpty ? "\(model.visibleItems.count) items" : "Search results")
          .foregroundStyle(.secondary)
      }
      .padding(14)
      Divider95()
      ScrollView {
        if model.visibleItems.isEmpty {
          VStack(spacing: 12) {
            Icon95(.fileFind, size: .large)
            Text(model.search.isEmpty ? "This folder is ready for ideas." : "No matching files.")
          }
          .frame(maxWidth: .infinity).padding(.top, 70)
        } else if model.isGrid {
          LazyVGrid(columns: [GridItem(.adaptive(minimum: 108), spacing: 12)], spacing: 24) {
            ForEach(model.visibleItems) { item in gridItem(item) }
          }
          .padding(20)
        } else {
          LazyVStack(spacing: 0) {
            ForEach(model.visibleItems) { item in listItem(item) }
          }
          .padding(8)
        }
      }
      Spacer(minLength: 0)
      HStack(spacing: 6) {
        Icon95(.folderOpen, size: .small)
        Text("Select to inspect · Double-click a folder to open")
          .font(.system(size: 10)).foregroundStyle(.secondary)
      }
      .padding(10)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.white)
    .bevel95(.input)
    .padding(.horizontal, 4)
  }

  private func gridItem(_ item: FinderItem) -> some View {
    VStack(spacing: 8) {
      Icon95(item.icon, size: .large).frame(height: 50)
      Text(item.name)
        .multilineTextAlignment(.center).lineLimit(2)
        .padding(.horizontal, 4).padding(.vertical, 3)
        .foregroundStyle(model.selectedID == item.id ? .white : .black)
        .background(model.selectedID == item.id ? theme.colors.accent : .clear)
      Text(item.kind == .folder ? "Folder" : item.size)
        .font(.system(size: 10)).foregroundStyle(.secondary)
    }
    .frame(maxWidth: .infinity, minHeight: 112, alignment: .top)
    .contentShape(.rect)
    .onTapGesture(count: 2) { model.open(item) }
    .onTapGesture { model.select(item) }
    .accessibilityElement(children: .ignore)
    .accessibilityLabel("\(item.name), \(item.kind.rawValue)")
    .accessibilityAddTraits(.isButton)
    .accessibilityAction { model.open(item) }
    .accessibilityIdentifier("finder.item.\(item.id)")
    .contextMenu {
      Button("Open") { model.open(item) };
      Button("Get Info") {
        model.select(item); model.showsInfo = true
      }
    }
  }

  private func listItem(_ item: FinderItem) -> some View {
    Button {
      model.open(item)
    } label: {
      HStack(spacing: 10) {
        Icon95(item.icon, size: .small)
        Text(item.name).lineLimit(1)
        Spacer()
        Text(model.sizeLabel(for: item))
          .foregroundStyle(model.selectedID == item.id ? .white : .secondary)
      }
      .padding(10)
      .foregroundStyle(model.selectedID == item.id ? .white : .black)
      .background(model.selectedID == item.id ? theme.colors.accent : .clear)
      .contentShape(.rect)
    }
    .buttonStyle(.plain)
    .accessibilityIdentifier("finder.item.\(item.id)")
  }

  private var inspector: some View {
    VStack(alignment: .leading, spacing: 13) {
      HStack {
        Text("GET INFO").font(.system(size: 10, weight: .bold, design: .monospaced))
        Spacer()
        Button95("×") { model.showsInfo = false }.accessibilityLabel("Close info")
      }
      if let item = model.selected {
        ScrollView {
          VStack(alignment: .leading, spacing: 14) {
            if item.kind == .image {
              landscape.frame(height: 148).bevel95(.input)
            } else {
              Icon95(item.icon, size: .large).frame(maxWidth: .infinity).padding(.vertical, 20)
            }
            Text(item.name).bold().font(.system(size: 18)).textSelection(.enabled)
            Divider95()
            infoRow("Kind", item.kind.rawValue)
            infoRow("Size", model.sizeLabel(for: item))
            infoRow("Modified", "Today, 9:41 AM")
            Divider95()
            Text(item.kind == .image ? "ABOUT THIS IMAGE" : "PREVIEW")
              .font(.system(size: 10, weight: .bold, design: .monospaced))
              .foregroundStyle(.secondary)
            Text(item.summary).lineSpacing(5).frame(maxWidth: .infinity, alignment: .leading)
            if item.kind == .folder {
              Button95("Open folder") { model.open(item) }
            }
            Divider95()
            Text("Name & extension").bold()
            TextField95("File name", text: $model.renameDraft)
              .accessibilityIdentifier("finder.renameField")
            if let error = model.renameError { Text(error).foregroundStyle(.red) }
            Button95("Rename", action: model.renameSelected)
              .accessibilityIdentifier("finder.rename")
          }
        }
      } else {
        Spacer()
        Icon95(.fileFind, size: .large).frame(maxWidth: .infinity)
        Text("Select a file to take a closer look.").frame(maxWidth: .infinity)
        Spacer()
      }
    }
    .padding(14)
    .frame(maxHeight: .infinity)
    .background(Color(red: 0.94, green: 0.94, blue: 0.91))
    .bevel95(.sunken)
    .onChange(of: model.selectedID, initial: true) { _, _ in
      model.renameDraft = model.selected?.name ?? ""
    }
  }

  private func infoRow(_ label: String, _ value: String) -> some View {
    HStack(alignment: .top) {
      Text(label).foregroundStyle(.secondary).frame(width: 62, alignment: .leading)
      Text(value)
      Spacer(minLength: 0)
    }
  }

  private var landscape: some View {
    GeometryReader { proxy in
      ZStack {
        Color(red: 0.62, green: 0.79, blue: 0.79)
        Rectangle().fill(Color(red: 0.98, green: 0.9, blue: 0.55))
          .frame(width: 30, height: 30).offset(x: 58, y: -34)
        Path { path in
          path.move(to: CGPoint(x: 0, y: 75))
          path.addLines([
            CGPoint(x: 60, y: 45), CGPoint(x: 105, y: 65), CGPoint(x: 155, y: 38),
            CGPoint(x: proxy.size.width, y: 70), CGPoint(x: proxy.size.width, y: 148),
            CGPoint(x: 0, y: 148)
          ])
        }
        .fill(Color(red: 0.27, green: 0.48, blue: 0.43))
        Rectangle().fill(Color(red: 0.18, green: 0.49, blue: 0.58))
          .frame(height: 56).frame(maxHeight: .infinity, alignment: .bottom)
        Path { path in
          path.move(to: CGPoint(x: 0, y: 108))
          path.addLines([CGPoint(x: 75, y: 119), CGPoint(x: 110, y: 148), CGPoint(x: 0, y: 148)])
        }
        .fill(Color(red: 0.87, green: 0.8, blue: 0.61))
        Text("COAST / 001").font(.system(size: 9, design: .monospaced))
          .foregroundStyle(.white)
          .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing).padding(8)
      }
      .clipped()
    }
    .accessibilityLabel("Pixel landscape with a golden sun, distant hills and a blue sea")
  }

  private var statusBar: some View {
    HStack {
      Text("\(model.visibleItems.count) objects")
      Spacer()
      Text(model.selected?.name ?? "No selection").lineLimit(1)
      Spacer()
      Text("Demo disk · In memory").foregroundStyle(.secondary)
    }
    .font(.system(size: 11))
    .padding(7).bevel95(.sunken).padding(.top, 6)
  }
}

private extension FinderItem {
  var icon: Icon95.Name {
    switch kind {
    case .folder: .folder
    case .document: .fileText
    case .image: .paint
    case .project: .fileSettings
    }
  }
}
