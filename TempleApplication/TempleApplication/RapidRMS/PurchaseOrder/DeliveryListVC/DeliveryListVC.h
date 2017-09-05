//
//  DeliveryListView.h
//  I-RMS
//
//  Created by Siya Infotech on 06/03/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "POmenuListDelegateVC.h"

@interface DeliveryListVC : UIViewController <UIActionSheetDelegate,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
    

@property (nonatomic, weak) id<POmenuListVCDelegate> pOmenuListVCDelegate;


@end
