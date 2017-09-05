//
//  HItemCategoriesVC.h
//  RapidRMS
//
//  Created by Siya on 25/12/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HItemCategoriesVC : UIViewController<NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSString *strCatalog;
@property (nonatomic, strong) NSString *strPoID;

@property (nonatomic, assign) BOOL isfromItem;
@property (nonatomic, assign) BOOL isFromNewRelease;

@property (nonatomic, strong) NSIndexPath *indCategory;
@property (nonatomic, strong) NSIndexPath *indCatalog;

@end
