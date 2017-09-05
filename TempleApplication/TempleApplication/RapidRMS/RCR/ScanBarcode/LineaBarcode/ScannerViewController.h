#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import "ProgressViewController.h"
#import "DTDevices.h"

@interface ScannerViewController : UIViewController <DTDeviceDelegate> {
    
	IBOutlet UIButton *scanButton;
	IBOutlet UITextView *displayText;
	IBOutlet UITextView *debugText;
	IBOutlet UIImageView *statusImage;
	IBOutlet ProgressViewController *progressViewController;
    IBOutlet UIButton *batteryButton;
    IBOutlet UITextField *numBarcodesField;
	IBOutlet UITabBarController *mainTabBarController;
    IBOutlet UIButton *printButton;
	
	NSMutableString *status;
	NSMutableString *debug;	

	DTDevices *dtdev;
}

-(void)debug:(NSString *)text;

-(IBAction)scanDown:(id)sender;
-(IBAction)scanUp:(id)sender;
-(IBAction)onBattery:(id)sender;
-(IBAction)onPrint:(id)sender;

@property (assign) bool suspendDisplayInfo;

@end

ScannerViewController *scannerViewController;

#ifdef SHOWERR
#undef SHOWERR
#endif
#define SHOWERR(func) func; if(error)[scannerViewController debug:error.localizedDescription];
#define ERRMSG(title) {UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]; [alert show];}

