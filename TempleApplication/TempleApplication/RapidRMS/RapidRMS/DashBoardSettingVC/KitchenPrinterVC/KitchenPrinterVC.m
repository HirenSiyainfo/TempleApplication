//
//  KitchenPrinterVC.m
//  RapidRMS
//
//  Created by Siya on 06/04/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "KitchenPrinterVC.h"
#import "RmsDbController.h"
#import "KitchenPrinter+Dictionary.h"
#import "Department+Dictionary.h"
#import "PrinterVC.h"
#import "UpdateManager.h"

@interface KitchenPrinterVC ()

@property (nonatomic, weak) IBOutlet UITableView *tblPrinters;

@property (nonatomic, weak) IBOutlet UILabel *lblsearchPrinters;

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activity;

@property (nonatomic, strong) UpdateManager *updateManager;
@property (nonatomic, strong) RmsDbController *rmsDbController;

@property (nonatomic, strong) NSMutableArray *arrayTCP;
@property (nonatomic, strong) NSMutableArray *acitvePrinters;
@property (nonatomic, strong) NSMutableArray *selectedDepartment;

@property (nonatomic, strong) NSIndexPath *indxpath;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation KitchenPrinterVC
@synthesize managedObjectContext = __managedObjectContext;

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title=@"Printer Setting";
    UIImage* image3 = [UIImage imageNamed:@"RmsheaderLogo.png"];
    CGRect frameimg = CGRectMake(0, 0, image3.size.width, image3.size.height);
    UIButton *someButton = [[UIButton alloc] initWithFrame:frameimg];
    [someButton setBackgroundImage:image3 forState:UIControlStateNormal];
    UIBarButtonItem *mailbutton =[[UIBarButtonItem alloc] initWithCustomView:someButton];
    self.navigationItem.rightBarButtonItem=mailbutton;
    [self loadPrintersFunctions];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
     self.updateManager = [[UpdateManager alloc] initWithManagedObjectContext:self.rmsDbController.managedObjectContext delegate:self];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    self.selectedDepartment = [[NSMutableArray alloc]init];
    _arrayTCP = [[NSMutableArray alloc]init];
    [self loadPrinters];
    // Do any additional setup after loading the view.
}

-(void)loadPrintersFunctions{
//    [self loadPrinters];
    [self loadActivePrinters];
    [self.tblPrinters reloadData];
}

-(void)loadPrinters
{
//#ifdef DEBUG
//    [self fetchPrinters];
//#else
    [self.activity setHidden:NO];
    [self.lblsearchPrinters setHidden:NO];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self fetchPrinters];
    });
//#endif
}

-(void)fetchPrinters
{
//#ifdef DEBUG
//    _arrayTCP = [NSMutableArray arrayWithObjects:@"TCP:198.168.20.10",@"TCP:198.168.4.1",@"TCP:198.168.2.1",@"TCP:198.168.10.7", nil];
//#else
    NSArray *arrayTcpPrinter =  [SMPort searchPrinter:@"TCP:"];
    [self setPrintertoArray:arrayTcpPrinter];
    [self.activity setHidden:YES];
    [self.lblsearchPrinters setHidden:YES];
    if(_arrayTCP.count == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Message" message:@"No TCP Printer Found" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    else{
        
        [self loadActivePrinters];
    }
//#endif
}
-(void)setPrintertoArray:(NSArray *)TcpPrinter{
    
    for(int i=0;i<TcpPrinter.count;i++){
        PortInfo *portInfo  = TcpPrinter[i];
        [_arrayTCP addObject:portInfo.portName];
    }
}
-(void)loadActivePrinters{
    
    _acitvePrinters = [[NSMutableArray alloc]init];
    _acitvePrinters = [self fetchAllActivePrinters:self.managedObjectContext];
    [self.tblPrinters reloadData];
}

-(NSMutableArray *)fetchAllActivePrinters:(NSManagedObjectContext *)moc
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"KitchenPrinter" inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    NSArray *resultSet = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    
    for(KitchenPrinter *printer in resultSet){
        
        for(int i = 0 ; i <_arrayTCP.count;i++){
            
            if([printer.printer_ip isEqualToString:_arrayTCP[i]]){
                
                [_arrayTCP removeObjectAtIndex:i];
            }
        }
        [_acitvePrinters addObject:printer.printerDictionary];
    }
    return _acitvePrinters;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *headerTitle;
    if (section == 0)
    {
        headerTitle = @"    Available Printers";
    }
    if (section == 1)
    {
        headerTitle = @"    Added to this device";
    }
    return headerTitle;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section==0)
    {
        if(_arrayTCP.count>0){
            
            return _arrayTCP.count;
        }
        else{
            return 1;
        }
    }
    else if(section==1){
        
        if(_acitvePrinters.count>0){
            
           return _acitvePrinters.count;
        }
        else{
            return 1;
        }
    }
    else{
        return 1;
    }
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCellStyle style =  UITableViewCellStyleDefault;
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"BaseCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

   // PortInfo *port = arrayTCP[indexPath.row];
    
   // NSString *detailText = [NSString stringWithFormat:@"%@(%@)", port.portName, port.macAddress];
    
    if(indexPath.section==0){
        
        if(_arrayTCP.count>0){
    
            cell.textLabel.text = _arrayTCP[indexPath.row];
        }
        else{
            cell.textLabel.text = @"No Printer Available";
        }
    }
    else if(indexPath.section==1){
        
        if(_acitvePrinters.count>0){

            NSMutableDictionary *dictPrinter = _acitvePrinters[indexPath.row];
            
            CGRect printerNameframe;
            CGRect ipnumberframe;
            CGRect buttonFrame;
            
            if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
            {
                printerNameframe = CGRectMake(10, 2, 200, 40);
                ipnumberframe = CGRectMake(230, 2, 200, 40);
                buttonFrame  = CGRectMake(630.0, 2, 50.0, 40);
            }
            else
            {
                printerNameframe = CGRectMake(10, 2, 200, 40);
                ipnumberframe = CGRectMake(230, 2, 200, 40);
                buttonFrame  = CGRectMake(630.0, 2, 50.0, 40);

            }
            
            UILabel *printername = [[UILabel alloc] initWithFrame:printerNameframe];
            printername.text = [dictPrinter valueForKey:@"printer_Name"];
            printername.numberOfLines = 2;
            printername.textAlignment = NSTextAlignmentLeft;
            printername.backgroundColor = [UIColor clearColor];
            printername.textColor = [UIColor blackColor];
            printername.font = [UIFont fontWithName:@"Helvetica Neue" size:18];
            [cell.contentView addSubview:printername];
            
            UILabel * ipnumber = [[UILabel alloc] initWithFrame:ipnumberframe];
            ipnumber.text = [dictPrinter valueForKey:@"printer_ip"];
            ipnumber.numberOfLines = 2;
            ipnumber.textAlignment = NSTextAlignmentLeft;
            ipnumber.backgroundColor = [UIColor clearColor];
            ipnumber.textColor = [UIColor blackColor];
            ipnumber.font = [UIFont fontWithName:@"Helvetica Neue" size:18];
            [cell.contentView addSubview:ipnumber];
            
            UIButton * btnDelete = [UIButton buttonWithType:UIButtonTypeCustom];
            btnDelete.frame = buttonFrame;
            [btnDelete addTarget:self action:@selector(deletePrinter:) forControlEvents:UIControlEventTouchUpInside];
            btnDelete.tag=indexPath.row;
            btnDelete.backgroundColor = [UIColor clearColor];
            [btnDelete setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [btnDelete setTitle:@"X" forState:UIControlStateNormal];
            [cell.contentView addSubview:btnDelete];


        }
        else{
            
             cell.textLabel.text = @"No Printer Selected";
        }
        
    }

    return cell;
}

-(void)deletePrinter:(id)sender{
    
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        
    };
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        [self removePrinter:[sender tag]];
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Message" message:@"Are you sure want to delete the Printer ?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];

    
}
-(void)removePrinter:(NSInteger)intRow{
    
    [self deletePrinterFromTable:[_acitvePrinters[intRow] valueForKey:@"printer_ip"]];
    [self loadPrintersFunctions];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.rmsDbController playButtonSound];
    self.indxpath = indexPath;
    
    if(indexPath.section==0){
        
        if(_arrayTCP.count>0){
            
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            PrinterVC *printerVc = [storyBoard instantiateViewControllerWithIdentifier:@"PrinterVC"];
            printerVc.strIPAddress=_arrayTCP[indexPath.row];
            [self.navigationController pushViewController:printerVc animated:YES];
        }
    }
    else if(indexPath.section==1){
    
         if(_acitvePrinters.count>0){
             
             UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
             PrinterVC *printerVc = [storyBoard instantiateViewControllerWithIdentifier:@"PrinterVC"];
             printerVc.selectedDeptArray=[self getDepartmentList:[_acitvePrinters[indexPath.row] valueForKey:@"printer_ip"]];
             printerVc.strIPAddress=[_acitvePrinters[indexPath.row]valueForKey:@"printer_ip"];
             printerVc.strPrinterName=[_acitvePrinters[indexPath.row]valueForKey:@"printer_Name"];
             [self.navigationController pushViewController:printerVc animated:YES];
         }
        
    }
}

-(NSMutableArray *)getDepartmentList:(NSString *)strPrinterIp{
    
    NSMutableArray *deptArray =[[NSMutableArray alloc]init];
    KitchenPrinter *kitchenPrinter;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"KitchenPrinter" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"printer_ip == %@", strPrinterIp];
    fetchRequest.predicate = predicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    
    if(resultSet.count>0)
    {
        kitchenPrinter = resultSet.firstObject;
        for(Department *dept in kitchenPrinter.printerDepartments){
            NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
            dict[@"DepartmentName"] = dept.deptName;
            dict[@"DeptId"] = dept.deptId;
            [deptArray addObject:dict];
        }
    }
    return deptArray;
}

-(void)deletePrinterFromTable:(NSString *)strPrinterIp{
    
    NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
    KitchenPrinter *kitchenPrinter;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"KitchenPrinter" inManagedObjectContext:privateContextObject];
    fetchRequest.entity = entity;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"printer_ip == %@", strPrinterIp];
    fetchRequest.predicate = predicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:privateContextObject FetchRequest:fetchRequest];
 
    if(resultSet.count>0){
        kitchenPrinter = resultSet.firstObject;
        NSSet *departments = kitchenPrinter.printerDepartments;
        [kitchenPrinter removePrinterDepartments:departments];
        
        for (Department *dept in departments) {
            dept.departmentPrinter = nil;
        }
        [UpdateManager deleteFromContext:privateContextObject object:kitchenPrinter];
    }
    [UpdateManager saveContext:privateContextObject];
    
}
-(IBAction)back:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
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
