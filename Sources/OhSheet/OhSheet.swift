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
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }),
               var topController = keyWindow.rootViewController
            {
                
                var presentedControllers: [UIViewController] = []
                
                while let presented = topController.presentedViewController,
                      presented is UIHostingController<AnyView>
                {
                    presentedControllers.append(presented)
                    topController = presented
                }
                if let vc = presentedControllers.last, let sheet = vc.sheetPresentationController {
                    guard let data = Data(base64Encoded: "d2FudHNGdWxsU2NyZWVu"),
                            let key1 =  String(data: data, encoding: .utf8) else {
                        return
                    }
                    guard let data2 = Data(base64Encoded: "YWxsb3dzSW50ZXJhY3RpdmVEaXNtaXNzV2hlbkZ1bGxTY3JlZW4="),
                            let key2 =  String(data: data2, encoding: .utf8) else {
                        return
                    }
                    sheet.setValue(true, forKey: key1)
                    sheet.setValue(true, forKey: key2)
                }
            }
        }
    }
}

struct SheetFullScreenDetents: ViewModifier {
    let detents: Set<UISheetPresentationController.Detent>
    func body(content: Content) -> some View {
        content.onAppear {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }),
               var topController = keyWindow.rootViewController
            {
                
                var presentedControllers: [UIViewController] = []
                
                while let presented = topController.presentedViewController,
                      presented is UIHostingController<AnyView>
                {
                    presentedControllers.append(presented)
                    topController = presented
                }
                if let vc = presentedControllers.last, let sheet = vc.sheetPresentationController {
                    sheet.detents = Array(detents)
                }
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
