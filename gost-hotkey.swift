import AppKit
import ApplicationServices
import Foundation

// Control + Command + T
let keyCode: Int64 = 17
let requiredFlags: CGEventFlags = [.maskControl, .maskCommand]

let mappings: [(String, String)] = [
    ("shh", "щ"), ("sh", "ш"), ("ch", "ч"), ("zh", "ж"),
    ("cz", "ц"), ("yo", "ё"), ("yu", "ю"), ("ya", "я"),
    ("y'", "ы"), ("e'", "э"), ("''", "ъ"), ("kh", "х"),
    ("a", "а"), ("b", "б"), ("c", "ц"), ("d", "д"),
    ("e", "е"), ("f", "ф"), ("g", "г"), ("h", "х"),
    ("i", "и"), ("j", "й"), ("k", "к"), ("l", "л"),
    ("m", "м"), ("n", "н"), ("o", "о"), ("p", "п"),
    ("q", "щ"), ("r", "р"), ("s", "с"), ("t", "т"),
    ("u", "у"), ("v", "в"), ("w", "ы"), ("x", "х"),
    ("y", "ы"), ("z", "з"), ("'", "ь")
]

func transliterate(_ text: String) -> String {
    var rest = text[...]
    var result = ""
    while !rest.isEmpty {
        if let (latin, russian) = mappings.first(where: { rest.lowercased().hasPrefix($0.0) }) {
            let original = String(rest.prefix(latin.count))
            result += original.first?.isUppercase == true ? russian.uppercased() : russian
            rest.removeFirst(latin.count)
        } else {
            result.append(rest.removeFirst())
        }
    }
    return result
}

func convertSelection() {
    guard let app = NSWorkspace.shared.frontmostApplication else {
        print("ERROR: No frontmost app"); return
    }
    print("Shortcut detected; target: \(app.localizedName ?? "unknown")")
    let axApp = AXUIElementCreateApplication(app.processIdentifier)
    AXUIElementSetMessagingTimeout(axApp, 3)
    var focused: CFTypeRef?
    let focusStatus = AXUIElementCopyAttributeValue(axApp, kAXFocusedUIElementAttribute as CFString, &focused)
    guard focusStatus == .success, let focused else {
        print("ERROR: Focused element: \(focusStatus.rawValue)"); return
    }
    let element = focused as! AXUIElement
    var selection: CFTypeRef?
    let selectionStatus = AXUIElementCopyAttributeValue(element, kAXSelectedTextAttribute as CFString, &selection)
    guard selectionStatus == .success, let selected = selection as? String, !selected.isEmpty else {
        print("ERROR: Selected text unavailable: \(selectionStatus.rawValue)"); return
    }
    let replacement = transliterate(selected)
    if replacement == selected { print("No transliteration changes"); return }
    let result = AXUIElementSetAttributeValue(element, kAXSelectedTextAttribute as CFString, replacement as CFString)
    switch result {
    case .success:
        print("Replaced: \(replacement)")
    case .failure:
        print("Accessibility returned -25200; replacement may have succeeded")
    default:
        print("Accessibility status: \(result.rawValue)")
    }
}

let callback: CGEventTapCallBack = { _, type, event, _ in
    if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
        print("Event tap disabled by macOS")
        return Unmanaged.passUnretained(event)
    }
    guard type == .keyDown else { return Unmanaged.passUnretained(event) }
    let flags = event.flags.intersection([.maskCommand, .maskControl, .maskAlternate, .maskShift])
    guard event.getIntegerValueField(.keyboardEventKeycode) == keyCode,
          flags == requiredFlags else { return Unmanaged.passUnretained(event) }

    // Avoid repeating while the key is held down.
    if event.getIntegerValueField(.keyboardEventAutorepeat) == 0 {
        convertSelection()
    }
    return Unmanaged.passUnretained(event)
}

guard AXIsProcessTrusted() else {
    fputs("ERROR: Grant Accessibility permission to Terminal (or this binary) in System Settings.\n", stderr)
    exit(1)
}
let mask = CGEventMask(1) << CGEventType.keyDown.rawValue
guard let tap = CGEvent.tapCreate(tap: .cgSessionEventTap,
                                  place: .headInsertEventTap,
                                  options: .listenOnly,
                                  eventsOfInterest: mask,
                                  callback: callback,
                                  userInfo: nil) else {
    fputs("ERROR: Cannot create keyboard event tap.\n", stderr)
    exit(1)
}
let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .commonModes)
CGEvent.tapEnable(tap: tap, enable: true)
print("Listening: Control + Command + T (⌃⌘T)")
fflush(stdout)
CFRunLoopRun()
