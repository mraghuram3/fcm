import Foundation
import Capacitor
import UserNotifications

import FirebaseMessaging
import FirebaseCore
import FirebaseInstanceID


/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitor.ionicframework.com/docs/plugins/ios
 *
 * Created by Stewan Silva on 1/23/19.
 */
@objc(FCM)
public class FCM: CAPPlugin, MessagingDelegate {
    
    public override func load() {
        // if (FirebaseApp.app() == nil) {
        //   FirebaseApp.configure();
        // }
        Messaging.messaging().delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(self.didRegisterWithToken(notification:)), name: Notification.Name(CAPNotifications.DidRegisterForRemoteNotificationsWithDeviceToken.name()), object: nil)
    }
    
    @objc func didRegisterWithToken(notification: NSNotification) {
        guard let deviceToken = notification.object as? Data else {
            return
        }
        Messaging.messaging().apnsToken = deviceToken
    }
    
    @objc func subscribeTo(_ call: CAPPluginCall) {
        let topicName = call.getString("topic") ?? ""
        Messaging.messaging().subscribe(toTopic: topicName) { error in
            // print("Subscribed to weather topic")
            if ((error) != nil) {
                print("ERROR while trying to subscribe topic \(topicName)")
                call.error("Can't subscribe to topic \(topicName)")
            }else{
                call.success([
                    "message": "subscribed to topic \(topicName)"
                    ])
            }
        }
    }
    
    @objc func unsubscribeFrom(_ call: CAPPluginCall) {
        let topicName = call.getString("topic") ?? ""
        Messaging.messaging().unsubscribe(fromTopic: topicName) { error in
            if ((error) != nil) {
                call.error("Can't unsubscribe from topic \(topicName)")
            }else{
                call.success([
                    "message": "unsubscribed from topic \(topicName)"
                    ])
            }
        }
    }
    
    @objc func getToken(_ call: CAPPluginCall) {
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                call.error("Failed to get instance FirebaseID", error)
            } else {
                call.success([
                    "token": result?.token
                ]);
            }
        }
    }
    
    @objc func deleteInstance(_ call: CAPPluginCall) {
        InstanceID.instanceID().deleteID { error in
            if let error = error {
                call.error("Cant delete Firebase Instance ID", error)
            } else {
                call.success();
            }
        }
    }

    @objc func initConfig(_ call: CAPPluginCall) {
        let env = call.getString("env") ?? ""
        var configFilepath: String?
            switch env {
            case "eu":
                configFilepath = Bundle.main.path(forResource: "GoogleService-Info-EU", ofType: "plist")
            case "dev":
                configFilepath = Bundle.main.path(forResource: "GoogleService-Info-Dev", ofType: "plist")
            default:
                configFilepath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist")
            }
        guard let config = FirebaseOptions(contentsOfFile: configFilepath!) else {
            assert(false, "Unable to load Firebase config file")
            return
        }
        if (FirebaseApp.app() == nil) {
            FirebaseApp.configure(options: config);
        }
    }

}
