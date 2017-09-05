//
//  TenderConfigurationSubViewController.m
//  RapidRMS
//
//  Created by Siya on 28/05/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "TenderConfigurationSubEditVC.h"
#import "RmsDbController.h"
#import "TenderPay+Dictionary.h"
#import "RcrController.h"
#import "TenderConfigReceiptCell.h"
#import "TenderConfigSwitchCell.h"


typedef enum SelectedPaymentGateWay{
    BridgePay = 1,
    Pax,
}SelectedPaymentGateWay;


@interface TenderConfigurationSubEditVC ()
{
    NSString *cardIntType;
    IntercomHandler *intercomHandler;
    NSInteger selectedPaymentGateWay;
}

@property (nonatomic, weak) IBOutlet UIImageView *printImageView;
@property (nonatomic, weak) IBOutlet UIImageView *promptImageView;
@property (nonatomic, weak) IBOutlet UIImageView *doNotPrintImageView;

@property (nonatomic, weak) IBOutlet UILabel *lblPrintReciept;
@property (nonatomic, weak) IBOutlet UILabel *lblPromptPrint;
@property (nonatomic, weak) IBOutlet UILabel *lblCashDrawer;
@property (nonatomic, weak) IBOutlet UILabel *lblCardswipe;
@property (nonatomic, weak) IBOutlet UILabel *lblDoNotPrint;

@property (nonatomic, weak) IBOutlet UIButton *btnPromptPrintReceipt;
@property (nonatomic, weak) IBOutlet UIButton *btnDoNotPrintReceipt;
@property (nonatomic, weak) IBOutlet UIButton *btnPrintReceipt;

@property (nonatomic, weak) IBOutlet UITableView *tenderConfigurationOptiontbl;

@property (nonatomic, strong) RcrController *crmController;
@property (nonatomic, strong) RmsDbController *rmsDbController;

@property (nonatomic) BOOL isPrintReceipt;
@property (nonatomic) BOOL isPromptPrintReceipt;
@property (nonatomic) BOOL isDoNotPrintReceipt;
@property (nonatomic) BOOL isPOSReceipt;
@property (nonatomic) BOOL isCustDispReceipt;

@property (nonatomic) BOOL isCashDrawerOpen;
@property (nonatomic) BOOL isCardSwipe;
@property (nonatomic) BOOL isMultipleCardSwipe;
@property (nonatomic) BOOL isTenderShortcut;
@property (nonatomic) BOOL isiDynamoCardReaderSelected;
@property (nonatomic) BOOL isAudioCardReaderSelected;
@property (nonatomic) BOOL isBridgePaySelected;
@property (nonatomic) BOOL isServerSelected;
@property (nonatomic) BOOL isPaxSignatureSelected;
@property (nonatomic) BOOL isSignatureCaptureOnPaperSelected;
@property (nonatomic) BOOL isSignatureApplicable;
@property (nonatomic) BOOL isTenderDisable;



@property (nonatomic) BOOL isPaxApplicable;
@property (nonatomic) BOOL isBroadPosApplicable;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation TenderConfigurationSubEditVC
@synthesize strIndex,strPayID,btnPrintReceipt,btnPromptPrintReceipt,btnDoNotPrintReceipt,printImageView,promptImageView,doNotPrintImageView;

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
    
    cardIntType = [(self.arrpaymentType)[self.strIndex.integerValue] valueForKey:@"CardIntType"];
//    
//    if (![cardIntType isEqualToString:@"Credit"])
//    {
//        self.isCardSwipe = NO;
//        self.isMultipleCardSwipe = NO;
//        self.isiDynamoCardReaderSelected = NO;
//        self.isAudioCardReaderSelected= NO;
//    }
    
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    
    NSString *gateWay = [self.rmsDbController.paymentCardTypearray.firstObject valueForKey:@"Gateway"];
//    gateWay = @"Pax";
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
    
    
    self.navigationItem.backBarButtonItem.target = self;
    self.navigationItem.backBarButtonItem.action = @selector(backButtonDidPressed:);
    
    UIImage* image3 = [UIImage imageNamed:@"RmsheaderLogo.png"];
    CGRect frameimg = CGRectMake(0, 0, image3.size.width, image3.size.height);
    UIButton *someButton = [[UIButton alloc] initWithFrame:frameimg];
    [someButton setBackgroundImage:image3 forState:UIControlStateNormal];
    UIBarButtonItem *mailbutton =[[UIBarButtonItem alloc] initWithCustomView:someButton];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
    UIBarButtonItem *intercom =[[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItems = @[mailbutton,intercom];
    intercomHandler = [[IntercomHandler alloc] initWithButtton:button withViewController:self];
    
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.crmController = [RcrController sharedCrmController];

    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    
    // TenderConfigReceiptCell
    UINib *receiptNib = [UINib nibWithNibName:@"TenderConfigReceiptCell" bundle:nil];
    [self.tenderConfigurationOptiontbl registerNib:receiptNib forCellReuseIdentifier:@"TenderConfigReceiptCell"];
    
    // TenderConfigSwitchCell
    UINib *switchNib = [UINib nibWithNibName:@"TenderConfigSwitchCell" bundle:nil];
    [self.tenderConfigurationOptiontbl registerNib:switchNib forCellReuseIdentifier:@"TenderConfigSwitchCell"];
    
//    NSString *paymentId = [[self.arrpaymentType objectAtIndex:[self.strIndex integerValue]] valueForKey:@"PayId"];
    

    [self reloadTenderConfigurationOption];
    //[self setSelectedOptionForPaymentType];
    // Do any additional setup after loading the view from its nib.
}

-(void)reloadTenderConfigurationOption
{
    self.isCashDrawerOpen = NO;
    self.isCardSwipe = NO;
    self.isMultipleCardSwipe = NO;
    self.isPrintReceipt = NO;
    self.isPOSReceipt = NO;
    self.isCustDispReceipt = NO;
    self.isPromptPrintReceipt = NO;
    self.isDoNotPrintReceipt = NO;
    self.isiDynamoCardReaderSelected = NO;
    self.isAudioCardReaderSelected= NO;
    self.isTenderShortcut=NO;
    self.isTenderDisable = NO;
    self.isBridgePaySelected = NO;
    self.isServerSelected = NO;
    self.isPaxSignatureSelected = NO;
    self.isSignatureCaptureOnPaperSelected = NO;
    self.isSignatureApplicable = NO;

    self.isPaxApplicable = NO;
    self.isBroadPosApplicable = NO;

    
    [self setSelectedOptionForPaymentType];
}

-(void)setSelectedOptionForPaymentType
{
    for(int j=0; j < self.crmController.globalArrTenderConfig.count;j++)
    {
        NSString  *strIndexPath = [(self.crmController.globalArrTenderConfig)[j] valueForKey:@"indexpath"];
        
        NSString *strPayIDTemp1 = [NSString stringWithFormat:@"%@",strPayID];
        NSString *strPayIDTemp2 = [NSString stringWithFormat:@"%@",[(self.crmController.globalArrTenderConfig)[j] valueForKey:@"PayId"]];
        
        if([strPayIDTemp1 isEqualToString:strPayIDTemp2]){
            

            NSString *lastCharacter;
            if(strIndexPath.length == 3)
            {
                lastCharacter = [strIndexPath substringFromIndex:strIndexPath.length - 2];
            }
            else
            {
                lastCharacter = [strIndexPath substringFromIndex:strIndexPath.length - 1];
            }

            if ([lastCharacter isEqualToString:@"0"]) {
                self.isPrintReceipt = YES;
            }
//            else if ([lastCharacter isEqualToString:@"1"]) {
//                self.isPromptPrintReceipt = YES;
//            }
            else if ([lastCharacter isEqualToString:@"5"]) {
                self.isDoNotPrintReceipt = YES;
            }
            else if ([lastCharacter isEqualToString:@"6"]) {
                self.isPOSReceipt = YES;
            }
            else if ([lastCharacter isEqualToString:@"7"]) {
                self.isCustDispReceipt = YES;
            }
            else if ([lastCharacter isEqualToString:@"8"]) {
                self.isiDynamoCardReaderSelected = YES;
            }
            else if ([lastCharacter isEqualToString:@"9"]) {
                self.isAudioCardReaderSelected = YES;
            }
            else if ([lastCharacter isEqualToString:@"2"]) {
                self.isCashDrawerOpen = YES;
            }
            else if ([lastCharacter isEqualToString:@"3"]) {
                self.isCardSwipe = YES;
            }
            else if ([lastCharacter isEqualToString:@"4"]) {
                self.isMultipleCardSwipe = YES;
            }
            else if ([lastCharacter isEqualToString:@"10"]) {
                self.isTenderShortcut = YES;
            }
            else if ([lastCharacter isEqualToString:@"11"]) {
                self.isTenderDisable = YES;
            }
            else if ([lastCharacter isEqualToString:@"12"]) {
                self.isBridgePaySelected = YES;
            }
            else if ([lastCharacter isEqualToString:@"13"]) {
                self.isServerSelected = YES;
            }
            else if ([lastCharacter isEqualToString:@"14"]) {
                self.isPaxSignatureSelected = YES;
            }
            else if ([lastCharacter isEqualToString:@"15"]) {
                self.isSignatureCaptureOnPaperSelected = YES;
            }
            else if ([lastCharacter isEqualToString:@"16"] && ![cardIntType  isEqualToString:@"RapidRMS Gift Card"]) {
                self.isSignatureApplicable = YES;
            }
            else if ([lastCharacter isEqualToString:@"17"]) {
                self.isPaxApplicable = YES;
            }
           else if ([lastCharacter isEqualToString:@"18"]) {
                self.isBroadPosApplicable = YES;
            }
        }
    }
    [self.tenderConfigurationOptiontbl reloadData];
}

- (void)backButtonDidPressed:(id)aResponder {
      [self.rmsDbController playButtonSound];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = @"Tender Configuration";
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSUserDefaults standardUserDefaults] setObject:self.crmController.globalArrTenderConfig forKey:@"TendConfig"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

- (BOOL)allPaymentOptionDisable
{
    NSMutableArray *arrTemp = [[NSUserDefaults standardUserDefaults] valueForKey:@"TendConfig"];
    NSPredicate * filterTenderPrediacte = [NSPredicate predicateWithFormat:@"SpecOption == %@",@"11"];
    BOOL allPaymentOptionDisable = FALSE;
    
    NSArray  *filterTenderDisablearray = [arrTemp filteredArrayUsingPredicate:filterTenderPrediacte];
    if (filterTenderDisablearray.count > 0) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"TenderPay" inManagedObjectContext:self.managedObjectContext];
        fetchRequest.entity = entity;
        NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
        
        if (resultSet.count == filterTenderDisablearray.count)
        {
            allPaymentOptionDisable = TRUE;
            
        }
    }
    return allPaymentOptionDisable;
}

-(IBAction)btnCheckbox:(id)sender
{
    [self.rmsDbController playButtonSound];
    if([sender isKindOfClass:[UIButton class]])
    {
        UIButton *btnTemp = (UIButton *)sender;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[sender tag] inSection:[sender superview].tag];
        
        NSMutableDictionary *itemDetailDict = [[NSMutableDictionary alloc] init];
        
        if (btnTemp.selected)
        {
            NSString *lastCharacter = [[NSString stringWithFormat:@"%ld",(long)indexPath.row] substringFromIndex:[NSString stringWithFormat:@"%ld",(long)indexPath.row].length - 1];
            
            if ([lastCharacter isEqualToString:@"0"]) {
                // printImageView.image=nil;
                //self.lblPrintReciept.textColor=[UIColor blackColor];
            }
            else if ([lastCharacter isEqualToString:@"1"]) {
                // promptImageView.image=nil;
                // self.lblPromptPrint.textColor=[UIColor blackColor];
            }
            else if ([lastCharacter isEqualToString:@"5"]) {
                //doNotPrintImageView.image=nil;
                // self.lblDoNotPrint.textColor=[UIColor blackColor];
            }
            
            //[btnTemp setSelected:NO];
            
            for(int i=0;i < self.crmController.globalArrTenderConfig.count;i++)
            {
                if([[(self.crmController.globalArrTenderConfig)[i] valueForKey:@"indexpath"] intValue ] == indexPath.row )
                {
                    //[self.crmController.globalArrTenderConfig removeObjectAtIndex:i];
                }
            }
        }
        else
        {
            NSString *strTemp;
            NSString *strPayId;
            NSString *strTag = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
            if(strTag.length >= 2)
            {
                strTemp = [[NSString stringWithFormat:@"%ld",(long)indexPath.row] substringToIndex:1];
                strPayId = (self.arrpaymentType)[strTemp.intValue][@"PayId"];
            }
            else
            {
                strPayId = self.arrpaymentType.firstObject[@"PayId"];
            }
            
            NSString *lastChar;
            if(strTag.length == 3)
            {
                lastChar = [[NSString stringWithFormat:@"%ld",(long)indexPath.row] substringFromIndex:[NSString stringWithFormat:@"%ld",(long)indexPath.row].length - 2];
            }
            else
            {
                lastChar = [[NSString stringWithFormat:@"%ld",(long)indexPath.row] substringFromIndex:[NSString stringWithFormat:@"%ld",(long)indexPath.row].length - 1];
            }

            
            if(self.crmController.globalArrTenderConfig.count>0)
            {
                for(int i=0;i < self.crmController.globalArrTenderConfig.count;i++)
                {
                    if([[(self.crmController.globalArrTenderConfig)[i] valueForKey:@"PayId"]intValue] == strPayId.intValue)
                    {
                        int iopt = [[(self.crmController.globalArrTenderConfig)[i] valueForKey:@"SpecOption"]intValue];
                        if((iopt == 0)||(iopt == 1) || (iopt == 5))
                        {
                            if(([lastChar isEqualToString:@"0"]) ||
                               ([lastChar isEqualToString:@"5"])) //||([lastChar isEqualToString:@"1"])
                            {
                                [self.crmController.globalArrTenderConfig removeObjectAtIndex:i];
                            }
                        }
                        else if((iopt == 6)||(iopt == 7) || (iopt == 14) || (iopt == 15))
                        {
                            if([lastChar isEqualToString:@"6"] || [lastChar isEqualToString:@"7"] || [lastChar isEqualToString:@"14"] || [lastChar isEqualToString:@"15"])
                            {
                                [self.crmController.globalArrTenderConfig removeObjectAtIndex:i];
                                if(iopt == lastChar.integerValue)
                                {
                                    [self reloadTenderConfigurationOption];
                                    //lastChar = @"";
                                    return;
                                }
                            }
                        }
                        else if((iopt == 8)||(iopt == 9))
                        {
                            if([lastChar isEqualToString:@"8"] || [lastChar isEqualToString:@"9"])
                            {
                                [self.crmController.globalArrTenderConfig removeObjectAtIndex:i];
                            }
                        }
                        else if((iopt == 12)||(iopt == 13))
                        {
                            if([lastChar isEqualToString:@"12"] || [lastChar isEqualToString:@"13"])
                            {
                                [self.crmController.globalArrTenderConfig removeObjectAtIndex:i];
                            }
                        }
                        else if((iopt == 17)||(iopt == 18))
                        {
                            if([lastChar isEqualToString:@"17"] || [lastChar isEqualToString:@"18"])
                            {
                                [self.crmController.globalArrTenderConfig removeObjectAtIndex:i];
                            }
                        }

                    }
                }
            }
            
            itemDetailDict[@"SpecOption"] = lastChar;
            itemDetailDict[@"section"] = [NSString stringWithFormat:@"%ld",(long)indexPath.section];
            itemDetailDict[@"row"] = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
            itemDetailDict[@"indexpath"] = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
            itemDetailDict[@"PayId"] = strPayId;
            [self.crmController.globalArrTenderConfig insertObject:itemDetailDict atIndex:0];
        }
    }
    else if ([sender isKindOfClass:[UISwitch class]])
    {
        UISwitch *switchTemp = (UISwitch *)sender;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[sender tag] inSection:[sender superview].tag];

        NSMutableDictionary *itemDetailDict = [[NSMutableDictionary alloc] init];
        if (switchTemp.on == NO)
        {
            BOOL isPosCodFound = FALSE;
            BOOL isSignatureApplicableCodeFound =  FALSE;

//            NSString *lastCharacter = [[NSString stringWithFormat:@"%ld",(long)indexPath.row] substringFromIndex:[[NSString stringWithFormat:@"%ld",(long)indexPath.row] length] - 1];
            
            
            
            NSString *strTemp;
            NSString *strPayId;
            NSString *strTag = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
            if(strTag.length >= 2)
            {
                strTemp = [[NSString stringWithFormat:@"%ld",(long)indexPath.row] substringToIndex:1];
                strPayId = (self.arrpaymentType)[strTemp.intValue][@"PayId"];
            }
            else
            {
                strPayId = self.arrpaymentType.firstObject[@"PayId"];
            }
            NSString *lastChar;
            if(strTag.length == 3)
            {
                lastChar = [[NSString stringWithFormat:@"%ld",(long)indexPath.row] substringFromIndex:[NSString stringWithFormat:@"%ld",(long)indexPath.row].length - 2];
            }
            else
            {
                lastChar = [[NSString stringWithFormat:@"%ld",(long)indexPath.row] substringFromIndex:[NSString stringWithFormat:@"%ld",(long)indexPath.row].length - 1];
            }

            
            
            for(int i=0;i < self.crmController.globalArrTenderConfig.count;i++)
            {
                if([[(self.crmController.globalArrTenderConfig)[i] valueForKey:@"indexpath"] intValue ] == indexPath.row )
                {
                    [self.crmController.globalArrTenderConfig removeObjectAtIndex:i];
                    if ([lastChar isEqualToString:@"3"])
                    {
                        isPosCodFound = YES;
                    }
                   else if ([lastChar isEqualToString:@"16"])
                    {
                        isSignatureApplicableCodeFound = YES;
                        
                    }
                    else
                    {
                        isPosCodFound = NO;
                    }
                }
            }
            
            if(isPosCodFound)
            {
                NSString *strPayId = (self.arrpaymentType)[strIndex.intValue][@"PayId"];
                // Predicate -> PayId == 6 AND (SpecOption == "6" OR SpecOption == "7")
                NSPredicate *delPredicate = [NSPredicate predicateWithFormat:@"PayId = %@ AND ( SpecOption == %@ OR SpecOption == %@  OR SpecOption == %@ OR SpecOption == %@ OR SpecOption == %@ OR SpecOption == %@ OR SpecOption == %@)",strPayId,@"6",@"7",@"8",@"9",@"12",@"13",@"16",@"17",@"18"];
                // Reverse Predicate -> NOT (PayId == 6 AND (SpecOption == "6" OR SpecOption == "7"))
                NSPredicate *notFilter = [NSCompoundPredicate notPredicateWithSubpredicate:delPredicate];
                self.crmController.globalArrTenderConfig = [[self.crmController.globalArrTenderConfig filteredArrayUsingPredicate:notFilter] mutableCopy ];
            }
            
            else if (isSignatureApplicableCodeFound)
            {
                NSString *strPayId = (self.arrpaymentType)[strIndex.intValue][@"PayId"];
                NSPredicate *delPredicate = [NSPredicate predicateWithFormat:@"PayId = %@ AND ( SpecOption == %@ OR SpecOption == %@  OR SpecOption == %@)",strPayId,@"6",@"7",@"14",@"15"];
                NSPredicate *notFilter = [NSCompoundPredicate notPredicateWithSubpredicate:delPredicate];
                self.crmController.globalArrTenderConfig = [[self.crmController.globalArrTenderConfig filteredArrayUsingPredicate:notFilter] mutableCopy ];
            }
        }
        else
        {
            NSString *strTemp;
            NSString *strPayId;
            NSString *strTag = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
            if(strTag.length >= 2)
            {
                strTemp = [[NSString stringWithFormat:@"%ld",(long)indexPath.row] substringToIndex:1];
                strPayId = (self.arrpaymentType)[strTemp.intValue][@"PayId"];
            }
            else
            {
                strPayId = self.arrpaymentType.firstObject[@"PayId"];
            }
            NSString *lastChar;
            if(strTag.length == 3)
            {
                lastChar = [[NSString stringWithFormat:@"%ld",(long)indexPath.row] substringFromIndex:[NSString stringWithFormat:@"%ld",(long)indexPath.row].length - 2];
            }
            else
            {
                lastChar = [[NSString stringWithFormat:@"%ld",(long)indexPath.row] substringFromIndex:[NSString stringWithFormat:@"%ld",(long)indexPath.row].length - 1];
            }

       if([lastChar isEqualToString:@"16"])
           {
        if (self.isCardSwipe == FALSE) {
            switchTemp.on = NO;
            return;
        }
       }
            if(self.crmController.globalArrTenderConfig.count>0)
            {
                for(int i=0;i<self.crmController.globalArrTenderConfig.count;i++)
                {
                    if([[(self.crmController.globalArrTenderConfig)[i] valueForKey:@"PayId"]intValue]==strPayId.intValue)
                    {
                        int iopt = [[(self.crmController.globalArrTenderConfig)[i] valueForKey:@"SpecOption"]intValue];
                        if ((iopt == 0)||(iopt == 1)||(iopt == 5))
                        {
                            if(([lastChar isEqualToString:@"0"]) ||
                               ([lastChar isEqualToString:@"5"])) //||([lastChar isEqualToString:@"1"])
                            {
                                [self.crmController.globalArrTenderConfig removeObjectAtIndex:i];
                            }
                        }
                        else if ((iopt == 6)||(iopt == 7) || (iopt == 14))
                        {
                            if(([lastChar isEqualToString:@"6"]) || ([lastChar isEqualToString:@"7"]) || ([lastChar isEqualToString:@"4"]))
                            {
                                [self.crmController.globalArrTenderConfig removeObjectAtIndex:i];
                            }
                        }
                        else if ((iopt == 8)||(iopt == 9))
                        {
                            if(([lastChar isEqualToString:@"8"]) || ([lastChar isEqualToString:@"9"]))
                            {
                                [self.crmController.globalArrTenderConfig removeObjectAtIndex:i];
                            }
                        }
                        else if(iopt == 10)
                        {
                            if([lastChar isEqualToString:@"0"] )
                            {
                                [self.crmController.globalArrTenderConfig removeObjectAtIndex:i];
                            }
                        }
                        else if(iopt == 11)
                        {
                            if([lastChar isEqualToString:@"1"] )
                            {
                                [self.crmController.globalArrTenderConfig removeObjectAtIndex:i];
                            }
                        }
                        else if ((iopt == 12)||(iopt == 13))
                        {
                            if(([lastChar isEqualToString:@"2"]) || ([lastChar isEqualToString:@"3"]))
                            {
                                [self.crmController.globalArrTenderConfig removeObjectAtIndex:i];
                            }
                        }
                        else if ((iopt == 17)||(iopt == 18))
                        {
                            if(([lastChar isEqualToString:@"7"]) || ([lastChar isEqualToString:@"8"]))
                            {
                                [self.crmController.globalArrTenderConfig removeObjectAtIndex:i];
                            }
                        }

                    }
                }
            }

            itemDetailDict[@"SpecOption"] = lastChar;
            itemDetailDict[@"section"] = [NSString stringWithFormat:@"%ld",(long)indexPath.section];
            itemDetailDict[@"row"] = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
            itemDetailDict[@"indexpath"] = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
            itemDetailDict[@"PayId"] = strPayId;
            
            [self.crmController.globalArrTenderConfig insertObject:itemDetailDict atIndex:0];
            
            BOOL isPosCodFound=NO;
            NSString *lastCharacter = [[NSString stringWithFormat:@"%ld",(long)indexPath.row] substringFromIndex:[NSString stringWithFormat:@"%ld",(long)indexPath.row].length - 1];
            
            for(int i=0;i < self.crmController.globalArrTenderConfig.count;i++)
            {
                if([[(self.crmController.globalArrTenderConfig)[i] valueForKey:@"indexpath"] intValue ] == indexPath.row )
                {
                   // [self.crmController.globalArrTenderConfig removeObjectAtIndex:i];
                    if ([lastCharacter isEqualToString:@"3"])
                    {
                        isPosCodFound = YES;
                    }
                    else
                    {
                        isPosCodFound = NO;
                    }
                }
            }

            
            if(isPosCodFound)
            {

                //                {
                //                    PayId = 3;
                //                    SpecOption = 8;
                //                    indexpath = 38;
                //                    row = 38;
                //                    section = 0;
                //                }
                
                NSMutableDictionary *dictTemp = [[NSMutableDictionary alloc]init];
                
                NSString *strPayId = (self.arrpaymentType)[strIndex.intValue][@"PayId"];
                
                dictTemp[@"SpecOption"] = @"8";
                dictTemp[@"section"] = @"0";
                dictTemp[@"row"] = [NSString stringWithFormat:@"%@8",strPayId];
                dictTemp[@"indexpath"] = [NSString stringWithFormat:@"%@8",strPayId];
                dictTemp[@"PayId"] = strPayId;
                
                [self.crmController.globalArrTenderConfig insertObject:dictTemp atIndex:0];
                
//                NSMutableDictionary *dictBridgePayTemp = [[NSMutableDictionary alloc]init];
//
//                dictBridgePayTemp[@"SpecOption"] = @"12";
//                dictBridgePayTemp[@"section"] = @"0";
//                dictBridgePayTemp[@"row"] = [NSString stringWithFormat:@"%@12",strPayId];
//                dictBridgePayTemp[@"indexpath"] = [NSString stringWithFormat:@"%@12",strPayId];
//                dictBridgePayTemp[@"PayId"] = strPayId;
//                
//                [self.crmController.globalArrTenderConfig insertObject:dictBridgePayTemp atIndex:0];
            }
        }
    }
    [self reloadTenderConfigurationOption];
    // Below code will save setting at a time:
    [[NSUserDefaults standardUserDefaults] setObject:self.crmController.globalArrTenderConfig forKey:@"TendConfig"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    
    BOOL allPaymentOptionDisable;
    allPaymentOptionDisable = [self allPaymentOptionDisable];
    if (allPaymentOptionDisable)
    {
        UIAlertView * paymentDiableAlert = [[UIAlertView alloc]initWithTitle:@"Info" message:@"All payment options are disabled. Please enable at least one payment option." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [paymentDiableAlert show];
    }

}

#pragma UITableView Delegate Methods



- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 3)
    {
        if (self.isSignatureApplicable) {
        return @"Signature Capture Options";
        }
    }
    if(section == 3)
    {
        //return @"Select Card Reader Type";
        return @"";

    }
    return @"";
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if(section == 2)
    {
        return @"Multiple Card Swipe allows you to split payment into multiple credit cards.";
    }
    return @"";
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 3) {
        return 30;
    }
    return 10;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 2) {
        return 30;
    }
    return 10;
    
}



//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//   
//    return 35;
//    
//}
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    return 35;
//}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([cardIntType isEqualToString:@"Credit"] || [cardIntType isEqualToString:@"GiftCard"] || [cardIntType isEqualToString:@"Debit"] || [cardIntType  isEqualToString:@"EBT/Food Stamp"] || [cardIntType  isEqualToString:@"RapidRMS Gift Card"])
    {
        if (self.isCardSwipe && ![cardIntType  isEqualToString:@"RapidRMS Gift Card"])
        {
            return 6;
        }
         return 3;
    }
    
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
    {
        return 2;
    }
    if(section == 1)
    {
        return 3;
    }
    if(section == 2)
    {
        return 3;
    }
    if(section == 3)
    {
        if (self.isSignatureApplicable) {
            return 4;
        }
        return 0;
    }
    if(section == 4)
    {
        if (selectedPaymentGateWay == Pax) {
            return 0;
        }
        return 2;
    }
    if(section == 5)
    {
        return 2;
    }

    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCell *)tenderReceiptCell:(NSIndexPath *)indexPath
{
    TenderConfigReceiptCell *receiptCell = [self.tenderConfigurationOptiontbl dequeueReusableCellWithIdentifier:@"TenderConfigReceiptCell" forIndexPath:indexPath];
    
    if(indexPath.section == 0)
    {
        if(indexPath.row == 0)
        {
            receiptCell.receiptName.text = @"Print Receipt";
            
            NSString *strPrintIndexTemp = [NSString stringWithFormat:@"%@0",strIndex];
            receiptCell.buttonClicked.tag = strPrintIndexTemp.integerValue;
            receiptCell.accessoryView = receiptCell.buttonClicked;
            [receiptCell.buttonClicked addTarget: self action: @selector(btnCheckbox:) forControlEvents:UIControlEventTouchUpInside];
            
            receiptCell.rightTickImage.tag = strPrintIndexTemp.integerValue;
            if(self.isPrintReceipt)
            {
                receiptCell.rightTickImage.image = [UIImage imageNamed:@"soundCheckMark.png"];
            }
            else
            {
                receiptCell.rightTickImage.image = nil;
            }
        }
//        if(indexPath.row == 1)
//        {
//            receiptCell.receiptName.text = @"Prompt Print Receipt";
//            
//            NSString *strPromptIndexTemp = [NSString stringWithFormat:@"%@1",strIndex];
//            receiptCell.buttonClicked.tag = [strPromptIndexTemp integerValue];
//            receiptCell.accessoryView = receiptCell.buttonClicked;
//            [receiptCell.buttonClicked addTarget: self action: @selector(btnCheckbox:) forControlEvents:UIControlEventTouchUpInside];
//            
//            receiptCell.rightTickImage.tag = [strPromptIndexTemp integerValue];
//            if(self.isPromptPrintReceipt)
//            {
//                receiptCell.rightTickImage.image = [UIImage imageNamed:@"soundCheckMark.png"];
//            }
//            else
//            {
//                receiptCell.rightTickImage.image = nil;
//            }
//        }
        if(indexPath.row == 1)
        {
            receiptCell.receiptName.text = @"Do not Print Receipt";
            
            NSString *strDoNotPrintIndexTemp = [NSString stringWithFormat:@"%@5",strIndex];
            receiptCell.buttonClicked.tag = strDoNotPrintIndexTemp.integerValue;
            receiptCell.accessoryView = receiptCell.buttonClicked;
            [receiptCell.buttonClicked addTarget: self action: @selector(btnCheckbox:) forControlEvents:UIControlEventTouchUpInside];
            
            receiptCell.rightTickImage.tag = strDoNotPrintIndexTemp.integerValue;
            if(self.isDoNotPrintReceipt)
            {
                receiptCell.rightTickImage.image = [UIImage imageNamed:@"soundCheckMark.png"];
            }
            else
            {
                receiptCell.rightTickImage.image = nil;
            }
        }
    }
    if(indexPath.section == 3)
    {
        if(indexPath.row == 0)
        {
            receiptCell.receiptName.text = @"RCR Signature Capture";
            NSString *strDoNotPrintIndexTemp = [NSString stringWithFormat:@"%@6",strIndex];
            receiptCell.buttonClicked.tag = strDoNotPrintIndexTemp.integerValue;
            receiptCell.accessoryView = receiptCell.buttonClicked;
            [receiptCell.buttonClicked addTarget: self action: @selector(btnCheckbox:) forControlEvents:UIControlEventTouchUpInside];
            
            receiptCell.rightTickImage.tag = strDoNotPrintIndexTemp.integerValue;
            if(self.isPOSReceipt)
            {
                receiptCell.rightTickImage.image = [UIImage imageNamed:@"soundCheckMark.png"];
            }
            else
            {
                receiptCell.rightTickImage.image = nil;
            }
        }
        if(indexPath.row == 1)
        {
            receiptCell.receiptName.text = @"RCD Signature Capture";
            NSString *strDoNotPrintIndexTemp = [NSString stringWithFormat:@"%@7",strIndex];
            receiptCell.buttonClicked.tag = strDoNotPrintIndexTemp.integerValue;
            receiptCell.accessoryView = receiptCell.buttonClicked;
            [receiptCell.buttonClicked addTarget: self action: @selector(btnCheckbox:) forControlEvents:UIControlEventTouchUpInside];
            
            receiptCell.rightTickImage.tag = strDoNotPrintIndexTemp.integerValue;
            if(self.isCustDispReceipt)
            {
                receiptCell.rightTickImage.image = [UIImage imageNamed:@"soundCheckMark.png"];
            }
            else
            {
                receiptCell.rightTickImage.image = nil;
            }
        }
        
        if(indexPath.row == 2)
        {
            receiptCell.receiptName.text = @"Signature Capture On Paper";
            NSString *strDoNotPrintIndexTemp = [NSString stringWithFormat:@"%@15",strIndex];
            receiptCell.buttonClicked.tag = strDoNotPrintIndexTemp.integerValue;
            receiptCell.accessoryView = receiptCell.buttonClicked;
            [receiptCell.buttonClicked addTarget: self action: @selector(btnCheckbox:) forControlEvents:UIControlEventTouchUpInside];
            
            receiptCell.rightTickImage.tag = strDoNotPrintIndexTemp.integerValue;
            if(self.isSignatureCaptureOnPaperSelected)
            {
                receiptCell.rightTickImage.image = [UIImage imageNamed:@"soundCheckMark.png"];
            }
            else
            {
                receiptCell.rightTickImage.image = nil;
            }
        }
        if(indexPath.row == 3)
        {
            receiptCell.receiptName.text = @"Pax Signature Capture";
            NSString *strDoNotPrintIndexTemp = [NSString stringWithFormat:@"%@14",strIndex];
            receiptCell.buttonClicked.tag = strDoNotPrintIndexTemp.integerValue;
            receiptCell.accessoryView = receiptCell.buttonClicked;
            [receiptCell.buttonClicked addTarget: self action: @selector(btnCheckbox:) forControlEvents:UIControlEventTouchUpInside];
            
            receiptCell.rightTickImage.tag = strDoNotPrintIndexTemp.integerValue;
            if(self.isPaxSignatureSelected)
            {
                receiptCell.rightTickImage.image = [UIImage imageNamed:@"soundCheckMark.png"];
            }
            else
            {
                receiptCell.rightTickImage.image = nil;
            }
        }

    }
    if(indexPath.section == 4)
    {
        if(indexPath.row == 0)
        {
            receiptCell.receiptName.text = @"iDynamo Card Reader";
            NSString *strDoNotPrintIndexTemp = [NSString stringWithFormat:@"%@8",strIndex];
            receiptCell.buttonClicked.tag = strDoNotPrintIndexTemp.integerValue;
            receiptCell.accessoryView = receiptCell.buttonClicked;
            [receiptCell.buttonClicked addTarget: self action: @selector(btnCheckbox:) forControlEvents:UIControlEventTouchUpInside];
            
            receiptCell.rightTickImage.tag = strDoNotPrintIndexTemp.integerValue;
            if(self.isiDynamoCardReaderSelected)
            {
                receiptCell.rightTickImage.image = [UIImage imageNamed:@"soundCheckMark.png"];
            }
            else
            {
                receiptCell.rightTickImage.image = nil;
            }
        }
        if(indexPath.row == 1)
        {
            receiptCell.receiptName.text = @"Audio Card Reader";
            NSString *strDoNotPrintIndexTemp = [NSString stringWithFormat:@"%@9",strIndex];
            receiptCell.buttonClicked.tag = strDoNotPrintIndexTemp.integerValue;
            receiptCell.accessoryView = receiptCell.buttonClicked;
            [receiptCell.buttonClicked addTarget: self action: @selector(btnCheckbox:) forControlEvents:UIControlEventTouchUpInside];
            
            receiptCell.rightTickImage.tag = strDoNotPrintIndexTemp.integerValue;
            if(self.isAudioCardReaderSelected)
            {
                receiptCell.rightTickImage.image = [UIImage imageNamed:@"soundCheckMark.png"];
            }
            else
            {
                receiptCell.rightTickImage.image = nil;
            }
        }
    }
    if(indexPath.section == 5)
    {
        
        if (selectedPaymentGateWay == Pax) {
            
            if(indexPath.row == 0)
            {
                receiptCell.receiptName.text = @"Pax";
                NSString *strBridgePayIndexTemp = [NSString stringWithFormat:@"%@17",strIndex];
                receiptCell.buttonClicked.tag = strBridgePayIndexTemp.integerValue;
                receiptCell.accessoryView = receiptCell.buttonClicked;
                [receiptCell.buttonClicked addTarget: self action: @selector(btnCheckbox:) forControlEvents:UIControlEventTouchUpInside];
                
                receiptCell.rightTickImage.tag = strBridgePayIndexTemp.integerValue;
                if(self.isPaxApplicable)
                {
                    receiptCell.rightTickImage.image = [UIImage imageNamed:@"soundCheckMark.png"];
                }
                else
                {
                    receiptCell.rightTickImage.image = nil;
                }
            }
            if(indexPath.row == 1)
            {
                receiptCell.receiptName.text = @"Broad POS";
                NSString *strServerIndexTemp = [NSString stringWithFormat:@"%@18",strIndex];
                receiptCell.buttonClicked.tag = strServerIndexTemp.integerValue;
                receiptCell.accessoryView = receiptCell.buttonClicked;
                [receiptCell.buttonClicked addTarget: self action: @selector(btnCheckbox:) forControlEvents:UIControlEventTouchUpInside];
                
                receiptCell.rightTickImage.tag = strServerIndexTemp.integerValue;
                if(self.isBroadPosApplicable)
                {
                    receiptCell.rightTickImage.image = [UIImage imageNamed:@"soundCheckMark.png"];
                }
                else
                {
                    receiptCell.rightTickImage.image = nil;
                }
            }
            
        }

        else
        {
            if(indexPath.row == 0)
            {
                receiptCell.receiptName.text = @"Bridge Pay";
                NSString *strBridgePayIndexTemp = [NSString stringWithFormat:@"%@12",strIndex];
                receiptCell.buttonClicked.tag = strBridgePayIndexTemp.integerValue;
                receiptCell.accessoryView = receiptCell.buttonClicked;
                [receiptCell.buttonClicked addTarget: self action: @selector(btnCheckbox:) forControlEvents:UIControlEventTouchUpInside];
                
                receiptCell.rightTickImage.tag = strBridgePayIndexTemp.integerValue;
                if(self.isBridgePaySelected)
                {
                    receiptCell.rightTickImage.image = [UIImage imageNamed:@"soundCheckMark.png"];
                }
                else
                {
                    receiptCell.rightTickImage.image = nil;
                }
            }
            if(indexPath.row == 1)
            {
                receiptCell.receiptName.text = @"Rapid Server";
                NSString *strServerIndexTemp = [NSString stringWithFormat:@"%@13",strIndex];
                receiptCell.buttonClicked.tag = strServerIndexTemp.integerValue;
                receiptCell.accessoryView = receiptCell.buttonClicked;
                [receiptCell.buttonClicked addTarget: self action: @selector(btnCheckbox:) forControlEvents:UIControlEventTouchUpInside];
                
                receiptCell.rightTickImage.tag = strServerIndexTemp.integerValue;
                if(self.isServerSelected)
                {
                    receiptCell.rightTickImage.image = [UIImage imageNamed:@"soundCheckMark.png"];
                }
                else
                {
                    receiptCell.rightTickImage.image = nil;
                }
            }
        }

    }

    return receiptCell;
}

- (UITableViewCell *)tenderSwitchCell:(NSIndexPath *)indexPath
{
    TenderConfigSwitchCell *switchCell = [self.tenderConfigurationOptiontbl dequeueReusableCellWithIdentifier:@"TenderConfigSwitchCell" forIndexPath:indexPath];
    
    if(indexPath.section == 1)
    {
        if(indexPath.row == 0)
        {
            switchCell.optionName.text = @"Open Cash Drawer";
            if(self.isCashDrawerOpen)
            {
                [switchCell.onOffSwitch setOn:YES animated:YES];
            }
            else
            {
                [switchCell.onOffSwitch setOn:NO animated:YES];
            }
            
            NSString *strcashDrawerIndexTemp = [NSString stringWithFormat:@"%@2",strIndex];
            switchCell.onOffSwitch.tag = strcashDrawerIndexTemp.integerValue;
            
            switchCell.accessoryView = switchCell.onOffSwitch;
            [switchCell.onOffSwitch addTarget: self action: @selector(btnCheckbox:) forControlEvents:UIControlEventValueChanged];
        }


        if(indexPath.row == 1)
        {
            switchCell.optionName.text = @"Tender Shortcut";
            if(self.isTenderShortcut)
            {
                [switchCell.onOffSwitch setOn:YES animated:YES];
            }
            else
            {
                [switchCell.onOffSwitch setOn:NO animated:YES];
            }

            NSString *strTenderShortcutIndexTemp = [NSString stringWithFormat:@"%@10",strIndex];
            switchCell.onOffSwitch.tag = strTenderShortcutIndexTemp.integerValue;

            switchCell.accessoryView = switchCell.onOffSwitch;
            [switchCell.onOffSwitch addTarget: self action: @selector(btnCheckbox:) forControlEvents:UIControlEventValueChanged];
        }
        
        if(indexPath.row == 2)
        {
            switchCell.optionName.text = @"Tender Disable";
            if(self.isTenderDisable)
            {
                [switchCell.onOffSwitch setOn:YES animated:YES];
            }
            else
            {
                [switchCell.onOffSwitch setOn:NO animated:YES];
            }
            
            NSString *strTenderShortcutIndexTemp = [NSString stringWithFormat:@"%@11",strIndex];
            switchCell.onOffSwitch.tag = strTenderShortcutIndexTemp.integerValue;
            
            switchCell.accessoryView = switchCell.onOffSwitch;
            [switchCell.onOffSwitch addTarget: self action: @selector(btnCheckbox:) forControlEvents:UIControlEventValueChanged];
        }

    }
    if(indexPath.section == 2)
    {
        if(indexPath.row == 0)
        {
            switchCell.optionName.text = @"Card Swipe";
            if(self.isCardSwipe)
            {
                [switchCell.onOffSwitch setOn:YES animated:YES];
            }
            else
            {
                [switchCell.onOffSwitch setOn:NO animated:YES];
            }
            
            NSString *strcardSwipeIndexTemp = [NSString stringWithFormat:@"%@3",strIndex];
            switchCell.onOffSwitch.tag=strcardSwipeIndexTemp.integerValue;
            
            switchCell.accessoryView = switchCell.onOffSwitch;
            [switchCell.onOffSwitch addTarget: self action: @selector(btnCheckbox:) forControlEvents:UIControlEventValueChanged];
        }
        if(indexPath.row == 1)
        {
            switchCell.optionName.text = @"Multiple Card Swipe";
            if(self.isMultipleCardSwipe)
            {
                [switchCell.onOffSwitch setOn:YES animated:YES];
            }
            else
            {
                [switchCell.onOffSwitch setOn:NO animated:YES];
            }
            
            NSString *strmultiCardIndexTemp = [NSString stringWithFormat:@"%@4",strIndex];
            switchCell.onOffSwitch.tag=strmultiCardIndexTemp.integerValue;
            
            switchCell.accessoryView = switchCell.onOffSwitch;
            [switchCell.onOffSwitch addTarget: self action: @selector(btnCheckbox:) forControlEvents:UIControlEventValueChanged];
        }
        if(indexPath.row == 2)
        {
            switchCell.optionName.text = @"Signature Applicable";

            if ([cardIntType  isEqualToString:@"RapidRMS Gift Card"]) {
                switchCell.onOffSwitch.enabled = NO;
            }
            else
            {
                switchCell.onOffSwitch.enabled = YES;

                if(self.isSignatureApplicable)
                {
                    [switchCell.onOffSwitch setOn:YES animated:YES];
                }
                else
                {
                    [switchCell.onOffSwitch setOn:NO animated:YES];
                }
            }
            
            
            NSString *strmultiCardIndexTemp = [NSString stringWithFormat:@"%@16",strIndex];
            switchCell.onOffSwitch.tag=strmultiCardIndexTemp.integerValue;
            
            switchCell.accessoryView = switchCell.onOffSwitch;
            [switchCell.onOffSwitch addTarget: self action: @selector(btnCheckbox:) forControlEvents:UIControlEventValueChanged];
        }
    }
    return switchCell;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = nil;
    cell.backgroundColor = [UIColor clearColor];
    if(indexPath.section == 0)
    {
        cell = [self tenderReceiptCell:indexPath];
    }
    if(indexPath.section == 1)
    {
        cell = [self tenderSwitchCell:indexPath];
    }
    if(indexPath.section == 2)
    {
        cell = [self tenderSwitchCell:indexPath];
    }
    if(indexPath.section == 3)
    {
        if (self.isCardSwipe)
        {
            cell = [self tenderReceiptCell:indexPath];
        }
    }
    if(indexPath.section == 4)
    {
        if (self.isCardSwipe)
        {
            cell = [self tenderReceiptCell:indexPath];
        }
    }
    if(indexPath.section == 5)
    {
        if (self.isCardSwipe)
        {
            cell = [self tenderReceiptCell:indexPath];
        }
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
