//
//  NotificationViewController.h
//  POSRetail
//
//  Created by Siya Infotech on 31/12/13.
//  Copyright (c) 2013 Nirav Patel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *arrayNotification;
    NSString *strUrlUpdate;

}


@end
