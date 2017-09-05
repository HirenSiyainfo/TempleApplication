//
//  PurchaseOrderFilterViewController.m
//  RapidRMS
//
//  Created by Siya on 13/08/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "PurchaseOrderFilterVC.h"
#import "GenerateOrderView.h"
#import "PurchaseOrderFilterListDetail.h"
#import "RmsDbController.h"
#import "Department+Dictionary.h"
#import "SupplierMaster+Dictionary.h"
#import "SupplierCompany+Dictionary.h"
#import "PurchaseOrderFilterListDetail.h"
#import "ManualFilterOptionViewController.h"

@interface PurchaseOrderFilterVC ()
{
    IntercomHandler *intercomHandler;
}

@property (nonatomic, weak) IBOutlet UITableView *tblDepartment;
@property (nonatomic, weak) IBOutlet UITableView *tblSupplier;

@property (nonatomic, weak) IBOutlet UIView *viewManualOption;
@property (nonatomic, weak) IBOutlet UIView *viewDepartment;
@property (nonatomic, weak) IBOutlet UIView *viewSupplier;

@property (nonatomic, weak) IBOutlet UIButton *btnDept;
@property (nonatomic, weak) IBOutlet UIButton *btnSupp;
@property (nonatomic, weak) IBOutlet UIButton *btnManual;
@property (nonatomic, weak) IBOutlet UIButton *btnIntercom;

@property (nonatomic, weak) IBOutlet UILabel *lblDate;

@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) ManualFilterOptionViewController *objManualOption;

@property (nonatomic, strong) NSMutableArray *arrrDeptLocalCopy;
@property (nonatomic, strong) NSMutableArray *arrrSuppLocalCopy;

@property (nonatomic, strong) NSString *strPredicateDept;
@property (nonatomic, strong) NSString *strPredicateSupp;
@property (nonatomic, strong) NSString *strDeptIdList;
@property (nonatomic, strong) NSString *strSuppIdList;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;


@end

@implementation PurchaseOrderFilterVC

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
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
         _viewDepartment.hidden=YES;
         _btnDept.selected=NO;
    }
    else{
         _viewDepartment.hidden=NO;
         _btnDept.selected=YES;
    }
   
    _viewSupplier.hidden=YES;
   
    [_viewManualOption setHidden:YES];
    [self updateDateLabels];
    
    self.arrrDeptLocalCopy=[self.arrayDepartment mutableCopy];
    self.arrrSuppLocalCopy=[self.arraySupplier mutableCopy];

    
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    
    /*if([self.arrayDepartment count]>0)
    {
 
    }
    if([self.arraySupplier count]>0){
        
    }*/
    
    [self.tblDepartment reloadData];
    [self.tblSupplier reloadData];
    intercomHandler = [[IntercomHandler alloc] initWithButtton:_btnIntercom withViewController:self];
    // Do any additional setup after loading the view from its nib.
}

- (void)updateDateLabels
{
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MMMM dd, yyyy";
    _lblDate.text = [formatter stringFromDate:date];
}

-(IBAction)departmentClick:(id)sender{
    [Appsee addEvent:kPOFilterMenuDepartment];
    _viewDepartment.hidden=NO;
    _viewSupplier.hidden=YES;
    [self.tblDepartment reloadData];
    
    _viewManualOption.hidden=YES;
    
    [_btnDept setSelected:YES];
    [_btnSupp setSelected:NO];
    [_btnManual setSelected:NO];
}
-(IBAction)supplierClick:(id)sender{
    [Appsee addEvent:kPOFilterMenuSupplier];
    _viewDepartment.hidden=YES;
    _viewSupplier.hidden=NO;
    _viewManualOption.hidden=YES;
    
    [self.tblSupplier reloadData];
    [_btnDept setSelected:NO];
    [_btnSupp setSelected:YES];
    [_btnManual setSelected:NO];
}


-(IBAction)manualOptionClick:(id)sender{
    [Appsee addEvent:kPOFilterMenuManualOption];
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        self.objManualOption  = [[ManualFilterOptionViewController alloc]initWithNibName:@"ManualFilterOptionViewController_iPhone" bundle:nil];
        self.objManualOption.arrayMainPurchaseOrderList=[self.arrmainPurchaseOrderList mutableCopy];

    }
    else{
        
        self.objManualOption  = [[ManualFilterOptionViewController alloc]initWithNibName:@"ManualFilterOptionViewController" bundle:nil];
        self.objManualOption.arrayMainPurchaseOrderList=[self.arrmainPurchaseOrderList mutableCopy];
 
    }
    
    self.objManualOption.manualOption=YES;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        if ([UIScreen mainScreen].bounds.size.height>480.0f)
        {
            
        }
        else
        {
        
            _viewManualOption.frame=CGRectMake(0, 0, _viewManualOption.frame.size.width, 431);
            _viewManualOption.backgroundColor=[UIColor redColor];
             self.objManualOption.view.frame=CGRectMake(0, 0, self.objManualOption.view.frame.size.width, 431);
        }
    }
    
    [_viewManualOption addSubview:self.objManualOption.view];
    _viewManualOption.hidden=NO;
    _viewDepartment.hidden=YES;
    _viewSupplier.hidden=YES;
    
    [_btnDept setSelected:NO];
    [_btnSupp setSelected:NO];
    [_btnManual setSelected:YES];
}


#pragma mark - UITableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    if(tableView == self.tblDepartment)
        return self.arrayDepartment.count;
    else if(tableView == self.tblSupplier)
        return self.arraySupplier.count;
    else
        return 1;

}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCellStyle style =  UITableViewCellStyleDefault;
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"BaseCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    if(tableView == self.tblDepartment)
    {
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
         cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UILabel *lbltemp = (UILabel *)[cell viewWithTag:500];
        [lbltemp removeFromSuperview];
        
        
        UIImageView *imgTemp = (UIImageView *)[cell viewWithTag:502];
        [imgTemp removeFromSuperview];
        
        NSMutableDictionary *dictDept = (self.arrayDepartment)[indexPath.row];

    
        UILabel *lbldept = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 0, 120, 44.0)];
        lbldept.textAlignment = NSTextAlignmentLeft;
        lbldept.backgroundColor = [UIColor clearColor];
        lbldept.font = [UIFont fontWithName:@"Helvetica Neue" size:14];
        
        if([[dictDept valueForKey:@"selection"] isEqualToString:@"1"])
        {
            lbldept.textColor = [UIColor colorWithRed:0.0/255.0 green:115.0/255.0 blue:170.0/255.0 alpha:1.0];
        }
        else{
           lbldept.textColor = [UIColor blackColor];
        }
        
        
        lbldept.tag=500;
        
    
        UIImageView *imgCheck = [[UIImageView alloc]init];
        
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        {
            imgCheck.frame=CGRectMake(280.0, 10.0, 22.0, 16.0);
        }
        else{
            imgCheck.frame=CGRectMake(640.0, 10.0, 22.0, 16.0);
        }
        
        if([[dictDept valueForKey:@"selection"] isEqualToString:@"1"])
        {
            imgCheck.image = [UIImage imageNamed:@"soundCheckMark.png"];
        }
        else{
            [imgCheck setImage:nil];
        }
        imgCheck.tag=502;
        [cell addSubview:imgCheck];
        
        lbldept.text =  [dictDept valueForKey:@"Dept"];
        [cell addSubview:lbldept];
        return cell;
        
        
    }
    else if(tableView == self.tblSupplier)
    {
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UILabel *lblsuppTemp = (UILabel *)[cell viewWithTag:500];
        [lblsuppTemp removeFromSuperview];
        
        UILabel *lblsuppname = (UILabel *)[cell viewWithTag:510];
        [lblsuppname removeFromSuperview];
        
        UIImageView *imgTemp = (UIImageView *)[cell viewWithTag:502];
        [imgTemp removeFromSuperview];
        
        
        
        NSMutableDictionary *dictSupp = (self.arraySupplier)[indexPath.row];
        
        UIImageView *imgCheck = [[UIImageView alloc]init];
        
        
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        {
            imgCheck.frame=CGRectMake(280.0, 10.0, 22.0, 16.0);
        }
        else{
            imgCheck.frame=CGRectMake(640.0, 10.0, 22.0, 16.0);
        }
        
        if([[dictSupp valueForKey:@"selection"] isEqualToString:@"1"])
        {
            imgCheck.image = [UIImage imageNamed:@"soundCheckMark.png"];
        }
        else{
            [imgCheck setImage:nil];
        }
        imgCheck.tag=502;
        [cell addSubview:imgCheck];
        
        UILabel *lblsupp = [[UILabel alloc] init];
        
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        {
            lblsupp.frame=CGRectMake(20.0, 0, 120.0, 44);
        }
        else{
            lblsupp.frame=CGRectMake(20.0, 0, 300.0, 44);
        }
        
        lblsupp.textAlignment = NSTextAlignmentLeft;
        lblsupp.backgroundColor = [UIColor clearColor];
        lblsupp.font = [UIFont fontWithName:@"Helvetica Neue" size:14];
        lblsupp.textColor = [UIColor blackColor];
        lblsupp.tag=500;
        if([[dictSupp valueForKey:@"selection"] isEqualToString:@"1"])
        {
            lblsupp.textColor = [UIColor colorWithRed:0.0/255.0 green:115.0/255.0 blue:170.0/255.0 alpha:1.0];
        }
        else{
            lblsupp.textColor = [UIColor blackColor];
        }
       
        //lblsupp.backgroundColor=[UIColor redColor];
        lblsupp.text = [dictSupp valueForKey:@"compName"];
        
        
        
        UILabel *lblname = [[UILabel alloc] init];
        
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        {
            lblname.frame=CGRectMake(150.0, 0, 120.0, 44);
        }
        else{
            lblname.frame=CGRectMake(330.0, 0, 300.0, 44);
        }
        
        lblname.textAlignment = NSTextAlignmentLeft;
        lblname.backgroundColor = [UIColor clearColor];
        lblname.font = [UIFont fontWithName:@"Helvetica Neue" size:14];
        lblname.textColor = [UIColor blackColor];
        lblname.tag=510;
        if([[dictSupp valueForKey:@"selection"] isEqualToString:@"1"])
        {
            lblname.textColor = [UIColor colorWithRed:0.0/255.0 green:115.0/255.0 blue:170.0/255.0 alpha:1.0];
        }
        else{
            lblname.textColor = [UIColor blackColor];
        }
        // lblname.backgroundColor=[UIColor redColor];
        lblname.text = [dictSupp valueForKey:@"Supp"];
        
        [cell addSubview:lblsupp];
        [cell addSubview:lblname];
        
        return cell;
        
    }
    
   return cell;

    
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == self.tblDepartment)
    {
        NSMutableArray *dict = [(self.arrayDepartment)[indexPath.row]mutableCopy];

        if([[dict valueForKey:@"selection"] isEqualToString:@"0"])
        {
            [dict setValue:@"1" forKey:@"selection"];
            
        }
        else{
            [dict setValue:@"0" forKey:@"selection"];
        }
        (self.arrayDepartment)[indexPath.row] = dict;
        [self.tblDepartment reloadData];
        

        
    }
    else if(tableView == self.tblSupplier)
    {
        NSMutableArray *dict = [(self.arraySupplier)[indexPath.row]mutableCopy];
        if([[dict valueForKey:@"selection"] isEqualToString:@"0"])
        {
            [dict setValue:@"1" forKey:@"selection"];
            
        }
        else{
            [dict setValue:@"0" forKey:@"selection"];
        }
        (self.arraySupplier)[indexPath.row] = dict;
        [self.tblSupplier reloadData];
        
    }
}

-(IBAction)btnDoneClick:(id)sender{
    [Appsee addEvent:kPOFilterFooterDone];
    [self departmentListQuery];
    self.objPlist.strPredicateDept=self.strPredicateDept;
    
    [self supplierListQuery];
    self.objPlist.strPredicateSupp=self.strPredicateSupp;
    
    self.objPlist.strDeprtidList=self.strDeptIdList;
    self.objPlist.strSuppidList=self.strSuppIdList;

    NSPredicate *isselection = [NSPredicate predicateWithFormat:@"selection == \"1\""];
    self.objPlist.arrSelectedManualList = [[self.objManualOption.arrayMainPurchaseOrderList filteredArrayUsingPredicate:isselection]mutableCopy];
    
    if(self.objPlist.arrSelectedManualList.count>0)
    {
        for(NSMutableDictionary *dict  in self.objPlist.arrSelectedManualList){
            [dict removeObjectForKey:@"selection"];
        }
    }
    NSDictionary *selectedManualDict = @{kPOFilterManualSelectedKey : @(self.objPlist.arrSelectedManualList.count)};
    [Appsee addEvent:kPOFilterManualSelected withProperties:selectedManualDict];
  
    self.objPlist.arrdepartmentList=self.arrayDepartment;
    NSDictionary *selectedDepartmentDict = @{kPOFilterDepartmentSelectedKey : @([self countSelectedDepartmentOrSupplierFromArray:self.arrayDepartment])};
    [Appsee addEvent:kPOFilterDepartmentSelected withProperties:selectedDepartmentDict];

    self.objPlist.arrsupplierlist=self.arraySupplier;
    NSDictionary *selectedSupplierDict = @{kPOFilterSupplierSelectedKey : @([self countSelectedDepartmentOrSupplierFromArray:self.arraySupplier])};
    [Appsee addEvent:kPOFilterSupplierSelected withProperties:selectedSupplierDict];
    
    [self.objPlist filterDepartmentamdSupplierforFilterList];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)countSelectedDepartmentOrSupplierFromArray:(NSArray *)array
{
    NSInteger count;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"selection == \"1\""]];
    count = [array filteredArrayUsingPredicate:predicate].count;
    return count;
}

-(void)departmentListQuery{
    
    NSMutableString *strResult = [NSMutableString string];
    NSMutableString *strdeptResult = [NSMutableString string];
    if(self.arrayDepartment.count>0)
    {
        for(int i=0;i < self.arrayDepartment.count;i++){
            
            NSMutableDictionary *dict = (self.arrayDepartment)[i];
            if([[dict valueForKey:@"selection"] isEqualToString:@"1"]){
                
                NSString *ch = [dict valueForKey:@"DeptId"];
                [strResult appendFormat:@"DeptId == %@ OR ", ch];
                [strdeptResult appendFormat:@"%@,", ch];
            }
        }
        if(strResult.length>0)
        {
            self.strPredicateDept = [strResult substringToIndex:strResult.length-4];
            self.strDeptIdList = [strdeptResult substringToIndex:strdeptResult.length-1];
           
        }
        else{
            self.strPredicateDept =@"";
            self.strDeptIdList=@"";
        }
    }
}
-(void)supplierListQuery{
    
    NSMutableString *strResult = [NSMutableString string];
    NSMutableString *strsuppResult = [NSMutableString string];
    if(self.arraySupplier.count>0)
    {
        for(int i=0;i < self.arraySupplier.count;i++){
            
            NSMutableDictionary *dict = (self.arraySupplier)[i];
            if([[dict valueForKey:@"selection"] isEqualToString:@"1"]){
                
                NSString *ch = [dict valueForKey:@"Suppid"];
                [strResult appendFormat:@"SupplierIds contains[cd] \"%@\" OR ", ch];
                [strsuppResult appendFormat:@"%@,", ch];
            }
            
        }
        if(strResult.length>0)
        {
            self.strPredicateSupp = [strResult substringToIndex:strResult.length-4];
             self.strSuppIdList = [strsuppResult substringToIndex:strsuppResult.length-1];
        }
        else{
            self.strPredicateSupp =@"";
            self.strSuppIdList=@"";
        }
        
        
    }
    
}


-(IBAction)cancelFilter:(id)sender{
    [Appsee addEvent:kPOFilterFooterCancel];
    self.objPlist.arrdepartmentList=[self.arrrDeptLocalCopy mutableCopy];
    self.objPlist.arrsupplierlist=[self.arrrSuppLocalCopy mutableCopy];
    
    
   // [objPlist filterDepartmentamdSupplierforFilterList];
    [self.navigationController popViewControllerAnimated:YES];
}
-(IBAction)btnDonDept:(id)sender{
 
    [_viewDepartment setHidden:YES];
}
-(IBAction)btnDonSupp:(id)sender{
    [_viewSupplier setHidden:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
