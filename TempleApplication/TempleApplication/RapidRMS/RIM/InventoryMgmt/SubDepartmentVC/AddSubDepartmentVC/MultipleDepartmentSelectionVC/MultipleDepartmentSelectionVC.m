//
//  MultipleDepartmentSelectionVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 28/11/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "MultipleDepartmentSelectionVC.h"
#import "MultipleDepartmentCustomeCell.h"
#import "UITableViewCell+NIB.h"
#import "RmsDbController.h"
#import "Department+Dictionary.h"

@interface MultipleDepartmentSelectionVC ()

@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) RimsController * rimsController;


@end

@implementation MultipleDepartmentSelectionVC

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.rimsController = [RimsController sharedrimController];
    self.rmsDbController = [RmsDbController sharedRmsDbController];

    self.managedObjectContext = self.rmsDbController.managedObjectContext;

    NSString *strMultipleDepartmentNib;
    if(IsPhone())
    {
        strMultipleDepartmentNib = @"MultipleDepartmentCustomeCell";
    }
    else
    {
        strMultipleDepartmentNib = @"MultipleDepartmentCustomeCell_iPad";
    }
    UINib *multipleDepartmentNib = [UINib nibWithNibName:strMultipleDepartmentNib bundle:nil];
    [self.aTableView registerNib:multipleDepartmentNib forCellReuseIdentifier:@"MultipleDepartmentCustomeCell"];

    self.aTableView.allowsMultipleSelection = YES;
    if(self.arrDeptSelected == nil){
        self.arrDeptSelected = [[NSMutableArray alloc]init];
    }
   // self.resposeDepartmentArray = [[NSMutableArray alloc] init];

    [self getDepartmentList];
    [self.aTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) getDepartmentList
{
   self.resposeDepartmentArray = [[NSMutableArray alloc] init];

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Department" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;

    NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"deptName" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortDescriptors = @[aSortDescriptor];
    fetchRequest.sortDescriptors = sortDescriptors;

    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];

    if (resultSet.count > 0)
    {
        for (Department *departmentmst in resultSet) {
            NSMutableDictionary *departmentDict=[[NSMutableDictionary alloc]init];
            departmentDict[@"DepartmentName"] = departmentmst.deptName;
            departmentDict[@"DeptId"] = departmentmst.deptId;

            if (self.arrDeptSelected.count > 0) {
                for (int iDept=0; iDept < self.arrDeptSelected.count; iDept++) {
                    if ([[(self.arrDeptSelected)[iDept] valueForKey:@"DeptId"]integerValue] == [[departmentDict valueForKey:@"DeptId"]integerValue] ) {
                        if ([(self.arrDeptSelected)[iDept] valueForKey:@"Checked"])
                        {
                            departmentDict[@"Checked"] = @"1";
                        }
                    }
                }
            }
            [self.resposeDepartmentArray addObject:departmentDict];

        }
    }
}

-(IBAction)backToItemView:(id)sender
{
    self.arrayCheckedArry=[[NSMutableArray alloc]init];
    for(int i=0;i<self.resposeDepartmentArray.count;i++)
    {
        NSMutableDictionary *dict = (self.resposeDepartmentArray)[i];
        if(dict[@"Checked"]){
            [self.arrayCheckedArry addObject:dict];
        }
        else
        {
            [self.arrayCheckedArry removeObject:dict];
        }
    }
    if(self.arrayCheckedArry.count > 0)
    {
        self.arrDeptSelected = [self.arrayCheckedArry mutableCopy];
      //  self.objAddSubDepartment.arrSelectedDepartment = [self.arrDeptSelected mutableCopy];
        self.objAddSubDepartment.arrDepartment = [self.arrDeptSelected mutableCopy];


    }
    else
    {
        [self.objAddSubDepartment.arrDepartment removeAllObjects];
    }
    [self.view removeFromSuperview];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.resposeDepartmentArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MultipleDepartmentCustomeCell";
    MultipleDepartmentCustomeCell *multipleDepartmentCell = [self.aTableView dequeueReusableCellWithIdentifier:CellIdentifier];

    multipleDepartmentCell.lblDepartmentName.text = [(self.resposeDepartmentArray)[indexPath.row]valueForKey:@"DepartmentName"];


    if ([[(self.resposeDepartmentArray)[indexPath.row]valueForKey:@"Checked"] intValue] == 1) {
        multipleDepartmentCell.selectionArrow.image = [UIImage imageNamed:@"soundCheckMark.png"];
    }
    else
    {
        multipleDepartmentCell.selectionArrow.image = nil;
    }
//    if (self.arrDeptSelected.count > 0) {
//        NSMutableDictionary *departmentDict=[[NSMutableDictionary alloc]init];
//        for (int iDept=0; iDept < self.arrDeptSelected.count; iDept++) {
//            if ([[[self.arrDeptSelected objectAtIndex:iDept] valueForKey:@"DeptId"]integerValue] == [[[self.resposeDepartmentArray objectAtIndex:indexPath.row]valueForKey:@"Checked"] integerValue] ) {
//                if ([[self.arrDeptSelected objectAtIndex:iDept] valueForKey:@"Checked"])
//                {
//                    [departmentDict setObject:@"1" forKey:@"Checked"];
//                    [self.resposeDepartmentArray addObject:departmentDict];
//                }
//            }
//        }
//    }


    return multipleDepartmentCell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSMutableDictionary *dictTemp = (self.resposeDepartmentArray)[indexPath.row];
    if(dictTemp[@"Checked"])
    {
        [dictTemp removeObjectForKey:@"Checked"];
    }
    else
    {
        dictTemp[@"Checked"] = @"1";
    }
    (self.resposeDepartmentArray)[indexPath.row] = dictTemp;
    [tableView reloadData];

}



-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.objAddSubDepartment.tblAddSubDepartment reloadData];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
