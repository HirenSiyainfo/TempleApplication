//
//  HDepartment.h
//  RapidRMS
//
//  Created by Siya on 09/02/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPurchaseOrderVC.h"

@interface HDepartment : UIViewController<NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) HPurchaseOrderVC *hpurchaseOrder;

@end
