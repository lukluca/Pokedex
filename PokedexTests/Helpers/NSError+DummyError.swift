// See LICENSE.txt for licensing information

import Foundation

extension NSError {
    static var dummyError: NSError {
        NSError(domain: "Dummy", code: 0, userInfo: nil)
    }
}
