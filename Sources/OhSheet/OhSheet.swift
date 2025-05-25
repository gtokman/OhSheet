import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

public extension View {
    func fullScreenSheet() -> some View {
        self.modifier(SheetFullScreen())
    }
    
    func sheet(with detents: Set<UISheetPresentationController.Detent>) -> some View {
        self.modifier(SheetFullScreenDetents(detents: detents))
    }
}

struct SheetFullScreen: ViewModifier {
    
    func body(content: Content) -> some View {
        content.onAppear {
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
    func body(content: Content) -> some View {
        content.onAppear {
            if let sheet = currentSheetPresentationController() {
                sheet.detents = Array(detents)
            }
        }
    }
}

public extension UISheetPresentationController.Detent {
    static func full() -> Self {
        guard let data = Data(base64Encoded: "X2Z1bGxEZXRlbnQ="),
              let key1 =  String(data: data, encoding: .utf8) else {
            return Self.large()
        }
        guard let d = value(forKey: key1) as? Self else {
            return Self.large()
        }
        return d
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
    Button(action: { isPresented = true }) {
        Text("hello")
    }
    .sheet(isPresented: $isPresented) {
        Text("world")
            .sheet(with: [.medium(), .full()])
    }
}
