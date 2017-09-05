//
//  rimDepartmentVC.h
//  RapidRMS
//
//  Created by Siya Infotech on 07/10/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SideMenuVCDelegate.h"

@interface SubDepartmentVC : UIViewController <NSFetchedResultsControllerDelegate,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>

@property (nonatomic, weak) id<SideMenuVCDelegate> sideMenuVCDelegate;

@end
