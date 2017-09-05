//
//  TenderConfigurationViewController.m
//  RapidRMS
//
//  Created by Siya on 28/05/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "TenderConfigurationViewController.h"
#import "RmsDbController.h"
#import "TenderPay+Dictionary.h"
#import "Configuration+Dictionary.h"
#import "PopOverControllerDelegate.h"
#import "AddPaymentMasterVC.h"
#import "TenderConfigApplyTaxCell.h"
#import "TenderConfigChangeDueTimerCell.h"
#import "TenderConfigSwitchCell.h"
#import "RIMNumberPadPopupVC.h"


typedef enum SelectedPaymentGateWay{
    BridgePay = 1,
    Pax,
}SelectedPaymentGateWay;


typedef NS_ENUM(NSUInteger, OTHER_TENDER_OPTION) {
    SWITCH_GAS_RECEIPT,
    SWITCH_CCBATCH_RECEIPT,
    SWITCH_TIP,
    SWITCH_CHANGE_DUE_TIMER,
    SWITCH_APPLY_TAX,
};



@interface TenderConfigurationViewController ()<PriceInputDelegate,UIPopoverPresentationControllerDelegate,UITextFieldDelegate>
{
    IntercomHandler *intercomHandler;
    NSInteger selectedPaymentGateWay;
    PopOverControllerDelegate * popoverController;
    TenderConfigChangeDueTimerCell *changeDuecell;
    TenderConfigApplyTaxCell *applyTaxcell;
    TenderConfigSwitchCell *switchCell;
}

@property (nonatomic, weak) IBOutlet UITextField *chenDueTimerTextField;
@property (nonatomic, weak) IBOutlet UITableView *tblPaymentType;
@property (nonatomic, weak) IBOutlet UITableView *tblOtherOption;
@property (nonatomic, strong) NSMutableArray *otherOption;

@property (nonatomic, weak) IBOutlet UIButton * btnApplyTaxOriginal;
@property (nonatomic, weak) IBOutlet UIButton * btnApplyTaxDiscount;
@property (nonatomic, weak) IBOutlet UISwitch *tipSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *changeDueTimerSwitch;

@property (nonatomic, strong) RcrController *crmController;
@property (nonatomic, strong) RmsDbController *rmsDbController;

@property (nonatomic, strong) NSMutableArray *arrInfo;
@property (nonatomic, strong) NSMutableArray *arrpaymentType;

@property (nonatomic, strong) UIPopoverPresentationController *popOverController;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;




@end

@implementation TenderConfigurationViewController
@synthesize dashBoard;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UIFont *font = [UIFont fontWithName:@"Helvetica Neue" size:17.0];
    NSDictionary *attributes = @{NSFontAttributeName: font,
                                NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    [UINavigationBar appearance].titleTextAttributes = attributes;
    
    
    self.title=@"Tender Configuration";
    self.arrInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"TendConfig"];
    [self.arrpaymentType removeAllObjects];
    [self GetPaymentData];
    [_tblPaymentType reloadData];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.navigationBarHidden = NO;
   // [tblPaymentType reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *image3 = [UIImage imageNamed:@"RmsheaderLogo.png"];
    CGRect frameimg = CGRectMake(0, 0, image3.size.width, image3.size.height);
    UIButton *someButton = [[UIButton alloc] initWithFrame:frameimg];
    [someButton setBackgroundImage:image3 forState:UIControlStateNormal];
    UIBarButtonItem *mailbutton =[[UIBarButtonItem alloc] initWithCustomView:someButton];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
    UIBarButtonItem *intercom =[[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItems = @[mailbutton,intercom];
    intercomHandler = [[IntercomHandler alloc] initWithButtton:button withViewController:self];
    
    self.automaticallyAdjustsScrollViewInsets=NO;
    
    self.arrpaymentType = [[NSMutableArray alloc] init];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.crmController = [RcrController sharedCrmController];
    
    self.managedObjectContext=self.rmsDbController.managedObjectContext;
    
    self.managedObjectContext=self.rmsDbController.managedObjectContext;
    
    
    NSString *gateWay = [self.rmsDbController.paymentCardTypearray.firstObject valueForKey:@"Gateway"];
//        gateWay = @"Pax";
    if ([gateWay isEqualToString:@"Pax"])
    {
        selectedPaymentGateWay = Pax;
    }
    else if ([gateWay isEqualToString:@"Bridgepay"])
    {
        selectedPaymentGateWay = BridgePay;
    }
    else
    {
        selectedPaymentGateWay = BridgePay;
        
    }

    
    
//    [self setTipSwitchStatus];
//    [self setChangeDueTimerSetting];
//    [self setTaxApplySetting];
    
    // TenderConfigSwitchCell
    UINib *switchNib = [UINib nibWithNibName:@"TenderConfigSwitchCell" bundle:nil];
    [self.tblOtherOption registerNib:switchNib forCellReuseIdentifier:@"TenderConfigSwitchCell"];
    
    // TenderConfigChangeDueTimer
    UINib *changeDueNib = [UINib nibWithNibName:@"TenderConfigChangeDueTimerCell" bundle:nil];
    [self.tblOtherOption registerNib:changeDueNib forCellReuseIdentifier:@"TenderConfigChangeDueTimerCell"];
    
    // TenderConfigApplyTaxCell
    UINib *applyTaxNib = [UINib nibWithNibName:@"TenderConfigApplyTaxCell" bundle:nil];
    [self.tblOtherOption registerNib:applyTaxNib forCellReuseIdentifier:@"TenderConfigApplyTaxCell"];
    
    
    
    if([self isRcrGasActive]){
          self.otherOption = [[NSMutableArray alloc] initWithObjects:@(SWITCH_GAS_RECEIPT),@(SWITCH_CCBATCH_RECEIPT),@(SWITCH_TIP),@(SWITCH_CHANGE_DUE_TIMER),@(SWITCH_APPLY_TAX), nil];
    }
    else{
        self.otherOption = [[NSMutableArray alloc] initWithObjects:@(SWITCH_CCBATCH_RECEIPT),@(SWITCH_TIP),@(SWITCH_CHANGE_DUE_TIMER),@(SWITCH_APPLY_TAX), nil];
    }
  
    // Do any additional setup after loading the view from its nib.
}


-(BOOL)isRcrGasActive
{
    NSPredicate *deactive = [NSPredicate predicateWithFormat:@"MacAdd == %@ AND IsRelease == 0", (self.rmsDbController.globalDict)[@"DeviceId"]];
    
    NSMutableArray *activeModulesArray = [[self.rmsDbController.appsActvDeactvSettingarray filteredArrayUsingPredicate:deactive] mutableCopy];
    
    BOOL isRcrActive = FALSE;
    NSPredicate *rcrActive = [NSPredicate predicateWithFormat:@"ModuleCode == %@",@"RCRGAS"];
    NSArray *rcrArray = [activeModulesArray filteredArrayUsingPredicate:rcrActive];
    if (rcrArray.count > 0) {
        isRcrActive = TRUE;
    }
    return isRcrActive;
}

- (void)updateViewWithChangeDueTimerSetting:(NSNumber *)changeDueTimeSettingValue
{
    if([changeDueTimeSettingValue isEqual: @(1)])
    {
        _changeDueTimerSwitch.on = YES;
    }
    else
    {
        _changeDueTimerSwitch.on = NO;
    }
}

-(IBAction)changeApplyTaxType:(UIButton *)sender {
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tblOtherOption];
    NSIndexPath *indexPath = [self.tblOtherOption indexPathForRowAtPoint:buttonPosition];
    applyTaxcell = [self.tblOtherOption cellForRowAtIndexPath:indexPath];
    
    [self.view endEditing:YES];
    applyTaxcell.btnApplyTaxOriginal.selected = FALSE;
    applyTaxcell.btnApplyTaxDiscount.selected = FALSE;
    sender.selected = TRUE;
    
    NSInteger taxSetting = TAX_APPLY_FOR_DISCOUNT_PRICE;
    
    if (applyTaxcell.btnApplyTaxDiscount.selected == YES)
    {
        taxSetting = TAX_APPLY_FOR_DISCOUNT_PRICE;
    }
    if (applyTaxcell.btnApplyTaxOriginal.selected == YES) {
        taxSetting = TAX_APPLY_FOR_ORIGNAL_PRICE;
    }
    
    [self updateTaxSettingWith:taxSetting];

}

-(void)updateTaxSettingWith:(TAX_Setting)taxSetting
{
    NSMutableDictionary *dictionayForTaxSetting = [[NSMutableDictionary alloc]init];
    dictionayForTaxSetting[@"ApplyTax"] = @(taxSetting);
    [[NSUserDefaults standardUserDefaults] setObject:dictionayForTaxSetting forKey:@"Tax_Setting"];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

-(void)setTaxApplySetting
{
    NSDictionary *changeTaxApply = [[NSUserDefaults standardUserDefaults] objectForKey:@"Tax_Setting"];
    if (changeTaxApply != nil) {
        [self updateTaxSetting:[changeTaxApply valueForKey:@"ApplyTax"]];
    }
    else
    {
        _btnApplyTaxDiscount.selected = YES;
        [self updateTaxSettingWith:TAX_APPLY_FOR_DISCOUNT_PRICE];
    }
}

- (void)updateTaxSetting:(NSNumber *)changeTaxValue
{
    if([changeTaxValue isEqual: @(TAX_APPLY_FOR_DISCOUNT_PRICE)])
    {
        _btnApplyTaxDiscount.selected = YES;
    }
    else if([changeTaxValue isEqual: @(TAX_APPLY_FOR_ORIGNAL_PRICE)])
    {
        _btnApplyTaxOriginal.selected = YES;
    }
    else{
        _btnApplyTaxDiscount.selected = YES;
    }
}

-(void)setChangeDueTimerSetting
{
    NSDictionary *changeDueTimeDictionary = [[NSUserDefaults standardUserDefaults] objectForKey:@"ChangeDue_Setting"];
    if (changeDueTimeDictionary != nil) {
       [self updateViewWithChangeDueTimerSetting:[changeDueTimeDictionary valueForKey:@"changeDueTimerSwitch"]];
          _chenDueTimerTextField.text = [NSString stringWithFormat:@"%.0f",[[changeDueTimeDictionary valueForKey:@"changeDueTimerValue"] floatValue]];
    }
    else
    {
        _changeDueTimerSwitch.on = NO;
    }
}

- (void)updateViewWithTipSetting:(NSNumber *)tipSetting withTipCell:(TenderConfigSwitchCell *)tipCell
{
    if([tipSetting isEqual: @(1)])
    {
        tipCell.onOffSwitch.on = YES;
    }
    else
    {
        tipCell.onOffSwitch.on = NO;
    }
}
-(IBAction)btnAddPaymentClick:(id)sender
{
    BOOL hasRights = [UserRights hasRights:UserRightInventoryInfo];
    if (!hasRights) {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"User Rights" message:@"You don't have rights to add new payment mode. Please contact to Admin." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        return;
    }

    AddPaymentMasterVC *addPaymentMasterVC =
    [[UIStoryboard storyboardWithName:@"RimStoryboard" bundle:NULL] instantiateViewControllerWithIdentifier:@"AddPaymentMasterVC_sid"];
    [self.navigationController pushViewController:addPaymentMasterVC animated:TRUE];
//    [self.view addSubview:addPaymentMasterVC.view];
 //   [self pu:addPaymentMasterVC animated:TRUE completion:nil];

}

//-(void)setTipSwitchStatus
//{
//    NSManagedObjectContext *privateContext = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
//    Configuration *configuration = [UpdateManager getConfigurationMoc:privateContext];
//    [self updateViewWithTipSetting:configuration.localTipsSetting];
//    if([configuration.tips isEqual:@(0)])
//    {
//        self.tipSwitch.enabled = NO;
//    }
//    else
//    {
//        self.tipSwitch.enabled = YES;
//    }
//    [privateContext reset];
//}

-(void)GetPaymentData
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TenderPay" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"paymentName" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortDescriptors = @[aSortDescriptor];
    fetchRequest.sortDescriptors = sortDescriptors;
    
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    
    if (resultSet.count > 0)
    {
        for (TenderPay *tender in resultSet) {
            NSMutableDictionary *paymentDict=[[NSMutableDictionary alloc]init];
            paymentDict[@"CardIntType"] = tender.cardIntType;
            paymentDict[@"PayId"] = tender.payId;
            paymentDict[@"PayImage"] = tender.payImage;
            paymentDict[@"PaymentName"] = tender.paymentName;
            [self.arrpaymentType addObject:paymentDict];
        }
    }
    else{
        
    }
    
    NSMutableDictionary *dict1 = [[NSMutableDictionary alloc]init];
    dict1[@"PayId"] = @"0";
    dict1[@"PayImage"] = @"0";
    dict1[@"PaymentName"] = @"0";
    [self.arrpaymentType insertObject:dict1 atIndex:0];
    
    NSMutableArray *arrTemp = [[NSUserDefaults standardUserDefaults] valueForKey:@"TendConfig" ];
    
    if(arrTemp.count > 0)
    {
        self.crmController.globalArrTenderConfig = [arrTemp mutableCopy];
        
    }
    else
        
    {
        NSArray *arrSpecOption = [self.crmController.globalArrTenderConfig valueForKey:@"SpecOption"];
        
        if (self.rmsDbController.isFirstTimeActivate)
        {
            [[NSUserDefaults standardUserDefaults] setObject:self.crmController.globalArrTenderConfig forKey:@"TendConfig"];

        }
        
        if (![arrSpecOption containsObject:@"0"])
        {
            for(int i = 0; i < self.arrpaymentType.count; i++)
            {
                if(i > 0)
                {
                    NSMutableDictionary *paymentDict = (self.arrpaymentType)[i];
                    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
                  
                    dict[@"PayId"] = paymentDict[@"PayId"];
                    dict[@"SpecOption"] = @"5";
                    NSString *strIndexpath  = [NSString stringWithFormat:@"%d5",i];
                    dict[@"indexpath"] = strIndexpath;
                    dict[@"row"] = strIndexpath;
                    
//                    NSLog(@"%@",dict[@"SpecOption"]);
                    
                    dict[@"section"] = @"0";
                    [self.crmController.globalArrTenderConfig insertObject:dict atIndex:0];
                }
            }
            [[NSUserDefaults standardUserDefaults] setObject:self.crmController.globalArrTenderConfig forKey:@"TendConfig"];
        }
        
        
    }
    
    /* int cellCount = [self.arrpaymentType count]-1;
     if(cellCount<=10){
     int tblheight = 44 * cellCount;
     tblPaymentType.frame=CGRectMake(tblPaymentType.frame.origin.x, tblPaymentType.frame.origin.y, tblPaymentType.frame.size.width, tblheight);
     }*/
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    if(tableView == self.tblOtherOption)
    {
        return self.otherOption.count;
    }
    else{
        return 1;
    }

}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == self.tblOtherOption){
        return 1;
    }
    else{
        return (self.arrpaymentType).count-1;
 
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 3.0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
     return 2.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCellStyle style =  UITableViewCellStyleDefault;
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"BaseCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    
    if(tableView == self.tblOtherOption)
    {
        OTHER_TENDER_OPTION tenderOption = [self.otherOption[indexPath.section] integerValue];
        
        if (tenderOption == SWITCH_GAS_RECEIPT) {
            cell = [self gasPrintCell:indexPath];
        }
        else if (tenderOption == SWITCH_CCBATCH_RECEIPT) {
            cell = [self ccBatchPrintCell:indexPath];
            
        }
        else if (tenderOption == SWITCH_TIP) {
            cell = [self tipCell:indexPath];
            
        }
        else if (tenderOption == SWITCH_CHANGE_DUE_TIMER) {
            cell = [self changeDueTimerCell:indexPath];
 
        }
        else if(tenderOption == SWITCH_APPLY_TAX){
             cell = [self applyTaxCell:indexPath];
        }

    }
    else{
        
        UIImageView* img = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"FormRowBgWhite.png"]];
        [cell addSubview:img];
        
        UIView *view =[[UIView alloc]initWithFrame:CGRectMake(0, 0, 734, 40)];
        
        UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(15, 5, 250, 30)];
        lable.text = (self.arrpaymentType)[indexPath.row +1][@"PaymentName"];
        lable.textAlignment = NSTextAlignmentLeft;
        lable.font = [UIFont fontWithName:@"Helvetica Neue" size:16.0];
        lable.backgroundColor = [UIColor clearColor];
        
        [cell addSubview:lable];
        
        NSString *strSubTitle = @"";
        
        NSMutableDictionary *dictTemp = (self.arrpaymentType)[indexPath.row+1];
        
        for(int i=0;i<(self.crmController.globalArrTenderConfig).count;i++)
        {
            NSMutableDictionary *dictGlobel = (self.crmController.globalArrTenderConfig)[i];
            NSString *strPayIDGlole = [NSString stringWithFormat:@"%@",[dictGlobel valueForKey:@"PayId"]];
            NSString *strPayIDTemp = [NSString stringWithFormat:@"%@",[dictTemp valueForKey:@"PayId"]];
            
            if([strPayIDGlole isEqualToString:strPayIDTemp]){
                
                NSString *strIndexPath = [NSString stringWithFormat:@"%@",[dictGlobel valueForKey:@"indexpath"]];
                
                NSString *lastCharacter;
                if(strIndexPath.length == 3)
                {
                    lastCharacter = [strIndexPath substringFromIndex:strIndexPath.length - 2];
                }
                else
                {
                    lastCharacter = [strIndexPath substringFromIndex:strIndexPath.length - 1];
                }
                
                if([lastCharacter isEqualToString:@"0"])
                {
                    strSubTitle=[strSubTitle stringByAppendingString:@"Print Receipt,"];
                }
                //            else if([lastCharacter isEqualToString:@"1"]){
                //
                //                strSubTitle=[strSubTitle stringByAppendingString:@"Prompt Print Receipt,"];
                //            }
                else if([lastCharacter isEqualToString:@"2"]){
                    
                    strSubTitle=[strSubTitle stringByAppendingString:@"Open Cash Drawer,"];
                }
                else if([lastCharacter isEqualToString:@"3"]){
                    
                    strSubTitle=[strSubTitle stringByAppendingString:@"Card Swipe,"];
                }
                else if([lastCharacter isEqualToString:@"4"]){
                    
                    strSubTitle=[strSubTitle stringByAppendingString:@"Multiple Card Swipe,"];
                }
                else if([lastCharacter isEqualToString:@"5"]){
                    
                    strSubTitle=[strSubTitle stringByAppendingString:@"Do Not Print Receipt,"];
                }
                else if([lastCharacter isEqualToString:@"6"]){
                    
                    strSubTitle=[strSubTitle stringByAppendingString:@"RCR Signature Capture,"];
                }
                else if([lastCharacter isEqualToString:@"7"]){
                    
                    strSubTitle=[strSubTitle stringByAppendingString:@"RCD Signature Capture,"];
                }
                
                else if([lastCharacter isEqualToString:@"10"]){
                    
                    strSubTitle=[strSubTitle stringByAppendingString:@"Tender Shortcut,"];
                }
                else if([lastCharacter isEqualToString:@"11"]){
                    
                    strSubTitle=[strSubTitle stringByAppendingString:@"Tender Disable,"];
                }
                else if([lastCharacter isEqualToString:@"14"]){
                    
                    strSubTitle=[strSubTitle stringByAppendingString:@"Pax Signature,"];
                }
                else if([lastCharacter isEqualToString:@"15"]){
                    
                    strSubTitle=[strSubTitle stringByAppendingString:@"Signature Capture on Paper,"];
                }
                
                
                if (selectedPaymentGateWay == Pax) {
                    if([lastCharacter isEqualToString:@"17"]){
                        
                        strSubTitle=[strSubTitle stringByAppendingString:@"Pax,"];
                    }
                    else if([lastCharacter isEqualToString:@"18"]){
                        
                        strSubTitle=[strSubTitle stringByAppendingString:@"Broad Pos,"];
                    }
                }
                else
                {
                    if([lastCharacter isEqualToString:@"12"]){
                        
                        strSubTitle=[strSubTitle stringByAppendingString:@"Bridge Pay,"];
                    }
                    else if([lastCharacter isEqualToString:@"13"]){
                        
                        strSubTitle=[strSubTitle stringByAppendingString:@"Rapid Server,"];
                    }
                    else if([lastCharacter isEqualToString:@"8"]){
                        
                        strSubTitle=[strSubTitle stringByAppendingString:@"iDynamo Card Reader,"];
                    }
                    else if([lastCharacter isEqualToString:@"9"]){
                        
                        strSubTitle=[strSubTitle stringByAppendingString:@"Audio Card Reader,"];
                    }
                }
            }
        }
        
        if(strSubTitle.length>0)
        {
            strSubTitle = [strSubTitle substringToIndex:strSubTitle.length-1];
            
        }
        UILabel *lableDes = [[UILabel alloc] initWithFrame:CGRectMake(130, 5, 515, 30)];
        lableDes.text=strSubTitle;
        lableDes.textColor=[UIColor colorWithRed:142.0/255.0 green:142.0/255.0 blue:142.0/255.0 alpha:1.0];
        lableDes.textAlignment = NSTextAlignmentRight;
        lableDes.font = [UIFont fontWithName:@"Helvetica Neue" size:13];
        // lableDes.backgroundColor = [UIColor clearColor];
        [cell addSubview:lableDes];
        
        
        UIImageView *imgLine;
        if(indexPath.row!=(self.arrpaymentType).count-1) {
            imgLine = [[UIImageView alloc]initWithFrame:CGRectMake(0, 43, 734, 1)];
            imgLine.image = [UIImage imageNamed:@"BreakLine_ipad.png"];
        }
        
        
        UIImageView *imgArrow = [[UIImageView alloc]initWithFrame:CGRectMake(663, 13, 8, 14)];
        imgArrow.image = [UIImage imageNamed:@"ArrowRightNormal.png"];
        
        [view addSubview:imgArrow];
        [view addSubview:lable];
        //[view addSubview:imgLine];
        [cell addSubview:view];
    }
    return cell;
}
- (UITableViewCell *)gasPrintCell:(NSIndexPath *)indexPath
{
    TenderConfigSwitchCell *gasPrintCell = [self.tblOtherOption dequeueReusableCellWithIdentifier:@"TenderConfigSwitchCell" forIndexPath:indexPath];
    gasPrintCell.selectionStyle = UITableViewCellSelectionStyleNone;

    gasPrintCell.optionName.text = @"Print Gas Receipt";
    gasPrintCell.accessoryView = gasPrintCell.onOffSwitch;

    NSDictionary *gasPrintDictionary = [[NSUserDefaults standardUserDefaults] objectForKey:@"GasPrint_Setting"];
    if (gasPrintDictionary != nil) {
        if([[gasPrintDictionary valueForKey:@"GasSwitch"] isEqual: @(1)])
        {
            gasPrintCell.onOffSwitch.on = YES;
        }
        else
        {
            gasPrintCell.onOffSwitch.on = NO;
        }
    }
    else
    {
        gasPrintCell.onOffSwitch.on = NO;
    }
    
    [gasPrintCell.onOffSwitch addTarget:self action:@selector(gasPrint:) forControlEvents:UIControlEventValueChanged];
    return gasPrintCell;
}
-(void)gasPrint:(id)sender{

    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tblOtherOption];
    NSIndexPath *indexPath = [self.tblOtherOption indexPathForRowAtPoint:buttonPosition];
    switchCell = [self.tblOtherOption cellForRowAtIndexPath:indexPath];
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"GasPrint_Setting"]) {
        NSMutableDictionary *dictionayForGasPrint = [[[NSUserDefaults standardUserDefaults] valueForKey:@"GasPrint_Setting"] mutableCopy];
        dictionayForGasPrint[@"GasSwitch"] = @(switchCell.onOffSwitch.on);
        [[NSUserDefaults standardUserDefaults] setObject:dictionayForGasPrint forKey:@"GasPrint_Setting"];
    }
    else
    {
        NSMutableDictionary *dictionayForGasPrint = [[NSMutableDictionary alloc]init];
        dictionayForGasPrint[@"GasSwitch"] = @(switchCell.onOffSwitch.on);
        [[NSUserDefaults standardUserDefaults] setObject:dictionayForGasPrint forKey:@"GasPrint_Setting"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

///** CCbatch Print ***

- (UITableViewCell *)ccBatchPrintCell:(NSIndexPath *)indexPath
{
    TenderConfigSwitchCell *ccBatchPrintCell = [self.tblOtherOption dequeueReusableCellWithIdentifier:@"TenderConfigSwitchCell" forIndexPath:indexPath];
    ccBatchPrintCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    ccBatchPrintCell.optionName.text = @"Print CCBatch Receipt";
    ccBatchPrintCell.accessoryView = ccBatchPrintCell.onOffSwitch;
    
    NSDictionary *printccBatchReceiptDictionary = [[NSUserDefaults standardUserDefaults] objectForKey:@"PrintCCBatchReceiptSetting"];
    
    if (printccBatchReceiptDictionary != nil) {
        if([[printccBatchReceiptDictionary valueForKey:@"PrintCCBatchReceipt"] isEqual: @(1)])
        {
            ccBatchPrintCell.onOffSwitch.on = YES;
        }
        else
        {
            ccBatchPrintCell.onOffSwitch.on = NO;
        }
    }
    else
    {
        ccBatchPrintCell.onOffSwitch.on = NO;
    }
    
    [ccBatchPrintCell.onOffSwitch addTarget:self action:@selector(ccBatchPrint:) forControlEvents:UIControlEventValueChanged];
    return ccBatchPrintCell;
}
-(void)ccBatchPrint:(id)sender{
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tblOtherOption];
    NSIndexPath *indexPath = [self.tblOtherOption indexPathForRowAtPoint:buttonPosition];
    switchCell = [self.tblOtherOption cellForRowAtIndexPath:indexPath];
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"PrintCCBatchReceiptSetting"]) {
        NSMutableDictionary *dictionayForCCBatchPrint = [[[NSUserDefaults standardUserDefaults] valueForKey:@"PrintCCBatchReceiptSetting"] mutableCopy];
        
        dictionayForCCBatchPrint[@"PrintCCBatchReceipt"] = @(switchCell.onOffSwitch.on);
        [[NSUserDefaults standardUserDefaults] setObject:dictionayForCCBatchPrint forKey:@"PrintCCBatchReceiptSetting"];
    }
    else
    {
        NSMutableDictionary *dictionayForCCBatch = [[NSMutableDictionary alloc]init];
        
        dictionayForCCBatch[@"PrintCCBatchReceipt"] = @(switchCell.onOffSwitch.on);
        
        [[NSUserDefaults standardUserDefaults] setObject:dictionayForCCBatch forKey:@"PrintCCBatchReceiptSetting"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (UITableViewCell *)tipCell:(NSIndexPath *)indexPath
{
    TenderConfigSwitchCell *tipCell = [self.tblOtherOption dequeueReusableCellWithIdentifier:@"TenderConfigSwitchCell" forIndexPath:indexPath];
    tipCell.optionName.text = @"Tip";
    tipCell.selectionStyle = UITableViewCellSelectionStyleNone;

    NSManagedObjectContext *privateContext = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
    
    Configuration *configuration = [UpdateManager getConfigurationMoc:privateContext];
    [self updateViewWithTipSetting:configuration.localTipsSetting withTipCell:tipCell];
    if([configuration.tips isEqual:@(0)])
    {
        tipCell.onOffSwitch.enabled = NO;
    }
    else
    {
        tipCell.onOffSwitch.enabled = YES;
    }
    tipCell.accessoryView = tipCell.onOffSwitch;

    [tipCell.onOffSwitch addTarget:self action:@selector(tipSwicheClicked:) forControlEvents:UIControlEventValueChanged];

    return tipCell;
}
- (UITableViewCell *)changeDueTimerCell:(NSIndexPath *)indexPath
{
    TenderConfigChangeDueTimerCell *changeDueCell = [self.tblOtherOption dequeueReusableCellWithIdentifier:@"TenderConfigChangeDueTimerCell" forIndexPath:indexPath];
    changeDueCell.selectionStyle = UITableViewCellSelectionStyleNone;
    changeDueCell.chengDueTimerTextField.delegate = self;
    NSDictionary *changeDueTimeDictionary = [[NSUserDefaults standardUserDefaults] objectForKey:@"ChangeDue_Setting"];
    if (changeDueTimeDictionary != nil) {
        if([[changeDueTimeDictionary valueForKey:@"changeDueTimerSwitch"] isEqual: @(1)])
        {
            changeDueCell.changeDueTimerSwitch.on = YES;
        }
        else
        {
            changeDueCell.changeDueTimerSwitch.on = NO;
        }
        
        changeDueCell.chengDueTimerTextField.text = [NSString stringWithFormat:@"%.0f",[[changeDueTimeDictionary valueForKey:@"changeDueTimerValue"] floatValue]];
    }
    else
    {
        changeDueCell.changeDueTimerSwitch.on = NO;
    }
    [changeDueCell.changeDueTimerSwitch addTarget:self action:@selector(changeDueTimerClicked:) forControlEvents:UIControlEventValueChanged];
    
    return changeDueCell;
}
- (UITableViewCell *)applyTaxCell:(NSIndexPath *)indexPath
{
    TenderConfigApplyTaxCell *applyTaxCell = [self.tblOtherOption dequeueReusableCellWithIdentifier:@"TenderConfigApplyTaxCell" forIndexPath:indexPath];
    applyTaxCell.selectionStyle = UITableViewCellSelectionStyleNone;

    [applyTaxCell.btnApplyTaxDiscount addTarget:self action:@selector(changeApplyTaxType:) forControlEvents:UIControlEventTouchUpInside];
    
     [applyTaxCell.btnApplyTaxOriginal addTarget:self action:@selector(changeApplyTaxType:) forControlEvents:UIControlEventTouchUpInside];
    
    NSDictionary *changeTaxApply = [[NSUserDefaults standardUserDefaults] objectForKey:@"Tax_Setting"];
    if (changeTaxApply != nil) {
        [self updateTaxSetting:[changeTaxApply valueForKey:@"ApplyTax"]];
        
        if([[changeTaxApply valueForKey:@"ApplyTax"] isEqual: @(TAX_APPLY_FOR_DISCOUNT_PRICE)])
        {
            applyTaxCell.btnApplyTaxDiscount.selected = YES;
        }
        else if([[changeTaxApply valueForKey:@"ApplyTax"] isEqual: @(TAX_APPLY_FOR_ORIGNAL_PRICE)])
        {
            applyTaxCell.btnApplyTaxOriginal.selected = YES;
        }
        else{
            applyTaxCell.btnApplyTaxDiscount.selected = YES;
        }

    }
    else
    {
        applyTaxCell.btnApplyTaxDiscount.selected = YES;
        [self updateTaxSettingWith:TAX_APPLY_FOR_DISCOUNT_PRICE];
    }
    
    return applyTaxCell;
}

       
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == self.tblPaymentType){
        
        [self.rmsDbController playButtonSound];
        NSString *strPayID = (self.arrpaymentType)[indexPath.row +1][@"PayId"];
        // [dashBoard tenderConfigurationSub:strPayID];
        self.title=(self.arrpaymentType)[indexPath.row +1][@"PaymentName"];
        NSString *strIndex = [NSString stringWithFormat:@"%ld",(long)indexPath.row+1];
        [dashBoard tenderConfigurationSub:strPayID Index:strIndex arrPaymentType:self.arrpaymentType];

    }
    
}

// Himanshu
// save tips value 
-(IBAction)tipSwicheClicked:(id)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tblOtherOption];
    NSIndexPath *indexPath = [self.tblOtherOption indexPathForRowAtPoint:buttonPosition];
    switchCell = [self.tblOtherOption cellForRowAtIndexPath:indexPath];
    
    NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
    Configuration *configuration = [UpdateManager getConfigurationMoc:privateContextObject];
    if(switchCell.onOffSwitch.on)
    {
        configuration.localTipsSetting = @(1);
    }
    else
    {
        configuration.localTipsSetting = @(0);
    }
    [UpdateManager saveContext:privateContextObject];
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"ChangeDue_Setting"]) {
        NSMutableDictionary *dictionayForTips = [[[NSUserDefaults standardUserDefaults] valueForKey:@"ChangeDue_Setting"] mutableCopy];
        dictionayForTips[@"TipsSwitch"] = @(switchCell.onOffSwitch.on);
        [[NSUserDefaults standardUserDefaults] setObject:dictionayForTips forKey:@"ChangeDue_Setting"];
    }
    else
    {
        NSMutableDictionary *dictionayForTips = [[NSMutableDictionary alloc]init];
        dictionayForTips[@"TipsSwitch"] = @(switchCell.onOffSwitch.on);
        [[NSUserDefaults standardUserDefaults] setObject:dictionayForTips forKey:@"ChangeDue_Setting"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)changeDueStoreDataInUserDefault:(UITextField *)timerTextField withSwitch:(UISwitch *)changeDueTimerSwitch
{
    NSMutableDictionary *dictionayForChangDueTimer = [[NSMutableDictionary alloc]init];
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"ChangeDue_Setting"] valueForKey:@"TipsSwitch"]) {
        dictionayForChangDueTimer[@"TipsSwitch"] = [[[NSUserDefaults standardUserDefaults] valueForKey:@"ChangeDue_Setting"] valueForKey:@"TipsSwitch"];
    }
    dictionayForChangDueTimer[@"changeDueTimerSwitch"] = @(changeDueTimerSwitch.on);
    dictionayForChangDueTimer[@"changeDueTimerValue"] = [NSString stringWithFormat:@"%.2f",(timerTextField.text).floatValue];
    [[NSUserDefaults standardUserDefaults] setObject:dictionayForChangDueTimer forKey:@"ChangeDue_Setting"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// Hiren
// ChangeDue Time Setting

-(IBAction)changeDueTimerClicked:(id)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tblOtherOption];
    NSIndexPath *indexPath = [self.tblOtherOption indexPathForRowAtPoint:buttonPosition];
    changeDuecell = [self.tblOtherOption cellForRowAtIndexPath:indexPath];
    
    if (changeDuecell.changeDueTimerSwitch.on ==  YES && (changeDuecell.chengDueTimerTextField.text).floatValue == 0.00 ) {
        UIAlertView *changeDueAlert = [[UIAlertView alloc]initWithTitle:@"Info" message:@"Please add timer value" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [changeDueAlert show];
        changeDuecell.changeDueTimerSwitch.on = NO;
        return;
    }
    
    [self changeDueStoreDataInUserDefault:changeDuecell.chengDueTimerTextField withSwitch:changeDuecell.changeDueTimerSwitch];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    changeDuecell = (TenderConfigChangeDueTimerCell*) textField.superview.superview;

    if (textField == changeDuecell.chengDueTimerTextField)
    {
        RIMNumberPadPopupVC * objRIMNumberPadPopupVC = [RIMNumberPadPopupVC getInputPopupWith:NumberPadPickerTypesQTY NumberPadCompleteInput:^(NSNumber *numInput, NSString *strInput, id inputView) {
            if(numInput.floatValue > 0) {
                textField.text = numInput.stringValue;
            }
        } NumberPadColseInput:^(UIViewController *popUpVC) {
            [((RIMNumberPadPopupVC *) popUpVC) popoverPresentationControllerShouldDismissPopover];
        }];
        objRIMNumberPadPopupVC.inputView = textField;
        [objRIMNumberPadPopupVC presentViewControllerForviewConteroller:self sourceView:textField ArrowDirection:UIPopoverArrowDirectionLeft];
        [self.view endEditing:YES];
        return FALSE;
    }
    return YES;
}
-(void)didEnter:(id)inputControl inputValue:(CGFloat)inputValue
{
    if(inputValue == 0.00)
    {
        UIAlertView *changeDueAlert = [[UIAlertView alloc]initWithTitle:@"Info" message:@"Please Enter valid second" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [changeDueAlert show];
        return;
    }
    
    [popoverController dismissViewControllerAnimated:YES completion:nil];
    changeDuecell.chengDueTimerTextField.text = [NSString stringWithFormat:@"%.0f",inputValue];
    [self changeDueStoreDataInUserDefault:changeDuecell.chengDueTimerTextField withSwitch:changeDuecell.changeDueTimerSwitch];
}
-(void)didCancel
{
    [popoverController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
