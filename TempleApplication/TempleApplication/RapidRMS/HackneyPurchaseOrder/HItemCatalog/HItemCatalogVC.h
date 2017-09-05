//
//  HItemCatalogVC.h
//  RapidRMS
//
//  Created by Siya on 24/12/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HItemCatalogVC : UIViewController<NSFetchedResultsControllerDelegate, UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tblCatalog;

@property (nonatomic, strong) NSString *strPoID;

@property (nonatomic, assign) BOOL isfromItem;
@property (nonatomic, assign) BOOL isFromNewRelease;

@end
