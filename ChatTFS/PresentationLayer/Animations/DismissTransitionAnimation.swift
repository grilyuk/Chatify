import UIKit

class DismissTransition: NSObject, UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: .from),
              let toViewController = transitionContext.viewController(forKey: .to)
        else { return }
        let containerView = transitionContext.containerView

        UIView.animate(withDuration: transitionDuration(using: transitionContext)) {
            fromViewController.view.alpha = 0.0
            toViewController.view.alpha = 1.0
        } completion: { finished in
            containerView.removeFromSuperview()
            transitionContext.completeTransition(finished)
        }
    }
}
