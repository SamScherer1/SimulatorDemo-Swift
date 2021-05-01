//
//  RootViewController.swift
//  DJISimulatorDemo
//
//  Created by Samuel Scherer on 4/30/21.
//  Copyright © 2021 Demo. All rights reserved.
//

import Foundation
import UIKit
import DJISDK


//TODO: consider breaking out Delegate methods in extension
class RootViewController : UIViewController, DJISDKManagerDelegate {
    var product : DJIBaseProduct?
    @IBOutlet weak var connectStatusLabel: UILabel!
    @IBOutlet weak var modelNameLabel: UILabel!
    @IBOutlet weak var connectButton: UIButton!
    
    override func viewDidAppear(_ animated: Bool) {
//    [super viewDidAppear:animated];
        super.viewDidAppear(animated)
//
//    //Please enter the App Key in info.plist file to register the app.
//    [DJISDKManager registerAppWithDelegate:self];
        DJISDKManager.registerApp(with: self)
        if let product = self.product {
            self .updateStatusBasedOn(product)
        }
    }

    override func viewDidLoad() {
//    [super viewDidLoad];
//    [self initUI];
        self.initUI()
        super.viewDidLoad()
    }

    func initUI() {
        self.title = "DJISimulator Demo"
        self.modelNameLabel.isHidden = true
        //Disable the connect button by default
        self.connectButton.isEnabled = false
    }

//MARK: - DJISDKManager Delegate Methods
    func appRegisteredWithError(_ error: Error?) {
        if let error = error {
    //        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    //        //[DemoUtility showAlertViewWithTitle:nil message:[NSString stringWithFormat:@"Registration Error:%@", error] cancelAlertAction:cancelAction defaultAlertAction:nil viewController:self];
            DemoUtility.show(result: "Registration Error: \(error)")
    //        [self.connectButton setEnabled:NO];
            self.connectButton.isEnabled = false
            return
        }
        DJISDKManager.startConnectionToProduct()
    }

//MARK: DJIBaseProductDelegate Method
//- (void)productConnected:(DJIBaseProduct *)product {
    func productConnected(_ product: DJIBaseProduct?) {
        if let product = product {
            self.product = product
            self.connectButton.isEnabled = true
        } else {
//
//        NSString* message = [NSString stringWithFormat:@"Connection lost. Back to root."];
            let message = "Connection lost. Back to root."
//
//        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
//        UIAlertAction *backAction = [UIAlertAction actionWithTitle:@"Back" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            if (![self.navigationController.topViewController isKindOfClass:[RootViewController class]]) {
//                [self.navigationController popToRootViewControllerAnimated:NO];
//            }
//        }];
            //TODO: add actions to alert
            let cancelAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil)
            let backAction = UIAlertAction(title: "Back", style: UIAlertAction.Style.default) { (action:UIAlertAction) in
                if let topVC = self.navigationController?.topViewController {
                    if topVC.isKind(of: RootViewController.self) {
                        self.navigationController?.popToRootViewController(animated: false)
                    }
                }
            }
            //[DemoUtility showAlertViewWithTitle:nil message:message cancelAlertAction:cancelAction defaultAlertAction:backAction viewController:self];
            //TODO use cancel and back...
            DemoUtility.show(result: message)
            self.connectButton.isEnabled = false
            self.product = nil
        }
//
//    [self updateStatusBasedOn:product];
        self.updateStatusBasedOn(product)
//
//    //If this demo is used in China, it's required to login to your DJI account to activate the application. Also you need to use DJI Go app to bind the aircraft to your DJI account. For more details, please check this demo's tutorial.
        //TODO: implement login
//    [[DJISDKManager userAccountManager] logIntoDJIUserAccountWithAuthorizationRequired:NO withCompletion:^(DJIUserAccountState state, NSError * _Nullable error) {
//        if (error) {
//            NSLog(@"Login failed: %@", error.description);
//        }
//    }];
        
    }

    func updateStatusBasedOn(_ newConnectedProduct:DJIBaseProduct?) {
        if let product = newConnectedProduct {
            self.connectStatusLabel.text = "Status: Product Connected"
            self.modelNameLabel.text = "Model: \(product.model ?? "Not Available")"
            self.modelNameLabel.isHidden = false
        } else {
            //        self.connectStatusLabel.text = NSLocalizedString(@"Status: Product Not Connected", @"");
            self.connectStatusLabel.text = "Status: Product Not Connected"
            //        self.modelNameLabel.text = NSLocalizedString(@"Model: Unknown", @"");
            self.modelNameLabel.text = "Model: Unknown"
        }
    }
    
    func didUpdateDatabaseDownloadProgress(_ progress: Progress) {
        //TODO: Unused?
    }
}
