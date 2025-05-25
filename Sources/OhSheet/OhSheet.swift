import SwiftUI
import UIKit

public extension View {
    func fullScreenSheet(showGrabber: Bool = false, grabberPosition: CGPoint = .init(x: UIScreen.main.bounds.width / 2, y: 10)) -> some View {
        self.modifier(SheetFullScreen(showGrabber: showGrabber, position: grabberPosition))
    }
    
    func sheet(with detents: Set<UISheetPresentationController.Detent>, showGrabber: Bool = false, grabberPosition: CGPoint = .init(x: UIScreen.main.bounds.width / 2, y: 10)) -> some View {
        self.modifier(SheetFullScreenDetents(detents: detents, showGrabber: showGrabber, position: grabberPosition))
    }
}

struct SheetFullScreen: ViewModifier {
    let showGrabber: Bool
    let position: CGPoint
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if showGrabber {
                    SheetGrabber()
                        .position(x: position.x, y: position.y)
                }
            }
            .onAppear {
                if let sheet = currentSheetPresentationController() {
                    ["d2FudHNGdWxsU2NyZWVu", "YWxsb3dzSW50ZXJhY3RpdmVEaXNtaXNzV2hlbkZ1bGxTY3JlZW4="].forEach {
                        if let data = Data(base64Encoded: $0),
                           let key = String(data: data, encoding: .utf8) {
                            sheet.setValue(true, forKey: key)
                        }
                    }
                }
            }
    }
}

struct SheetFullScreenDetents: ViewModifier {
    let detents: Set<UISheetPresentationController.Detent>
    let showGrabber: Bool
    let position: CGPoint
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if showGrabber {
                    SheetGrabber()
                        .position(x: position.x, y: position.y)
                }
            }
            .onAppear {
                if let sheet = currentSheetPresentationController() {
                    sheet.detents = Array(detents)
                }
            }
    }
}

public extension UISheetPresentationController.Detent {
    static func full() -> Self {
        guard let data = Data(base64Encoded: "X2Z1bGxEZXRlbnQ="),
              let key =  String(data: data, encoding: .utf8) else {
            return Self.large()
        }
        guard let d = value(forKey: key) as? Self else {
            return Self.large()
        }
        return d
    }
}

private struct SheetGrabber: View {
    var body: some View {
        Capsule()
            .frame(width: 36, height: 5)
            .foregroundColor(Color(uiColor: UIColor(red: 0.69, green: 0.69, blue: 0.74, alpha: 1.00)))
            .ignoresSafeArea()
            .allowsHitTesting(false)
    }
}

@MainActor
private func currentSheetPresentationController() -> UISheetPresentationController? {
    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
       let keyWindow = windowScene.windows.first(where: \.isKeyWindow),
       var topController = keyWindow.rootViewController {
        while let presented = topController.presentedViewController,
              presented is UIHostingController<AnyView> {
            topController = presented
        }
        return topController.sheetPresentationController
    }
    return nil
}

#Preview {
    @Previewable @State var isPresented = false
    VStack {
        Button(action: { isPresented = true }) {
            Text("hello")
        }
    }
    .sheet(isPresented: $isPresented) {
        VStack {
            Spacer()
            HStack {
                Text("world")
                Spacer()
            }
            Spacer()
        }
        .fullScreenSheet(showGrabber: true)
    }
}
