import Foundation

extension Bundle {
    static var isSwizzled = false
    
    static func swizzleLocalization() {
        guard !isSwizzled else { return }
        isSwizzled = true
        
        let originalSelector = #selector(localizedString(forKey:value:table:))
        let swizzledSelector = #selector(gs_localizedString(forKey:value:table:))
        
        guard let originalMethod = class_getInstanceMethod(Bundle.self, originalSelector),
              let swizzledMethod = class_getInstanceMethod(Bundle.self, swizzledSelector) else {
            return
        }
        
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
    
    @objc func gs_localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        // 1. Try to get from GhostStrings
        if self == Bundle.main {
            if let gsValue = GhostStrings.shared.getSyncInternal(key) {
                return gsValue
            }
        }
        
        // 2. Fallback to original implementation
        return gs_localizedString(forKey: key, value: value, table: tableName)
    }
}
