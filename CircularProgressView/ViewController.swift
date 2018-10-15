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
        reloadButton.isEnabled = false
        dataItems = [NSIndexPath: DataItem]()
        tableView.reloadData()
    }

    @IBAction func clockwiseBtnTapped(sender: UIButton)
    {
        sender.isSelected = !sender.isSelected
        clockwise = !sender.isSelected
        for row in 0..<DataLoader.dataSize()
        {
            let indexPath = NSIndexPath(row: row, section: 0)
            let cell = tableView.cellForRow(at: indexPath as IndexPath) as? CustomCell
            cell?.progressView.clockwise = clockwise
        }
    }

    @IBAction func progressBtnTapped(sender: UIButton)
    {
        sender.isSelected = !sender.isSelected
        reversed = sender.isSelected
        for row in 0..<DataLoader.dataSize()
        {
            let indexPath = NSIndexPath(row: row, section: 0)
            let cell = tableView.cellForRow(at: indexPath as IndexPath) as? CustomCell
            cell?.progressView.reversed = reversed
        }
    }

    @IBAction func percentBtnTapped(sender: UIButton)
    {
        sender.isSelected = !sender.isSelected
        showPercs = !sender.isSelected
        for row in 0..<DataLoader.dataSize()
        {
            let indexPath = NSIndexPath(row: row, section: 0)
            let cell = tableView.cellForRow(at: indexPath as IndexPath) as? CustomCell
            cell?.progressView.showPercent = showPercs
        }
    }
}


extension ViewController: UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    { return DataLoader.dataSize() }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID") as? CustomCell
        cell?.dataItem = dataItems[indexPath]
        cell?.progressView.clockwise = clockwise
        cell?.progressView.reversed = reversed
        cell?.progressView.showPercent = showPercs
        return cell!
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath)
    {
        if let customCell = cell as? CustomCell
        {
            if customCell.dataItem != nil
            { customCell.showContent(show: true, animated: true) }
            else
            {
                customCell.showContent(show: false, animated: false)
                DataLoader.loadDataForIndexPath(indexPath: indexPath as NSIndexPath, delegate: self)
            }
        }
    }
}


extension ViewController: DataLoaderDelegate
{
    func dataLoader(dataLoader: DataLoader, didUpdateDataWithPercentValue value: CGFloat)
    {
        let cell = tableView.cellForRow(at: dataLoader.loaderIndexPath as IndexPath) as? CustomCell
        cell?.progressView.value = value
    }

    func dataLoaderDidFinishLoadingData(dataLoader: DataLoader)
    {
        let indexPath = dataLoader.loaderIndexPath
        let data = dataLoader.loaderData

        dataItems[indexPath] = data

        let cell = tableView.cellForRow(at: indexPath as IndexPath) as? CustomCell
        cell?.dataItem = data

        if data != nil { cell?.showContent(show: true, animated: true) }

        let canReload = (dataItems.count == DataLoader.dataSize())
        reloadButton.isEnabled = canReload
    }
}
