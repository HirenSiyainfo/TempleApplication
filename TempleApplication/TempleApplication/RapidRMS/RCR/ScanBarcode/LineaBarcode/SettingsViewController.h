#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "ScannerViewController.h"
#import "ProgressViewController.h"

@interface SettingsViewController : UIViewController <DTDeviceDelegate,UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,UITextFieldDelegate> {
	IBOutlet UITableView *settingsTable;
	IBOutlet ProgressViewController *progressViewController;

	DTDevices *dtdev;
    
    int progressPhase;
    int progressPercent;
    
    NSMutableArray *btDevices;
    int firmareTarget;
    NSString *firmwareFile;
    NSMutableArray *firmwareUpdates;
}


@property(assign) NSInteger scanMode;

@end
