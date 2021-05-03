//
//  DemoUtility.swift
//  DJISimulatorDemo
//
//  Created by Samuel Scherer on 4/30/21.
//  Copyright © 2021 Demo. All rights reserved.
//

import Foundation
import DJISDK

class DemoUtility: NSObject {//TODO: make DemoUtility a struct?
    @objc public class func show(result:String) {//TODO: convert to string once no ObjC class uses this. Also should I make this a global function like the objc original?
        DispatchQueue.main.async {
            let alertViewController = UIAlertController(title: nil, message: result as String, preferredStyle: UIAlertController.Style.alert)
            let okAction = UIAlertAction.init(title: "OK", style: UIAlertAction.Style.default, handler: nil)
            alertViewController.addAction(okAction)
            let navController = UIApplication.shared.keyWindow?.rootViewController as! UINavigationController
            navController.present(alertViewController, animated: true, completion: nil)
        }
    }
    
    @objc public class func fetchProduct () -> DJIBaseProduct? {
        return DJISDKManager.product()
    }
    
    @objc public class func fetchAircraft () -> DJIAircraft? {
        return DJISDKManager.product() as? DJIAircraft
    }
    
    @objc public class func fetchFlightController() -> DJIFlightController? {
        let aircraft = DJISDKManager.product() as? DJIAircraft
        return aircraft?.flightController
    }
}
