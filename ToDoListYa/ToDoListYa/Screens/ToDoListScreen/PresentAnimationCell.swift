import UIKit

final class PresentAnimaitionFromCell: NSObject, UIViewControllerAnimatedTransitioning {

    private let cellFrame: CGRect

    init(cellFrame: CGRect) {
        self.cellFrame = cellFrame
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let from = transitionContext.viewController(forKey: .from),
              let to = transitionContext.viewController(forKey: .to),
              let snapshot = to.view.snapshotView(afterScreenUpdates: true)
        else {
            return
        }

        let containerView = transitionContext.containerView
        let finalFrame = transitionContext.finalFrame(for: to)
        let scale = UIScreen.main.scale
        let yCoordinate = 20.0 * scale
        to.view.frame = CGRect(
            x: finalFrame.origin.x,
            y: yCoordinate,
            width: finalFrame.width,
            height: finalFrame.height + (finalFrame.height/CGFloat(5))
        )

        snapshot.frame = cellFrame
        snapshot.layer.cornerRadius = 16
        snapshot.layer.masksToBounds = true

        containerView.addSubview(to.view)
        containerView.addSubview(snapshot)
        to.view.isHidden = true

        let duration = transitionDuration(using: transitionContext)

        UIView.animateKeyframes(
            withDuration: duration,
            delay: 0,
            options: .calculationModeCubic,
            animations: {
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.3) {
                    snapshot.frame = CGRect(
                        x: finalFrame.origin.x,
                        y: yCoordinate,
                        width: finalFrame.width,
                        height: finalFrame.height
                    )
                }
            },
            completion: { _ in
                to.view.isHidden = false
                snapshot.removeFromSuperview()
                from.view.layer.transform = CATransform3DIdentity
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
    }
}
