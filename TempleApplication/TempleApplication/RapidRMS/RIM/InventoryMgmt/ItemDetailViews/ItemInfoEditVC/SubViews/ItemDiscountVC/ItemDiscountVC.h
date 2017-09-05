//
//  ItemDiscountVC.h
//  RapidRMS
//
//  Created by Siya Infotech on 16/07/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ItemInfoDataObject.h"
typedef NS_ENUM(NSInteger, DiscountSection)
{
    DiscountSectionNoPOS,
    DiscountSectionDescountscheme,
    DiscountSectionQTYDescount,
    DiscountSectionMMDescount
};
@interface ItemDiscountVC : UIViewController<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,UIPopoverControllerDelegate>

@property (nonatomic, strong) ItemInfoDataObject * itemInfoDataObject;

@property (nonatomic, weak) IBOutlet UITableView *tblDiscountDetails;

@end
