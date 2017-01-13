//
//  SwipeableTableView.swift
//  Tunsy-iOS
//
//  Created by Guillaume on 15/04/15.
//  Copyright (c) 2015 Tunsy. All rights reserved.
//

import UIKit

@objc protocol PannableTableViewDelegate: UITableViewDelegate {
    
    @objc optional func tableView(_ tableView: PannableTableView, shouldStartSwipeForCellAtIndexPath indexPath: IndexPath) -> Bool
    
}

class PannableTableView: UITableView, UIGestureRecognizerDelegate {
    
    fileprivate var savedPannedFrame: CGRect?
    
    fileprivate(set) var currentPannedCell: PannableTableViewCell?
    
    fileprivate(set) var currentPannedIndexPath: IndexPath?
    
    fileprivate var savedTx: CGFloat?
    
    fileprivate var pan: UIPanGestureRecognizer!
    
    var pannableDelegate: PannableTableViewDelegate? {
        return self.delegate as? PannableTableViewDelegate
    }
    
    var isPanned: Bool {
        return currentPannedCell != nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        pan = UIPanGestureRecognizer(target: self, action: #selector(PannableTableView.panRecognized(_:)))
        pan.delegate = self
        addGestureRecognizer(pan)
    }
    
    override func dequeueReusableCell(withIdentifier identifier: String) -> UITableViewCell? {
        let cell = super.dequeueReusableCell(withIdentifier: identifier)
        if let temp = cell as? PannableTableViewCell {
            temp.collapse(false)
        }
        return cell
    }
    
    override func dequeueReusableCell(withIdentifier identifier: String, for indexPath: IndexPath) -> UITableViewCell {
        let cell = super.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        if let temp = cell as? PannableTableViewCell {
            temp.collapse(false)
        }
        return cell
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if gestureRecognizer == pan {
            if let indexPath = self.indexPathForRow(at: gestureRecognizer.location(in: self)) {
                if let cell = self.cellForRow(at: indexPath) as? PannableTableViewCell {
                    let t = pan.translation(in: self)
                    if abs(t.x) > abs(t.y) && t.x < 0 {
                        if pannableDelegate?.tableView?(self, shouldStartSwipeForCellAtIndexPath: indexPath) ?? true {
                            self.currentPannedIndexPath = indexPath
                            self.currentPannedCell = cell
                            return true
                        }
                    }
                }
            }
            return false
        } else {
            return super.gestureRecognizerShouldBegin(gestureRecognizer)
        }
        
    }
    
    func panRecognized(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            self.currentPannedCell?.backContentView.isHidden = false
            break
        case .changed:
            let tx = maxmin(sender.translation(in: self).x, 0, -currentPannedCell!.maxTx)
            currentPannedCell!.tx = tx
            break
        default:
            let tempCell = self.currentPannedCell!
            var tx = maxmin(sender.translation(in: self).x, 0, -tempCell.maxTx)
            if tx < -tempCell.maxTx * 0.25 {
                tx = -tempCell.maxTx
                savedPannedFrame = self.convert(tempCell.backContentView.frame, from: tempCell.backContentView.superview!)
            } else {
                tx = 0
                clearPanned(false)
            }
            
            UIView.animate(withDuration: 0.15, animations: { () -> Void in
                tempCell.tx = tx
            })
            break
        }
    }
    
    func clearPanned(_ animated: Bool) {
        self.currentPannedCell?.collapse(animated)
        self.savedPannedFrame = nil
        self.currentPannedCell = nil
        self.currentPannedIndexPath = nil
    }
    
    func expandCellAtIndexPath(_ indexPath: IndexPath, animated: Bool = true) {
        if let cell = cellForRow(at: indexPath) as? PannableTableViewCell {
            if currentPannedCell === cell {
                return
            }
            clearPanned(animated)
            cell.expand(animated)
            currentPannedCell = cell
            savedPannedFrame = self.convert(cell.backContentView.frame, from: cell.backContentView.superview!)
        }
    }
    
    func collapseCellAtIndexPath(_ indexPath: IndexPath, animated: Bool = true) {
        if let cell = cellForRow(at: indexPath) as? PannableTableViewCell {
            if currentPannedCell === cell {
                clearPanned(animated)
            }
        }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if self.isPanned {
            if !self.savedPannedFrame!.contains(point) {
                self.clearPanned(true)
                return nil
            }
        }
        return super.hitTest(point, with: event)
    }
    
}

fileprivate func maxmin<T: Comparable>(_ value: T, _ max: T, _ min: T) -> T{
    assert(max >= min, "Careful max < min")
    if value > max {
        return max
    } else if value < min {
        return min
    } else {
        return value
    }
}
