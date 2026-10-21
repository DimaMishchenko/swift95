import Testing

@testable import Finder95

@MainActor
struct FinderModelTests {
  @Test func historyPreservesDirectionAndClearsWhenBranching() {
    let model = FinderModel()
    model.navigate(to: "assets")
    model.back()
    #expect(model.folderID == "projects")
    model.forward()
    #expect(model.folderID == "assets")
    model.back()
    model.navigate(to: "documents")
    #expect(model.forwardHistory.isEmpty)
    #expect(model.breadcrumbs.map(\.id) == ["home", "documents"])
  }

  @Test func searchOnlyMatchesCurrentFolderAndResetsOnNavigation() {
    let model = FinderModel()
    model.search = "PNG"
    #expect(Set(model.visibleItems.map(\.id)) == ["coast", "palette"])
    model.navigate(to: "pictures")
    #expect(model.search.isEmpty)
    #expect(model.visibleItems.map(\.id) == ["holiday"])
  }

  @Test func newFoldersHaveUniqueNamesAndCanBeOpened() throws {
    let model = FinderModel()
    model.newFolder()
    let first = try #require(model.selected)
    model.newFolder()
    #expect(model.selected?.name == "Untitled folder 2")
    model.open(first)
    #expect(model.folderID == first.id)
    #expect(model.visibleItems.isEmpty)
    model.up()
    #expect(model.folderID == "projects")
  }

  @Test func newFolderAvoidsNamesThatDifferOnlyByCase() {
    let model = FinderModel()
    model.newFolder()
    model.renameDraft = "untitled folder"
    model.renameSelected()
    model.newFolder()
    #expect(model.selected?.name == "Untitled folder 2")
    let matchingFolders = model.visibleItems.filter {
      $0.name.caseInsensitiveCompare("untitled folder") == .orderedSame
    }
    #expect(matchingFolders.count == 1)
  }

  @Test func folderSizeLabelsTrackNewChildren() throws {
    let model = FinderModel()
    model.navigate(to: "assets")
    let folder = model.folder
    #expect(model.sizeLabel(for: folder) == "1 item")
    model.newFolder()
    #expect(model.sizeLabel(for: folder) == "2 items")
    let newFolder = try #require(model.selected)
    #expect(model.sizeLabel(for: newFolder) == "0 items")
  }

  @Test func renameValidatesDuplicatesAndChangesTheSelectedItem() {
    let model = FinderModel()
    model.renameDraft = "Read Me.txt"
    model.renameSelected()
    #expect(model.renameError != nil)
    #expect(model.selected?.name == "Coastline.png")
    model.renameDraft = "  Shore.png  "
    model.renameSelected()
    #expect(model.selected?.name == "Shore.png")
    #expect(model.renameError == nil)
    model.renameDraft = "bad/name"
    model.renameSelected()
    #expect(model.selected?.name == "Shore.png")
  }

  @Test func navigationRejectsFilesAndClearsOldSelection() {
    let model = FinderModel()
    model.navigate(to: "coast")
    #expect(model.folderID == "projects")
    model.navigate(to: "documents")
    #expect(model.selected == nil)
    model.back()
    #expect(model.folderID == "projects")
  }
}
