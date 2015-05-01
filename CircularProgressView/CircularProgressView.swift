/*
CircularProgressView.swift
CircularProgressView

Created by Wagner Truppel on 26/04/2015.

The MIT License (MIT)

Copyright (c) 2015 Wagner Truppel (wagner@restlessbrain.com).

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

When crediting me (Wagner Truppel) for this work, please use one
of the following two suggested formats:

Uses "CircularProgressView" code by Wagner Truppel
http://www.restlessbrain.com/wagner/

or

CircularProgressView code by Wagner Truppel
http://www.restlessbrain.com/wagner/

Where possible, a hyperlink to http://www.restlessbrain.com/wagner/
would be appreciated.
*/

import UIKit

@IBDesignable
class CircularProgressView: UIView
{
    // The color of the full track.
    @IBInspectable var trackTint: UIColor {

        get { return iTrackTint }

        set
        {
            if newValue != iTrackTint
            {
                iTrackTint = newValue
                setNeedsDisplay()

                if newValue == iProgressTint
                {
                    print("[CircularProgressView] WARNING: setting trackTint to the same color as progressTint " +
                          "will make the circular progress view appear as if it's not progressing.")
                }
            }
        }
    }
    private var iTrackTint: UIColor = UIColor.blackColor()


    // The color of the part of the track representing progress.
    @IBInspectable var progressTint: UIColor {

        get { return iProgressTint }

        set
        {
            if newValue != iProgressTint
            {
                iProgressTint = newValue
                setNeedsDisplay()

                if newValue == iTrackTint
                {
                    print("[CircularProgressView] WARNING: setting progressTint to the same color as trackTint " +
                          "will make the circular progress view appear as if it's not progressing.")
                }
            }
        }
    }
    private var iProgressTint: UIColor = UIColor.whiteColor()


    // The thickness of the full track, in points. It shouldn't be less than minTrackThickness,
    // and is clipped to that value if set otherwise. Always set this value before setting the
    // values of either progressThickness or progressThicknessFraction.
    @IBInspectable var trackThickness: CGFloat {

        get { return iTrackThickness }

        set
        {
            if newValue != iTrackThickness
            {
                iTrackThickness = max(minTrackThickness, newValue)
                updateProgressThickness(iProgressThickness)
                setNeedsDisplay()
            }
        }
    }
    private var   iTrackThickness: CGFloat = 30.0 // points
    private let minTrackThickness: CGFloat =  6.0 // points


    // The thickness of the part of the track representing progress, in points. Alternatively,
    // use progressThicknessFraction (see below) to set the progress thickness. progressThickness
    // should be in the range [minProgressThickness, trackThickness]. Note that the range depends
    // on the current value of trackThickness so always set that value first before setting the value
    // of progressThickness.
    @IBInspectable var progressThickness: CGFloat {

        get { return iProgressThickness }

        set
        {
            if newValue != iProgressThickness
            {
                updateProgressThickness(newValue)
                setNeedsDisplay()
            }
        }
    }
    private var   iProgressThickness: CGFloat = 10.0 // points
    private let minProgressThickness: CGFloat =  2.0 // points


    // The thickness of the part of the track representing progress, as a fraction of the full track
    // thickness. Alternatively, use progressThickness (see above) to set the progress thickness.
    // progressThicknessFraction should be a floating point number in the range
    // [minProgressThickness/trackThickness, 1]. Values outside that range are clipped to that range.
    // Note that the range depends on the current value of trackThickness so always set that value
    // first before setting the value of progressThicknessFraction.
    /*@IBInspectable*/ var progressThicknessFraction: CGFloat {

        get { return iProgressThicknessFraction }

        set
        {
            if newValue != iProgressThicknessFraction
            {
                iProgressThicknessFraction = max(minProgressThickness / iTrackThickness, newValue)
                iProgressThicknessFraction = min(iProgressThicknessFraction, 1)
                self.progressThickness = iProgressThicknessFraction * iTrackThickness
                setNeedsDisplay()
            }
        }
    }
    private var iProgressThicknessFraction: CGFloat = 0.5


    // Whether the progress track grows clockwise or counterclockwise as the progress value increases.
    @IBInspectable var clockwise: Bool {

        get { return iClockwise }

        set
        {
            if newValue != iClockwise
            {
                iClockwise = newValue
                setNeedsDisplay()
            }
        }
    }
    private var iClockwise = true


    // Whether the progress track shows the progress made (normal mode) or the progress remaining (reversed mode).
    // The default value is false, ie, show the progress made.
    @IBInspectable var reversed: Bool {

        get { return iReversed }

        set
        {
            if newValue != iReversed
            {
                iReversed = newValue
                updateLabel()
                setNeedsDisplay()
            }
        }
    }
    private var iReversed = false


    // Whether to display the percent label. Setting this property is equivalent to accessing the
    // percent label directly and hiding or unhiding it so it's just a convenience.
    @IBInspectable var showPercent: Bool {

        get { return iShowPercent }

        set
        {
            // if showing then we want to have a label; do something innocuous to force the label to be created.
            if newValue { self.percentLabel?.alpha = 1.0 }

            if newValue != iShowPercent
            {
                iShowPercent = newValue
                iPercentLabel?.hidden = !iShowPercent
                if iShowPercent { updateLabel() }
                setNeedsDisplay()
            }
        }
    }
    private var iShowPercent = true


    // The color of the percent text when it's showing. Setting this property is equivalent to accessing the
    // percent label directly and setting its text color property so it's just a convenience.
    @IBInspectable var percentTint: UIColor {

        get { return iPercentTint }

        set
        {
            if newValue != iPercentTint
            {
                iPercentTint = newValue
                iPercentLabel?.textColor = iPercentTint
                setNeedsDisplay()
            }
        }
    }
    private var iPercentTint = UIColor.blackColor()


    // The font size of the percent text when it's showing. Setting this property is equivalent to
    // accessing the percent label directly and setting its text font size so it's just a convenience.
    @IBInspectable var percentSize: CGFloat {

        get { return iPercentSize }

        set
        {
            if newValue != iPercentSize
            {
                iPercentSize = newValue
                updateLabelFontSize()
                setNeedsDisplay()
            }
        }
    }
    private var iPercentSize: CGFloat = 48


    // Whether to display the percent text using the bold or regular system font. Setting this property is
    // equivalent to accessing the percent label directly and setting its font property so it's just a convenience.
    @IBInspectable var percentBold: Bool {

        get { return iPercentBold }

        set
        {
            if newValue != iPercentBold
            {
                iPercentBold = newValue
                updateLabelFontSize()
                setNeedsDisplay()
            }
        }
    }
    private var iPercentBold = true


    // The value representing the progress made. It should be in the range [0, 1]. Values outside
    // that range will be clipped to that range.
    @IBInspectable var value: CGFloat {

        get { return iValue }

        set
        {
            let val: CGFloat
            #if TARGET_INTERFACE_BUILDER
                val = 0.01 * newValue // interpret the integers in the inspector stepper as percentages
            #else
                val = newValue
            #endif

            if val != iValue
            {
                iValue = max(0, val)
                iValue = min(iValue, 1)
                updateLabel()
                setNeedsDisplay()
            }
        }
    }
    private var iValue: CGFloat = 0.75


    // An optional UILabel to appear at the center of the circular progress view. This property can
    // be set with any UILabel instance or one can be automatically provided, then accessed and
    // customized as desired. Note that, either way, certain layout constraints are created to
    // keep the label centered. Those constraints should not be messed with.
    @IBOutlet var percentLabel: UILabel? {

        get
        {
            if iPercentLabel == nil { self.percentLabel = UILabel() }
            return iPercentLabel
        }

        set(newLabel)
        {
            if newLabel != iPercentLabel
            {
                iPercentLabel?.removeFromSuperview()
                iPercentLabel = newLabel

                if let label = iPercentLabel
                {
                    addSubview(label)

                    updateLabelFontSize()
                    label.textColor = iPercentTint

                    label.textAlignment = .Center
                    label.adjustsFontSizeToFitWidth = true
                    label.baselineAdjustment = .AlignCenters
                    label.minimumScaleFactor = 0.5

                    label.setTranslatesAutoresizingMaskIntoConstraints(false)
                    label.removeConstraints(label.constraints())

                    var constraint: NSLayoutConstraint

                    constraint = NSLayoutConstraint(item: label, attribute: .CenterX,
                        relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0)
                    addConstraint(constraint)

                    constraint = NSLayoutConstraint(item: label, attribute: .CenterY,
                        relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 0)
                    addConstraint(constraint)

                    let w = CGRectGetWidth(bounds)
                    let h = CGRectGetHeight(bounds)
                    var s = (min(w, h) - iTrackThickness) / 2
                    s *= 0.9 // Use up to 90% of the space between opposite sides of the inner circle.

                    constraint = NSLayoutConstraint(item: label, attribute: .Width,
                        relatedBy: .LessThanOrEqual, toItem: self, attribute: .Width, multiplier: 0.0, constant: s)
                    addConstraint(constraint)

                    constraint = NSLayoutConstraint(item: label, attribute: .Height,
                        relatedBy: .LessThanOrEqual, toItem: self, attribute: .Height, multiplier: 0.0, constant: s)
                    addConstraint(constraint)

                    updateLabel()
                    setNeedsDisplay()
                }
            }
        }
    }
    private var iPercentLabel: UILabel?


    override func drawRect(rect: CGRect)
    {
        let w = CGRectGetWidth(bounds)
        let h = CGRectGetHeight(bounds)
        let r = (min(w, h) - iTrackThickness) / 2
        let cp = CGPoint(x: w/2, y: h/2) // *not* 'let cp = center' because center will be in the frame's coord system!

        // Draw the full track.
        fillTrack(center: cp, radius: r, sangle: 0, eangle: CGFloat(2*M_PI),
            color: iTrackTint, thickness: iTrackThickness, clockwise: true)

        // Draw the progress track.
        var val = (iReversed ? (1 - iValue) : iValue)
        val = (iClockwise ? +iValue : -iValue)
        let clockwise = (iReversed ? !iClockwise : iClockwise)
        fillTrack(center: cp, radius: r, sangle: CGFloat(-M_PI/2), eangle: CGFloat(2*M_PI*Double(val) - M_PI/2),
            color: iProgressTint, thickness: iProgressThickness, clockwise: clockwise)
    }


    private func fillTrack(#center: CGPoint, radius: CGFloat, sangle: CGFloat, eangle: CGFloat,
        color: UIColor, thickness: CGFloat, clockwise: Bool)
    {
        color.set()
        let p = UIBezierPath()
        p.lineWidth = thickness
        p.lineCapStyle = kCGLineCapRound
        p.addArcWithCenter(center, radius: radius, startAngle: sangle, endAngle: eangle, clockwise: clockwise)
        p.stroke()
    }


    private func updateProgressThickness(value: CGFloat)
    {
        iProgressThickness = max(minProgressThickness, value)
        iProgressThickness = min(iProgressThickness, iTrackThickness)
        self.progressThicknessFraction = iProgressThickness / iTrackThickness
    }


    private func updateLabelFontSize()
    {
        if iPercentBold
        {
            iPercentLabel?.font = UIFont.boldSystemFontOfSize(iPercentSize)
        }
        else
        {
            iPercentLabel?.font = UIFont.systemFontOfSize(iPercentSize)
        }
    }


    private func updateLabel()
    {
        if let label = iPercentLabel where !label.hidden
        {
            let val = (iReversed ? (1 - iValue) : iValue)
            label.text = "\(Int(val * 100.0) % 101) %"
            label.sizeToFit()
            setNeedsLayout()
        }
    }


    #if TARGET_INTERFACE_BUILDER

    override func prepareForInterfaceBuilder()
    {
        super.prepareForInterfaceBuilder()
        percentLabel?.hidden = !showPercent
    }

    #endif
}
