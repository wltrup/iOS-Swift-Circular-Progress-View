//
//  ViewController.swift
//  CircularProgressView
//
//  Created by Wagner Truppel on 26/04/2015.
//  Copyright (c) 2015 Wagner Truppel. All rights reserved.
//

import UIKit


class ViewController: UITableViewController
{
    private var dataItems = [Int: DataItem]()

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    { return DataLoader.dataSize() }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let index = indexPath.row

        let cell = tableView.dequeueReusableCellWithIdentifier("cellID") as? CustomCell
        cell!.dataIndex = index
        cell!.dataItem = dataItems[index]

        return cell!
    }

    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell,
        forRowAtIndexPath indexPath: NSIndexPath)
    {
        if let customCell = cell as? CustomCell
        {
            if customCell.dataItem != nil
            { customCell.showContent(true, animated: true) }
            else
            { customCell.startLoadingData() }
        }
    }

    override func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell,
        forRowAtIndexPath indexPath: NSIndexPath)
    {
        if let customCell = cell as? CustomCell
        { customCell.stopLoadingData() }
    }
}


extension ViewController: CustomCellDelegate
{
    func cellDidFinishLoadingData(dataItem: DataItem?, forIndex index: Int)
    { dataItems[index] = dataItem }
}
