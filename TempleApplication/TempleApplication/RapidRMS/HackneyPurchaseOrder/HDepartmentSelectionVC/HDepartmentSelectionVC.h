//
//  HDepartmentSelectionVC.h
//  RapidRMS
//
//  Created by Siya on 04/03/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "HItemCatalogVC.h"

@protocol DepartmentSelectionDelegate <NSObject>
- (void)didselectinoDeparment:(NSString *)strDept withIndexpath:(NSIndexPath *)indpath;

@end

@interface HDepartmentSelectionVC : HItemCatalogVC
@property (nonatomic, weak) id<DepartmentSelectionDelegate> departmentSelectionDelegate
;
@property (nonatomic, strong) NSIndexPath *indcatalog;
@property (nonatomic, strong) NSIndexPath *indCategory;
@end
