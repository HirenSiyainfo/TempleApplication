//
//  HPOItemListVC.h
//  RapidRMS
//
//  Created by Siya on 25/12/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VPurchaseOrder+Dictionary.h"


@interface HPOItemListVC : UIViewController<NSFetchedResultsControllerDelegate,UpdateDelegate>

@property (nonatomic, strong) VPurchaseOrder *vPurchaseOrder;

@property (nonatomic, strong) NSString *strPoID;
@property (nonatomic, strong) NSString *UpdateDate;

@end
