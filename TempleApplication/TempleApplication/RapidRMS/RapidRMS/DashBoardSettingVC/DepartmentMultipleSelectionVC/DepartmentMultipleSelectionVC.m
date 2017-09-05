//
//  DepartmentMultipleSelectionVC.m
//  RapidRMS
//
//  Created by Siya on 06/04/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "DepartmentMultipleSelectionVC.h"
#import "RmsDbController.h"
#import "Department+Dictionary.h"
#import "KitchenPrinter+Dictionary.h"

@interface DepartmentMultipleSelectionVC ()
{
    MICheckBox * taxCheckBox;
}

@property (nonatomic, weak) IBOutlet UITableView *tbldepartment;

@property (nonatomic, strong) RmsDbController *rmsDbController;

@property (nonatomic, strong) NSMutableArray *resposeDepartmentArray;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation DepartmentMultipleSelectionVC
@synthesize managedObjectContext = __managedObjectContext;
@synthesize printer,strCurrentIp;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    self.resposeDepartmentArray = [[NSMutableArray alloc]init];
    [self getDepartmentList];
    self.automaticallyAdjustsScrollViewInsets=NO;
    // Do any additional setup after loading the view.
}

- (void) getDepartmentList
{
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
            NSMutableDictionary *supplierDict=[[NSMutableDictionary alloc]init];
            supplierDict[@"DepartmentName"] = departmentmst.deptName;
            supplierDict[@"DeptId"] = departmentmst.deptId;
            if(departmentmst.departmentPrinter){
                supplierDict[@"printer_ip"] = departmentmst.departmentPrinter.printer_ip;
                supplierDict[@"printerName"] = departmentmst.departmentPrinter.printer_Name;
            }
            [self.resposeDepartmentArray addObject:supplierDict];
        }
    }
    [self checkedDepartment:self.checkedDepartment];
    [self.tbldepartment reloadData];
}

-(void)checkedDepartment:(NSMutableArray *)deparmentarray{
    
    if(deparmentarray.count>0){
    
        for(int i=0;i<deparmentarray.count;i++){
            NSMutableDictionary *dictSelectedDept = deparmentarray[i];
            for(int j=0;j<self.resposeDepartmentArray.count;j++){
                NSMutableDictionary *dictSelectedDep2 = (self.resposeDepartmentArray)[j];
                if(([[dictSelectedDep2 valueForKey:@"DeptId"]integerValue] == [[dictSelectedDept valueForKey:@"DeptId"]integerValue]) && [dictSelectedDep2 valueForKey:@"printer_ip"]){
                    
                     dictSelectedDep2[@"Checked"] = @"1";
                    (self.resposeDepartmentArray)[j] = dictSelectedDep2;
                }
            }
        }
    }
    
}
#pragma mark - UITableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
    
    
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.resposeDepartmentArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCellStyle style =  UITableViewCellStyleDefault;
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"BaseCell"];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    CGRect deptNameFrame;
    CGRect printerNameFrame;
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        taxCheckBox = [[MICheckBox alloc] initWithFrame:CGRectMake(280, 14, 22, 16)];
        deptNameFrame = CGRectMake(35, 7, 150, 30);
        printerNameFrame = CGRectMake(70, 7, 150, 30);
        
    }
    else
    {
        taxCheckBox = [[MICheckBox alloc] initWithFrame:CGRectMake(560.0, 14, 22, 16)];
        deptNameFrame = CGRectMake(20, 7, 150, 30);
        printerNameFrame = CGRectMake(300.0, 7, 150, 30);
    }
    
    
    //taxCheckBox = [[MICheckBox alloc] initWithFrame:CGRectMake(5, 10, 20, 20)];
    [taxCheckBox setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [taxCheckBox setTitle:@"" forState:UIControlStateNormal];
    taxCheckBox.tag = indexPath.row;
    taxCheckBox.indexPath = [indexPath copy];
    taxCheckBox.delegate = self;
    taxCheckBox.isChecked = NO;
    [taxCheckBox setDefault];
    
    UILabel * deptname = [[UILabel alloc] initWithFrame:deptNameFrame];
    deptname.text = [NSString stringWithFormat:@"%@",[(self.resposeDepartmentArray)[indexPath.row] valueForKey:@"DepartmentName"]];
    deptname.numberOfLines = 0;
    deptname.textAlignment = NSTextAlignmentLeft;
    deptname.backgroundColor = [UIColor clearColor];
    deptname.textColor = [UIColor blackColor];
    deptname.font = [UIFont fontWithName:@"Helvetica Neue" size:14];
    [cell addSubview:deptname];
    
    NSMutableDictionary *dictTemp2 = (self.resposeDepartmentArray)[indexPath.row];

    if([dictTemp2 valueForKey:@"printerName"]){
        
        UILabel * printerName = [[UILabel alloc] initWithFrame:printerNameFrame];
        printerName.text = [NSString stringWithFormat:@"%@",[(self.resposeDepartmentArray)[indexPath.row] valueForKey:@"printerName"]];
        printerName.numberOfLines = 0;
        printerName.textAlignment = NSTextAlignmentLeft;
        printerName.backgroundColor = [UIColor clearColor];
        printerName.textColor = [UIColor blackColor];
        printerName.font = [UIFont fontWithName:@"Helvetica Neue" size:14];
        [cell addSubview:printerName];
    }
    
    if([dictTemp2[@"Checked"]intValue]==1)
    {
        dictTemp2[@"Checked"] = @"1";
        taxCheckBox.isChecked = YES;
        [taxCheckBox setImage:[UIImage imageNamed:@"soundCheckMark.png"] forState:UIControlStateNormal];
        
        deptname.textColor = [UIColor colorWithRed:0.0/255.0 green:115.0/255.0 blue:170.0/255.0 alpha:1.0];
    }
    
    for(int i = 0;i<self.checkedDepartment.count;i++)
    {
        NSMutableDictionary *dictTemp = (self.checkedDepartment)[i];
        if([dictTemp[@"DeptId"]intValue] == [dictTemp2[@"DeptId"]intValue])
        {
            dictTemp2[@"Checked"] = @"1";
            taxCheckBox.isChecked = YES;
            [taxCheckBox setImage:[UIImage imageNamed:@"soundCheckMark.png"] forState:UIControlStateNormal];
            
            deptname.textColor = [UIColor colorWithRed:0.0/255.0 green:115.0/255.0 blue:170.0/255.0 alpha:1.0];
            
            
        }
    }
    
    [cell addSubview:taxCheckBox];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    NSMutableDictionary *dictTemp = (self.resposeDepartmentArray)[indexPath.row];
    if ([dictTemp valueForKey:@"printer_ip"] && ![[dictTemp valueForKey:@"printer_ip"] isEqualToString:strCurrentIp]) {
        return;
    }
    taxCheckBox.indexPath = [indexPath copy];
    [taxCheckBox checkBoxClicked];
    [tableView reloadData];
}

#pragma mark -
#pragma mark Logic Implement

- (void) taxCheckBoxClickedAtIndex:(NSString *)index withValue:(BOOL)checked withIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *dictTemp = (self.resposeDepartmentArray)[indexPath.row];

    if(dictTemp[@"Checked"])
    {
        [dictTemp removeObjectForKey:@"Checked"];
        NSMutableDictionary *dictTemp2 = (self.resposeDepartmentArray)[indexPath.row];
        NSString *strTagString2=dictTemp2[@"DepartmentName"];
        for(int i = 0;i<self.checkedDepartment.count;i++)
        {
            NSMutableDictionary *dictTemp = (self.checkedDepartment)[i];
            NSString *strTagString=dictTemp[@"DepartmentName"];
            
            if([strTagString isEqualToString:strTagString2])
            {
                [self.checkedDepartment removeObjectAtIndex:i];
            }
        }
    }
    else
    {
        dictTemp[@"Checked"] = @"1";
    }
    (self.resposeDepartmentArray)[indexPath.row] = dictTemp;
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.checkedDepartment=[[NSMutableArray alloc]init];
    for(int i=0;i<self.resposeDepartmentArray.count;i++)
    {
        NSMutableDictionary *dict = (self.resposeDepartmentArray)[i];
        if(dict[@"Checked"]){
            [self.checkedDepartment addObject:dict];
        }
    }
    printer.selectedDeptArray = self.checkedDepartment;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
