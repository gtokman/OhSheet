# OhSheet

Inspired by this X [post](https://x.com/SebJVidal/status/1924721754074714258)

https://github.com/user-attachments/assets/1397f483-4dd4-4124-b468-8721b8311434

## Install

```
https://github.com/gtokman/OhSheet
```

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
