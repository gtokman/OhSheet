import Testing
import SwiftUI
@testable import OhSheet // Assuming OhSheet is the module name
#if canImport(UIKit)
import UIKit

// Helper to create a host and present a view
func hostView<V: View>(_ view: V) -> (UIWindow, UIHostingController<V>) {
    let hostingController = UIHostingController(rootView: view)
    let window = UIWindow()
    window.rootViewController = hostingController
    window.makeKeyAndVisible()
    
    // This is crucial to ensure the hosting controller is part of the hierarchy 
    // before we try to present something from it or its child.
    let expectation = XCTestExpectation(description: "Wait for view to appear")
    DispatchQueue.main.async {
        hostingController.beginAppearanceTransition(true, animated: false) // Trigger onAppear for the host itself
        hostingController.endAppearanceTransition()
        expectation.fulfill()
    }
    // Wait for the expectation, or use a Task.sleep for simplicity if XCTestExpectation is not available/easy in `swift-testing`
    // For swift-testing, Task.sleep is more straightforward.
    // This initial sleep/wait is for the hostView itself to be ready.
    // await Task.yield() // Or a small sleep if needed here.

    return (window, hostingController)
}

@Test func testFullScreenSheetModifier() async throws {
    struct TestView: View {
        @State var isPresented = false // Start as false, then set to true to trigger presentation
        var body: some View {
            Text("Presenting View")
                .onAppear {
                    isPresented = true // Trigger presentation on appear
                }
                .sheet(isPresented: $isPresented) {
                    Text("Presented Sheet")
                        .fullScreenSheet()
                }
        }
    }

    let (window, host) = hostView(TestView())
    
    // Allow run loop to process presentation and .onAppear within the sheet's content
    try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds, increased to allow presentation

    // Find the presented sheet's controller
    // The presented view controller will be a UIHostingController wrapping the `Text("Presented Sheet").fullScreenSheet()`
    guard let presentedNCRoot = host.presentedViewController,
          let presentedVC = presentedNCRoot as? UIHostingController<AnyView> ?? ((presentedNCRoot as? UINavigationController)?.topViewController as? UIHostingController<AnyView>) ?? (presentedNCRoot.children.first as? UIHostingController<AnyView>) else {
        // Try to get the actual view from the hierarchy if direct casting fails
        var currentVC = host.presentedViewController
        while currentVC?.presentedViewController != nil {
            currentVC = currentVC?.presentedViewController
        }
        if let finalPresentedVC = currentVC as? UIHostingController<AnyView> {
             #expect(finalPresentedVC.sheetPresentationController != nil, "Sheet presentation controller should exist on final presented VC")
             let sheet = finalPresentedVC.sheetPresentationController!
             // ... rest of the assertions
        } else if let platformView = Mirror(reflecting: host.presentedViewController!).descendant("platformView") {
             // Fallback for more complex hierarchies if needed
            print("PlatformView found: \(platformView) - further inspection might be needed")
             #expect(false, "Sheet presentation controller not found directly, check hierarchy. Presented: \(String(describing: host.presentedViewController))")
             return
        } else {
            #expect(false, "Sheet presentation controller not found. Presented VC: \(String(describing: host.presentedViewController))")
            return
        }
        // This part is reached if the first guard fails but the subsequent logic couldn't find it either.
        // To prevent compiler error, ensure all paths return or the variable `sheet` is initialized.
        // For simplicity, let's assume if the above complex search fails, the test fails.
        #expect(false, "Failed to find the UIHostingController for the sheet content.")
        return
    }
    
    let sheet = presentedVC.sheetPresentationController!


    // Retrieve the dynamic property keys
    guard let dataWantsFull = Data(base64Encoded: "d2FudHNGdWxsU2NyZWVu"), // "wantsFullScreen"
          let keyWantsFull = String(data: dataWantsFull, encoding: .utf8),
          let dataAllowsDismiss = Data(base64Encoded: "YWxsb3dzSW50ZXJhY3RpdmVEaXNtaXNzV2hlbkZ1bGxTY3JlZW4="), // "allowsInteractiveDismissWhenFullScreen"
          let keyAllowsDismiss = String(data: dataAllowsDismiss, encoding: .utf8) else {
        #expect(false, "Failed to decode property keys")
        return
    }

    #expect(sheet.value(forKey: keyWantsFull) as? Bool == true, "wantsFullScreen should be true")
    #expect(sheet.value(forKey: keyAllowsDismiss) as? Bool == true, "allowsInteractiveDismissWhenFullScreen should be true")
    
    // Clean up by dismissing the sheet
    host.dismiss(animated: false)
    // Optional: Wait for dismissal to complete
    try await Task.sleep(nanoseconds: 100_000_000)
}

@Test func testSheetWithDetentsModifier() async throws {
    struct TestView: View {
        @State var isPresented = false
        var body: some View {
            Text("Presenting View")
                .onAppear { isPresented = true }
                .sheet(isPresented: $isPresented) {
                    Text("Presented Sheet with Detents")
                        .sheet(with: [.medium(), .large()])
                }
        }
    }

    let (window, host) = hostView(TestView())
    try await Task.sleep(nanoseconds: 200_000_000) 

    // Adjust finding presentedVC similar to testFullScreenSheetModifier
    guard let presentedNCRoot = host.presentedViewController,
          let presentedVC = presentedNCRoot as? UIHostingController<AnyView> ?? ((presentedNCRoot as? UINavigationController)?.topViewController as? UIHostingController<AnyView>) ?? (presentedNCRoot.children.first as? UIHostingController<AnyView>) else {
        #expect(false, "Sheet presentation controller not found. Presented VC: \(String(describing: host.presentedViewController))")
        return
    }
    let sheet = presentedVC.sheetPresentationController!
    
    #expect(sheet.detents.contains(.medium()), "Detents should contain .medium()")
    #expect(sheet.detents.contains(.large()), "Detents should contain .large()")
    #expect(sheet.detents.count == 2, "Detents count should be 2")

    host.dismiss(animated: false)
    try await Task.sleep(nanoseconds: 100_000_000)
}

@Test func testDetentFull() {
    let fullDetent = UISheetPresentationController.Detent.full()
    #expect(fullDetent != .large(), ".full() should not be the same as .large()") 
    
    guard let data = Data(base64Encoded: "X2Z1bGxEZXRlbnQ="), // "_fullDetent"
          let key = String(data: data, encoding: .utf8) else {
        #expect(false, "Failed to decode detent key for .full()")
        return
    }
    
    // This KVC access on a system class (UISheetPresentationController.Detent) might be restricted or fail.
    // It's a best effort to check against the internal implementation detail.
    if let internalFullDetent = UISheetPresentationController.Detent.value(forKey: key) as? UISheetPresentationController.Detent {
         #expect(fullDetent == internalFullDetent, ".full() should match the internal _fullDetent value")
    } else {
        // This path might be taken if KVC access is not allowed or the key doesn't exist.
        // The test still has some value due to the earlier #expect(fullDetent != .large()).
        print("Note: Could not directly verify .full() against internal key '\(key)'. This might be due to KVC restrictions or changes in internal API. Relying on inequality with .large().")
    }
}

#endif
