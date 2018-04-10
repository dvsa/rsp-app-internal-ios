//
//  MailHelper.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Yue Chen on 19/03/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation
import MessageUI

class MailHelper: NSObject, MFMailComposeViewControllerDelegate {
    let hostViewController: UIViewController
    var onMailSent: ((MFMailComposeResult, NSError?) -> Void)?

    init(hostViewController: UIViewController) {
        self.hostViewController = hostViewController
    }

    func showSendLogMailViewController() {
        if MFMailComposeViewController.canSendMail() {
            let mailComposerVC = MFMailComposeViewController()

            mailComposerVC.mailComposeDelegate = self
            if let supportEmail = Environment.supportEmail,
                supportEmail.isValidEmail() {
                mailComposerVC.setToRecipients([supportEmail])
            }

            mailComposerVC.setSubject("Send log data to support")
            let version  = SettingsBundleManager.version()
            mailComposerVC.setMessageBody("DVSA Payments \(version).\nLog files are attached in the e-mail.", isHTML: false)
            mailComposerVC.modalPresentationStyle = .fullScreen

            if let files = logFiles() {
                for file in files {
                    if let fileData = try? Data(contentsOf: file) {
                        mailComposerVC.addAttachmentData(fileData, mimeType: "text/plain", fileName: file.lastPathComponent)
                    }
                }
            }
            self.hostViewController.present(mailComposerVC, animated: true) {
                UIApplication.shared.statusBarStyle = .lightContent
            }
        } else {
            let alert = UIAlertController(title: "Cannot send e-mail",
                                          message: "This device has not been setup for sending e-mail.",
                                          preferredStyle: UIAlertControllerStyle.alert)

            let defaultAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
            alert.addAction(defaultAction)
            self.hostViewController.present(alert, animated: true, completion: nil)
        }
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.hostViewController.dismiss(animated: true, completion: nil)
        self.onMailSent?(result, error as NSError?)
    }
}
