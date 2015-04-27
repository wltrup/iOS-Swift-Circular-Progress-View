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
    @IBOutlet var button: UIButton!
    @IBOutlet var clockwiseSwitch: UISwitch!
    @IBOutlet var showPercentsSwitch: UISwitch!
    @IBOutlet var reversedSwitch: UISwitch!
    @IBOutlet var progressView: CircularProgressView!

    private var counter: Counter!

    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)

        forceSwitchUpdate(clockwiseSwitch)
        forceSwitchUpdate(showPercentsSwitch)
        forceSwitchUpdate(reversedSwitch)

        progressView.value = CGFloat.randomUniform01
    }

    @IBAction func switchTapped(sender: UISwitch)
    {
        if sender == clockwiseSwitch
        {
            progressView.clockwise = sender.on
        }
        else if sender == showPercentsSwitch
        {
            progressView.showPercent = sender.on
        }
        else if sender == reversedSwitch
        {
            progressView.reversed = sender.on
        }
    }

    @IBAction func buttonTapped(sender: UIButton)
    {
        sender.enabled = false
        UIView.animateWithDuration(NSTimeInterval(1.0), animations: { sender.alpha = 0.0 })

        counter = Counter()

        progressView.backgroundColor = UIColor.randomColor()
        progressView.trackThickness = CGFloat.randomUniform(a: 10, b: 50)
        progressView.progressThicknessFraction = CGFloat.randomUniform(a: 0.1, b: 0.9)
        progressView.trackTint = UIColor.randomColor()
        progressView.progressTint = UIColor.randomColor()
        progressView.percentTint = UIColor.randomColor()
        progressView.percentBold = CGFloat.randomBool
        progressView.percentSize = CGFloat.randomUniform(a: 15, b: 48)

        dispatch_async(globalConcurrentBackgroundQueue) { self.countUp() }
    }

    private func countUp()
    {
        let count = self.counter.count
        let maxCount = 100

        dispatch_sync(globalSerialMainQueue) {
            self.progressView.value = CGFloat(count)/CGFloat(maxCount)
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
                self.button.enabled = true
                UIView.animateWithDuration(NSTimeInterval(1.0), animations: { self.button.alpha = 1.0 })
            }
        }
    }

    private func forceSwitchUpdate(theSwitch: UISwitch)
    {
        theSwitch.on = !theSwitch.on
        switchTapped(theSwitch)

        theSwitch.on = !theSwitch.on
        switchTapped(theSwitch)
    }
}


// A simple thread-safe counter class

class Counter
{
    private var _count = 0
    private let counterMultiReadSingleWriteQueue = dispatch_queue_create(
        "com.wltruppel.Counter.counterMultiReadSingleWriteQueue", DISPATCH_QUEUE_CONCURRENT)

    var count: Int {

        get
        {
            var tempCount: Int = 0
            dispatch_sync(counterMultiReadSingleWriteQueue) { tempCount = self._count }
            return tempCount
        }

        set (newCount)
        {
            dispatch_barrier_sync(counterMultiReadSingleWriteQueue) {
                self._count = newCount
            }
        }

    }
}


// GCD utils

var globalSerialMainQueue: dispatch_queue_t!
{
    return dispatch_get_main_queue()
}

var globalConcurrentBackgroundQueue: dispatch_queue_t!
{
    return dispatch_get_global_queue(Int(QOS_CLASS_BACKGROUND.value), 0)
}

func dispatchTimeFromNowInSeconds(delayInSeconds: Double) -> dispatch_time_t!
{
    return dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)))
}


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

extension UIColor
{
    static func randomColor() -> UIColor
    {
        let r = CGFloat.randomUniform01
        let g = CGFloat.randomUniform01
        let b = CGFloat.randomUniform01
        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
    }
}

