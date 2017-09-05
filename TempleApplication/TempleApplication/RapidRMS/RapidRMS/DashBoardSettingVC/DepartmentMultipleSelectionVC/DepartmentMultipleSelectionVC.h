//
//  DepartmentMultipleSelectionVC.h
//  RapidRMS
//
//  Created by Siya on 06/04/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "DepartmentMultiple.h"
#import "PrinterVC.h"

@interface DepartmentMultipleSelectionVC : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) PrinterVC *printer;

@property (nonatomic, strong) NSString *strCurrentIp;

@property (nonatomic, strong) NSMutableArray *checkedDepartment;

@end
