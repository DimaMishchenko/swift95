import SwiftUI

/// A slider with native SwiftUI behavior and a classic Swift95 track and thumb.
///
/// `Slider95` preserves SwiftUI's binding, stepping, editing callbacks,
/// keyboard behavior, and accessibility. The visible control is optimized for
/// touch while retaining the narrow classic track.
///
/// ```swift
/// @State private var volume = 50.0
///
/// Slider95(value: $volume, in: 0...100)
/// ```
public struct Slider95<Value, Label, Control>: View
where
  Value: BinaryFloatingPoint,
  Value.Stride: BinaryFloatingPoint,
  Label: View,
  Control: View
{
  @Environment(\.isEnabled) private var isEnabled
  @Environment(\.theme95) private var theme
  @State private var isEditing = false
  @Binding private var value: Value

  private let bounds: ClosedRange<Value>
  private let label: Label
  private let control: Control
  private let step: Value.Stride?
  private let onEditingChanged: (Bool) -> Void

  /// Creates a continuous slider with a custom SwiftUI label.
  ///
  /// - Parameters:
  ///   - value: The slider's current value.
  ///   - bounds: The inclusive range of permitted values.
  ///   - label: A view that describes the slider.
  ///   - onEditingChanged: An action called when editing begins or ends.
  public init(
    value: Binding<Value>,
    in bounds: ClosedRange<Value> = 0...1,
    @ViewBuilder label: () -> Label,
    onEditingChanged: @escaping (Bool) -> Void = { _ in }
  ) where Control == Slider<Label, EmptyView> {
    let label = label()
    _value = value
    self.bounds = bounds
    self.label = label
    step = nil
    self.onEditingChanged = onEditingChanged
    control = Slider(
      value: value,
      in: bounds,
      label: { label },
      onEditingChanged: onEditingChanged
    )
  }

  /// Creates a stepped slider with a custom SwiftUI label.
  ///
  /// - Parameters:
  ///   - value: The slider's current value.
  ///   - bounds: The inclusive range of permitted values.
  ///   - step: The distance between permitted values.
  ///   - label: A view that describes the slider.
  ///   - onEditingChanged: An action called when editing begins or ends.
  public init(
    value: Binding<Value>,
    in bounds: ClosedRange<Value>,
    step: Value.Stride,
    @ViewBuilder label: () -> Label,
    onEditingChanged: @escaping (Bool) -> Void = { _ in }
  ) where Control == Slider<Label, EmptyView> {
    let label = label()
    _value = value
    self.bounds = bounds
    self.label = label
    self.step = step
    self.onEditingChanged = onEditingChanged
    control = Slider(
      value: value,
      in: bounds,
      step: step,
      label: { label },
      onEditingChanged: onEditingChanged
    )
  }

  private init(
    value: Binding<Value>,
    bounds: ClosedRange<Value>,
    label: Label,
    control: Control,
    step: Value.Stride?,
    onEditingChanged: @escaping (Bool) -> Void
  ) {
    _value = value
    self.bounds = bounds
    self.label = label
    self.control = control
    self.step = step
    self.onEditingChanged = onEditingChanged
  }

  /// The styled slider control.
  public var body: some View {
    VStack(alignment: .leading, spacing: Spacing95[4]) {
      label
        .font(theme.fonts.body)
        .foregroundStyle(isEnabled ? theme.colors.text : theme.colors.textDisabled)
        .accessibilityHidden(true)

      GeometryReader { geometry in
        ZStack {
          SliderDrawing95(
            fraction: fraction,
            isEnabled: isEnabled,
            theme: theme
          )

          control
            .labelsHidden()
            .tint(.clear)
            .opacity(0.01)
        }
        .contentShape(.rect)
        .highPriorityGesture(sliderGesture(width: geometry.size.width))
      }
      .frame(height: 28)
    }
  }

  /// Applies a transformation to the embedded SwiftUI slider.
  ///
  /// - Parameter transform: A closure that receives the embedded slider.
  /// - Returns: A slider containing the transformed SwiftUI control.
  public func swiftUI<ModifiedControl: View>(
    @ViewBuilder _ transform: (Control) -> ModifiedControl
  ) -> Slider95<Value, Label, ModifiedControl> {
    Slider95<Value, Label, ModifiedControl>(
      value: $value,
      bounds: bounds,
      label: label,
      control: transform(control),
      step: step,
      onEditingChanged: onEditingChanged
    )
  }

  private var fraction: CGFloat {
    let distance = bounds.upperBound - bounds.lowerBound
    guard distance > 0 else {
      return 0
    }
    let progress = (value - bounds.lowerBound) / distance
    return CGFloat(min(max(progress, 0), 1))
  }

  private func sliderGesture(width: CGFloat) -> some Gesture {
    DragGesture(minimumDistance: 0)
      .onChanged { gesture in
        guard isEnabled else {
          return
        }

        if !isEditing {
          isEditing = true
          onEditingChanged(true)
        }
        updateValue(at: gesture.location.x, width: width)
      }
      .onEnded { _ in
        guard isEditing else {
          return
        }
        isEditing = false
        onEditingChanged(false)
      }
  }

  private func updateValue(at location: CGFloat, width: CGFloat) {
    let thumbWidth = CGFloat(18)
    let travel = max(0, width - thumbWidth)
    guard travel > 0 else {
      return
    }

    let progress = min(max((location - thumbWidth / 2) / travel, 0), 1)
    let distance = bounds.upperBound - bounds.lowerBound
    var newValue = bounds.lowerBound + Value(progress) * distance

    if let step {
      let step = Value(step)
      if step > 0 {
        let steps = ((newValue - bounds.lowerBound) / step).rounded()
        newValue = bounds.lowerBound + steps * step
      }
    }

    value = min(max(newValue, bounds.lowerBound), bounds.upperBound)
  }
}

extension Slider95 where Label == EmptyView, Control == Slider<EmptyView, EmptyView> {
  /// Creates a continuous slider without a visible label.
  public init(
    value: Binding<Value>,
    in bounds: ClosedRange<Value> = 0...1,
    onEditingChanged: @escaping (Bool) -> Void = { _ in }
  ) {
    self.init(
      value: value,
      in: bounds,
      label: { EmptyView() },
      onEditingChanged: onEditingChanged
    )
  }

  /// Creates a stepped slider without a visible label.
  public init(
    value: Binding<Value>,
    in bounds: ClosedRange<Value>,
    step: Value.Stride,
    onEditingChanged: @escaping (Bool) -> Void = { _ in }
  ) {
    self.init(
      value: value,
      in: bounds,
      step: step,
      label: { EmptyView() },
      onEditingChanged: onEditingChanged
    )
  }
}

private struct SliderDrawing95: View {
  let fraction: CGFloat
  let isEnabled: Bool
  let theme: Theme95

  var body: some View {
    GeometryReader { geometry in
      let thumbWidth = CGFloat(18)
      let travel = max(0, geometry.size.width - thumbWidth)

      ZStack(alignment: .leading) {
        Color.clear
          .frame(height: 6)
          .bevel95(
            .input,
            background: isEnabled ? theme.colors.borderDarkest : theme.colors.textDisabled
          )

        Color.clear
          .frame(width: thumbWidth, height: 28)
          .bevel95(.raised)
          .offset(x: travel * fraction)
      }
    }
    .accessibilityHidden(true)
    .allowsHitTesting(false)
  }
}
