//
//  ReportAbuseViewController.swift
//  LifeshareApps
//
//  Created by Jacco Taal on 25/10/2018.
//  Copyright © 2018 Vidacle B.V. All rights reserved.
//

import Foundation
import UIKit
import ReactiveSwift
import ReactiveCocoa

private let localizationTable = "ReportAbuse"

@objc
public class ReportAbuseViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate {

    @objc
    public var viewModel: LSReportAbuseViewModel!

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var optionPicker: UIPickerView!
    @IBOutlet weak var messageText: UIPlaceholderTextView!
    @IBOutlet weak var sendButtonItem: UIBarButtonItem!
    @IBOutlet weak var scrollView: UIScrollView!

    override public func viewDidLoad() {
        super.viewDidLoad()
        messageText.placeholder = LSLocalizedString("report_abuse_specify_label", tableName: localizationTable, value: "")
        messageText.placeholderColor = UIColor(white: 0.5, alpha: 1.0)

        let theme = LifeshareSDK.shared().theme
        view.backgroundColor = theme.backgroundColor
        view.tintColor = theme.tintColor

        automaticallyAdjustsScrollViewInsets = true
        label.textColor = theme.foregroundColor
        messageText.textColor = theme.tintColor

        optionPicker.delegate = self
        optionPicker.dataSource = self
        let sendButtonItem = UIBarButtonItem(title: LSLocalizedString("report_abuse_submit", tableName: localizationTable), style: .done, target: nil, action: nil)
        self.sendButtonItem = sendButtonItem
        self.navigationItem.rightBarButtonItems = [sendButtonItem]
        bindViewModel()
    }

    func bindViewModel() {
        guard let viewModel = self.viewModel,
            let reportAction = viewModel.reportAction else {
            return
        }

        label.text = String(format: LSLocalizedString("report_abuse_decribe_reason_label", tableName: localizationTable), viewModel.title)
        sendButtonItem.reactive.pressed = CocoaAction(reportAction, input: ())

        reportAction.errors.observe { event in
            switch event {
            case .value(let error):
                let title = LSLocalizedString("report_abuse_submit_error_message", tableName: localizationTable)
                LifeshareSDK.shared().publish(UINotification(title, error: error))
            default:
                ()
            }
        }

        messageText.text = viewModel.reasonExplanation.value
        viewModel.reasonExplanation <~ messageText.reactive
            .continuousTextValues

        optionPicker.selectRow(viewModel.selectedReason.value, inComponent: 0, animated: false)
        viewModel.selectedReason <~ optionPicker.reactive.selections.map({ (row: Int, _: Int) -> Int in
            return row
        })
    }

    override public func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
        super.viewWillAppear(animated)
    }

    override public var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }

    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait, .landscapeLeft, .landscapeRight]
    }

    @objc
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel.reasons.count
    }

    @objc
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    @objc
    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        if view == nil {
            let lab = UILabel()
            lab.font = UIFont.systemFont(ofSize: 16)
            lab.backgroundColor = UIColor.clear
            lab.textColor = LifeshareSDK.shared().theme.tintColor
            lab.text = viewModel.localizedReason(index: row)
            return lab
        }
        (view as? UILabel)?.text = viewModel.reasons[row]
        return view!
    }

    @objc
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        messageText.becomeFirstResponder()
        scrollView.scrollRectToVisible(scrollView.convert(messageText.frame, from:messageText.superview), animated: true)
    }

    @objc
    public func textViewDidEndEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
    }
}
