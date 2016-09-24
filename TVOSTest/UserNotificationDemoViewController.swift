//
//  UserNotificationDemoViewController.swift
//  TVOSTest
//
//  Created by toshi0383 on 7/20/16.
//  Copyright © 2016 Toshihiro Suzuki. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications

class UserNotificationDemoViewController: UIViewController, UNUserNotificationCenterDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNotification()
    }

    @IBAction func updateBadge(sender: UIButton) {
        UIApplication.shared.applicationIconBadgeNumber = 1234
    }

    @IBAction func sendNotification(sender: UIButton) {
        UNUserNotificationCenter.current().getPendingNotificationRequests {
            requests in
            print("pendingNotificationRequests: \(requests)")
        }
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

        let content = UNMutableNotificationContent()
        content.badge = 2
        let sec: Int = 5
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(sec), repeats: false)
        let req = UNNotificationRequest(identifier: "hello", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(req) {
            error in
            guard error == nil else {fatalError()}
            let msg = L10n.notificationMessage(sec).string
            let alert = UIAlertController(title: "Info", message: msg, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .cancel)
            alert.addAction(action)
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

    // MARK: - UNUserNotificationCenterDelegate
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }

    // MARK: - Utilities
    func setupNotification() {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            granted, error in
            print(error)
            print(granted)
        }
    }

}
