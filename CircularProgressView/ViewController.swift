//
//  ViewController.swift
//  CircularProgressView
//
//  Created by Wagner Truppel on 26/04/2015.
//  Copyright (c) 2015 Wagner Truppel. All rights reserved.
//

import UIKit


class ViewController: UIViewController
{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var reloadButton: UIButton!

    private var dataItems = [NSIndexPath: DataItem]()
    private var clockwise = true
    private var reversed = false
    private var showPercs = true

    @IBAction func reloadBtnTapped()
    {
        reloadButton.enabled = false
        dataItems = [NSIndexPath: DataItem]()
        tableView.reloadData()
    }

    @IBAction func clockwiseBtnTapped(sender: UIButton)
    {
        sender.selected = !sender.selected
        clockwise = !sender.selected
        for row in 0..<DataLoader.dataSize()
        {
            let indexPath = NSIndexPath(forRow: row, inSection: 0)
            let cell = tableView.cellForRowAtIndexPath(indexPath) as? CustomCell
            cell?.progressView.clockwise = clockwise
        }
    }

    @IBAction func progressBtnTapped(sender: UIButton)
    {
        sender.selected = !sender.selected
        reversed = sender.selected
        for row in 0..<DataLoader.dataSize()
        {
            let indexPath = NSIndexPath(forRow: row, inSection: 0)
            let cell = tableView.cellForRowAtIndexPath(indexPath) as? CustomCell
            cell?.progressView.reversed = reversed
        }
    }

    @IBAction func percentBtnTapped(sender: UIButton)
    {
        sender.selected = !sender.selected
        showPercs = !sender.selected
        for row in 0..<DataLoader.dataSize()
        {
            let indexPath = NSIndexPath(forRow: row, inSection: 0)
            let cell = tableView.cellForRowAtIndexPath(indexPath) as? CustomCell
            cell?.progressView.showPercent = showPercs
        }
    }
}


extension ViewController: UITableViewDataSource, UITableViewDelegate
{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    { return DataLoader.dataSize() }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellID") as? CustomCell
        cell?.dataItem = dataItems[indexPath]
        cell?.progressView.clockwise = clockwise
        cell?.progressView.reversed = reversed
        cell?.progressView.showPercent = showPercs
        return cell!
    }

    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell,
        forRowAtIndexPath indexPath: NSIndexPath)
    {
        if let customCell = cell as? CustomCell
        {
            if customCell.dataItem != nil
            { customCell.showContent(true, animated: true) }
            else
            {
                customCell.showContent(false, animated: false)
                DataLoader.loadDataForIndexPath(indexPath, delegate: self)
            }
        }
    }
}


extension ViewController: DataLoaderDelegate
{
    func dataLoader(dataLoader: DataLoader, didUpdateDataWithPercentValue value: CGFloat)
    {
        let cell = tableView.cellForRowAtIndexPath(dataLoader.loaderIndexPath) as? CustomCell
        cell?.progressView.value = value
    }

    func dataLoaderDidFinishLoadingData(dataLoader: DataLoader)
    {
        let indexPath = dataLoader.loaderIndexPath
        let data = dataLoader.loaderData

        dataItems[indexPath] = data

        let cell = tableView.cellForRowAtIndexPath(indexPath) as? CustomCell
        cell?.dataItem = data

        if data != nil { cell?.showContent(true, animated: true) }

        let canReload = (dataItems.count == DataLoader.dataSize())
        reloadButton.enabled = canReload
    }
}