//
//  ColseOrderDetailVC.h
//  RapidRMS
//
//  Created by Siya9 on 18/05/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExportPopupVC.h"

@interface ColseOrderDetailVC : UIViewController

@property (nonatomic, strong) NSArray * arrItemOrderList;
@property (nonatomic, strong) NSDictionary * dictInventoryMain;
@property (nonatomic, weak) id<ExportPopupVCDelegate> popupVCdelegate;
@property (nonatomic) NSInteger tag;
@end
