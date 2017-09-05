//
//  TCPBluetoothViewController.h
//  RapidRMS
//
//  Created by Siya on 10/07/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCPBluetoothViewController : UIViewController<NSFetchedResultsControllerDelegate>

@property (nonatomic, weak) IBOutlet UIButton *btnTCP;
@property (nonatomic, weak) IBOutlet UIButton *btnBluetooth;
@property (nonatomic, weak) IBOutlet UIButton *btnEditIP;
@property (weak, nonatomic) IBOutlet UIButton *btnTestPrint;

- (IBAction)TestPrint:(id)sender;
- (IBAction)btnScanClicked:(id)sender;
-(NSString *)checkIPValidation:(NSString *)string;
@end
