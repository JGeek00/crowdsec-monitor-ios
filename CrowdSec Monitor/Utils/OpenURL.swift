import Foundation
import UIKit

func openURL(_ url: String) {
    guard let url = URL(string: url) else {
        print("Invalid URL: \(url)")
        return
    }
    
    if UIApplication.shared.canOpenURL(url) {
        UIApplication.shared.open(url)
    }
}
