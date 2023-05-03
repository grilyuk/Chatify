import UIKit

class DismissTransition: NSObject, UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: .from) else { return }
        let containerView = transitionContext.containerView

        UIView.animate(withDuration: transitionDuration(using: transitionContext)) {
            fromViewController.view.alpha = 0.0
        } completion: { finished in
            containerView.removeFromSuperview()
            transitionContext.completeTransition(finished)
        }
    }
}
