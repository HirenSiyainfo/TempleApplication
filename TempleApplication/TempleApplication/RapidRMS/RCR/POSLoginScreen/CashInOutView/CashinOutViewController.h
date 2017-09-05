//
//  CashinOutViewController.h
//  POSRetail
//
//  Created by Nirav Patel on 08/11/12.
//  Copyright (c) 2012 Nirav Patel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@class POSLoginView;

@class ReportViewController;

@interface CashinOutViewController : UIViewController<UIPopoverPresentationControllerDelegate>
{
  
}

-(void)cashinoutButtonEnable;
-(void)cashinoutButtonDisable;
- (void)resetCashInOutView;

@end
