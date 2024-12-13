import Foundation

// http://qiita.com/woxtu/items/284369fd2654edac2248
public extension String {
    func replace(regex: NSRegularExpression, template: String) -> String {
        return regex.stringByReplacingMatches(
            in: self,
            options: .reportProgress,
            range: NSMakeRange(0, self.utf16.count),
            withTemplate: template);
    }
}
