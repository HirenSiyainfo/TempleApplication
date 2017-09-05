//
//  rimDepartmentVC.h
//  RapidRMS
//
//  Created by Siya Infotech on 07/10/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SideMenuVCDelegate.h"

@interface RimDepartmentVC : UIViewController <NSFetchedResultsControllerDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, weak) id<SideMenuVCDelegate> sideMenuVCDelegate;

@end
