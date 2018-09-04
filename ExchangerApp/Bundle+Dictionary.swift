import Foundation

extension Bundle {
    func dictionary(for name: String) -> [String: AnyObject] {
        guard
            let url = url(forResource: name, withExtension: "plist"),
            let data = try? Data(contentsOf: url),
            let properties = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil),
            let list = properties as? [String: AnyObject]
        else { return [:] }
        return list
    }
}
