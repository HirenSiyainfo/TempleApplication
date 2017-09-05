//
//  SupplierInventoryView.h
//  I-RMS
//
//  Created by Siya Infotech on 11/01/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SideMenuVCDelegate.h"
@interface SupplierInventoryVC : UIViewController <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, weak) id<SideMenuVCDelegate> sideMenuVCDelegate;

@end
