import UIKit

class TransitionAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: .from),
              let toViewController = transitionContext.viewController(forKey: .to)
               else { return }
        let containerView = transitionContext.containerView
        
        toViewController.view.frame = CGRect(x: containerView.bounds.width,
                                             y: 0,
                                             width: containerView.bounds.width,
                                             height: containerView.bounds.height)
        containerView.addSubview(toViewController.view)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext)) {
            fromViewController.view.layer.opacity = 0.0
            fromViewController.view.transform = fromViewController.view.transform.rotated(by: .pi)
            fromViewController.view.frame = CGRect(x: -containerView.bounds.width,
                                                   y: 0,
                                                   width: containerView.bounds.width,
                                                   height: containerView.bounds.height)
            toViewController.view.layer.opacity = 1.0
            toViewController.view.transform = toViewController.view.transform.rotated(by: .pi)
            toViewController.view.frame = CGRect(x: 0,
                                                 y: 0,
                                                 width: containerView.bounds.width,
                                                 height: containerView.bounds.height)
        } completion: { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
