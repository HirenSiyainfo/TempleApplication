//
//  PrinterVC.m
//  RapidRMS
//
//  Created by Siya on 06/04/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "PrinterVC.h"
#import "DepartmentMultipleSelectionVC.h"
#import "RmsDbController.h"
#import "UpdateManager.h"
#import "KitchenPrinter+Dictionary.h"

#define iPadLabelXpos 10
#define iPadLabelYpos 7
#define iPadLabelWidth 150
#define iPadLabelHeight 30

#define iPadTextboxXpos 180
#define iPadTextboxYpos 7
#define iPadTextboxWidth 500
#define iPadTextboxHeight 30

typedef NS_ENUM(NSInteger,LanPrinters)
{
    printerIP,
    printerName,
    department,
    selecteddepartmentlist,
};
@interface PrinterVC ()<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tblAddPrinters;

@property (nonatomic, weak) UILabel *lblprinterIp;
@property (nonatomic, weak) UILabel *lblPrinterName;
@property (nonatomic, weak) UILabel *lblDepartment;

@property (nonatomic, strong) UITextField *txtprinterIP;
@property (nonatomic, strong) UITextField *txtprinterName;

@property (nonatomic, strong) UIButton *btnDepartment;

@property (nonatomic, strong) UIImageView *imgDepartment;

@property (nonatomic, strong) UIView *viewdepartment;

@property (nonatomic, strong) UITableView *tbldepartment;

@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) UpdateManager *updateManager;

@property (nonatomic, strong) NSMutableArray *printerArray;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation PrinterVC
@synthesize strIPAddress,strPrinterName;
@synthesize selectedDeptArray;
@synthesize managedObjectContext = __managedObjectContext;

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self createPrinterArray];
    [self createDepartmentList];
    [self.tblAddPrinters reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.updateManager = [[UpdateManager alloc] initWithManagedObjectContext:self.rmsDbController.managedObjectContext delegate:self];
    self.managedObjectContext = [UpdateManager privateConextFromParentContext:self.rmsDbController.managedObjectContext];
    [self allocatePrinterComponents];

    // Do any additional setup after loading the view.
}

-(void)createPrinterArray{
    
    if(self.selectedDeptArray.count>0){
        
        self.printerArray = [[NSMutableArray alloc] initWithObjects:@(printerIP),@(printerName),@(department),@(selecteddepartmentlist), nil];
    }
    else{
        self.printerArray = [[NSMutableArray alloc] initWithObjects:@(printerIP),@(printerName),@(department), nil];
    }
}
    
-(void)allocatePrinterComponents
{
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        _lblprinterIp = [self itemInfoLabelIpad];
        _lblPrinterName = [self itemInfoLabelIpad];
        _lblDepartment = [self itemInfoLabelIpad];
        
        _txtprinterIP = [[UITextField alloc] initWithFrame:CGRectMake(iPadTextboxXpos, iPadTextboxYpos, iPadTextboxWidth, iPadTextboxHeight)];
        _txtprinterIP.text=self.strIPAddress;
        _txtprinterName = [[UITextField alloc] initWithFrame:CGRectMake(iPadTextboxXpos, iPadTextboxYpos, iPadTextboxWidth, iPadTextboxHeight)];

        _btnDepartment = [[UIButton alloc] initWithFrame:CGRectMake(iPadTextboxXpos, iPadTextboxYpos, iPadTextboxWidth, iPadTextboxHeight)];
    
        _imgDepartment = [[UIImageView alloc] initWithFrame:CGRectMake(664, 18, 8, 14)];
        
        _tbldepartment = [[UITableView alloc] init ];
        _viewdepartment = [[UIView alloc] init];
    }
    else
    {
        
    }
}
-(void)createDepartmentList
{
    for(UIView *subview in _viewdepartment.subviews) {
        [subview removeFromSuperview];
    }
    if(self.selectedDeptArray.count > 0)
    {
        [self.tblAddPrinters reloadData];
        [_tbldepartment reloadData];
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) // iPhone tableview frame set
        {
            _viewdepartment.frame = CGRectMake(20, 0, 280,120);
        }
        else
        {
            _viewdepartment.frame = CGRectMake(0.0, 0, 688,400);
        }
        _viewdepartment.backgroundColor = [UIColor clearColor];
        _viewdepartment.userInteractionEnabled=YES;
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) // iPhone tableview frame set
        {
            _tbldepartment.frame = CGRectMake(0, 5, 280,115);
        }
        else{
            _tbldepartment.frame = CGRectMake(10.0, 5,688 ,390);
        }
        _tbldepartment.scrollEnabled = YES;
//        _tbldepartment.backgroundColor = [UIColor greenColor];
//        _viewdepartment.backgroundColor = [UIColor redColor];
        _tbldepartment.userInteractionEnabled = YES;
        _tbldepartment.bounces = YES;
        _tbldepartment.delegate = self;
        _tbldepartment.dataSource = self;
        _tbldepartment.backgroundColor = [UIColor clearColor];
        _tbldepartment.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tbldepartment.rowHeight=40;
        [_viewdepartment addSubview:_tbldepartment];
    }
    else
    {
        [self.tblAddPrinters reloadData];
    }
}

- (UILabel *)itemInfoLabelIpad
{
    // alloc label of table view
    UILabel *sender = [[UILabel alloc] initWithFrame:CGRectMake(iPadLabelXpos, iPadLabelYpos, iPadLabelWidth, iPadLabelHeight)];
    sender.textAlignment = NSTextAlignmentLeft;
    sender.backgroundColor = [UIColor clearColor];
    sender.font = [UIFont fontWithName:@"Helvetica Neue" size:14];
    sender.textColor = [UIColor blackColor];
    return sender;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == self.tblAddPrinters)
    {
        if(indexPath.row==3){
            return 400;
        }
        else{
           return 44.0;
        }
        
    }
    else if(tableView == _tbldepartment){
        return 40.0;
    }
    return 40.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    if(tableView == self.tblAddPrinters){
         return self.printerArray.count;
    }
    else if(tableView == _tbldepartment){
        
        return selectedDeptArray.count;
    }
    return 1;
}

-(void)setTxtBoxProperty:(UITextField *)sender
{
    sender.delegate = self;
    sender.borderStyle = UITextBorderStyleNone;
    sender.font = [UIFont fontWithName:@"Helvetica Neue" size:17];
    sender.clearButtonMode = UITextFieldViewModeWhileEditing;
    sender.backgroundColor = [UIColor clearColor];
    sender.tintColor = [UIColor blackColor];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCellStyle style =  UITableViewCellStyleDefault;
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"BaseCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor= [UIColor clearColor];
    
    if(tableView == self.tblAddPrinters){
        
         UIImageView *img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"FormRowBg.png"]];
        
        LanPrinters rowType = [self.printerArray[indexPath.row] integerValue];
        switch (rowType)
        {
            case printerIP:
            {

                [cell addSubview:img];
                _lblprinterIp.text = @"IP";
                [cell addSubview:_lblprinterIp];
                
                [self setTxtBoxProperty:_txtprinterIP];
                [_txtprinterIP setEnabled:NO];
                [cell addSubview:_txtprinterIP];
                
            }
                break;
                
            case printerName:
            {
                [cell addSubview:img];
                _lblPrinterName.text = @"Name";
                [cell addSubview:_lblPrinterName];
                
                [self setTxtBoxProperty:_txtprinterName];
                if(strPrinterName){
                    _txtprinterName.text = strPrinterName;
                }
                else{
                    _txtprinterName.placeholder = @"Enter Name";
                }
                [cell addSubview:_txtprinterName];
            }
                break;
                
            case department:
            {
                [cell addSubview:img];
                _lblDepartment.text = @"Department";
                [cell addSubview:_lblDepartment];
                
                _imgDepartment.image = [UIImage imageNamed:@"ArrowRightNormal.png"];
                [cell addSubview:_imgDepartment];
                
                _btnDepartment.backgroundColor = [UIColor clearColor];
                [_btnDepartment addTarget:self action:@selector(addDepartment:) forControlEvents:UIControlEventTouchUpInside];
                [cell addSubview:_btnDepartment];
                
                
                
            }
            break;
            case selecteddepartmentlist:
            {
                [cell addSubview:_viewdepartment];
                [cell bringSubviewToFront:_viewdepartment];
                
            }
                break;
                
            default:
                break;
        }
    }
    if(tableView == _tbldepartment){
        
        UITableViewCellStyle style =  UITableViewCellStyleDefault;
        UITableViewCell *cellDeptSupplier = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"DeptSupplier"];
        cellDeptSupplier.selectionStyle = UITableViewCellSelectionStyleNone;
        cellDeptSupplier.backgroundColor = [UIColor clearColor];
        UILabel *lbl=nil;
        for(lbl in cellDeptSupplier.subviews){
            if([lbl isKindOfClass:[UILabel class]]){
                [lbl removeFromSuperview];
            }
        }
        NSMutableArray *itemarray=[self.selectedDeptArray mutableCopy];
        UILabel * suppname = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 220, 20)];
        suppname.text = itemarray[indexPath.row][@"DepartmentName"];
        suppname.backgroundColor = [UIColor clearColor];
        suppname.textColor = [UIColor colorWithRed:0.0/255.0 green:115.0/255.0 blue:170.0/255.0 alpha:1.0];
        suppname.font = [UIFont fontWithName:@"Helvetica Neue" size:14];
        [cellDeptSupplier.contentView addSubview:suppname];
        
        return cellDeptSupplier;
    }
    return cell;
}

-(IBAction)addDepartment:(id)sender
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DepartmentMultipleSelectionVC *deptMultiple = [storyBoard instantiateViewControllerWithIdentifier:@"DepartmentMultipleSelectionVC"];
    deptMultiple.checkedDepartment = selectedDeptArray;
    deptMultiple.printer=self;
    deptMultiple.strCurrentIp=self.strIPAddress;
    [self.navigationController pushViewController:deptMultiple animated:YES];

}
-(IBAction)savePrinter:(id)sender{
    
    if([_txtprinterName.text isEqualToString:@""]){
        
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {};
        [self.rmsDbController popupAlertFromVC:self title:@"Message" message:@"Enter printer name" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
    }
    else{
        
        NSMutableDictionary *dictPrinter = [[NSMutableDictionary alloc]init];
        dictPrinter[@"printer_ip"] = _txtprinterIP.text;
        dictPrinter[@"printer_Name"] = _txtprinterName.text;
        KitchenPrinter *kitchenPrinter = [self getPrinter:_txtprinterIP.text withMoc:self.managedObjectContext];
        if(kitchenPrinter){
            
            NSManagedObjectContext *privateManagedObjectContext = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
            
              [self.updateManager updatePrinterDictionary:dictPrinter withDepartment:selectedDeptArray withMoc:privateManagedObjectContext];
        }
        else{
              [self.updateManager addPrinterDictionary:dictPrinter withDepartment:selectedDeptArray];
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

-(KitchenPrinter *)getPrinter:(NSString *)strPrinterIp withMoc:(NSManagedObjectContext *)moc{
    
    KitchenPrinter *kitchenPrinter;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"KitchenPrinter" inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"printer_ip == %@", strPrinterIp];
    fetchRequest.predicate = predicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    
    if(resultSet.count>0){
        
        kitchenPrinter = resultSet.firstObject;
    }
    return kitchenPrinter;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
 
    strPrinterName=textField.text;
    [textField resignFirstResponder];
    return YES;
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
