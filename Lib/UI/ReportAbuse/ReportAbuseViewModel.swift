//
//  LSReportAbuseViewModel.swift
//  LifeshareApps
//
//  Created by Jacco Taal on 19-09-18.
//  Copyright © 2018 Vidacle B.V. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import ReactiveObjCBridge

private var localizationTable = "ReportAbuse"

public struct FormError: Error {
    let reason: String
    let underlying: Error?

    static let reasonTooShort = FormError(reason: LSLocalizedString("report_abuse_error_abuse_reason_too_short", tableName: localizationTable, value: "Specified reason is too short. Use more words"), underlying: nil)

    static func submissionFailed(underlying: Error?) -> FormError {
        return FormError(reason: LSLocalizedString("report_abuse_report_failed_message", tableName: localizationTable, value: "Submission failed"), underlying: underlying)
    }
}

@objc
final public class LSReportAbuseViewModel: NSObject, ViewModel {

    public let video: LSVideoModel

    public let reasons: [String]
    public func localizedReason(index: Int) -> String {
        return LSLocalizedString("report_abuse_" + reasons[index].replacingOccurrences(of: "-", with: "_") + "_label", tableName: localizationTable)
    }

    public let selectedReason: MutableProperty<Int>

    public let reasonExplanation: ValidatingProperty<String?, FormError>

    public var title: String

    public var reportAction: Action<Void, Void, FormError>! = nil

    @objc
    public convenience init(with video: LSVideoModel, index: Int, of: Int) {
        self.init(with: video, description: String(format: LSLocalizedString("report_abuse_video_i_of_n", tableName: localizationTable), String(index + 1), String(of)))
    }

    @objc
    public init(with video: LSVideoModel, description: String? = nil) {
        self.video = video
        self.title = video.title ?? description ?? "-"
        let reasons = [
            "explicit-content",
            //"copyright-infringement",
            "extremely-violent-content",
            "portrait-rights-violation",
            "other-reason",
            "insufficient-quality"
        ]
        self.reasons = reasons
        selectedReason = MutableProperty(0)
        reasonExplanation = ValidatingProperty(nil, { value in
            return ( value != nil && !value!.isEmpty ) ? .valid : .invalid(FormError.reasonTooShort)
        })

        super.init()

        self.reportAction = Action(enabledIf: reasonExplanation.result.map({ result in !result.isInvalid}),
                                   execute: { _ in
            return SignalProducer({[weak self] observer, _ in

                guard let `self` = self,
                    let explanation = self.reasonExplanation.value else {
                    return
                }

                let parameters: [String: String] = [
                    "model": "video",
                    "model_id": video.id,
                    "reason": reasons[self.selectedReason.value],
                    "description": explanation
                ]

                LSApiClient.sharedInstance().postPath("report/abuse", parameters: parameters, success: { _, _ in
                    LifeshareSDK.shared().publish(title: LSLocalizedString("report_abuse_report_success_message", tableName: localizationTable))
                    observer.sendCompleted()
                }, failure: { _, error in
                    if let error = error {
                        LifeshareSDK.shared().publish(UINotification(LSLocalizedString("report_abuse_report_failed_message", tableName: localizationTable), error: error))
                    }
                    observer.send(error: .submissionFailed(underlying: error))
                })
            })
        })
    }
}
