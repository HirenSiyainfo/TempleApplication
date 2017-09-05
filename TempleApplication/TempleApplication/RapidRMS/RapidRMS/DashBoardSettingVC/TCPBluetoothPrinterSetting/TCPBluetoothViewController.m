//
//  TCPBluetoothViewController.m
//  RapidRMS
//
//  Created by Siya on 10/07/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "TCPBluetoothViewController.h"
#import "RmsDbController.h"
#import "StarIO/SMPort.h"
#import <StarIO/SMPort.h>
#import <StarIO/SMBluetoothManager.h>
#import "RmsActivityIndicator.h"
#import "Printers.h"
#import "TCPBluetoothCell.h"
#import "TCPBltOfflineCell.h"
#import "NSString+Validation.h"
#import "PrintJob.h"
#import "InvoiceReceiptPrint.h"
#import "EditPrinterPopOver.h"
#import "DrawerStatus.h"

typedef NS_ENUM(NSInteger, PrinterSectionTitle) {
    OnlinePrinterList,
    OfflinePrinterList,
};

@interface TCPBluetoothViewController ()<PrinterFunctionsDelegate,UITableViewDelegate,UITableViewDataSource,EditPrinterPopOverDelegate,DrawerStatusDelegate>
{
    IntercomHandler *intercomHandler;
    PrintJob *printJob;
    InvoiceReceiptPrint *TryDemo;
    NSMutableArray *PrintData;
    UIAlertController *printerAlert;
    NSString *_deviceName;
    NSArray *SectionArray;
    NSUInteger *sectionCount;
    NSIndexPath *currentIndexpath;
    EditPrinterPopOver *customAlertView;
    DrawerStatus *drawerStatus;
}

@property (nonatomic, weak) id<PrinterFunctionsDelegate> printerDelegate;
@property (nonatomic, weak) id<EditPrinterPopOverDelegate> editPrinterPopOverDelegate;
@property (nonatomic, weak) id printerWidth;
@property (nonatomic, strong) NSString *portName;
@property (nonatomic, strong) NSString *portSettings;

@property (nonatomic, weak) IBOutlet UILabel *lblSelectedTCPPrinter;
@property (nonatomic, weak) IBOutlet UILabel *lblSearching;
@property (nonatomic, weak) IBOutlet UILabel *lblbluetooth;
@property (nonatomic, weak) IBOutlet UILabel *lblTCP;
@property (nonatomic, strong) NSFetchedResultsController * tcpResultsController;

@property (nonatomic, weak) IBOutlet UITableView *tblTcpPrinter;

@property (nonatomic, strong) RmsDbController *rmsDbController;

@property (nonatomic, strong) NSMutableDictionary *dictTCPBluetooth;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
//@property (nonatomic, strong) NSArray *arrayTCP;
@property (nonatomic, weak) IBOutlet UIButton *btnAddPrinter;


@end

@implementation TCPBluetoothViewController
@synthesize btnBluetooth,btnTCP,dictTCPBluetooth,tblTcpPrinter,lblSearching,lblSelectedTCPPrinter;

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
    PrintData = [[NSMutableArray alloc] init];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    dictTCPBluetooth = [[NSMutableDictionary alloc] init];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    self.printerDelegate = self;
    [self setSelection];
    //    arrayTCP=[[NSArray alloc]init];
    UINib *printerSelectionNib = [UINib nibWithNibName:@"TCPBluetoothCell" bundle:nil];
    [self.tblTcpPrinter registerNib:printerSelectionNib forCellReuseIdentifier:@"PrinterCell"];
    
    [self insertSelectedPrinterIfNeeded];
    
    drawerStatus = [[DrawerStatus alloc] init];
    drawerStatus.drawerStatusDelegate = self;
    // Do any additional setup after loading the view from its nib.
    //    [PrintData setValue:@"Test Print" forKey:@"title"];
    //    [PrintData setValue:@"NULL" forKey:@"ip"];
    //    [PrintData setValue:@"NULL" forKey:@"name"];
    
    //    [self manageUserDefaults];
}
//-(void)manageUserDefaults
//{
////    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"SelectedTCPName"]) {
//        [PrintData addObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"SelectedTCPName"]];
////    }
////    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"SelectedTCPPrinter"])
////    {
////        [PrintData addObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"SelectedTCPPrinter"]];
////    }
//}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title=@"Printer Setting";
    SectionArray = @[@(OnlinePrinterList),@(OfflinePrinterList)];
    if (btnTCP.selected == YES)
    {
        [self TCPSelect];
    }
    
    UIImage* image3 = [UIImage imageNamed:@"RmsheaderLogo.png"];
    CGRect frameimg = CGRectMake(0, 0, image3.size.width, image3.size.height);
    UIButton *someButton = [[UIButton alloc] initWithFrame:frameimg];
    [someButton setBackgroundImage:image3 forState:UIControlStateNormal];
    UIBarButtonItem *mailbutton =[[UIBarButtonItem alloc] initWithCustomView:someButton];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
    UIBarButtonItem *intercom =[[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItems = @[mailbutton,intercom];
    intercomHandler = [[IntercomHandler alloc] initWithButtton:button withViewController:self];
}

-(void)setSelection
{
    NSString *Str = [[NSUserDefaults standardUserDefaults]objectForKey:@"PrinterSelection"];
    if(Str.length > 0)
    {
        if ([Str isEqualToString:@"Bluetooth"])
        {
            btnBluetooth.selected = YES;
            btnTCP.selected = NO;
            //            self.lbldepartment.textColor = [UIColor colorWithRed:30.0/255.0 green:114.0/255.0 blue:174.0/255.0 alpha:1.0];
            //            self.lblFavorite.textColor = [UIColor blackColor];
            
        }
        if ([Str isEqualToString:@"TCP"])
        {
            btnBluetooth.selected = NO;
            btnTCP.selected = YES;
            
            NSString *StrTCP = [[NSUserDefaults standardUserDefaults]objectForKey:@"SelectedTCPPrinter"];
            lblSelectedTCPPrinter.text=StrTCP;
            lblSelectedTCPPrinter.hidden = FALSE;
            tblTcpPrinter.hidden=NO;
            _btnAddPrinter.hidden = NO;
            
            //            self.lblFavorite.textColor = [UIColor colorWithRed:30.0/255.0 green:114.0/255.0 blue:174.0/255.0 alpha:1.0];
            //            self.lbldepartment.textColor = [UIColor blackColor];
        }
    }
}

#pragma mark - DrawerStatusDelegate

-(void)errorOccuredWhileGettingDrawerStatusWithTitle:(NSString *)title message:(NSString *)message {
    [_activityIndicator hideActivityIndicator];
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        
    };
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        [self detectDrawerType];
    };
    [self.rmsDbController popupAlertFromVC:self title:title message:message buttonTitles:@[@"Cancel",@"Retry"] buttonHandlers:@[leftHandler,rightHandler]];
}

-(void)getDrawerStatusProcessCompleted {
    [_activityIndicator updateLoadingMessage:@"Drawer type is detected."];
    [_activityIndicator hideActivityIndicator];
}

#pragma mark - Printer Option Selection

- (IBAction)btnBluetoothClicked:(id)sender {
    [self.rmsDbController playButtonSound];
    lblSearching.hidden=YES;
    lblSelectedTCPPrinter.hidden=YES;
    tblTcpPrinter.hidden=YES;
    _btnAddPrinter.hidden = YES;
    btnTCP.selected = NO;
    btnBluetooth.selected = YES;
    [self removeSelectedPrinters];
    [self bluetoothSelect];
    [self detectDrawerType];
}

- (IBAction)btnTCPClicked:(id)sender {
    [self.rmsDbController playButtonSound];
    [self TCPSelect];
}

#pragma mark - Detect Drawer Type

- (void)detectDrawerType {
    _activityIndicator =  [RmsActivityIndicator showActivityIndicator:self.parentViewController.view];
    [_activityIndicator updateLoadingMessage:@"Detecting drawer type."];
    [drawerStatus detectDrawerType];
}

- (IBAction)btnScanClicked:(id)sender {
    NSOperationQueue *myQueue = [[NSOperationQueue alloc] init];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        _activityIndicator =  [RmsActivityIndicator showActivityIndicator:self.parentViewController.view];
    }];
    [myQueue addOperationWithBlock:^{
        [self searchTCPPrinter];
        _tcpResultsController = nil;
        [tblTcpPrinter reloadData];
    }];
//        _activityIndicator =  [RmsActivityIndicator showActivityIndicator:self.parentViewController.view];
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [self searchTCPPrinter];
//            _tcpResultsController = nil;
//            [tblTcpPrinter reloadData];
//        });
}
#pragma mark -
#pragma mark Table View Delegate Method

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.tcpResultsController sections] count];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sections = self.tcpResultsController.sections;
    id <NSFetchedResultsSectionInfo> sectionInfo = sections[section];
    return sectionInfo.numberOfObjects;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    NSArray *sections = self.tcpResultsController.sections;
    id <NSFetchedResultsSectionInfo> sectionInfo = sections[section];
    PrinterSectionTitle SelectedSectionName = [sectionInfo.indexTitle integerValue];
    
    switch (SelectedSectionName) {
        case OnlinePrinterList:
            sectionName = @"   Online Printer List";
            break;
        case OfflinePrinterList:
            sectionName = @"   Offline Printer List";
        default:
            break;
    }
    return sectionName;
}

//-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    static NSString *CellIdentifier = @"PrinterCell";
//    TCPBluetoothCell *headerView = (TCPBluetoothCell *)[tableView initWithFrame:tableView.frame style:UITableViewCellEditingStyleNone];
//    headerView = (TCPBluetoothCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (headerView == nil){
//        [NSException raise:@"headerView == nil.." format:@"No cells with matching CellIdentifier loaded from your storyboard"];
//    }
//    NSString *sectionName;
//    NSArray *sections = self.tcpResultsController.sections;
//    id <NSFetchedResultsSectionInfo> sectionInfo = sections[section];
//    PrinterSectionTitle SelectedSectionName = [sectionInfo.indexTitle integerValue];
//
//    switch (SelectedSectionName) {
//        case OnlinePrinterList:
//            sectionName = @"OnlinePrinterList";
//            break;
//        case OfflinePrinterList:
//            sectionName = @"OfflinePrinterList";
//        default:
//            sectionName = @"";
//            break;
//    }
//    headerView.lblPrinter.text = sectionName;
//    headerView.accessoryType = UITableViewCellAccessoryNone;
//    headerView.btnEditPrinter.hidden = true;
//    return headerView;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Printers *printer = [self.tcpResultsController objectAtIndexPath:indexPath];
    NSString *ip = [printer.portName stringByReplacingOccurrencesOfString:@"TCP:" withString:@"TCP: "];

    NSString *detail = [NSString stringWithFormat:@"%@ (%@)", ip, printer.name];
    NSArray *sections = self.tcpResultsController.sections;
    id <NSFetchedResultsSectionInfo> sectionInfo = sections[indexPath.section];
    PrinterSectionTitle SelectedSectionName = [sectionInfo.indexTitle integerValue];
    if(SelectedSectionName == 0)
    {
        TCPBluetoothCell *cell = (TCPBluetoothCell *)[tableView dequeueReusableCellWithIdentifier:@"PrinterCell"];
        if (cell == nil) {
            cell = [[TCPBluetoothCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PrinterCell"];
        }
        cell.lblPrinter.text = detail;
        if(printer.isSelected.boolValue)
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            lblSelectedTCPPrinter.text = ip;
        }
        else{
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        [cell.btnTestPrinter addTarget:self action:@selector(TestPrint:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btnEditPrinter addTarget:self action:@selector(editPrinterIP:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
    else
    {
        
        TCPBltOfflineCell *cellOffline = [tableView dequeueReusableCellWithIdentifier:@"OfflineCell"];
        if (cellOffline == nil) {
            [tableView registerNib:[UINib nibWithNibName:@"TCPBltOfflineCell" bundle:nil] forCellReuseIdentifier:@"OfflineCell"];
            cellOffline = [tableView dequeueReusableCellWithIdentifier:@"OfflineCell"];
//            cellOffline = [[TCPBltOfflineCell alloc] initWithStyle:UITableViewCellEditingStyleNone reuseIdentifier:@"OfflineCell"];
        }
        if(printer.isSelected.boolValue)
        {
            cellOffline.accessoryType = UITableViewCellAccessoryCheckmark;
            lblSelectedTCPPrinter.text = printer.portName;
        }
        else{
            cellOffline.accessoryType = UITableViewCellAccessoryNone;
        }
        [cellOffline.btnEditPrinter addTarget:self action:@selector(editPrinterIP:) forControlEvents:UIControlEventTouchUpInside];
        cellOffline.lblOffline.text = detail;
        return cellOffline;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.rmsDbController playButtonSound];
    [self removeSelectedPrinters];
    
    Printers *printerInfo = [self.tcpResultsController objectAtIndexPath:indexPath];
    lblSelectedTCPPrinter.text = printerInfo.portName;
    
    printerInfo.isSelected = @(1);
    
    if(self.managedObjectContext.hasChanges)
    {
        [UpdateManager saveContext:self.managedObjectContext];
    }
    [PrintData removeAllObjects];
    [[NSUserDefaults standardUserDefaults] setObject:@"TCP" forKey:@"PrinterSelection"];
    [[NSUserDefaults standardUserDefaults] setObject:printerInfo.portName forKey:@"SelectedTCPPrinter"];
    [[NSUserDefaults standardUserDefaults] setObject:printerInfo.name forKey:@"SelectedTCPName"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSMutableDictionary *temp = [[NSMutableDictionary alloc] init];
    [temp setValue:@"TEST PRINT" forKey:@"title"];
    [temp setValue:[[NSUserDefaults standardUserDefaults]objectForKey:@"SelectedTCPPrinter"] forKey:@"ip"];
    [temp setValue:[[NSUserDefaults standardUserDefaults]objectForKey:@"SelectedTCPName"] forKey:@"name"];
    [PrintData addObject:temp];
    [self setSelection];
    [self detectDrawerType];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [self.managedObjectContext deleteObject:[self.tcpResultsController objectAtIndexPath:indexPath]];
        NSError *error = nil;
        if (![self.managedObjectContext save:&error]) {
            // handle error
        }
    }
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    Printers * printer = [self.tcpResultsController objectAtIndexPath:indexPath];
    NSString *StrTCP = [[NSUserDefaults standardUserDefaults]objectForKey:@"SelectedTCPPrinter"];
    if([printer.portName isEqualToString:StrTCP])
    {
        return NO;
    }
    return YES;
}
-(void)didCancel
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.tcpResultsController = nil;
        [self.tblTcpPrinter reloadData];
         });
    [customAlertView.view removeFromSuperview];
}
-(void)btnDonePress:(NSString *)TCPPortname TCPName:(NSString *)TCPName{
    Printers * printer;
    if (currentIndexpath) {
        printer = [self.tcpResultsController objectAtIndexPath:currentIndexpath];
    }
    NSString * strInputPrinter = TCPPortname;
    NSString * duplicate = [printer.portName stringByReplacingOccurrencesOfString:@"TCP:" withString:@""];
    NSString * strInputPrinterName = TCPName;
    
    NSString * strError;
    if (![strInputPrinter isEqualToString:duplicate]) {
        strError = [self checkIPValidation:strInputPrinter];
    }
    if (strError.length > 0) {
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Printer Setting" message:strError buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
    }
    else {
        if (currentIndexpath) {
            printer.portName = [NSString stringWithFormat:@"TCP:%@",strInputPrinter];
            printer.name = [NSString stringWithFormat:@"%@",strInputPrinterName];
            printer.isOnline = @(1);
            [self btnScanClicked:nil];
        }
        else
        {
            Printers * anObject = (Printers *)[self fetchEntityWithValue:[NSString stringWithFormat:@"TCP:%@",strInputPrinter] shouldCreate:true moc:self.managedObjectContext];
            anObject.portName = [NSString stringWithFormat:@"TCP:%@",strInputPrinter];
            anObject.name = [NSString stringWithFormat:@"%@",strInputPrinterName];
            anObject.isOnline = @(1);
            [UpdateManager saveContext:self.managedObjectContext];
        }
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
[customAlertView.view removeFromSuperview];
    });
}
-(void)addPrinterAtIndexPath:(NSIndexPath *)indexPath{
    currentIndexpath = indexPath;
    customAlertView = [[EditPrinterPopOver alloc] init];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    customAlertView = [storyBoard instantiateViewControllerWithIdentifier:@"EditPrinterPopOver"];
    customAlertView.editPrinterPopOverDelegate = self;
    customAlertView.modalPresentationStyle = UIModalPresentationCustom;
    customAlertView.view.frame = CGRectMake(0, 0, 724, 768);
    [self.view addSubview:customAlertView.view];
    Printers * printer;
    if (currentIndexpath) {
        printer = [self.tcpResultsController objectAtIndexPath:currentIndexpath];
    }
    
    if(printer){
        NSString * strInputPrinter = [printer.portName stringByReplacingOccurrencesOfString:@"TCP:" withString:@""];
        [customAlertView.txtTCPPortName setText:strInputPrinter];
        [customAlertView.txtTCPName setText:printer.name];
    }

//    customAlertView.view.superview.bounds = CGRectMake(311, 235, 299, 402);
//    self.view.superview.backgroundColor = [UIColor clearColor];
//    CGRect screen = self.view.superview.bounds;
//    CGRect frame = CGRectMake(0, 0, <width>, <height>);
//    float x = (screen.size.width - frame.size.width)*.5f;
//    float y = (screen.size.height - frame.size.height)*.5f;
//    frame = CGRectMake(x, y, frame.size.width, frame.size.height);
//    
//    self.view.frame = frame;

        // Alert event handling
    

//        [self presentViewController:customAlertView animated:YES completion:nil];

//    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:MainStoryBoard() bundle:nil];
//    customAlertView = [storyBoard instantiateViewControllerWithIdentifier:@"EditPrinterPopOver"];
//    customAlertView.modalPresentationStyle = UIModalPresentationCustom;
//    [self presentViewController:customAlertView animated:YES completion:nil];
}
- (void)configurePrint:(NSString *)portSettings portName:(NSString *)portName withDelegate:(id)delegate
{
    BOOL isBlueToothPrinter = [portName isEqualToString:@"BT:Star Micronics"];
    
    if (isBlueToothPrinter) {
        printJob = [[PrintJob alloc] initWithPort:portName portSettings:portSettings deviceName:@"Printer" withDelegate:delegate];
        [printJob enableSlashedZero:YES];
    }
    //    else
    //    {
    //        printJob = [[RasterPrintJobBase alloc] initWithPort:portName portSettings:portSettings deviceName:@"Printer" withDelegate:delegate];
    //    }
}

- (IBAction)TestPrint:(UIButton *)sender
{
//    NSOperationQueue *myQueue = [[NSOperationQueue alloc] init];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        _activityIndicator =  [RmsActivityIndicator showActivityIndicator:self.parentViewController.view];
    }];
    CGPoint center= sender.center;
    CGPoint rootViewPoint = [sender.superview convertPoint:center toView:self.tblTcpPrinter];
    NSIndexPath *indexPath = [self.tblTcpPrinter indexPathForRowAtPoint:rootViewPoint];
    Printers * printer;
    if (indexPath) {
        printer = [self.tcpResultsController objectAtIndexPath:indexPath];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self CheckPrint:printer];
        });
    }
}
-(void)CheckPrint:(Printers *)checkPrinter
{
    NSString *Printername = checkPrinter.name;
    NSMutableDictionary *temp = [[NSMutableDictionary alloc] init];
    [temp setValue: @"TEST PRINT" forKey:@"title"];
    [temp setValue:checkPrinter.portName forKey:@"ip"];
    [temp setValue:Printername forKey:@"name"];
    [PrintData removeAllObjects];
    [PrintData addObject:temp];
    TryDemo = [[InvoiceReceiptPrint alloc] initWithDemoPortName:checkPrinter.portName printData:PrintData withDelegate:self.printerDelegate];
}
#pragma mark Printer Delegate Method

-(void)printerTaskDidFailWithDevice:(NSString *)device statusCode:(NSInteger)statusCode message:(NSString *)message timeStamp:(NSDate *)timeStamp
{
    [self.activityIndicator hideActivityIndicator];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Info" message:@"fail to Print please try again" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    });
}
-(void)printerTaskDidSuccessWithDevice:(NSString *)device
{
    //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ });
    [self.activityIndicator hideActivityIndicator];
}

-(NSString *)checkIPValidation:(NSString *)string
{
    NSString * strErrorMessage = @"";
    if(string.length == 0)
    {
        strErrorMessage = @"Please enter IP Address";
    }
    else if(![string isValidIP])
    {
        strErrorMessage = @"IP is not Valid. Please enter different IP.";
    }
    else {
        Printers *getPrinter = (Printers *)[self fetchEntityWithValue:[NSString stringWithFormat:@"TCP:%@",string] shouldCreate:false moc:self.managedObjectContext];
        if(getPrinter != nil)
        {
            strErrorMessage = @"IP is already Exist. Please Enter another IP.";
        }
    }
    return strErrorMessage;
}
-(IBAction)addNewPrinter:(UIButton *)sender
{
    [self addPrinterAtIndexPath:nil];
}


-(IBAction)editPrinterIP:(UIButton *)sender
{
    CGPoint center= sender.center;
    CGPoint rootViewPoint = [sender.superview convertPoint:center toView:self.tblTcpPrinter];
    NSIndexPath *indexPath = [self.tblTcpPrinter indexPathForRowAtPoint:rootViewPoint];
    
    [self addPrinterAtIndexPath:indexPath];
}
-(void)bluetoothSelect
{
    if ([dictTCPBluetooth[@"PrinterSelection"]isEqualToString:@"TCP"])
    {
        [dictTCPBluetooth removeObjectForKey:@"PrinterSelection"];
        dictTCPBluetooth[@"PrinterSelection"] = @"Bluetooth";
    }
    else
    {
        dictTCPBluetooth[@"PrinterSelection"] = @"Bluetooth";
    }
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"PrinterSelection"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"SelectedTCPPrinter"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"SelectedTCPName"];
    
    [[NSUserDefaults standardUserDefaults] setObject:[dictTCPBluetooth valueForKey:@"PrinterSelection" ] forKey:@"PrinterSelection" ];
    [[NSUserDefaults standardUserDefaults] synchronize ];
}
-(void)TCPSelect
{
    lblSearching.hidden=NO;
    NSOperationQueue *myQueue = [[NSOperationQueue alloc] init];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        _activityIndicator =  [RmsActivityIndicator showActivityIndicator:self.parentViewController.view];
    }];
    [myQueue addOperationWithBlock:^{
        [self searchTCPPrinter];
    }];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self searchTCPPrinter];
//    });
}
-(void)searchTCPPrinter{
    
    [self updatePrintersInCoredata:[SMPort searchPrinter:@"TCP:"]  isScan:true];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_activityIndicator hideActivityIndicator];
        tblTcpPrinter.hidden=NO;
        _btnAddPrinter.hidden = NO;
        
        if(self.tcpResultsController.fetchedObjects.count>0)
        {
            //
            lblSearching.text=@"TCP Printers";
            [tblTcpPrinter reloadData];
            
            btnBluetooth.selected = NO;
            btnTCP.selected = YES;
            
            if ([dictTCPBluetooth[@"PrinterSelection"]isEqualToString:@"Bluetooth"])
            {
                [dictTCPBluetooth removeObjectForKey:@"PrinterSelection"];
                dictTCPBluetooth[@"PrinterSelection"] = @"TCP";
            }
            else
            {
                dictTCPBluetooth[@"PrinterSelection"] = @"TCP";
            }
            [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"PrinterSelection"];
            [[NSUserDefaults standardUserDefaults]setObject:[dictTCPBluetooth valueForKey:@"PrinterSelection" ] forKey:@"PrinterSelection" ];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
        }
        else{
            lblSearching.hidden=YES;
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Info" message:@"No TCP Printer Found" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    });
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - coredata -
-(void)insertSelectedPrinterIfNeeded
{
    NSString *strPrinters = [[NSUserDefaults standardUserDefaults] objectForKey:@"SelectedTCPPrinter"];
    if (strPrinters != nil && strPrinters.length > 0) {
        NSManagedObjectContext *privateMoc = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
        
        //        NSArray *arrTCP = [self setPrinters];
        //        if (arrTCP.count>0) {
        //            [arrTCP setValue:@(0) forKey:@"isSelected"];
        //
        //        }
        [self removeSelectedPrinters];
        PortInfo *p = [[PortInfo alloc]initWithPortName:strPrinters macAddress:@"" modelName:@""];
        [self updatePrintersInCoredata:@[p] isScan:false];
        Printers * anObject = (Printers *)[self fetchEntityWithValue:strPrinters shouldCreate:false moc:privateMoc];
        anObject.isSelected = @(1);
        anObject.isOnline = @(1);
        //        anObject.name = @"";
        //        [[NSUserDefaults standardUserDefaults] setObject:anObject.name forKey:@"SelectedTCPName"];
        [UpdateManager saveContext:privateMoc];
    }
}

-(void)removeSelectedPrinters
{
    NSArray *fetchedData = [self.tcpResultsController fetchedObjects];
    if (fetchedData.count>0) {
        [fetchedData setValue:@(0) forKey:@"isSelected"];
    }
}

- (NSManagedObject*)fetchEntityWithValue:(NSString *)value  shouldCreate:(BOOL)shouldCreate moc:(NsmoContext*)moc
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Printers" inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"portName == %@",value];
    fetchRequest.predicate = predicate;
    NSArray *arryTemp = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    
    NSManagedObject *anObject = nil;
    if (arryTemp.count == 0)
    {
        if(shouldCreate)
        {
            anObject = [NSEntityDescription insertNewObjectForEntityForName:@"Printers" inManagedObjectContext:moc];
        }
    }
    else{
        anObject =arryTemp.firstObject;
    }
    return anObject;
}


-(void)updatePrintersInCoredata:(NSArray *)arrPrinters isScan:(BOOL)isScan
{
    NSManagedObjectContext *privateMoc = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
    for (PortInfo * portInfo in arrPrinters) {
        Printers *objPrinter = (Printers *)[self fetchEntityWithValue:portInfo.portName shouldCreate:TRUE moc:privateMoc];
        objPrinter.portName = portInfo.portName;
//        Printers *objPrinter = (Printers *)[self fetchEntityWithValue:portInfo.portName shouldCreate:TRUE moc:privateMoc];
        if(objPrinter.macAddress == nil){
            objPrinter.macAddress = @"";
        }
        if(objPrinter.modelName == nil)
        {
            objPrinter.modelName = @"";
        }
        if(objPrinter.name == nil || [objPrinter.name isEqualToString:@""])
        {
            NSString *strInputPrinter = objPrinter.portName;
            strInputPrinter = [strInputPrinter stringByReplacingOccurrencesOfString:@"TCP:" withString:@""];
            objPrinter.name = strInputPrinter;
        }
        if(portInfo.macAddress.length >0)
        {
            objPrinter.macAddress = portInfo.macAddress;
        }
        if(portInfo.modelName.length >0)
        {
            objPrinter.modelName = portInfo.modelName;
        }
        NSString *userId = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
        NSString *registerId = (self.rmsDbController.globalDict)[@"RegisterId"];
        objPrinter.userId = @(userId.integerValue);
        objPrinter.registerId = @(registerId.integerValue);
        if(isScan)
        {
            objPrinter.isOnline = @(0);
        }
        else
        {
            objPrinter.isOnline = @(1);
        }
            //        objPrinter.isSelected = FALSE;
    }
    [UpdateManager saveContext:privateMoc];
}
- (NSFetchedResultsController *)tcpResultsController {
    
    if (_tcpResultsController != nil) {
        return _tcpResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Printers" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"isOnline" ascending:YES];
    NSArray *sortDescriptors = @[aSortDescriptor];
    fetchRequest.sortDescriptors = sortDescriptors;
    
    _tcpResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"isOnline" cacheName:nil];
    [_tcpResultsController performFetch:nil];
    _tcpResultsController.delegate = self;
    return _tcpResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    if (![controller isEqual:self.tcpResultsController]) {
        return;
    }
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tblTcpPrinter beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    if (![controller isEqual:self.tcpResultsController]) {
        return;
    }
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tblTcpPrinter insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tblTcpPrinter deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if (![controller isEqual:self.tcpResultsController]) {
        return;
    }
    [self.tblTcpPrinter endUpdates];
}


#pragma mark - CoreData Delegate -
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    if (![controller isEqual:self.tcpResultsController]) {
        return;
    }
    
    UITableView *tableView = self.tblTcpPrinter;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate:
            if ([tableView.indexPathsForVisibleRows indexOfObject:indexPath] != NSNotFound) {
                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

@end
