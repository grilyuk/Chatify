import UIKit

class PresentTransition: NSObject, UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toViewController = transitionContext.viewController(forKey: .to),
              let fromViewController = transitionContext.viewController(forKey: .from)
        else {
            return
        }
        let containerView = transitionContext.containerView

        toViewController.view.alpha = 0.0
        containerView.addSubview(toViewController.view)
        containerView.layer.cornerRadius = 20
        containerView.clipsToBounds = true
        let heightOffset = fromViewController.view.frame.height - toViewController.view.frame.height
        containerView.frame = CGRect(x: 0, y: heightOffset,
                                     width: toViewController.view.frame.width,
                                     height: fromViewController.view.frame.height)
        containerView.transform = containerView.transform.rotated(by: -.pi * 0.5)

        UIView.animate(withDuration: transitionDuration(using: transitionContext)) {
            toViewController.view.alpha = 1.0
            
            containerView.transform = containerView.transform.rotated(by: -.pi * 1.5)
            fromViewController.view.alpha = 0.5
        } completion: { finished in
            transitionContext.completeTransition(finished)
        }
    }
}
