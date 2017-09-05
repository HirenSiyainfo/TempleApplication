//
//  TenderConfigurationSubViewController.m
//  RapidRMS
//
//  Created by Siya on 28/05/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "TenderConfigurationSubViewController.h"
#import "RmsDbController.h"
#import "TenderPay+Dictionary.h"
#import "RcrController.h"

@interface TenderConfigurationSubViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *printImageView;
@property (nonatomic, weak) IBOutlet UIImageView *promptImageView;
@property (nonatomic, weak) IBOutlet UIImageView *doNotPrintImageView;

@property (nonatomic, weak) IBOutlet UILabel *lblPromptPrint;
@property (nonatomic, weak) IBOutlet UILabel *lblCashDrawer;
@property (nonatomic, weak) IBOutlet UILabel *lblCardswipe;
@property (nonatomic, weak) IBOutlet UILabel *lblDoNotPrint;
@property (nonatomic, weak) IBOutlet UILabel *lblPrintReciept;

@property (nonatomic, weak) IBOutlet UIButton *btnPromptPrintReceipt;
@property (nonatomic, weak) IBOutlet UIButton *btnDoNotPrintReceipt;
@property (nonatomic, weak) IBOutlet UIButton *btnPrintReceipt;

@property (nonatomic, weak) IBOutlet UISwitch *cashDrawer;
@property (nonatomic, weak) IBOutlet UISwitch *cardSwipe;
@property (nonatomic, weak) IBOutlet UISwitch *multiCardSwipe;

@property (nonatomic, strong) RcrController *crmController;
@property (nonatomic, strong) RmsDbController *rmsDbController;

@property (nonatomic, strong) NSString *strIndex;
@property (nonatomic, strong) NSString *strPayID;

@property (nonatomic, strong) NSMutableArray *arrpaymentType;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;


@end

@implementation TenderConfigurationSubViewController
@synthesize strIndex,strPayID,btnPrintReceipt,btnPromptPrintReceipt,btnDoNotPrintReceipt,cashDrawer,cardSwipe,multiCardSwipe,printImageView,promptImageView,doNotPrintImageView;

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

    self.navigationItem.backBarButtonItem.target = self;
    self.navigationItem.backBarButtonItem.action = @selector(backButtonDidPressed:);
    
    UIImage* image3 = [UIImage imageNamed:@"RmsheaderLogo.png"];
    CGRect frameimg = CGRectMake(0, 0, image3.size.width, image3.size.height);
    UIButton *someButton = [[UIButton alloc] initWithFrame:frameimg];
    [someButton setBackgroundImage:image3 forState:UIControlStateNormal];
    
    UIBarButtonItem *mailbutton =[[UIBarButtonItem alloc] initWithCustomView:someButton];
    self.navigationItem.rightBarButtonItem=mailbutton;
    
/*
    NSString *navTitle = [NSString stringWithFormat:@"%@",[[self.arrpaymentType objectAtIndex:[strIndex integerValue]] objectForKey:@"CardIntType"]];
    self.navigationItem.backBarButtonItem =[[UIBarButtonItem alloc] initWithTitle:navTitle style:UIBarButtonItemStyleBordered     target:nil action:nil];*/

//    self.navigationItem.title=@"Previous";
    
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.crmController = [RcrController sharedCrmController];

    self.managedObjectContext = self.rmsDbController.managedObjectContext;

    self.managedObjectContext = self.rmsDbController.managedObjectContext;

    NSString *strPrintIndexTemp = [NSString stringWithFormat:@"%@0",strIndex];
    btnPrintReceipt.tag = strPrintIndexTemp.integerValue;

    NSString *strPromptIndexTemp = [NSString stringWithFormat:@"%@1",strIndex];
    btnPromptPrintReceipt.tag =strPromptIndexTemp.integerValue;

    NSString *strDoNotPrintIndexTemp = [NSString stringWithFormat:@"%@5",strIndex];
    btnDoNotPrintReceipt.tag = strDoNotPrintIndexTemp.integerValue;
    doNotPrintImageView.tag = btnDoNotPrintReceipt.tag;
    printImageView.tag = btnPrintReceipt.tag;
    promptImageView.tag = btnPromptPrintReceipt.tag;
//    doNotPrintImageView.tag = btnDoNotPrintReceipt.tag;

    NSString *strcashDrawerIndexTemp = [NSString stringWithFormat:@"%@2",strIndex];
    cashDrawer.tag=strcashDrawerIndexTemp.integerValue;

    NSString *strcardSwipeIndexTemp = [NSString stringWithFormat:@"%@3",strIndex];
    cardSwipe.tag=strcardSwipeIndexTemp.integerValue;

    NSString *strmultiCardIndexTemp = [NSString stringWithFormat:@"%@4",strIndex];
    multiCardSwipe.tag=strmultiCardIndexTemp.integerValue;

    for(int j=0;j<self.crmController.globalArrTenderConfig.count;j++)
    {

        NSString  *strIndexPath = [(self.crmController.globalArrTenderConfig)[j] valueForKey:@"indexpath"];

        NSString *strPayIDTemp1 = [NSString stringWithFormat:@"%@",strPayID];
        NSString *strPayIDTemp2 = [NSString stringWithFormat:@"%@",[(self.crmController.globalArrTenderConfig)[j] valueForKey:@"PayId"]];

        if([strPayIDTemp1 isEqualToString:strPayIDTemp2]){

            NSString *lastCharacter = [strIndexPath substringFromIndex:strIndexPath.length - 1];

            if ([lastCharacter isEqualToString:@"0"]) {
                printImageView.image = [UIImage imageNamed:@"soundCheckMark.png"];
                self.lblPrintReciept.textColor = [UIColor colorWithRed:39.0/255.0 green:130.0/255.0 blue:177.0/255 alpha:1.0];
                [self.btnPrintReceipt setSelected:YES];
                self.btnPrintReceipt.tag=strIndexPath.intValue;
            }
            else if ([lastCharacter isEqualToString:@"1"]) {
                promptImageView.image = [UIImage imageNamed:@"soundCheckMark.png"];
                self.lblPromptPrint.textColor = [UIColor colorWithRed:39.0/255.0 green:130.0/255.0 blue:177.0/255 alpha:1.0];
                [self.btnPromptPrintReceipt setSelected:YES];
                self.btnPromptPrintReceipt.tag = strIndexPath.intValue;
            }
            else if ([lastCharacter isEqualToString:@"5"]) {
                doNotPrintImageView.image=[UIImage imageNamed:@"soundCheckMark.png"];
                self.lblDoNotPrint.textColor=[UIColor colorWithRed:39.0/255.0 green:130.0/255.0 blue:177.0/255 alpha:1.0];
                [self.btnDoNotPrintReceipt setSelected:YES];
            }
            else if ([lastCharacter isEqualToString:@"2"]) {
                cashDrawer.on=YES;
                cashDrawer.tag=strIndexPath.intValue;
            }
            else if ([lastCharacter isEqualToString:@"3"]) {
                cardSwipe.on=YES;
                 cardSwipe.tag=strIndexPath.intValue;
            }
            else if ([lastCharacter isEqualToString:@"4"]) {
                multiCardSwipe.on=YES;
                 multiCardSwipe.tag=strIndexPath.intValue;
            }

        }
    }


    // Do any additional setup after loading the view from its nib.
}
- (void)backButtonDidPressed:(id)aResponder {
      [self.rmsDbController playButtonSound];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title=@"Tender Configuration";
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSUserDefaults standardUserDefaults] setObject:self.crmController.globalArrTenderConfig forKey:@"TendConfig"];
    [[NSUserDefaults standardUserDefaults]synchronize];
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
            
            for(int i=0;i<self.crmController.globalArrTenderConfig.count;i++)
            {
                if([[(self.crmController.globalArrTenderConfig)[i] valueForKey:@"indexpath"] intValue ] == indexPath.row )
                {
                    //[self.crmController.globalArrTenderConfig removeObjectAtIndex:i];
                }
            }
        }
        else
        {

            NSString *lastCharacter = [[NSString stringWithFormat:@"%ld",(long)indexPath.row] substringFromIndex:[NSString stringWithFormat:@"%ld",(long)indexPath.row].length - 1];

            if ([lastCharacter isEqualToString:@"0"]) {
                printImageView.image=[UIImage imageNamed:@"soundCheckMark.png"];
                self.lblPrintReciept.textColor=[UIColor colorWithRed:0.0/255.0 green:115.0/255.0 blue:170.0/255 alpha:1.0];
            }
            else if ([lastCharacter isEqualToString:@"1"]) {
                promptImageView.image=[UIImage imageNamed:@"soundCheckMark.png"];
                self.lblPromptPrint.textColor=[UIColor colorWithRed:0.0/255.0 green:115.0/255.0 blue:170.0/255 alpha:1.0];
            }
            else if ([lastCharacter isEqualToString:@"5"]) {
                doNotPrintImageView.image=[UIImage imageNamed:@"soundCheckMark.png"];
                self.lblDoNotPrint.textColor=[UIColor colorWithRed:0.0/255.0 green:115.0/255.0 blue:170.0/255 alpha:1.0];
            }



            [btnTemp setSelected:YES];

            NSString *strTemp;
            NSString *strPayId;
            NSString *strTag = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
            if(strTag.length == 2)
            {
                strTemp = [[NSString stringWithFormat:@"%ld",(long)indexPath.row] substringToIndex:1];
                strPayId = (self.arrpaymentType)[strTemp.intValue][@"PayId"];
            }
            else
            {
                strPayId = self.arrpaymentType.firstObject[@"PayId"];
            }

            NSString *lastChar = [[NSString stringWithFormat:@"%ld",(long)indexPath.row] substringFromIndex:[NSString stringWithFormat:@"%ld",(long)indexPath.row].length - 1];

            if(self.crmController.globalArrTenderConfig.count>0)
            {

                for(int i=0;i<self.crmController.globalArrTenderConfig.count;i++)
                {
                    if([[(self.crmController.globalArrTenderConfig)[i] valueForKey:@"PayId"]intValue]==strPayId.intValue)
                    {
                        int iopt=[[(self.crmController.globalArrTenderConfig)[i] valueForKey:@"SpecOption"]intValue];
                        if((iopt==0)||(iopt==1) || (iopt == 5))
                        {
                            if(([lastChar isEqualToString:@"0"])||([lastChar isEqualToString:@"1"]) || ([lastChar isEqualToString:@"5"]))
                            {
                                [self.crmController.globalArrTenderConfig removeObjectAtIndex:i];

                                if (iopt==0) {
                                    printImageView.image=nil;
                                    self.lblPrintReciept.textColor=[UIColor blackColor];
                                    [btnPrintReceipt setSelected:NO];
                                }
                                else if (iopt==1) {
                                    promptImageView.image=nil;
                                    self.lblPromptPrint.textColor=[UIColor blackColor];
                                    [btnPromptPrintReceipt setSelected:NO];

                                }
                                else if (iopt==5) {
                                    doNotPrintImageView.image=nil;
                                    self.lblDoNotPrint.textColor=[UIColor blackColor];
                                    [btnDoNotPrintReceipt setSelected:NO];
                                }

                                //                            [self.tblTenderConf reloadData];
                            }
                        }
                    }
                }
            }

            if([lastChar isEqualToString:@"0"])
            {
                itemDetailDict[@"SpecOption"] = @"0";
            }
            else if([lastChar isEqualToString:@"1"])
            {
                itemDetailDict[@"SpecOption"] = @"1";
            }
            else if([lastChar isEqualToString:@"2"])
            {
                itemDetailDict[@"SpecOption"] = @"2";
            }
            else if([lastChar isEqualToString:@"3"])
            {
                itemDetailDict[@"SpecOption"] = @"3";
            }
            else if([lastChar isEqualToString:@"4"])
            {
                itemDetailDict[@"SpecOption"] = @"4";
            }
            else if([lastChar isEqualToString:@"5"])
            {
                itemDetailDict[@"SpecOption"] = @"5";
            }

            itemDetailDict[@"section"] = [NSString stringWithFormat:@"%ld",(long)indexPath.section];
            itemDetailDict[@"row"] = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
            itemDetailDict[@"indexpath"] = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
            itemDetailDict[@"PayId"] = strPayId;
            [self.crmController.globalArrTenderConfig insertObject:itemDetailDict atIndex:0];
        }

    }
    else if ([sender isKindOfClass:[UISwitch class]]){


        UISwitch *switchTemp = (UISwitch *)sender;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[sender tag] inSection:[sender superview].tag];

        NSMutableDictionary *itemDetailDict = [[NSMutableDictionary alloc] init];

        if (switchTemp.on==NO)
        {
            NSString *lastCharacter = [[NSString stringWithFormat:@"%ld",(long)indexPath.row] substringFromIndex:[NSString stringWithFormat:@"%ld",(long)indexPath.row].length - 1];

            if ([lastCharacter isEqualToString:@"2"]) {
                switchTemp.on=NO;
            }
            else if ([lastCharacter isEqualToString:@"3"]) {
                 switchTemp.on=NO;
            }
            else if ([lastCharacter isEqualToString:@"4"]) {
                 switchTemp.on=NO;
            }

            for(int i=0;i<self.crmController.globalArrTenderConfig.count;i++)
            {
                if([[(self.crmController.globalArrTenderConfig)[i] valueForKey:@"indexpath"] intValue ] == indexPath.row )
                {
                    [self.crmController.globalArrTenderConfig removeObjectAtIndex:i];
                }
            }
        }
        else
        {

            NSString *lastCharacter = [[NSString stringWithFormat:@"%ld",(long)indexPath.row] substringFromIndex:[NSString stringWithFormat:@"%ld",(long)indexPath.row].length - 1];

            if ([lastCharacter isEqualToString:@"2"]) {
                switchTemp.on=YES;
            }
            else if ([lastCharacter isEqualToString:@"3"]) {
                switchTemp.on=YES;
            }
            else if ([lastCharacter isEqualToString:@"4"]) {
                switchTemp.on=YES;
            }
            //[btnTemp setSelected:YES];

            NSString *strTemp;
            NSString *strPayId;
            NSString *strTag = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
            if(strTag.length == 2)
            {
                strTemp = [[NSString stringWithFormat:@"%ld",(long)indexPath.row] substringToIndex:1];
                strPayId = (self.arrpaymentType)[strTemp.intValue][@"PayId"];
            }
            else
            {
                strPayId = self.arrpaymentType.firstObject[@"PayId"];
            }

            NSString *lastChar = [[NSString stringWithFormat:@"%ld",(long)indexPath.row] substringFromIndex:[NSString stringWithFormat:@"%ld",(long)indexPath.row].length - 1];

            if(self.crmController.globalArrTenderConfig.count>0)
            {

                for(int i=0;i<self.crmController.globalArrTenderConfig.count;i++)
                {
                    if([[(self.crmController.globalArrTenderConfig)[i] valueForKey:@"PayId"]intValue]==strPayId.intValue)
                    {
                        int iopt=[[(self.crmController.globalArrTenderConfig)[i] valueForKey:@"SpecOption"]intValue];
                        if((iopt==0)||(iopt==1)||(iopt==5))
                        {
                            if(([lastChar isEqualToString:@"0"])||([lastChar isEqualToString:@"1"]) || ([lastChar isEqualToString:@"5"]))
                            {
                                [self.crmController.globalArrTenderConfig removeObjectAtIndex:i];

                                if (iopt==0) {
                                    printImageView.image=nil;
                                    self.lblPrintReciept.textColor=[UIColor blackColor];
                                }
                                else if (iopt==1) {
                                    promptImageView.image=nil;
                                    self.lblPromptPrint.textColor=[UIColor blackColor];
                                }
                                else if (iopt==5) {
                                    doNotPrintImageView.image=nil;
                                    self.lblDoNotPrint.textColor=[UIColor blackColor];
                                }

                                //                            [self.tblTenderConf reloadData];
                            }
                        }
                    }
                }
            }

            if([lastChar isEqualToString:@"0"])
            {
                itemDetailDict[@"SpecOption"] = @"0";
            }
            else if([lastChar isEqualToString:@"1"])
            {
                itemDetailDict[@"SpecOption"] = @"1";
            }
            else if([lastChar isEqualToString:@"2"])
            {
                itemDetailDict[@"SpecOption"] = @"2";
            }
            else if([lastChar isEqualToString:@"3"])
            {
                itemDetailDict[@"SpecOption"] = @"3";
            }
            else if([lastChar isEqualToString:@"4"])
            {
                itemDetailDict[@"SpecOption"] = @"4";
            }
            else if([lastChar isEqualToString:@"5"])
            {
                itemDetailDict[@"SpecOption"] = @"5";
            }

            itemDetailDict[@"section"] = [NSString stringWithFormat:@"%ld",(long)indexPath.section];
            itemDetailDict[@"row"] = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
            itemDetailDict[@"indexpath"] = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
            itemDetailDict[@"PayId"] = strPayId;
            [self.crmController.globalArrTenderConfig insertObject:itemDetailDict atIndex:0];
        }

    }

}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
