//
//  PannableTableView.swift
//  Pods
//
//  Created by Guillaume on 1/13/17.
//
//

import Foundation

public protocol PannableTableViewCell: class {

    var frontContentView: UIView! {get}

    /// Must be in the far right of the view
    var backContentView: UIView! {get}

    func expand(_ animated: Bool)

    func collapse(_ animated: Bool)

    var tx: CGFloat {get set}

    var maxTx: CGFloat {get}
}

extension PannableTableViewCell where Self: UITableViewCell {

    public var tx: CGFloat {
        get {
            return frontContentView.transform.tx
        }
        set {
            frontContentView.transform.tx = newValue
        }
    }

    public func expand(_ animated: Bool) {
        if animated {
            self.backContentView.isHidden = false
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                self.tx = -self.maxTx
            }, completion: { (_) -> Void in

            })
        } else {
            tx = -maxTx
            backContentView.isHidden = false
        }
    }

    public func collapse(_ animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                self.tx = 0
            }, completion: { (_) -> Void in
                self.backContentView.isHidden = true
            })
        } else {
            tx = 0
            backContentView.isHidden = true
        }
    }

    public var maxTx: CGFloat {
        return backContentView.bounds.width
    }

}
