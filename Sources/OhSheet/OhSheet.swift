import SwiftUI
import UIKit

public extension View {
    func fullScreenSheet(showGrabber: Bool = false, grabberPosition: CGPoint = .init(x: UIScreen.main.bounds.width / 2, y: 10)) -> some View {
        self.modifier(SheetFullScreen(showGrabber: showGrabber, position: grabberPosition))
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
                guard let sheet = currentSheetPresentationController() else { return }
                let dyn = Dynamic(sheet)
                dyn.wantsFullScreen = true
                dyn.allowsInteractiveDismissWhenFullScreen = true
            }
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

@dynamicMemberLookup
private final class Dynamic {
    private let base: NSObject

    init(_ base: NSObject) {
        self.base = base
    }

    subscript(dynamicMember member: String) -> Any? {
        get { base.value(forKey: member) }
        set { base.setValue(newValue, forKey: member) }
    }
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
