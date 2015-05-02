//
//  CustomCell.swift
//  CircularProgressView
//
//  Created by Wagner Truppel on 01/05/2015.
//  Copyright (c) 2015 Wagner Truppel. All rights reserved.
//

import UIKit


protocol CustomCellDelegate
{
    func cellDidFinishLoadingData(dataItem: DataItem?, forIndex index: Int)
}


class CustomCell: UITableViewCell
{
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var progressView: CircularProgressView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var reloadButton: UIButton!

    var dataIndex: Int!
    var dataItem: DataItem? {
        didSet {
            if let dataItem = self.dataItem
            {
                self.nameLabel.text = dataItem.personName
                self.emailLabel.text = dataItem.personEmail
                self.photoView!.image = UIImage(named: dataItem.photoName)
            }
        }
    }

    var delegate: CustomCellDelegate?
    var contentAlreadyShowing = false

    override func awakeFromNib()
    {
        super.awakeFromNib()
        showContent(false, animated: false)
    }

    func startLoadingData()
    { DataLoader.startLoadingDataForIndex(dataIndex, delegate: self) }

    func stopLoadingData()
    { DataLoader.stopLoadingDataForIndex(dataIndex) }

    func showContent(show: Bool, animated: Bool)
    {
        if animated
        {
            let duration: NSTimeInterval = (show ? 0.3 : 0.25)
            animateContent(duration, show: show)
        }
        else
        {
            let alpha: CGFloat = (show ? 1.0 : 0.0)

            reloadButton.hidden = !show

            photoView.alpha = alpha
            progressView.alpha = 1.0 - alpha

            nameLabel.hidden = !show
            nameLabel.alpha = alpha

            emailLabel.hidden = !show
            emailLabel.alpha = alpha
        }
    }

    @IBAction func reloadButtonTapped(sender: UIButton)
    {
        showContent(false, animated: true)
        dataItem = nil
        startLoadingData()
    }
}


extension CustomCell: DataLoaderDelegate
{
    func dataLoaderDidUpdateDataWithPercentValue(value: CGFloat)
    { progressView.value = value }

    func dataLoaderDidFinishLoadingData(dataLoader: DataLoader)
    {
        dataItem = dataLoader.loaderData
        showContent(true, animated: true)
        delegate?.cellDidFinishLoadingData(dataItem, forIndex: dataLoader.loaderIndex)
    }
}


// Content animation
extension CustomCell
{
    private func animateContent(duration: NSTimeInterval, show: Bool)
    {
        if show
        {
            UIView.animateWithDuration(0.75,
                animations: {
                    self.photoView.alpha    = 1.0
                    self.progressView.alpha = 0.0
                },
                completion: { (completed) -> Void in
                    self.reloadButton.hidden = false
                    self.animateView(self.nameLabel,
                        duration: duration, show: true,
                        completion: { (completed) -> Void in
                            self.animateView(self.emailLabel,
                                duration: duration, show: show, completion: nil)
                    })
            })
        }
        else
        {
            self.animateView(self.emailLabel,
                duration: duration, show: false,
                completion: { (completed) -> Void in
                    self.animateView(self.nameLabel,
                        duration: duration, show: false,
                        completion: { (completed) -> Void in
                            UIView.animateWithDuration(0.75,
                                animations: {
                                    self.photoView.alpha    = 0.0
                                    self.progressView.alpha = 1.0
                                },
                                completion: { (completed) -> Void in
                                    self.reloadButton.hidden = true
                            })
                    })
            })
        }
    }

    private func animateView(view: UIView, duration: NSTimeInterval, show: Bool, completion: ((Bool) -> Void)?)
    {
        let alpha: CGFloat = (show ? 1.0 : 0.0)

        UIView.animateWithDuration(duration,
            animations: {
                view.alpha = alpha
            },
            completion: { (completed) -> Void in
                view.hidden = !show
                completion?(completed)
        })
    }
}
