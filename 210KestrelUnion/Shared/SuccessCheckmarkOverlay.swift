import SwiftUI

struct SuccessCheckmarkOverlay: View {
    @Binding var isVisible: Bool
    @State private var scale: CGFloat = 0.7
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            if isVisible {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(Color("AppAccent"))
                    .scaleEffect(scale)
                    .opacity(opacity)
                    .onAppear {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            scale = 1
                            opacity = 1
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                opacity = 0
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                isVisible = false
                                scale = 0.7
                            }
                        }
                    }
            }
        }
    }
}
