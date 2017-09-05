//
//  HItemProductVC.h
//  RapidRMS
//
//  Created by Siya on 25/12/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VPurchaseOrderItem+Dictionary.h"
#import "HDepartmentSelectionVC.h"

@interface HItemProductVC : UIViewController<NSFetchedResultsControllerDelegate,UpdateDelegate,DepartmentSelectionDelegate>

@property (nonatomic, strong) NSString *strCatelog;
@property (nonatomic, strong) NSString *strCategory;
@property (nonatomic, strong) NSString *strUPC;
@property (nonatomic, strong) NSString *strPoId;

@property (nonatomic, assign) BOOL isfromItem;
@property (nonatomic, assign) BOOL isFromNewRelease;

@property (nonatomic, strong) NSIndexPath *indpathCatalog;
@property (nonatomic, strong) NSIndexPath *indpathCategory;

@end
