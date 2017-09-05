//
//  ItemInfoPopupVC.h
//  RapidRMS
//
//  Created by Siya9 on 03/05/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopupSuperVC.h"

#define ItemInfoPopupVCNumOfProduct @"numOfProduct"
#define ItemInfoPopupVCAddedQTY @"addedQTY"
#define ItemInfoPopupVCTotalCost @"totalCost"

@interface ItemInfoPopupVC : PopupSuperVC

@property (nonatomic, strong) NSDictionary * dictItemInfo;

@end
