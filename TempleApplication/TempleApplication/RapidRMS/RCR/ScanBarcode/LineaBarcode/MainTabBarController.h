#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "ScannerViewController.h"
#import "DTDevices.h"

#define POS_NORMAL 0
#define POS_FLIPPED 1

@interface MainTabBarController : UITabBarController <DTDeviceDelegate,UIAccelerometerDelegate> {
	IBOutlet ScannerViewController *scannerViewController;
	IBOutlet UIViewController *settingsViewController;
	IBOutlet UIViewController *cryptoViewController;
	IBOutlet UIViewController *rfViewController;
	IBOutlet UIViewController *emsrCryptoViewController;
	IBOutlet UIViewController *printViewController;
	IBOutlet UIViewController *emvViewController;
	
	DTDevices *dtdev;
    int position;
    
    CGRect mainRect;
    CGRect tabRect;
}

@end
