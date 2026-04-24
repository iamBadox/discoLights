import SwiftUI

// MARK: - Safety Warning View

struct SafetyWarningView: View {
    let onAccept: () -> Void

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 24) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.yellow)

                Text("Flashing Lights Warning")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text("This app produces rapidly flashing colored lights.\n\nIf you or anyone nearby has a history of photosensitive epilepsy or is sensitive to flashing lights, do not use this app.")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Button {
                    onAccept()
                } label: {
                    Text("I Understand — Let's Disco! 🕺")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.yellow)
                        .cornerRadius(14)
                }
                .padding(.horizontal)
            }
            .padding()
        }
    }
}
