import SwiftUI

struct AppBackgroundView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color("AppBackground"), Color("AppSurface")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            RadialGradient(
                colors: [Color("AppAccent").opacity(0.12), Color.clear],
                center: .topTrailing,
                startRadius: 20,
                endRadius: 260
            )
            .ignoresSafeArea()

            Canvas { context, size in
                let spacing: CGFloat = 34
                for x in stride(from: 0, through: size.width, by: spacing) {
                    for y in stride(from: 0, through: size.height, by: spacing) {
                        if Int((x + y) / spacing).isMultiple(of: 2) == false { continue }
                        let dotRect = CGRect(x: x, y: y, width: 1.8, height: 1.8)
                        context.fill(Path(ellipseIn: dotRect), with: .color(Color("AppAccent").opacity(0.10)))
                    }
                }
            }
            .ignoresSafeArea()
        }
    }
}
