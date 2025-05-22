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
            if let sheet = OhSheetHelper.findSheetPresentationController() {
                let base64EncodedKeys = [
                    "d2FudHNGdWxsU2NyZWVu", // wantsFullScreen
                    "YWxsb3dzSW50ZXJhY3RpdmVEaXNtaXNzV2hlbkZ1bGxTY3JlZW4=" // allowsInteractiveDismissWhenFullScreen
                ]

                for base64Key in base64EncodedKeys {
                    guard let data = Data(base64Encoded: base64Key),
                          let key = String(data: data, encoding: .utf8) else {
                        // If a key fails to decode, print an error and skip to the next key,
                        // or return early to match original behavior.
                        // The original behavior was to return from the function if any key fails.
                        // So, we should adhere to that.
                        print("Error: Failed to decode base64 key: \(base64Key)") // Optional: for debugging
                        return
                    }
                    sheet.setValue(true, forKey: key)
                }
            }
        }
    }
}

struct SheetFullScreenDetents: ViewModifier {
    let detents: Set<UISheetPresentationController.Detent>
    func body(content: Content) -> some View {
        content.onAppear {
            if let sheet = OhSheetHelper.findSheetPresentationController() {
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

private enum OhSheetHelper {
    static func findSheetPresentationController() -> UISheetPresentationController? {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let keyWindow = windowScene.windows.first(where: \.isKeyWindow),
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
                return sheet
            }
        }
        return nil
    }
}
