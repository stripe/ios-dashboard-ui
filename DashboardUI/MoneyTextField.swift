//
//  MoneyTextField.swift
//  Dashboard
//
//  Created by Ben Guo on 6/22/16.
//  Copyright © 2016 Stripe. All rights reserved.
//

import UIKit

@IBDesignable
open class MoneyTextField: UIControl, UITextViewDelegate, InternalTextViewDelegate {
    @IBInspectable
    open var amount: UInt {
        get {
            var number = NSDecimalNumber(string: self.rawString, locale: self.locale)
            if !self.currency.stp_isNoDecimalCurrency {
                let handler = NSDecimalNumberHandler(roundingMode: .plain,
                                                     scale: 0,
                                                     raiseOnExactness: false,
                                                     raiseOnOverflow: false,
                                                     raiseOnUnderflow: false,
                                                     raiseOnDivideByZero: false)
                number = number.multiplying(byPowerOf10: 2, withBehavior: handler)
            }
            if number.stp_isNAN() {
                return 0
            } else {
                return UInt(number.intValue)
            }
        }
        set(newAmount) {
            let number = NSDecimalNumber(value: Int(newAmount) as Int)
            self.rawString = self.formatNumber(number,
                                               convertToSuperUnit: !self.isNoDecimalCurrency,
                                               hideCentsIfZero: false)
            self.refreshAttributedString()
        }
    }
    @IBInspectable
    open var currency: String = "usd" {
        didSet(oldValue) {
            var localeInfo = [NSLocale.Key.currencyCode.rawValue: self.currency]
            if let language = Locale.preferredLanguages.first {
                localeInfo[NSLocale.Key.languageCode.rawValue] = language
            }
            let localeID = Locale.identifier(fromComponents: localeInfo)
            let locale = Locale(identifier: localeID)
            self.locale = locale
            self.numberFormatter = self.numberFormatter(locale)
            var number = NSDecimalNumber(string: self.rawString, locale: locale)
            if !oldValue.stp_isNoDecimalCurrency {
                number = number.multiplying(byPowerOf10: self.superUnitPowerOf10)
            }
            let amount = UInt(number.intValue)
            self.amount = amount
        }
    }
    open var amountString: String {
        let number = NSDecimalNumber(value: Int(self.amount) as Int)
        return self.formatNumber(number,
                                 usesGroupingSeparator: true,
                                 convertToSuperUnit: !self.isNoDecimalCurrency,
                                 hideCentsIfZero: self.isNoDecimalCurrency,
                                 hideCurrencySymbol: false)
    }
    @IBInspectable
    open var usesGroupingSeparator: Bool = true {
        didSet {
            self.refreshAttributedString()
        }
    }
    @IBInspectable
    open var borderColor: UIColor = UIColor(white: 0.85, alpha: 1) {
        didSet { self.layer.borderColor = self.borderColor.cgColor }
    }
    @IBInspectable
    open var borderWidth: CGFloat = 1 {
        didSet { self.layer.borderWidth = self.borderWidth }
    }
    @IBInspectable
    open var cornerRadius: CGFloat = 5 {
        didSet { self.layer.cornerRadius = self.cornerRadius }
    }
    open var largeFont: UIFont = UIFont.systemFont(ofSize: 58) {
        didSet { self.refreshAttributedString() }
    }
    open var smallFont: UIFont = UIFont.systemFont(ofSize: 37) {
        didSet { self.refreshAttributedString() }
    }
    @IBInspectable
    open var numberColor: UIColor = UIColor.black {
        didSet { self.refreshAttributedString() }
    }
    @IBInspectable
    open var currencySymbolColor: UIColor = UIColor(white: 0.54, alpha: 1) {
        didSet { self.refreshAttributedString() }
    }
    override open var tintColor: UIColor! {
        didSet {
            self.internalTextView.tintColor = self.tintColor
        }
    }

    /// MoneyTextField constrains text to its width, with margins defined by `inset`.
    /// This property also affects the size returned by `sizeThatFits`.
    @IBInspectable
    open var inset: CGFloat = 16

    fileprivate var currentEdgeInsets: UIEdgeInsets {
        let textSize = self.internalTextView.bounds.size
        let verticalInset = (self.bounds.size.height - textSize.height)/2.0
        let horizontalInset = (self.bounds.size.width - textSize.height)/2.0
        return UIEdgeInsets(top: verticalInset, left: horizontalInset, bottom: verticalInset, right: horizontalInset)
    }
    fileprivate var numberFormatter = NumberFormatter()
    fileprivate var locale = Locale.current
    fileprivate func numberFormatter(_ locale: Locale) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.currency
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
    fileprivate var decimalSeparator: String {
        return self.numberFormatter.decimalSeparator
    }
    fileprivate var currencySymbol: String {
        return self.numberFormatter.currencySymbol
    }
    fileprivate var isNoDecimalCurrency: Bool {
        return self.currency.stp_isNoDecimalCurrency
    }
    fileprivate var superUnitPowerOf10: Int16 {
        return Int16(self.numberFormatter.minimumFractionDigits)
    }
    fileprivate var zero: String {
        let number = NSDecimalNumber(value: 0 as Int)
        return self.formatNumber(number, convertToSuperUnit: false, hideCentsIfZero: true)
    }
    fileprivate var rawString = "0"
    fileprivate let internalTextView = InternalTextView()
    fileprivate let tapGestureRecognizer = UITapGestureRecognizer()

    public init(amount: UInt, currency: String) {
        super.init(frame: CGRect.zero)
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

    fileprivate func setup(_ amount: UInt, currency: String) {
        self.currency = currency
        self.amount = amount
        self.internalTextView.delegate = self
        self.internalTextView.internalTextViewDelegate = self
        self.layer.borderColor = self.borderColor.cgColor
        self.layer.borderWidth = self.borderWidth
        self.layer.cornerRadius = self.cornerRadius
        self.backgroundColor = UIColor(white: 0.97, alpha: 1)
        self.addSubview(self.internalTextView)
        self.tapGestureRecognizer.addTarget(self, action: #selector(tapped))
        self.addGestureRecognizer(self.tapGestureRecognizer)
    }

    @objc fileprivate func tapped() {
        self.internalTextView.becomeFirstResponder()
    }

    fileprivate func refreshAttributedString() {
        self.internalTextView.attributedText = self.attributedString(self.rawString)
    }

    fileprivate func split(_ amountString: String) -> (String, String?) {
        var integerPart = amountString
        var fractionalPart: String? = nil
        if let decimalRange = amountString.range(of: self.decimalSeparator) {
            integerPart = String(amountString.prefix(upTo: decimalRange.lowerBound))
            fractionalPart = String(amountString.suffix(from: decimalRange.upperBound))
        }
        if integerPart.isEmpty {
            integerPart = self.zero
        }
        return (integerPart, fractionalPart)
    }

    fileprivate func attributedString(_ amountString: String) -> NSAttributedString {
        let baselinePoints = self.largeFont.pointSize - self.smallFont.pointSize
        // not sure why this multiplier is necessary (baseline offset is in points),
        // but it scales well for different font sizes.
        let baselineOffset = baselinePoints*0.7
        let smallAttributes: [NSAttributedString.Key : Any]?
        smallAttributes = [
            .baselineOffset: baselineOffset,
            .font: self.smallFont
        ]
        var currencyAttributes = smallAttributes
        currencyAttributes![.foregroundColor] = self.currencySymbolColor
        var fractionalAttributes = smallAttributes
        fractionalAttributes![.foregroundColor] = self.numberColor
        let integerAttributes: [NSAttributedString.Key : Any]?
        integerAttributes = [
            .font: self.largeFont,
            .foregroundColor: self.numberColor
        ]
        let string = NSMutableAttributedString(string: self.numberFormatter.currencySymbol,
                                               attributes: currencyAttributes)
        string.addAttribute(.kern, value: 4,
                            range: NSRange(location: string.length - 1, length: 1))
        let (integerPart, fractionalPart) = self.split(amountString)
        if integerPart.count > 0 {
            let number = NSDecimalNumber(string: integerPart.stp_sanitize(),
                                         locale: self.locale)
            let formatted = self.formatNumber(number,
                                              usesGroupingSeparator: self.usesGroupingSeparator,
                                              convertToSuperUnit: false,
                                              hideCentsIfZero: true)
            let integer = NSAttributedString(string: formatted,
                                             attributes: integerAttributes)
            string.append(integer)
        }
        if let fractional = fractionalPart {
            // using a space rather than kerning in order to make the caret resize
            let spaceAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10)]
            let space = NSAttributedString(string: " ", attributes: spaceAttributes)
            string.append(space)
            let fraction = NSAttributedString(string: fractional,
                                              attributes: fractionalAttributes)
            string.append(fraction)
        }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        string.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: string.length))
        return string
    }

    fileprivate func formatNumber(_ number: NSDecimalNumber,
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
            superUnits = number.multiplying(byPowerOf10: -self.superUnitPowerOf10)
        }
        guard let string = self.numberFormatter.string(from: superUnits) else {
            return number.stringValue
        }
        if hideCurrencySymbol {
            let comps = string.components(separatedBy: self.numberFormatter.currencySymbol)
            return comps.joined(separator: "")
        }
        else {
            return string
        }
    }

    fileprivate var hasDecimalSeparator: Bool {
        return self.rawString.range(of: self.decimalSeparator) != nil
    }

    override open func becomeFirstResponder() -> Bool {
        return self.internalTextView.becomeFirstResponder()
    }

    override open func resignFirstResponder() -> Bool {
        return self.internalTextView.resignFirstResponder()
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        let size = self.internalTextView.sizeThatFits(CGSize(width: self.bounds.width, height: 0))
        self.internalTextView.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: size.height)
        self.internalTextView.center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
    }

    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        let width = self.internalTextView.attributedText.size().width + self.inset*2
        let height = self.largeFont.stp_height + self.inset*2
        return CGSize(width: width, height: height)
    }

    // MARK: InternalTextViewDelegate
    fileprivate func internalTextView(_ textView: InternalTextView, modifiedCaretRect rect: CGRect) -> CGRect {
        var newRect = rect
        var topInset = self.currentEdgeInsets.top
        if topInset < 0 {
            topInset = self.inset - topInset
        }
        newRect.origin = CGPoint(x: rect.origin.x, y: topInset)
        if self.hasDecimalSeparator {
            newRect.size = CGSize(width: rect.width, height: self.smallFont.stp_height)
        }
        else {
            newRect.size = CGSize(width: rect.width, height: self.largeFont.stp_height)
        }
        return newRect
    }

    // MARK: UITextViewDelegate
    open func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        var newRawString = self.rawString
        let deleting = range.location == textView.text.count - 1 && range.length == 1 && text == ""
        if deleting {
            if newRawString.count > 0 {
                var lastIndex = newRawString.index(before: newRawString.endIndex)
                // delete over the decimal separator
                if String(newRawString[lastIndex]) == self.decimalSeparator &&
                    newRawString.count > 1 {
                    lastIndex = newRawString.index(before: lastIndex)
                }
                newRawString = String(newRawString[..<lastIndex])
                if newRawString.isEmpty {
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
                let sanitized = text.stp_sanitize()
                if let fractional = fractionalPart {
                    if fractional.count < self.numberFormatter.minimumFractionDigits {
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
            self.sendActions(for: .valueChanged)
        }
        return false
    }

}

private protocol InternalTextViewDelegate {
    func internalTextView(_ textView: InternalTextView, modifiedCaretRect rect: CGRect) -> CGRect
}

private class InternalTextView: UITextView, UITextViewDelegate {
    var internalTextViewDelegate: InternalTextViewDelegate?

    init() {
        super.init(frame: CGRect.zero, textContainer: nil)
        self.isScrollEnabled = false
        self.keyboardType = .decimalPad
        self.textAlignment = .natural
        self.isUserInteractionEnabled = false
        self.backgroundColor = UIColor.clear
        self.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func caretRect(for position: UITextPosition) -> CGRect {
        let rect = super.caretRect(for: position)
        if let delegate = self.internalTextViewDelegate {
            return delegate.internalTextView(self, modifiedCaretRect:rect)
        }
        else {
            return rect
        }
    }
}

private extension String {
    var stp_isNoDecimalCurrency: Bool {
        let currencies = ["bif", "clp","djf","gnf",
                          "jpy","kmf","krw","mga","pyg","rwf","vnd",
                          "vuv","xaf","xof","xpf"]
        return currencies.contains(self.lowercased())
    }

    func stp_sanitize() -> String {
        let set = CharacterSet.decimalDigits
        let components = self.components(separatedBy: set.inverted)
        return components.joined(separator: "")
    }
}

private extension UIFont {
    var stp_height: CGFloat {
        let string: NSString = "0"
        let rect = string.boundingRect(with: CGSize.zero,
                                               options: .usesDeviceMetrics,
                                               attributes: [.font: self],
                                               context: nil)
        return rect.size.height
    }
}

private extension NSDecimalNumber {
    func stp_isZero() -> Bool {
        return NSDecimalNumber.zero.isEqual(to: self)
    }

    func stp_isNAN() -> Bool {
        return NSDecimalNumber.notANumber.isEqual(to: self)
    }
}
