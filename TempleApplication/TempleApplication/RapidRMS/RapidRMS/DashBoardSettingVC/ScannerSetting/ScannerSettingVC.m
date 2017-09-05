//
//  ScannerSettingController.m
//  I-RMS
//  Created by Siya Infotech on 25/10/13.
//  Copyright (c) 2013 Siya Infotech. All rights reserved.
//

#import "ScannerSettingVC.h"
#import "RmsDbController.h"
#import "UPCSettingCustomCell.h"
#import "UITableViewCell+NIB.h"
#import "RIMNumberPadPopupVC.h"

@interface ScannerSettingVC () <UPCSettingCustomCellDelegate>
{
    NSArray *upcTypes;
    
    NSMutableDictionary *dictDeviceSet;
}

@property (nonatomic, weak) IBOutlet UIButton *btn_DeviceScan;
@property (nonatomic, weak) IBOutlet UIButton *btn_BluetoothScan;

@property (nonatomic, weak) IBOutlet UIView *uvScanOption;
@property (nonatomic, weak) IBOutlet UISwitch *scannerSwitch;
@property (nonatomic, weak) IBOutlet UITableView *tblUpcSetting;

@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) UIPopoverPresentationController *popOverController;

@property (nonatomic, strong) NSMutableArray *upcSettingArray;

@end

@implementation ScannerSettingVC
@synthesize btn_BluetoothScan,btn_DeviceScan;

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
    self.rmsDbController = [RmsDbController sharedRmsDbController];

    dictDeviceSet = [[NSMutableDictionary alloc] init];
    [self setScanner];
    
    upcTypes = @[@"UPC - A",@"UPC - B",@"UPC - C",@"UPC - D"];
    
    // DatewiseDiscountCell_iPad
    NSString *UPCSettingCustomCellNib;
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        UPCSettingCustomCellNib = @"UPCSettingCustomCell_iPhone";
    }
    else
    {
        UPCSettingCustomCellNib = @"UPCSettingCustomCell";
    }
    UINib *UPCSettingNib = [UINib nibWithNibName:UPCSettingCustomCellNib bundle:nil];
    [self.tblUpcSetting registerNib:UPCSettingNib forCellReuseIdentifier:@"UPCSettingCustomCell"];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(upcSettingChangedNotification:) name:@"UpcSettingChangedNotification" object:nil];
    self.upcSettingArray = [[NSUserDefaults standardUserDefaults]objectForKey:@"UPC_Setting"];
    if (([self.upcSettingArray isKindOfClass:[NSMutableArray class]] || [self.upcSettingArray isKindOfClass:[NSArray class]]) &&  (self.upcSettingArray.count > 2))
    {
        [self.tblUpcSetting reloadData];
    }
    else
    {
        [self updateUPCsetting];
    }
}

-(IBAction)btnBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UpcSettingChangedNotification" object:nil];
}

- (int)checkUpcSettingDictionary:(NSDictionary *)p1
{
    int type = 10;
    if([p1[@"settingId"] isEqualToString:@"1"])
    {
        type = 1;
    }
    else if([p1[@"settingId"] isEqualToString:@"2"])
    {
        type = 2;
    }
    else if([p1[@"settingId"] isEqualToString:@"3"])
    {
        type = 3;
    }
    else if([p1[@"settingId"] isEqualToString:@"4"])
    {
        type = 4;
    }
    return type;
}

- (void) upcSettingChangedNotification:(NSNotification *)notification
{
    // Replace dictionary at proper index
    int settingId = [self checkUpcSettingDictionary:notification.userInfo];
    if(settingId >= 1 && settingId <= 4 )
    {
        if ([self.upcSettingArray isKindOfClass:[NSMutableArray class]])
        {
            self.upcSettingArray = [self.upcSettingArray mutableCopy ];
            (self.upcSettingArray)[settingId - 1] = notification.userInfo;
        }
        else
        {
            NSLog(@"self.upcSettingArray class : %@",[self.upcSettingArray class]);
        }
    }
    // Save setting to NSUserDefaults
    [[NSUserDefaults standardUserDefaults] setObject:self.upcSettingArray forKey:@"UPC_Setting"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    [self.tblUpcSetting reloadData];
}

-(void)updateUPCsetting
{
    self.upcSettingArray = [[NSMutableArray alloc] init ];
    NSMutableDictionary *UpcSettingDict = [@{
                                             @"settingId":@"",
                                             @"UpcSwitch":@"0",
                                             @"UpcLimit":@"0",
                                             @"LeadingDigit":@"0",
                                             @"CheckDigit":@"0",
                                             } mutableCopy ];
    [self.upcSettingArray addObject:[UpcSettingDict mutableCopy ]];
    [self.upcSettingArray addObject:[UpcSettingDict mutableCopy ]];
    [self.upcSettingArray addObject:[UpcSettingDict mutableCopy ]];
    [self.upcSettingArray addObject:[UpcSettingDict mutableCopy ]];
    
    self.upcSettingArray[0] [@"settingId"] = @"1";
    self.upcSettingArray[1] [@"settingId"] = @"2";
    self.upcSettingArray[2] [@"settingId"] = @"3";
    self.upcSettingArray[3] [@"settingId"] = @"4";
    
    [[NSUserDefaults standardUserDefaults] setObject:self.upcSettingArray forKey:@"UPC_Setting"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.tblUpcSetting reloadData];
}

-(void)setScanner
{
    NSString *Str = (self.rmsDbController.globalScanDevice)[@"Type"];
    if(self.rmsDbController.globalScanDevice.count > 0)
    {
        if ([Str isEqualToString:@"Bluetooth"])
        {
            btn_BluetoothScan.selected = YES;
            btn_DeviceScan.selected = NO;
            
        }
        if ([Str isEqualToString:@"Scanner"])
        {
            btn_BluetoothScan.selected = NO;
            btn_DeviceScan.selected = YES;
        }
    }
    else
    {
        _scannerSwitch.on = FALSE;
    }
}

-(IBAction)btnBackClicked:(id)sender
{
    [self.rmsDbController playButtonSound];
}

-(IBAction)btnDeviceScanClicked:(id)sender
{
    [self.rmsDbController playButtonSound];
    btn_BluetoothScan.selected = NO;
    btn_DeviceScan.selected = YES;
    [self DeviceSelect];
}

-(void)DeviceSelect
{
    if ([dictDeviceSet[@"id"]isEqualToString:@"Bluetooth"])
    {
        [dictDeviceSet removeObjectForKey:@"id"];
        dictDeviceSet[@"id"] = @"Scanner";
    }
    else
    {
        dictDeviceSet[@"id"] = @"Scanner";
    }
    [self btnDoneClicked:nil];
}

-(IBAction)btnBluetoothScanClicked:(id)sender
{
    [self.rmsDbController playButtonSound];
    btn_BluetoothScan.selected = YES;
    btn_DeviceScan.selected = NO;
    [self bluetoothSelect];
}

-(void)bluetoothSelect
{
    if ([dictDeviceSet[@"id"]isEqualToString:@"Scanner"])
    {
        [dictDeviceSet removeObjectForKey:@"id"];
        dictDeviceSet[@"id"] = @"Bluetooth";
    }
    else
    {
        dictDeviceSet[@"id"] = @"Bluetooth";
    }
    [self btnDoneClicked:nil];
}

-(IBAction)btnDoneClicked:(id)sender
{
    [self.rmsDbController playButtonSound];
    if (![dictDeviceSet[@"Type"] isEqualToString:@""])
    {
        NSString *strViewDictString = dictDeviceSet[@"id"];
        
        if([strViewDictString isKindOfClass:[NSString class]])
        {
            if ([strViewDictString isEqualToString:@"<null>"])
            {
                (self.rmsDbController.globalScanDevice)[@"Type"] = @"Bluetooth";
            }
            else
            {
                (self.rmsDbController.globalScanDevice)[@"Type"] = strViewDictString;
                [[NSUserDefaults standardUserDefaults] setObject:dictDeviceSet[@"id"] forKey:@"ScannerType"];
                [[NSUserDefaults standardUserDefaults]synchronize];
            }
        }
        else
        {
            if ([(self.rmsDbController.globalScanDevice)[@"Type"] isEqualToString:@"Scanner"])
            {
                (self.rmsDbController.globalScanDevice)[@"Type"] = @"Scanner";
            }
            else
            {
                (self.rmsDbController.globalScanDevice)[@"Type"] = @"Bluetooth";
            }
        }
    }
}

- (IBAction)scannerSwitchSetting:(id)sender
{
    [self.rmsDbController playButtonSound];
    if(_scannerSwitch.on)
    {
        _uvScanOption.userInteractionEnabled = YES;
        self.rmsDbController.globalScanDevice = [[NSMutableDictionary alloc] init];
    }
    else
    {
        btn_BluetoothScan.selected = NO;
        btn_DeviceScan.selected = NO;
        _uvScanOption.userInteractionEnabled = NO;
        
        dictDeviceSet[@"id"] = @"";
        (self.rmsDbController.globalScanDevice)[@"Type"] = @"";
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"ScannerType"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        self.rmsDbController.globalScanDevice = nil;
    }
}

#pragma mark - UITableView Delegate Method

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 23.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(tableView == self.tblUpcSetting) 
    {
        return [NSString stringWithFormat:@"%@ SETTING",upcTypes[section]];
    }
        return @"";
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 20)];

    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 150, 20)];
    [lbl setFont:[UIFont fontWithName:@"Lato-Bold" size:12.0]];
    lbl.backgroundColor = [UIColor clearColor];
    lbl.textColor = [UIColor whiteColor];
    lbl.text = [self tableView:tableView titleForHeaderInSection:section];
    [view addSubview:lbl];
    [view setBackgroundColor:[UIColor colorWithWhite:0.667 alpha:0.60]];
    return view;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"UPCSettingCustomCell";
    UPCSettingCustomCell *upcCell = (UPCSettingCustomCell *)[self.tblUpcSetting dequeueReusableCellWithIdentifier:cellIdentifier];
    upcCell.uPCSettingCustomCellDelegate = self;
    upcCell.backgroundColor = [UIColor clearColor];
    upcCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    upcCell.lblupcType.text = upcTypes[indexPath.section];
    upcCell.updSettingDict = [self.upcSettingArray[indexPath.section] mutableCopy ];
    [upcCell refreshUpcSettingCell];
    return upcCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

-(void)textFieldInCellDidReturn:(UITableViewCell *)cell
{
    NSIndexPath* indexPathForCell = [self.tblUpcSetting indexPathForCell:cell];
    if(indexPathForCell.row < [self.tblUpcSetting numberOfRowsInSection:indexPathForCell.section]-1)
    {
        NSIndexPath* nextIndexPathInSection = [NSIndexPath indexPathForRow:indexPathForCell.row+1 inSection:indexPathForCell.section];
        UITableViewCell* nextCellInSection = [self.tblUpcSetting cellForRowAtIndexPath:nextIndexPathInSection];
        if (nextCellInSection)
        {
            [nextCellInSection becomeFirstResponder];
        }
        else
        {
         //   indexPathOfFirstResponder = nextIndexPathInSection;
            [self.tblUpcSetting scrollToRowAtIndexPath:nextIndexPathInSection atScrollPosition:(UITableViewScrollPositionMiddle) animated:YES];
        }
    }
    else
    {
        [self.tblUpcSetting endEditing:YES];
    }
}

//-(void)launchPopUp:(id)priceInputDelegate forTextField:(UITextField *)textField isQty:(BOOL)isQty sourceRect:(CGRect)sourceRect sourceView:(UIView *)view {
//    popoverController = [[PopOverControllerDelegate alloc] initWithNibName:@"PopOverControllerDelegate" bundle:nil];
//    popoverController.priceInputDelegate = priceInputDelegate;
//    popoverController.inputControl = textField;
//    popoverController.isQty = isQty;
//    
//    // Present the view controller using the popover style.
//    popoverController.modalPresentationStyle = UIModalPresentationPopover;
//    [self presentViewController:popoverController animated:YES completion:nil];
//    
//    // Get the popover presentation controller and configure it.
//    self.popOverController = [popoverController popoverPresentationController];
//    self.popOverController.delegate = self;
//    popoverController.preferredContentSize = CGSizeMake(popoverController.view.frame.size.width, popoverController.view.frame.size.height);
//    self.popOverController.permittedArrowDirections = UIPopoverArrowDirectionAny;
//    self.popOverController.sourceView = view;
//    self.popOverController.sourceRect = sourceRect;
//}

//-(void)showInputPriceingView:(UITextField *)textField {
//    UPCSettingCustomCell *upcCell = [[UPCSettingCustomCell alloc]init];
//    upcCell.uPCSettingCustomCellDelegate = self;
//
//    RIMNumberPadPopupVC * objRIMNumberPadPopupVC = [RIMNumberPadPopupVC getInputPopupWith:NumberPadPickerTypesQTY NumberPadCompleteInput:^(NSNumber *numInput, NSString *strInput, id inputView) {
//        [upcCell didEnter:inputView inputValue:numInput.floatValue];
//    } NumberPadColseInput:^(UIViewController *popUpVC) {
//        [((RIMNumberPadPopupVC *) popUpVC) popoverPresentationControllerShouldDismissPopover];
//    }];
//    objRIMNumberPadPopupVC.inputView = textField;
//    [objRIMNumberPadPopupVC presentViewControllerForviewConteroller:self sourceView:textField ArrowDirection:UIPopoverArrowDirectionLeft];
//
//}
//-(void)dismissPopUp {
//    [popoverController dismissViewControllerAnimated:YES completion:nil];
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
