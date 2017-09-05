//
//  PrintSettings.h
//  POSFrontEnd
//
//  Created by Minesh Purohit on 10/02/12.
//  Copyright 2012 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PickerPopup.h"

@interface PrintSettings : UIViewController {
	IBOutlet UITextField * txtIPAddress;
	IBOutlet UITextField * txtPort;
	IBOutlet UIButton * btnSave;
	
	PickerPopup *pickerpopup_alignment;
}

- (IBAction) savePrintSetting:(id)sender;

@end
