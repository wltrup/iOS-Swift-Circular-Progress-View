//
//  DataLoader.swift
//  CircularProgressView
//
//  Created by Wagner Truppel on 01/05/2015.
//  Copyright (c) 2015 Wagner Truppel. All rights reserved.
//

import Foundation
import UIKit


protocol DataLoaderDelegate
{
    func dataLoaderDidUpdateDataWithPercentValue(value: CGFloat)
    func dataLoaderDidFinishLoadingData(dataLoader: DataLoader)
}


class DataLoader
{
    let loaderIndex: Int
    var loaderData: DataItem?

    static func dataSize() -> Int
    { return data.count }

    static func startLoadingDataForIndex(index: Int, delegate: DataLoaderDelegate)
    {
        let dataLoader = DataLoader(index: index, delegate: delegate)
        dataLoader.loadData()
    }

    static func stopLoadingDataForIndex(index: Int)
    { dataLoaders[index]?.counter.abort = true }

    private init(index: Int, delegate: DataLoaderDelegate)
    {
        loaderIndex = index
        self.delegate = delegate
        DataLoader.dataLoaders[index] = self
    }

    private static var dataLoaders = [Int: DataLoader]()
    private var delegate: DataLoaderDelegate?
    private let maxCount = Int(CGFloat.randomUniform(a: 50, b: 120))
    private var counter: Counter!

    private func loadData()
    {
        counter = Counter()
        dispatch_async(globalConcurrentBackgroundQueue) { self.countUp() }
    }

    private func countUp()
    {
        if self.counter.abort
        {
            dispatch_sync(globalSerialMainQueue) {
                self.loaderData = nil
                DataLoader.dataLoaders[self.loaderIndex] = nil
            }
        }
        else
        {
            let count = self.counter.count
            let maxCount = self.maxCount

            dispatch_sync(globalSerialMainQueue) {
                let value = CGFloat(count)/CGFloat(maxCount)
                self.delegate?.dataLoaderDidUpdateDataWithPercentValue(value)
            }

            if count < maxCount
            {
                self.counter.count += 1
                let delay = dispatchTimeFromNowInSeconds(0.01)
                dispatch_after(delay, globalConcurrentBackgroundQueue) { self.countUp() }
            }
            else
            {
                dispatch_sync(globalSerialMainQueue) {
                    self.loaderData = data[self.loaderIndex]
                    self.delegate?.dataLoaderDidFinishLoadingData(self)
                    DataLoader.dataLoaders[self.loaderIndex] = nil
                }
            }
        }
    }
}


let data: [DataItem] =
{
    var da = [DataItem]()
    da.append(DataItem("ned", "Eddard S.", "ned@got.com"))
    da.append(DataItem("brienne", "Brienne of T.", "renly_lives@got.com"))
    da.append(DataItem("snow", "Jon S.", "lord_commander@got.com"))
    da.append(DataItem("cersei", "Cersei L.", "queen_bitch@got.com"))
    da.append(DataItem("margie", "Margaery T.", "bite_me_cersei@got.com"))
    da.append(DataItem("littlefinger", "Petyr B.", "brothels_r_us@got.com"))
    da.append(DataItem("danny", "Danny T.", "mommy_of_dragons@got.com"))
    da.append(DataItem("theon", "Theon G.", "want_my_junk_back@got.com"))
    da.append(DataItem("jaime", "Jaime L.", "want_my_hand_back@got.com"))
    da.append(DataItem("arya", "Arya S.", "faceless@got.com"))
    return da
    }()


class DataItem
{
    let  photoName:  String!
    let personName:  String!
    let personEmail: String!

    init(_ photoName: String, _ personName: String, _ personEmail: String)
    {
        self.photoName = photoName
        self.personName = personName
        self.personEmail = personEmail
    }
}


// A simple thread-safe counter class

class Counter
{
    private var icount = 0
    private var iabort = false
    private let counterMultiReadSingleWriteQueue = dispatch_queue_create(
        "com.wltruppel.Counter.counterMultiReadSingleWriteQueue", DISPATCH_QUEUE_CONCURRENT)

    var count: Int {

        get
        {
            var tempCount: Int = 0
            dispatch_sync(counterMultiReadSingleWriteQueue) { tempCount = self.icount }
            return tempCount
        }

        set (newCount)
        {
            dispatch_barrier_sync(counterMultiReadSingleWriteQueue) {
                self.icount = newCount
            }
        }

    }

    var abort: Bool {

        get
        {
            var tempAbort = false
            dispatch_sync(counterMultiReadSingleWriteQueue) { tempAbort = self.iabort }
            return tempAbort
        }

        set
        {
            dispatch_barrier_sync(counterMultiReadSingleWriteQueue) {
                self.iabort = newValue
            }
        }
        
    }
}


// GCD utils

var globalSerialMainQueue: dispatch_queue_t!
{ return dispatch_get_main_queue() }

var globalConcurrentBackgroundQueue: dispatch_queue_t!
{ return dispatch_get_global_queue(Int(QOS_CLASS_BACKGROUND.value), 0) }

func dispatchTimeFromNowInSeconds(delayInSeconds: Double) -> dispatch_time_t!
{ return dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC))) }


// UIKit extensions

extension CGFloat
{
    // Returns a uniformly distributed random CGFloat in the range [0, 1].
    public static var randomUniform01: CGFloat
    { return CGFloat(arc4random_uniform(UInt32.max)) / CGFloat(UInt32.max - 1) }

    // Returns a uniformly distributed random CGFloat in the range [min(a,b), max(a,b)].
    public static func randomUniform(#a: CGFloat, b: CGFloat) -> CGFloat
    { return a + (b - a) * CGFloat.randomUniform01 }

    // Returns a uniformly distributed random boolean.
    public static var randomBool: Bool
    { return CGFloat.randomUniform01 <= 0.5 }
}
