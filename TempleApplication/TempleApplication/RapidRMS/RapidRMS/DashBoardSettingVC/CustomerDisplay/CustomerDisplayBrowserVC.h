//
//  PosBrowserVC.h
//  CustomerDisplayApp
//
//  Created by Siya Infotech on 02/04/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DashBoardSettingVC.h"

@protocol CustomerDisplayBrowserVCDelegate <NSObject>

- (void)serviceSelected:(NSNetService*)selectedService;

@end

@interface CustomerDisplayBrowserVC : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) id<CustomerDisplayBrowserVCDelegate> browserDelegate;
@property (nonatomic, strong) DashBoardSettingVC *dashCustomer;


@end
