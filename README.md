# OhSheet

## API

```swift
.sheet(isPresented: $isPresented) {
    Text("FullScreen Sheet")
        .presentationBackground(.blue)
        .fullScreenSheet() // Add this
}
```

```swift
.sheet(isPresented: $isPresented) {
    Text("FullScreen Sheet")
        .presentationBackground(.blue)
        .sheet(with: [.full()]) // detents
}
```
