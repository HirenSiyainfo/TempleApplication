//
//  POSLoginView.h
//  POSFrontEnd
//
//  Created by Minesh Purohit on 12/11/11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CashinOutViewController.h"
#import "ReportViewController.h"
#import "AppDelegate.h"
#import "BackGroundVc.h"

@protocol LoginResultDelegate <NSObject>

-(void)openSettingView;
-(void)cancelSettingView;
- (void)userDidLogin:(NSMutableDictionary *)user;
- (void)customerLoyalty;
@end


@interface POSLoginView : BackGroundVc <UIPopoverControllerDelegate, UpdateDelegate> {
}

@property (nonatomic, weak) id<LoginResultDelegate> loginResultDelegate;

@property (nonatomic,weak) IBOutlet UITextField *displayText;

@property (nonatomic) BOOL isInvoiceCustomerRights;
-(IBAction) checkIsAvailableCashInOut:(id)sender;
-(void) sideBarbuttonActionHandler:(id)sender;
-(IBAction) pressKeyPadButton:(id)sender;
-(void) highlightSideButton:(id)sender;
-(void) resetButtonImage;
-(IBAction)btnUserLoginClick:(id)sender;
-(IBAction) dobtnSignin:(id)sender;
-(IBAction) doQuickLogin:(id)sender;
-(void) hideAllSubViewOfSlideBar;

@end
