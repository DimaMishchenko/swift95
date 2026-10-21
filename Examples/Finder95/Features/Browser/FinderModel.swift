import Foundation
import Observation

struct FinderItem: Identifiable, Equatable, Sendable {
  enum Kind: String, Sendable {
    case folder = "Folder"
    case document = "Text document"
    case image = "PNG image"
    case project = "Project file"
  }

  let id: String
  var name: String
  let parentID: String?
  let kind: Kind
  let size: String
  let summary: String
}

@MainActor @Observable
final class FinderModel {
  private(set) var items = FinderItem.seed
  private(set) var folderID = "projects"
  private(set) var selectedID: String? = "coast"
  private(set) var backHistory: [String] = []
  private(set) var forwardHistory: [String] = []
  var search = ""
  var isGrid = true
  var showsInfo = true
  var renameDraft = ""
  var renameError: String?

  var folder: FinderItem {
    guard let folder = items.first(where: { $0.id == folderID }) else {
      preconditionFailure("The current folder must exist in the demo disk.")
    }
    return folder
  }
  var selected: FinderItem? { items.first { $0.id == selectedID } }
  var folders: [FinderItem] { items.filter { $0.kind == .folder } }
  var visibleItems: [FinderItem] {
    items.filter {
      $0.parentID == folderID
        && (search.isEmpty || $0.name.localizedCaseInsensitiveContains(search))
    }
    .sorted {
      if ($0.kind == .folder) != ($1.kind == .folder) { return $0.kind == .folder }
      return $0.name.localizedStandardCompare($1.name) == .orderedAscending
    }
  }
  var breadcrumbs: [FinderItem] {
    var path = [folder]
    while let parent = path.first?.parentID, let item = items.first(where: { $0.id == parent }) {
      path.insert(item, at: 0)
    }
    return path
  }

  func navigate(to id: String) {
    guard id != folderID, items.contains(where: { $0.id == id && $0.kind == .folder }) else {
      return
    }
    backHistory.append(folderID)
    forwardHistory.removeAll()
    setFolder(id)
  }

  func back() {
    guard let id = backHistory.popLast() else { return }
    forwardHistory.append(folderID)
    setFolder(id)
  }

  func forward() {
    guard let id = forwardHistory.popLast() else { return }
    backHistory.append(folderID)
    setFolder(id)
  }

  func up() {
    if let parent = folder.parentID { navigate(to: parent) }
  }

  func select(_ item: FinderItem) {
    selectedID = item.id
    renameDraft = item.name
    renameError = nil
  }

  func open(_ item: FinderItem) {
    if item.kind == .folder {
      navigate(to: item.id)
    } else {
      select(item)
      showsInfo = true
    }
  }

  func sizeLabel(for item: FinderItem) -> String {
    guard item.kind == .folder else { return item.size }
    let count = items.filter { $0.parentID == item.id }.count
    return "\(count) \(count == 1 ? "item" : "items")"
  }

  func newFolder() {
    var name = "Untitled folder"
    var suffix = 2
    while items.contains(where: {
      $0.parentID == folderID && $0.name.caseInsensitiveCompare(name) == .orderedSame
    }) {
      name = "Untitled folder \(suffix)"
      suffix += 1
    }
    let item = FinderItem(
      id: UUID().uuidString, name: name, parentID: folderID, kind: .folder,
      size: "0 items", summary: "A new place for your next idea."
    )
    items.append(item)
    search = ""
    select(item)
    showsInfo = true
  }

  func renameSelected() {
    guard let index = items.firstIndex(where: { $0.id == selectedID }) else { return }
    let name = renameDraft.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !name.isEmpty, !name.contains("/"), !name.contains(":") else {
      renameError = "Use a name without / or : ."
      return
    }
    guard
      !items.contains(where: {
        $0.id != selectedID && $0.parentID == items[index].parentID
          && $0.name.caseInsensitiveCompare(name) == .orderedSame
      })
    else {
      renameError = "That name is already in this folder."
      return
    }
    items[index].name = name
    renameDraft = name
    renameError = nil
  }

  private func setFolder(_ id: String) {
    folderID = id
    selectedID = nil
    search = ""
    renameError = nil
  }
}

extension FinderItem {
  static let seed: [FinderItem] = [
    .init(
      id: "home", name: "Macintosh HD", parentID: nil, kind: .folder, size: "128 MB",
      summary: "Your imaginary local disk."),
    .init(
      id: "projects", name: "Studio Projects", parentID: "home", kind: .folder, size: "12 items",
      summary: "Small ideas. Big possibilities."),
    .init(
      id: "documents", name: "Documents", parentID: "home", kind: .folder, size: "2 items",
      summary: "Notes and correspondence."),
    .init(
      id: "pictures", name: "Pictures", parentID: "home", kind: .folder, size: "1 item",
      summary: "A few favorite views."),
    .init(
      id: "archive", name: "Archive", parentID: "projects", kind: .folder, size: "1 item",
      summary: "Earlier experiments, safely tucked away."),
    .init(
      id: "assets", name: "Brand Assets", parentID: "projects", kind: .folder, size: "1 item",
      summary: "The building blocks of a new identity."),
    .init(
      id: "references", name: "References", parentID: "projects", kind: .folder, size: "1 item",
      summary: "Collected sparks of inspiration."),
    .init(
      id: "coast", name: "Coastline.png", parentID: "projects", kind: .image, size: "248 KB",
      summary: "A quiet afternoon by the sea.\n640 × 480 pixels · RGB color"),
    .init(
      id: "brief", name: "Creative Brief.txt", parentID: "projects", kind: .document, size: "4 KB",
      summary:
        "THE LITTLE STUDIO\n\nMake something useful. Keep it simple. Add a little personality.\n\nNext milestone: a prototype we can share."
    ),
    .init(
      id: "notes", name: "Field Notes.txt", parentID: "projects", kind: .document, size: "2 KB",
      summary:
        "Monday, 10:30 AM\n\nGood ideas often start on paper. Take a walk. Notice the details. Bring a notebook."
    ),
    .init(
      id: "palette", name: "Palette.png", parentID: "projects", kind: .image, size: "32 KB",
      summary: "Colors from our favorite coastal walk.\n640 × 480 pixels · RGB color"),
    .init(
      id: "readme", name: "Read Me.txt", parentID: "projects", kind: .document, size: "1 KB",
      summary:
        "Welcome to Finder95.\n\nOpen a folder, search for a file, or make a new folder. Everything here is fictional and stays in memory."
    ),
    .init(
      id: "sketch", name: "Sketchbook.project", parentID: "projects", kind: .project, size: "86 KB",
      summary: "Sketchbook / version 0.4\n\nA home for sketches, snippets and unfinished ideas."),
    .init(
      id: "site", name: "Studio Site.project", parentID: "projects", kind: .project, size: "124 KB",
      summary: "Studio website / draft 3\n\nPages: Welcome, Work, About, Contact."),
    .init(
      id: "todo", name: "To Do.txt", parentID: "projects", kind: .document, size: "1 KB",
      summary:
        "[✓] Gather references\n[✓] Choose a palette\n[ ] Finish the first prototype\n[ ] Share with a friend"
    ),
    .init(
      id: "welcome", name: "Welcome Letter.txt", parentID: "documents", kind: .document,
      size: "2 KB",
      summary:
        "Dear explorer,\n\nWelcome to your new desktop. There is always room for another idea."),
    .init(
      id: "meeting", name: "Meeting Notes.txt", parentID: "documents", kind: .document,
      size: "3 KB",
      summary: "Studio catch-up\n\nA smaller first release. More time for the details."),
    .init(
      id: "holiday", name: "Summer.png", parentID: "pictures", kind: .image, size: "320 KB",
      summary: "The long way home.\n640 × 480 pixels · RGB color"),
    .init(
      id: "old", name: "First Draft.txt", parentID: "archive", kind: .document, size: "2 KB",
      summary: "Every project starts somewhere."),
    .init(
      id: "logo", name: "Studio Mark.png", parentID: "assets", kind: .image, size: "16 KB",
      summary: "The studio's first mark.\n640 × 480 pixels · RGB color"),
    .init(
      id: "links", name: "Inspiration.txt", parentID: "references", kind: .document, size: "1 KB",
      summary: "Look at old maps, book covers, and the colors of the sea.")
  ]
}
