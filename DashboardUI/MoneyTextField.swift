//
//  MoneyTextField.swift
//  Dashboard
//
//  Created by Ben Guo on 6/22/16.
//  Copyright © 2016 Stripe. All rights reserved.
//

import UIKit

@IBDesignable
public class MoneyTextField: UIControl, UITextViewDelegate, InternalTextViewDelegate {
    @IBInspectable
    public var amount: UInt {
        get {
            var number = NSDecimalNumber(string: self.rawString, locale: self.locale)
            if !self.isNoDecimalCurrency {
                number = number.decimalNumberByMultiplyingByPowerOf10(self.superUnitPowerOf10)
            }
            return UInt(number.integerValue)
        }
        set(newAmount) {
            let number = NSDecimalNumber(integer: Int(newAmount))
            self.rawString = self.formatNumber(number,
                                               convertToSuperUnit: !self.isNoDecimalCurrency,
                                               hideCentsIfZero: false)
            self.refreshAttributedString()
        }
    }
    @IBInspectable
    public var currency: String = "usd" {
        didSet(oldValue) {
            var localeInfo = [NSLocaleCurrencyCode: self.currency]
            if let language = NSLocale.preferredLanguages().first {
                localeInfo[NSLocaleLanguageCode] = language
            }
            let localeID = NSLocale.localeIdentifierFromComponents(localeInfo)
            let locale = NSLocale(localeIdentifier: localeID)
            self.locale = locale
            self.numberFormatter = self.numberFormatter(locale)
            var number = NSDecimalNumber(string: self.rawString, locale: locale)
            if !oldValue.isNoDecimalCurrency {
                number = number.decimalNumberByMultiplyingByPowerOf10(self.superUnitPowerOf10)
            }
            let amount = UInt(number.integerValue)
            self.amount = amount
        }
    }
    public var amountString: String {
        let number = NSDecimalNumber(integer: Int(self.amount))
        return self.formatNumber(number,
                                 usesGroupingSeparator: true,
                                 convertToSuperUnit: !self.isNoDecimalCurrency,
                                 hideCentsIfZero: self.isNoDecimalCurrency,
                                 hideCurrencySymbol: false)
    }
    @IBInspectable
    public var usesGroupingSeparator: Bool = true {
        didSet {
            self.refreshAttributedString()
        }
    }
    @IBInspectable
    public var borderColor: UIColor = UIColor(white: 0.85, alpha: 1) {
        didSet { self.layer.borderColor = self.borderColor.CGColor }
    }
    @IBInspectable
    public var borderWidth: CGFloat = 1 {
        didSet { self.layer.borderWidth = self.borderWidth }
    }
    @IBInspectable
    public var cornerRadius: CGFloat = 5 {
        didSet { self.layer.cornerRadius = self.cornerRadius }
    }
    public var largeFont: UIFont = UIFont.systemFontOfSize(58) {
        didSet { self.refreshAttributedString() }
    }
    public var smallFont: UIFont = UIFont.systemFontOfSize(37) {
        didSet { self.refreshAttributedString() }
    }
    @IBInspectable
    public var numberColor: UIColor = UIColor.blackColor() {
        didSet { self.refreshAttributedString() }
    }
    @IBInspectable
    public var currencySymbolColor: UIColor = UIColor(white: 0.54, alpha: 1) {
        didSet { self.refreshAttributedString() }
    }
    override public var tintColor: UIColor! {
        didSet {
            self.internalTextView.tintColor = self.tintColor
        }
    }

    /// MoneyTextField constrains text to its width, with margins defined by `inset`.
    /// This property also affects the size returned by `sizeThatFits`.
    @IBInspectable
    public var inset: CGFloat = 16

    private var currentEdgeInsets: UIEdgeInsets {
        let textSize = self.internalTextView.bounds.size
        let verticalInset = (self.bounds.size.height - textSize.height)/2.0
        let horizontalInset = (self.bounds.size.width - textSize.height)/2.0
        return UIEdgeInsetsMake(verticalInset, horizontalInset, verticalInset, horizontalInset)
    }
    private var numberFormatter = NSNumberFormatter()
    private var locale = NSLocale.currentLocale()
    private func numberFormatter(locale: NSLocale) -> NSNumberFormatter {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        formatter.locale = locale
        formatter.usesGroupingSeparator = true
        if formatter.minimumFractionDigits == 0 {
            formatter.minimumFractionDigits = 2
        }
        if self.isNoDecimalCurrency {
            formatter.minimumFractionDigits = 0
        }
        return formatter
    }
    private var decimalSeparator: String {
        return self.numberFormatter.decimalSeparator
    }
    private var currencySymbol: String {
        return self.numberFormatter.currencySymbol
    }
    private var isNoDecimalCurrency: Bool {
        return self.currency.isNoDecimalCurrency
    }
    private var superUnitPowerOf10: Int16 {
        return Int16(self.numberFormatter.minimumFractionDigits)
    }
    private var zero: String {
        let number = NSDecimalNumber(integer: 0)
        return self.formatNumber(number, convertToSuperUnit: false, hideCentsIfZero: true)
    }
    private var rawString = "0"
    private let internalTextView = InternalTextView()
    private let tapGestureRecognizer = UITapGestureRecognizer()

    public init(amount: UInt, currency: String) {
        super.init(frame: CGRectZero)
        self.setup(amount, currency: currency)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup(0, currency: "usd")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup(0, currency: "usd")
    }

    private func setup(amount: UInt, currency: String) {
        self.currency = currency
        self.amount = amount
        self.internalTextView.delegate = self
        self.internalTextView.internalTextViewDelegate = self
        self.layer.borderColor = self.borderColor.CGColor
        self.layer.borderWidth = self.borderWidth
        self.layer.cornerRadius = self.cornerRadius
        self.backgroundColor = UIColor(white: 0.97, alpha: 1)
        self.addSubview(self.internalTextView)
        self.tapGestureRecognizer.addTarget(self, action: #selector(tapped))
        self.addGestureRecognizer(self.tapGestureRecognizer)
    }

    @objc private func tapped() {
        self.internalTextView.becomeFirstResponder()
    }

    private func refreshAttributedString() {
        self.internalTextView.attributedText = self.attributedString(self.rawString)
    }

    private func split(amountString: String) -> (String, String?) {
        var integerPart = amountString
        var fractionalPart: String? = nil
        if let decimalRange = amountString.rangeOfString(self.decimalSeparator) {
            integerPart = String(amountString.characters.prefixUpTo(decimalRange.startIndex))
            fractionalPart = String(amountString.characters.suffixFrom(decimalRange.endIndex))
        }
        if integerPart.characters.isEmpty {
            integerPart = self.zero
        }
        return (integerPart, fractionalPart)
    }

    private func attributedString(amountString: String) -> NSAttributedString {
        let baselinePoints = self.largeFont.pointSize - self.smallFont.pointSize
        // not sure why this multiplier is necessary (baseline offset is in points),
        // but it scales well for different font sizes.
        let baselineOffset = baselinePoints*0.7
        let smallAttributes = [
            NSBaselineOffsetAttributeName: baselineOffset,
            NSFontAttributeName: self.smallFont
        ]
        var currencyAttributes = smallAttributes
        currencyAttributes[NSForegroundColorAttributeName] = self.currencySymbolColor
        var fractionalAttributes = smallAttributes
        fractionalAttributes[NSForegroundColorAttributeName] = self.numberColor
        let integerAttributes = [
            NSFontAttributeName: self.largeFont,
            NSForegroundColorAttributeName: self.numberColor
        ]
        let string = NSMutableAttributedString(string: self.numberFormatter.currencySymbol,
                                               attributes: currencyAttributes)
        string.addAttribute(NSKernAttributeName, value: 4,
                            range: NSMakeRange(string.length - 1, 1))
        let (integerPart, fractionalPart) = self.split(amountString)
        if integerPart.characters.count > 0 {
            let number = NSDecimalNumber(string: integerPart.sanitize(),
                                         locale: self.locale)
            let formatted = self.formatNumber(number,
                                              usesGroupingSeparator: self.usesGroupingSeparator,
                                              convertToSuperUnit: false,
                                              hideCentsIfZero: true)
            let integer = NSAttributedString(string: formatted,
                                             attributes: integerAttributes)
            string.appendAttributedString(integer)
        }
        if let fractional = fractionalPart {
            // using a space rather than kerning in order to make the caret resize
            let spaceAttributes = [NSFontAttributeName: UIFont.systemFontOfSize(10)]
            let space = NSAttributedString(string: " ", attributes: spaceAttributes)
            string.appendAttributedString(space)
            let fraction = NSAttributedString(string: fractional,
                                              attributes: fractionalAttributes)
            string.appendAttributedString(fraction)
        }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .Center
        string.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, string.length))
        return string
    }

    private func formatNumber(number: NSDecimalNumber,
                              usesGroupingSeparator: Bool = false,
                              convertToSuperUnit: Bool,
                              hideCentsIfZero: Bool,
                              hideCurrencySymbol: Bool = true) -> String {
        let minimumFractionDigits = self.numberFormatter.minimumFractionDigits
        defer {
            self.numberFormatter.minimumFractionDigits = minimumFractionDigits
        }
        self.numberFormatter.minimumFractionDigits = hideCentsIfZero ? 0 : minimumFractionDigits
        self.numberFormatter.usesGroupingSeparator = usesGroupingSeparator
        var superUnits = number
        if convertToSuperUnit {
            superUnits = number.decimalNumberByMultiplyingByPowerOf10(-self.superUnitPowerOf10)
        }
        guard let string = self.numberFormatter.stringFromNumber(superUnits) else {
            return number.stringValue
        }
        if hideCurrencySymbol {
            let comps = string.componentsSeparatedByString(self.numberFormatter.currencySymbol)
            return comps.joinWithSeparator("")
        }
        else {
            return string
        }
    }

    private var hasDecimalSeparator: Bool {
        return self.rawString.rangeOfString(self.decimalSeparator) != nil
    }

    override public func becomeFirstResponder() -> Bool {
        return self.internalTextView.becomeFirstResponder()
    }

    override public func resignFirstResponder() -> Bool {
        return self.internalTextView.resignFirstResponder()
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        let size = self.internalTextView.sizeThatFits(CGSizeMake(self.bounds.width, 0))
        self.internalTextView.frame = CGRectMake(0, 0, self.bounds.width, size.height)
        self.internalTextView.center = CGPointMake(self.bounds.midX, self.bounds.midY)
    }

    override public func sizeThatFits(size: CGSize) -> CGSize {
        let width = self.internalTextView.attributedText.size().width + self.inset*2
        let height = self.largeFont.height + self.inset*2
        return CGSizeMake(width, height)
    }

    // MARK: InternalTextViewDelegate
    private func internalTextView(textView: InternalTextView, modifiedCaretRect rect: CGRect) -> CGRect {
        var newRect = rect
        var topInset = self.currentEdgeInsets.top
        if topInset < 0 {
            topInset = self.inset - topInset
        }
        newRect.origin = CGPointMake(rect.origin.x, topInset)
        if self.hasDecimalSeparator {
            newRect.size = CGSizeMake(rect.width, self.smallFont.height)
        }
        else {
            newRect.size = CGSizeMake(rect.width, self.largeFont.height)
        }
        return newRect
    }

    // MARK: UITextViewDelegate
    public func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        var newRawString = self.rawString
        let deleting = range.location == textView.text.characters.count - 1 && range.length == 1 && text == ""
        if deleting {
            if newRawString.characters.count > 0 {
                var lastIndex = newRawString.endIndex.predecessor()
                // delete over the decimal separator
                if String(newRawString[lastIndex]) == self.decimalSeparator &&
                    newRawString.characters.count > 1 {
                    lastIndex = lastIndex.predecessor()
                }
                newRawString = newRawString.substringToIndex(lastIndex)
                if newRawString.characters.isEmpty {
                    newRawString = self.zero
                }
            }
        }
        else {
            if text == self.decimalSeparator && !self.hasDecimalSeparator && !self.isNoDecimalCurrency {
                newRawString = newRawString + self.decimalSeparator
            }
            else {
                let (integerPart, fractionalPart) = self.split(newRawString)
                let sanitized = text.sanitize()
                if let fractional = fractionalPart {
                    if fractional.characters.count < self.numberFormatter.minimumFractionDigits {
                        newRawString = integerPart + self.decimalSeparator + fractional + sanitized
                    }
                }
                else {
                    newRawString = integerPart + sanitized
                }
            }
        }
        let attrString = self.attributedString(newRawString)
        let newWidth = attrString.size().width + self.inset*2.0
        if newWidth < self.bounds.width && newRawString != self.rawString {
            textView.attributedText = attrString
            self.rawString = newRawString
            self.sendActionsForControlEvents(.ValueChanged)
        }
        return false
    }

}

private protocol InternalTextViewDelegate {
    func internalTextView(textView: InternalTextView, modifiedCaretRect rect: CGRect) -> CGRect
}

private class InternalTextView: UITextView, UITextViewDelegate {
    var internalTextViewDelegate: InternalTextViewDelegate?

    init() {
        super.init(frame: CGRectZero, textContainer: nil)
        self.scrollEnabled = false
        self.keyboardType = .DecimalPad
        self.textAlignment = .Natural
        self.userInteractionEnabled = false
        self.backgroundColor = UIColor.clearColor()
        self.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func caretRectForPosition(position: UITextPosition) -> CGRect {
        let rect = super.caretRectForPosition(position)
        if let delegate = self.internalTextViewDelegate {
            return delegate.internalTextView(self, modifiedCaretRect:rect)
        }
        else {
            return rect
        }
    }
}

private extension String {
    var isNoDecimalCurrency: Bool {
        let currencies = ["bif", "clp","djf","gnf",
                          "jpy","kmf","krw","mga","pyg","rwf","vnd",
                          "vuv","xaf","xof","xpf"]
        return currencies.contains(self.lowercaseString)
    }

    func sanitize() -> String {
        let set = NSCharacterSet.decimalDigitCharacterSet()
        let components = self.componentsSeparatedByCharactersInSet(set.invertedSet)
        return components.joinWithSeparator("")
    }
}

private extension UIFont {
    var height: CGFloat {
        let string: NSString = "0"
        let rect = string.boundingRectWithSize(CGSizeZero,
                                               options: .UsesDeviceMetrics,
                                               attributes: [NSFontAttributeName: self],
                                               context: nil)
        return rect.size.height
    }
}
