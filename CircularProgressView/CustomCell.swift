//
//  CustomCell.swift
//  CircularProgressView
//
//  Created by Wagner Truppel on 01/05/2015.
//  Copyright (c) 2015 Wagner Truppel. All rights reserved.
//

import UIKit


class CustomCell: UITableViewCell
{
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var progressView: CircularProgressView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!

    var dataItem: DataItem? {
        didSet {
            if let dataItem = self.dataItem
            {
                self.nameLabel.text = dataItem.personName
                self.emailLabel.text = dataItem.personEmail
                self.photoView!.image = UIImage(named: dataItem.photoName)
            }
            else
            {
                self.nameLabel.text = nil
                self.emailLabel.text = nil
                self.photoView!.image = nil
            }
        }
    }

    override func awakeFromNib()
    {
        super.awakeFromNib()
        showContent(show: false, animated: false)
    }

    func showContent(show: Bool, animated: Bool)
    {
        if animated
        {
            let duration: TimeInterval = (show ? 0.3 : 0.25)
            animateContent(duration: duration, show: show)
        }
        else
        {
            let alpha: CGFloat = (show ? 1.0 : 0.0)

            photoView.alpha = alpha
            progressView.alpha = 1.0 - alpha

            nameLabel.isHidden = !show
            nameLabel.alpha = alpha

            emailLabel.isHidden = !show
            emailLabel.alpha = alpha
        }
    }
}


// Content animation
extension CustomCell
{
    private func animateContent(duration: TimeInterval, show: Bool)
    {
        if show
        {
            UIView.animate(withDuration: 0.75, animations: {
                self.photoView.alpha    = 1.0
                self.progressView.alpha = 0.0
            }) { (completed) -> Void in
                self.animateView(view: self.nameLabel,
                                 duration: duration, show: true,
                                 completion: { (completed) -> Void in
                                    self.animateView(view: self.emailLabel,
                                                     duration: duration, show: show, completion: nil)
                })
            }
        }
        else
        {
            self.animateView(view: self.emailLabel,
                duration: duration, show: false,
                completion: { (completed) -> Void in
                    self.animateView(view: self.nameLabel,
                        duration: duration, show: false,
                        completion: { (completed) -> Void in
                            UIView.animate(withDuration: 0.75, animations: {
                                
                                self.photoView.alpha    = 0.0
                                self.progressView.alpha = 1.0
                            })
                    })
            })
        }
    }

    private func animateView(view: UIView, duration: TimeInterval, show: Bool, completion: ((Bool) -> Void)?)
    {
        let alpha: CGFloat = (show ? 1.0 : 0.0)

        UIView.animate(withDuration: duration,
            animations: {
                view.alpha = alpha
            },
            completion: { (completed) -> Void in
                view.isHidden = !show
                completion?(completed)
        })
    }
}
