import SwiftUI

/// The visual treatment of a determinate ``ProgressView95`` bar.
public enum ProgressView95BarStyle: Sendable {
  /// A continuous fill with a centered percentage label.
  case continuous

  /// A classic sequence of narrow blocks without an inline percentage label.
  case segmented
}

/// A determinate or indeterminate progress view with classic Swift95 styling.
///
/// Determinate progress displays a centered percentage with inverted text over
/// the filled region. Passing `nil` as the value creates an animated
/// indeterminate indicator that respects Reduce Motion. Native progress-view
/// configuration remains available through ``swiftUI(_:)``.
///
/// ```swift
/// ProgressView95("Installing", value: completed, total: total)
///   .swiftUI { progress in
///     progress.accessibilityHint("Installation progress")
///   }
///
/// ProgressView95(
///   "Copying files",
///   value: completed,
///   total: total,
///   barStyle: .segmented
/// )
/// ```
public struct ProgressView95<Label: View, Control: View>: View {
  @Environment(\.theme95) private var theme

  private let control: Control
  private let barStyle: ProgressView95BarStyle

  /// Creates a progress view with a custom SwiftUI label.
  ///
  /// - Parameters:
  ///   - value: The completed amount, or `nil` for indeterminate progress.
  ///   - total: The total amount represented by a completed progress view.
  ///   - barStyle: The visual treatment used for determinate progress.
  ///   - label: Content describing the operation being measured.
  public init(
    value: Double? = nil,
    total: Double = 1,
    barStyle: ProgressView95BarStyle = .continuous,
    @ViewBuilder label: () -> Label
  ) where Control == ProgressView<Label, EmptyView> {
    control = ProgressView(value: value, total: total, label: label)
    self.barStyle = barStyle
  }

  private init(control: Control, barStyle: ProgressView95BarStyle) {
    self.control = control
    self.barStyle = barStyle
  }

  /// The styled progress control.
  public var body: some View {
    control.progressViewStyle(
      ProgressViewRenderingStyle95(
        barStyle: barStyle,
        theme: theme
      )
    )
  }

  /// Applies a transformation to the embedded SwiftUI progress view.
  ///
  /// The transformed control continues to receive the Swift95 progress style.
  ///
  /// - Parameter transform: A closure that receives the embedded progress view.
  /// - Returns: A progress view containing the transformed SwiftUI control.
  public func swiftUI<ModifiedControl: View>(
    @ViewBuilder _ transform: (Control) -> ModifiedControl
  ) -> ProgressView95<Label, ModifiedControl> {
    ProgressView95<Label, ModifiedControl>(
      control: transform(control),
      barStyle: barStyle
    )
  }
}

extension ProgressView95
where Label == EmptyView, Control == ProgressView<EmptyView, EmptyView> {
  /// Creates a progress view without a visible label.
  ///
  /// - Parameters:
  ///   - value: The completed amount, or `nil` for indeterminate progress.
  ///   - total: The total amount represented by a completed progress view.
  ///   - barStyle: The visual treatment used for determinate progress.
  public init(
    value: Double? = nil,
    total: Double = 1,
    barStyle: ProgressView95BarStyle = .continuous
  ) {
    control = ProgressView(value: value, total: total)
    self.barStyle = barStyle
  }
}

extension ProgressView95 where Label == Text, Control == ProgressView<Text, EmptyView> {
  /// Creates a progress view with a localized text label.
  ///
  /// - Parameters:
  ///   - titleKey: The localization key describing the operation.
  ///   - value: The completed amount, or `nil` for indeterminate progress.
  ///   - total: The total amount represented by a completed progress view.
  ///   - barStyle: The visual treatment used for determinate progress.
  public init(
    _ titleKey: LocalizedStringKey,
    value: Double? = nil,
    total: Double = 1,
    barStyle: ProgressView95BarStyle = .continuous
  ) {
    control = ProgressView(titleKey, value: value, total: total)
    self.barStyle = barStyle
  }

  /// Creates a progress view with an unlocalized text label.
  ///
  /// - Parameters:
  ///   - title: Text describing the operation.
  ///   - value: The completed amount, or `nil` for indeterminate progress.
  ///   - total: The total amount represented by a completed progress view.
  ///   - barStyle: The visual treatment used for determinate progress.
  public init<S>(
    _ title: S,
    value: Double? = nil,
    total: Double = 1,
    barStyle: ProgressView95BarStyle = .continuous
  ) where S: StringProtocol {
    control = ProgressView(value: value, total: total) {
      Text(verbatim: String(title))
    }
    self.barStyle = barStyle
  }
}

struct ProgressFraction95: Equatable {
  let value: CGFloat?

  init(_ fraction: Double?) {
    guard let fraction else {
      value = nil
      return
    }

    guard fraction.isFinite else {
      value = 0
      return
    }

    value = CGFloat(min(max(fraction, 0), 1))
  }

  var percentage: Int? {
    value.map { Int(($0 * 100).rounded()) }
  }
}

private struct ProgressViewRenderingStyle95: ProgressViewStyle {
  @Environment(\.isEnabled) private var isEnabled

  let barStyle: ProgressView95BarStyle
  let theme: Theme95

  func makeBody(configuration: Configuration) -> some View {
    VStack(alignment: .leading, spacing: theme.spacing.xxs) {
      configuration.label
        .font(theme.fonts.body)
        .foregroundStyle(isEnabled ? theme.colors.text : theme.colors.textDisabled)

      ProgressBar95(
        progress: ProgressFraction95(configuration.fractionCompleted),
        style: barStyle,
        isEnabled: isEnabled,
        theme: theme
      )
    }
  }
}

private struct ProgressBar95: View {
  #if !os(macOS)
    @ScaledMetric(relativeTo: .body) private var dynamicTypeScale = CGFloat(1)
  #endif

  let progress: ProgressFraction95
  let style: ProgressView95BarStyle
  let isEnabled: Bool
  let theme: Theme95

  var body: some View {
    GeometryReader { geometry in
      if let fraction = progress.value {
        switch style {
        case .continuous:
          continuousProgress(fraction: fraction, size: geometry.size)
        case .segmented:
          SegmentedProgressDrawing95(
            fraction: fraction,
            color: progressColor
          )
          .padding(theme.metrics.progressContentInset)
        }
      } else {
        IndeterminateProgressDrawing95(
          color: progressColor
        )
        .padding(theme.metrics.progressContentInset)
      }
    }
    .frame(height: scaledProgressBarHeight)
    .bevel95(
      .input,
      background: isEnabled ? theme.colors.inputBackground : theme.colors.inputBackgroundDisabled
    )
  }

  private var progressColor: Color {
    isEnabled ? theme.colors.accent : theme.colors.textDisabled
  }

  private var scaledProgressBarHeight: CGFloat {
    #if os(macOS)
      theme.metrics.progressBarHeight
    #else
      theme.metrics.progressBarHeight * dynamicTypeScale
    #endif
  }

  private func continuousProgress(fraction: CGFloat, size: CGSize) -> some View {
    let inset = theme.metrics.progressContentInset
    let fillWidth = max(0, size.width - inset * 2) * fraction
    let percentage = "\(progress.percentage ?? 0)%"

    return ZStack {
      Text(percentage)
        .font(theme.fonts.body)
        .foregroundStyle(isEnabled ? theme.colors.text : theme.colors.textDisabled)
        .frame(width: size.width, height: size.height)

      Rectangle()
        .fill(progressColor)
        .frame(width: fillWidth)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(inset)

      Text(percentage)
        .font(theme.fonts.body)
        .foregroundStyle(theme.colors.accentText)
        .frame(width: size.width, height: size.height)
        .mask(alignment: .leading) {
          Rectangle()
            .frame(width: fillWidth)
            .padding(.leading, inset)
        }
    }
    .frame(width: size.width, height: size.height)
  }
}

private struct SegmentedProgressDrawing95: View {
  let fraction: CGFloat
  let color: Color

  var body: some View {
    Canvas { context, size in
      let segmentWidth = CGFloat(10)
      let gap = CGFloat(2)
      let segmentStride = segmentWidth + gap
      let segmentCount = Int((size.width + gap) / segmentStride)
      let completedCount = Int((CGFloat(segmentCount) * fraction).rounded(.down))

      for index in 0..<completedCount {
        context.fill(
          Path(
            CGRect(
              x: CGFloat(index) * segmentStride,
              y: 0,
              width: segmentWidth,
              height: size.height
            )
          ),
          with: .color(color)
        )
      }
    }
    .accessibilityHidden(true)
  }
}

struct IndeterminateProgressDrawing95: View {
  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  let color: Color
  var phase: CGFloat?

  init(color: Color, phase: CGFloat? = nil) {
    self.color = color
    self.phase = phase
  }

  var body: some View {
    TimelineView(.animation(minimumInterval: 1 / 30, paused: reduceMotion)) { timeline in
      Canvas { context, size in
        let blockWidth = CGFloat(10)
        let gap = CGFloat(2)
        let cycle = size.width + blockWidth * 3 + gap * 2
        let phase =
          phase
          ?? (reduceMotion
            ? CGFloat(0.35)
            : CGFloat(
              timeline.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 1.2)
                / 1.2))
        let leading = phase * cycle - blockWidth * 3 - gap * 2

        for index in 0..<3 {
          let rect = CGRect(
            x: leading + CGFloat(index) * (blockWidth + gap),
            y: 0,
            width: blockWidth,
            height: size.height
          )
          context.fill(Path(rect), with: .color(color))
        }
      }
    }
    .accessibilityHidden(true)
  }
}
