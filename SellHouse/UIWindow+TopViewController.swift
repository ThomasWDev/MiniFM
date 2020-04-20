
import UIKit

extension UIWindow {
    
    func topViewController() -> UIViewController? {
        if var topController = self.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        } else {
            return nil
        }
    }
    
    func viewControllerForStatusBarStyle() -> UIViewController? {
        var currentViewController = self.topViewController()
        while currentViewController?.childViewControllerForStatusBarStyle != nil {
            currentViewController = currentViewController?.childViewControllerForStatusBarStyle
        }
        return currentViewController
    }
    
    func viewControllerForStatusBarHidden() -> UIViewController? {
        var currentViewController = self.topViewController()
        while currentViewController?.childViewControllerForStatusBarHidden != nil {
            currentViewController = currentViewController?.childViewControllerForStatusBarHidden
        }
        return currentViewController
    }
}

