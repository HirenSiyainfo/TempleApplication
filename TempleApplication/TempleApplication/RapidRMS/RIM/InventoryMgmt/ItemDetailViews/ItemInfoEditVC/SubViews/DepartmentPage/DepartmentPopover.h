//
//  I-RMS
//
//  Created by Siya Infotech on 12/09/13.
//  Copyright (c) 2013 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ItemInfoEditVC.h"

@protocol DepartmentPopoverDelegate <NSObject>

-(void)newDepartmentSelected:(NSDictionary *)addedDepatmentDict;
-(void)didChangeSelectedDepartment:(NSDictionary *)changeDepatmentDict;
@end

@interface DepartmentPopover : UIViewController

@property (nonatomic, weak) id<DepartmentPopoverDelegate> departmentPopoverDelegate;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, weak) IBOutlet UITableView * aTableView;

@property (nonatomic, strong) NSMutableArray * arrayCheckedArry;
@property (nonatomic, strong) NSMutableArray * resposeDepartmentArray;

@property (nonatomic, strong) NSString *getDeptId;
@property (nonatomic, strong) NSString *getDeptName;
@property (nonatomic, strong) NSString *checkItemType;


@end