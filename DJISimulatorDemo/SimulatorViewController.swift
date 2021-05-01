//
//  SimulatorViewController.swift
//  DJISimulatorDemo
//
//  Created by Samuel Scherer on 5/1/21.
//  Copyright © 2021 Demo. All rights reserved.

/**
 *  This file demonstrates how to use the advanced set of methods in DJIFlightController to control the aircraft and how to start the simulator.
 *
 *  Through DJIFlightController, user can make the aircraft enter the virtual stick mode. In this mode, SDK gives the flexibility for user to control the aircraft just like controlling it using the virtual stick. There are different combinations to control the aircraft in the
 *  virtual stick mode. In this sample, we will control the horizontal movement by velocity. For more information about the virtual stick, please refer to the Flight Controller guide page on https://developer.dji.com/mobile-sdk/documentation/introduction/component-guide-flightController.html.
 *
 *  Through the simulator object in DJIFlightController, user can test the flight controller interfaces and Mission Manager without PC. In this sample, we will start/stop the simulator and display the aircraft's state during the simulation.
 *
 */

import Foundation
import UIKit
import DJISDK

class SimulatorViewController : UIViewController, DJISimulatorDelegate {
    
    //@property(nonatomic, weak) IBOutlet VirtualStickView *virtualStickLeft;
    //@property(nonatomic, weak) IBOutlet VirtualStickView *virtualStickRight;
    @IBOutlet weak var virtualStickLeft: VirtualStickView!
    @IBOutlet weak var virtualStickRight: VirtualStickView!
    
    //@property (weak, nonatomic) IBOutlet UIButton *simulatorButton;
    //@property (weak, nonatomic) IBOutlet UILabel *simulatorStateLabel;
    @IBOutlet weak var simulatorButton: UIButton!
    @IBOutlet weak var simulatorStateLabel: UILabel!

    //@property (assign, nonatomic) BOOL isSimulatorOn;
    //@property (assign, nonatomic) float mXVelocity;
    //@property (assign, nonatomic) float mYVelocity;
    //@property (assign, nonatomic) float mYaw;
    //@property (assign, nonatomic) float mThrottle;
    var isSimulatorOn = false
    var mXVelocity : Float = 0.0
    var mYVelocity : Float = 0.0
    var mYaw : Float = 0.0
    var mThrottle : Float = 0.0

    //MARK: - Inherited Methods
    override func viewDidLoad() {
        //    [super viewDidLoad];
        super.viewDidLoad()
        //
        //    self.title = @"DJISimulator Demo";
        self.title = "DJISimulator Demo"
        //
        //    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onStickChangedWith(notification:)),
                                               name: NSNotification.Name("StickChanged"),
                                               object: nil)
        //    [notificationCenter addObserver: self
        //                           selector: @selector (onStickChanged:)
        //                               name: @"StickChanged"
        //                             object: nil];
    }

    //
    //-(void)viewWillAppear:(BOOL)animated {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //    DJIFlightController* fc = [DemoUtility fetchFlightController];
        //    if (fc && fc.simulator) {
        //        self.isSimulatorOn = fc.simulator.isSimulatorActive;
        //        [self updateSimulatorUI];
        //
        //        [fc.simulator addObserver:self forKeyPath:@"isSimulatorActive" options:NSKeyValueObservingOptionNew context:nil];
        //        [fc.simulator setDelegate:self];
        //    }
        if let flightController = DemoUtility.fetchFlightController(), let simulator = flightController.simulator {
            self.isSimulatorOn = simulator.isSimulatorActive
            self.updateSimulatorUI()
            
            simulator.addObserver(self, forKeyPath: "isSimulatorActive", options: NSKeyValueObservingOptions.new, context: nil)
            simulator.delegate = self
        }
    }

    //
    //-(void)viewWillDisappear:(BOOL)animated {
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //    DJIFlightController* fc = [DemoUtility fetchFlightController];
        //    if (fc && fc.simulator) {
        //        [fc.simulator removeObserver:self forKeyPath:@"isSimulatorActive"];
        //        [fc.simulator setDelegate:nil];
        //    }
        if let flightController = DemoUtility.fetchFlightController(), let simulator = flightController.simulator {
            simulator.removeObserver(self, forKeyPath: "isSimulatorActive")
            simulator.delegate = nil
        }
    }

    //MARK: - Custom Methods
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let change = change, keyPath == "isSimulatorActive" {
            //self.isSimulatorOn = Bool(change[NSKeyValueChangeNewKey])
            self.isSimulatorOn = change[NSKeyValueChangeKey.newKey] as? Bool ?? false
            self.updateSimulatorUI()
        }
    }

    func updateSimulatorUI() {
        if !self.isSimulatorOn {
            self.simulatorButton.setTitle("Start Simulator", for: UIControl.State.normal)
            self.simulatorStateLabel.isHidden = true
        } else {
            self.simulatorButton.setTitle("Stop Simulator", for: UIControl.State.normal)
        }
    }
    
    
    //TODO: refactor these enter/exit methods?
    @IBAction func onEnterVirtualStickControlButtonClicked(_ sender: Any) {
    //    DJIFlightController* fc = [DemoUtility fetchFlightController];
    //    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        if let flightController = DemoUtility.fetchFlightController() {
            flightController.yawControlMode = .angularVelocity
            //        fc.rollPitchControlMode = DJIVirtualStickRollPitchControlModeVelocity;
            flightController.rollPitchControlMode = .velocity

    //        [fc setVirtualStickModeEnabled:YES withCompletion:^(NSError * _Nullable error) {
            flightController.setVirtualStickModeEnabled(true) { (error:Error?) in
                if let error = error {
                    //[DemoUtility showAlertViewWithTitle:nil message:[NSString stringWithFormat:@"Enter Virtual Stick Mode: %@", error.description] cancelAlertAction:cancelAction defaultAlertAction:nil viewController:target];
                    DemoUtility.show(result: "Enter Virtual Stick Mode: \(error.localizedDescription)")
                } else {
    //                //[DemoUtility showAlertViewWithTitle:nil message:@"Enter Virtual Stick Mode:Succeeded" cancelAlertAction:cancelAction defaultAlertAction:nil viewController:target];
                    DemoUtility.show(result: "Enter Virtual Stick Mode: Succeeded")
                }
            }
        } else {
            //[DemoUtility showAlertViewWithTitle:nil message:@"Component not exist." cancelAlertAction:cancelAction defaultAlertAction:nil viewController:self];
            DemoUtility.show(result: "Component does not exist.")
        }
    }
    

    @IBAction func onExitVirtualStickControlButtonClicked(_ sender: Any) {
    //    DJIFlightController* fc = [DemoUtility fetchFlightController];
    //    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        if let flightController = DemoUtility.fetchFlightController() {
            //        [fc setVirtualStickModeEnabled:NO withCompletion:^(NSError * _Nullable error) {
            flightController.setVirtualStickModeEnabled(false) { (error:Error?) in
                if let error = error {
                    //                //[DemoUtility showAlertViewWithTitle:nil message:[NSString stringWithFormat:@"Exit Virtual Stick Mode: %@", error.description] cancelAlertAction:cancelAction defaultAlertAction:nil viewController:target];
                    DemoUtility.show(result: "Exit Virtual Stick Mode: \(error.localizedDescription)")
                } else {
                    //                //[DemoUtility showAlertViewWithTitle:nil message:@"Exit Virtual Stick Mode:Succeeded" cancelAlertAction:cancelAction defaultAlertAction:nil viewController:target];
                    DemoUtility.show(result: "Exit Virtual Stick Mode:Succeeded")
                }
            }
        } else {
            //        //[DemoUtility showAlertViewWithTitle:nil message:@"Component not exist." cancelAlertAction:cancelAction defaultAlertAction:nil viewController:self];
            DemoUtility.show(result: "Component does not exist.")
        }
    }
    
    @IBAction func onSimulatorButtonClicked(_ sender: Any) {
        //    DJIFlightController* fc = [DemoUtility fetchFlightController];
        //    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
        //    if (fc && fc.simulator) {

        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        guard let flightController = DemoUtility.fetchFlightController() else {
            print("Failed to fetch flightController")
            return
        }
        guard let simulator = flightController.simulator else {
            print("Failed to fetch simulator")
            return
        }
        if !self.isSimulatorOn {
//            // The initial aircraft's position in the simulator.
            let location = CLLocationCoordinate2DMake(22, 113)
            simulator.start(withLocation: location, updateFrequency: 20, gpsSatellitesNumber: 10) { (error:Error?) in
                if let error = error {
                    //[DemoUtility showAlertViewWithTitle:nil message:[NSString stringWithFormat:@"Start simulator error: %@", error.description] cancelAlertAction:cancelAction defaultAlertAction:nil viewController:target];
                    DemoUtility.show(result: "Start simulator error: \(error.localizedDescription)")
                } else {
                    //[DemoUtility showAlertViewWithTitle:nil message:@"Start Simulator succeeded." cancelAlertAction:cancelAction defaultAlertAction:nil viewController:target];
                    DemoUtility.show(result: "Start simulator succeeded.")
                }
            }
        } else {
            simulator.stop() { (error:Error?) in
                if let error = error {
                    //[DemoUtility showAlertViewWithTitle:nil message:[NSString stringWithFormat:@"Start simulator error: %@", error.description] cancelAlertAction:cancelAction defaultAlertAction:nil viewController:target];
                    DemoUtility.show(result: "Stop simulator error: \(error.localizedDescription)")
                } else {
                    //[DemoUtility showAlertViewWithTitle:nil message:@"Start Simulator succeeded." cancelAlertAction:cancelAction defaultAlertAction:nil viewController:target];
                    DemoUtility.show(result: "Stop simulator succeeded.")
                }
            }
        }
    }

    @IBAction func onTakeoffButtonClicked(_ sender: Any) {
    //    DJIFlightController* fc = [DemoUtility fetchFlightController];
    //    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    //
    //    if (fc) {
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        guard let flightController = DemoUtility.fetchFlightController() else {
            //[DemoUtility showAlertViewWithTitle:nil message:@"Component not exist." cancelAlertAction:cancelAction defaultAlertAction:nil viewController:self];
            print("Failed to fetch flightController")
            return
        }

        flightController.startTakeoff { (error:Error?) in
            if let error = error {
                //[DemoUtility showAlertViewWithTitle:nil message:[NSString stringWithFormat:@"Takeoff: %@", error.description] cancelAlertAction:cancelAction defaultAlertAction:nil viewController:target];
                DemoUtility.show(result: "Takeoff \(error.localizedDescription)")

            } else {
                //[DemoUtility showAlertViewWithTitle:nil message:@"Takeoff Success." cancelAlertAction:cancelAction defaultAlertAction:nil viewController:target];
                DemoUtility.show(result: "Takeoff Success.")
            }
        }
    }

    //- (IBAction)onLandButtonClicked:(id)sender {
    @IBAction func onLandButtonClicked(_ sender: Any) {
        //TODO:!
        //    DJIFlightController* fc = [DemoUtility fetchFlightController];
        //    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
        //
        //    if (fc) {
        //        WeakRef(target);
        //        [fc startLandingWithCompletion:^(NSError * _Nullable error) {
        //            WeakReturn(target);
        //            if (error) {
        //                //[DemoUtility showAlertViewWithTitle:nil message:[NSString stringWithFormat:@"AutoLand : %@", error.description] cancelAlertAction:cancelAction defaultAlertAction:nil viewController:target];
        //
        //            } else {
        //                //[DemoUtility showAlertViewWithTitle:nil message:@"AutoLand Started." cancelAlertAction:cancelAction defaultAlertAction:nil viewController:target];
        //            }
        //        }];
        //    }
        //    else
        //    {
        //        //[DemoUtility showAlertViewWithTitle:nil message:@"Component not exist." cancelAlertAction:cancelAction defaultAlertAction:nil viewController:self];
        //    }
        
    }

    @objc func onStickChangedWith(notification:NSNotification) {
        //    NSDictionary *dict = [notification userInfo];
        let userInfoDictionary = notification.userInfo
        //    NSValue *vdir = [dict valueForKey:@"dir"];
        guard let directionValue = userInfoDictionary?["dir"] as? NSValue else {
            print("Failed to get directionValue from stick changed notification")
            return
        }
        //    CGPoint dir = [vdir CGPointValue];
        let directionPoint = directionValue.cgPointValue
        if let virtualStick = notification.object as? VirtualStickView {
            if virtualStick === self.virtualStickLeft {
                self.set(throttle: Float(directionPoint.y), yaw: Float(directionPoint.x))
            } else {
                self.set(xVelocity: Float(directionPoint.x), yVelocity: Float(directionPoint.y))
            }
        }
    }

    func set(throttle:Float, yaw:Float) {
        self.mThrottle = throttle * -2
        self.mYaw = yaw * 30
        self.updateVirtualStick()
    }
    
    func set(xVelocity:Float, yVelocity:Float) {
        self.mXVelocity = xVelocity * 10.0
        self.mYVelocity = yVelocity * 10.0
        self.updateVirtualStick()
    }

    func updateVirtualStick() {
        let controlData = DJIVirtualStickFlightControlData(pitch: self.mYVelocity,
                                                           roll: self.mXVelocity,
                                                           yaw: self.mYaw,
                                                           verticalThrottle: self.mThrottle)
        if let flightController = DemoUtility.fetchFlightController(), let _ = flightController.simulator {
            flightController.send(controlData, withCompletion: nil)
        }
    }

    //MARK: - DJI Simulator Delegate
    func simulator(_ simulator: DJISimulator, didUpdate state: DJISimulatorState) {
        self.simulatorStateLabel.isHidden = false
        self.simulatorStateLabel.text = String(format:"Yaw: %0.2f Pitch: %0.2f, Roll: %0.2f\n PosX: %0.2f PosY: %0.2f PosZ: %0.2f", state.yaw, state.pitch, state.roll, state.positionX, state.positionY, state.positionZ)
    }
}
