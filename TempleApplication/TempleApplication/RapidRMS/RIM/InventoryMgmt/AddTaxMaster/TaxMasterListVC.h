//
//  TaxMasterListVC.h
//  RapidRMS
//
//  Created by Siya Infotech on 25/09/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SideMenuVCDelegate.h"

@interface TaxMasterListVC : UIViewController<NSFetchedResultsControllerDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, weak) id<SideMenuVCDelegate> sideMenuVCDelegate;

@end
