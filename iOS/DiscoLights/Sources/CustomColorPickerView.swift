import SwiftUI

// MARK: - Custom Color Picker

struct CustomColorPickerView: View {
    @Binding var colors: [Color]
    @Environment(\.dismiss) var dismiss
    @State private var newColor: Color = .red

    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemBackground).ignoresSafeArea()

                VStack(spacing: 0) {
                    // Color picker + add button
                    VStack(spacing: 16) {
                        ColorPicker("Pick a color", selection: $newColor, supportsOpacity: false)
                            .padding()

                        Button {
                            colors.append(newColor)
                        } label: {
                            Label("Add Color", systemImage: "plus.circle.fill")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(newColor)
                                .foregroundColor(newColor.isLight ? .black : .white)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom)

                    Divider()

                    if colors.isEmpty {
                        VStack {
                            Spacer()
                            Text("No colors yet.\nAdd some above!")
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                    } else {
                        List {
                            ForEach(Array(colors.enumerated()), id: \.offset) { index, color in
                                HStack(spacing: 14) {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(color)
                                        .frame(width: 44, height: 44)
                                        .shadow(radius: 2)

                                    Text("Color \(index + 1)")
                                        .font(.body)
                                }
                            }
                            .onDelete { colors.remove(atOffsets: $0) }
                            .onMove { colors.move(fromOffsets: $0, toOffset: $1) }
                        }
                        .listStyle(.plain)
                    }
                }
            }
            .navigationTitle("Custom Colors")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
            }
        }
    }
}

// MARK: - Color Brightness Helper

extension Color {
    /// Returns true if the color is perceptually light (use dark text on top).
    var isLight: Bool {
        let uiColor = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        let luminance = 0.299 * r + 0.587 * g + 0.114 * b
        return luminance > 0.6
    }
}
