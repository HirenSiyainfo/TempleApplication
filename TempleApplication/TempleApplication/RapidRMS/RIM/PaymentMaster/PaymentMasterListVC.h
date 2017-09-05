//
//  PaymentMasterListVC.h
//  RapidRMS
//
//  Created by siya-IOS5 on 9/25/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SideMenuVCDelegate.h"


@interface PaymentMasterListVC : UIViewController<NSFetchedResultsControllerDelegate>
@property (nonatomic, weak) id<SideMenuVCDelegate> sideMenuVCDelegate;

@end
