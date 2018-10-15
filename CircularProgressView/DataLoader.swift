//
//  DataLoader.swift
//  CircularProgressView
//
//  Created by Wagner Truppel on 01/05/2015.
//  Copyright (c) 2015 Wagner Truppel. All rights reserved.
//

import Foundation
import CoreGraphics


protocol DataLoaderDelegate
{
    func dataLoader(dataLoader: DataLoader, didUpdateDataWithPercentValue value: CGFloat)
    func dataLoaderDidFinishLoadingData(dataLoader: DataLoader)
}


class DataLoader
{
    let loaderIndexPath: NSIndexPath
    var loaderData: DataItem?

    static func dataSize() -> Int
    { return data.count }

    static func loadDataForIndexPath(indexPath: NSIndexPath, delegate: DataLoaderDelegate)
    {
        let dataLoader = DataLoader(indexPath: indexPath, delegate: delegate)
        dataLoader.loadData()
    }

    private init(indexPath: NSIndexPath, delegate: DataLoaderDelegate)
    {
        loaderIndexPath = indexPath
        self.delegate = delegate
        DataLoader.dataLoaders[indexPath] = self
    }

    private static var dataLoaders = [NSIndexPath: DataLoader]()
    private var delegate: DataLoaderDelegate?

    private func loadData()
    { globalConcurrentBackgroundQueue.async() { self.countUp() } }

    private func countUp()
    {
        let maxCount = Int(CGFloat.randomUniform(a: 300, b: 1000))

        for count in 0..<maxCount
        {
            globalSerialMainQueue.sync() {
                let value = CGFloat(count)/CGFloat(maxCount)
                self.delegate?.dataLoader(dataLoader: self, didUpdateDataWithPercentValue: value)
            }
        }

        globalSerialMainQueue.sync() {
            self.loaderData = data[self.loaderIndexPath.row]
            self.delegate?.dataLoaderDidFinishLoadingData(dataLoader: self)
        }

        DataLoader.dataLoaders[self.loaderIndexPath] = nil
    }
}


let data: [DataItem] = {
    var da = [DataItem]()
    da.append(DataItem("arya", "Arya S.", "faceless@got.com"))
    da.append(DataItem("brienne", "Brienne of T.", "i_heart_renly@got.com"))
    da.append(DataItem("cersei", "Cersei L.", "queen_bitch@got.com"))
    da.append(DataItem("danny", "Danny T.", "mommy_of_dragons@got.com"))
    da.append(DataItem("ned", "Eddard S.", "ned@got.com"))
    da.append(DataItem("jaime", "Jaime L.", "want_my_hand_back@got.com"))
    da.append(DataItem("snow", "Jon S.", "lord_commander@got.com"))
    da.append(DataItem("margie", "Margaery T.", "bite_me_cersei@got.com"))
    da.append(DataItem("littlefinger", "Petyr B.", "brothels_r_us@got.com"))
    da.append(DataItem("theon", "Theon G.", "want_my_junk_back@got.com"))
    return da
    }()


class DataItem
{
    let photoName:  String!
    let personName:  String!
    let personEmail: String!

    init(_ photoName: String, _ personName: String, _ personEmail: String)
    {
        self.photoName = photoName
        self.personName = personName
        self.personEmail = personEmail
    }
}


// GCD utils

var globalSerialMainQueue: DispatchQueue!
{ return DispatchQueue.main }

var globalConcurrentBackgroundQueue: DispatchQueue!
{ return DispatchQueue.global(qos: .background) }

// CG extensions

extension CGFloat
{
    // Returns a uniformly distributed random CGFloat in the range [0, 1].
    public static var randomUniform01: CGFloat
    { return CGFloat(arc4random_uniform(UInt32.max)) / CGFloat(UInt32.max - 1) }

    // Returns a uniformly distributed random CGFloat in the range [min(a,b), max(a,b)].
    public static func randomUniform(a: CGFloat, b: CGFloat) -> CGFloat
    { return a + (b - a) * CGFloat.randomUniform01 }

    // Returns a uniformly distributed random boolean.
    public static var randomBool: Bool
    { return CGFloat.randomUniform01 <= 0.5 }
}
