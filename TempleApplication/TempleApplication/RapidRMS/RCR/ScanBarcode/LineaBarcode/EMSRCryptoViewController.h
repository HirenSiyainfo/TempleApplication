//
//  CryptoViewController.h
//
//  Created by Anton Rajnov on 8/31/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "ScannerViewController.h"
#import "ProgressViewController.h"

@interface EMSRCryptoViewController : UIViewController <DTDeviceDelegate,UITextFieldDelegate> {
	IBOutlet UITabBarController *mainTabBarController;
	IBOutlet ProgressViewController *progressViewController;
    IBOutlet UIView *cryptoView;
    
	IBOutlet UITextField *newAES256KeyEncryptionKey;
	IBOutlet UITextField *newAES256KeyEncryptionKeyVersion;
	IBOutlet UITextField *oldAES256KeyEncryptionKey;
    
	IBOutlet UITextField *newAES256EncryptionKey;
	IBOutlet UITextField *newAES256EncryptionKeyVersion;
    
    IBOutlet UITableView *emsrAlgorithmTable;

	DTDevices *dtdev;
}

-(IBAction)setAES256KeyEncryptionKey:(id)sender;
-(IBAction)setAES256EncryptionKey:(id)sender;
-(IBAction)setDUKPTEncryptionKey:(id)sender;
-(IBAction)getEMSRInfo:(id)sender;
-(IBAction)enterMSData:(id)sender;
-(IBAction)enterPIN:(id)sender;
@end
