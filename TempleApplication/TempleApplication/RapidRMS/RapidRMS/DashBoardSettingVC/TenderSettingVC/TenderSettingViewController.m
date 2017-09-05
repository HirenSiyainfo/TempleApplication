//
//  TenderSettingViewController.m
//  RapidRMS
//
//  Created by siya-IOS5 on 5/14/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "TenderSettingViewController.h"
#import "RmsDbController.h"
#import "TenderPay+Dictionary.h"

@interface TenderSettingViewController ()

@property (nonatomic, strong) RcrController *crmController;
@property (nonatomic, strong) RmsDbController *rmsDbController;

@property (nonatomic, strong) UITableView *tblTenderConf;

@property (nonatomic, strong) NSMutableArray *arrpaymentType;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation TenderSettingViewController
@synthesize managedObjectContext = __managedObjectContext;

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
    self.arrpaymentType = [[NSMutableArray alloc] init];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.crmController = [RcrController sharedCrmController];
    
    self.managedObjectContext=self.rmsDbController.managedObjectContext;
    
    [self GetPaymentData];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
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
    NSMutableDictionary *dict1=[[NSMutableDictionary alloc]init];
    dict1[@"PayId"] = @"0";
    dict1[@"PayImage"] = @"0";
    dict1[@"PaymentName"] = @"0";
    [self.arrpaymentType insertObject:dict1 atIndex:0];
    
    NSMutableArray *arrTemp = [[NSUserDefaults standardUserDefaults] valueForKey:@"TendConfig" ];
    
    if(arrTemp.count > 0)
    {
        self.crmController.globalArrTenderConfig = [arrTemp mutableCopy];
    }
   
    self.tblTenderConf = [[UITableView alloc] initWithFrame:CGRectMake(250, -125, 235, 700) style:UITableViewStylePlain];
    self.tblTenderConf.delegate = self;
    self.tblTenderConf.dataSource = self;
    self.tblTenderConf.backgroundColor = [UIColor colorWithRed:228.0/255.0 green:228.0/255.0 blue:234.0/255.0 alpha:1.0];
    [self.tblTenderConf setShowsHorizontalScrollIndicator:NO];
    [self.tblTenderConf setShowsVerticalScrollIndicator:NO];
    [self.view addSubview:self.tblTenderConf];
    [self.tblTenderConf reloadData];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tblTenderConf)
    {
        
        if (indexPath.section==0) {
            return 200;
        }
        else
        {
            return 110;
        }
    }
    else
    {
        return 44;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
   if(tableView == self.tblTenderConf)
    {
        return self.arrpaymentType.count;
    }
    else
    {
        return 1;
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tblTenderConf)
    {
        return 1;
    }
    else
    {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCellStyle style =  UITableViewCellStyleDefault;
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"BaseCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
     if (tableView == self.tblTenderConf)
    {
        tableView.transform = CGAffineTransformMakeRotation(M_PI*1.5);
        cell.transform = CGAffineTransformMakeRotation(M_PI/2);
        
        cell.contentView.layer.borderColor = [UIColor blackColor].CGColor;
        cell.contentView.layer.borderWidth = 0.5;
        if (indexPath.section==0) {
            
            UILabel *lable1 = [[UILabel alloc] initWithFrame:CGRectMake(5, 2, 180, 25)];
            lable1.text = @"Options";
            lable1.textAlignment=NSTextAlignmentLeft;
            lable1.backgroundColor=[UIColor clearColor];
            lable1.font = [UIFont fontWithName:@"Helvetica Neue" size:14];
            [cell addSubview:lable1];
            
            
            UILabel *lable2 = [[UILabel alloc] initWithFrame:CGRectMake(5, 36, 180, 30)];
            lable2.text = @"Print Receipt Prompt";
            lable2.textAlignment=NSTextAlignmentLeft;
            lable2.backgroundColor=[UIColor clearColor];
            lable2.font = [UIFont fontWithName:@"Helvetica Neue" size:14];
            [cell addSubview:lable2];
            
            UILabel *lable3 = [[UILabel alloc] initWithFrame:CGRectMake(5, 72, 180, 30)];
            lable3.numberOfLines=2;
            lable3.lineBreakMode = NSLineBreakByWordWrapping;
            lable3.text = @"Print Receipt";
            lable3.textAlignment=NSTextAlignmentLeft;
            lable3.backgroundColor=[UIColor clearColor];
            lable3.font = [UIFont fontWithName:@"Helvetica Neue" size:14];
            [cell addSubview:lable3];
            
            
            
            UILabel *lable4 = [[UILabel alloc] initWithFrame:CGRectMake(5,115 , 180, 30)];
            lable4.text = @"Open Cash Drawer";
            lable4.textAlignment=NSTextAlignmentLeft;
            lable4.backgroundColor=[UIColor clearColor];
            
            lable4.font = [UIFont fontWithName:@"Helvetica Neue" size:14];
            [cell addSubview:lable4];
            
            UILabel *lable5 = [[UILabel alloc] initWithFrame:CGRectMake(5,155 , 180, 30)];
            lable5.text = @"Card Swipe";
            lable5.textAlignment=NSTextAlignmentLeft;
            lable5.backgroundColor=[UIColor clearColor];
            
            lable5.font = [UIFont fontWithName:@"Helvetica Neue" size:14];
            [cell addSubview:lable5];
            
            
            UILabel *lable6 = [[UILabel alloc] initWithFrame:CGRectMake(5,190, 180, 30)];
            lable6.text = @"Multiple Card Swipe";
            lable6.textAlignment=NSTextAlignmentLeft;
            lable6.backgroundColor=[UIColor clearColor];
            
            lable6.font = [UIFont fontWithName:@"Helvetica Neue" size:14];
            [cell addSubview:lable6];
            
            //            UILabel *lable6 = [[UILabel alloc] initWithFrame:CGRectMake(15,170 , 90, 30)];
            //            lable6.text = @"Print Receipt Required";
            //            lable6.textAlignment=NSTextAlignmentCenter;
            //            lable6.font = [UIFont systemFontOfSize:16];
            //            [cell addSubview:lable6];
            //
            
            int y=28;
            for (int i=0 ; i < 5; i++)
            {
                UILabel *lableSeprator = [[UILabel alloc] initWithFrame:CGRectMake(0, y, 200, 1)];
                lableSeprator.backgroundColor=[UIColor lightGrayColor];
                [cell addSubview:lableSeprator];
                y+=40;
            }
        }
        else
        {
            UIButton *btn;
            for(btn in cell.subviews){
                if([btn isKindOfClass:[UIButton class]])
                    [btn removeFromSuperview];
            }
            
            UILabel *lbl;
            for(lbl in cell.subviews){
                if([lbl isKindOfClass:[UILabel class]])
                    [lbl removeFromSuperview];
            }
            
            if (self.arrpaymentType.count>0)
            {
                UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 110, 30)];
                lable.text = (self.arrpaymentType)[indexPath.section][@"PaymentName"];
                lable.textAlignment = NSTextAlignmentCenter;
                lable.font = [UIFont fontWithName:@"Helvetica Neue" size:17];
                lable.backgroundColor = [UIColor clearColor];
                [cell addSubview:lable];
            }
            int y=38;
            for (int i=0 ; i < 5; i++)
            {
                UIButton *btnCheckbox = [UIButton buttonWithType:UIButtonTypeCustom];
                btnCheckbox.frame = CGRectMake(43, y, 25, 25);
                btnCheckbox.tag = [NSString stringWithFormat:@"%ld%ld",(long)indexPath.section,(long)indexPath.row+i].intValue ;
                if(self.crmController.globalArrTenderConfig.count > 0 )
                {
                    for(int j=0;j<self.crmController.globalArrTenderConfig.count;j++)
                    {
                        if([[(self.crmController.globalArrTenderConfig)[j] valueForKey:@"indexpath"] intValue ] == btnCheckbox.tag )
                        {
                            UIImage* checkButtonImage = [UIImage imageNamed:@"checked_checkbox.png"];
                            [btnCheckbox setBackgroundImage:checkButtonImage forState:UIControlStateSelected];
                            [btnCheckbox setSelected:YES];
                        }
                        else
                        {
                            UIImage* unCheckButtonImage = [UIImage imageNamed:@"unchecked_checkbox.png"];
                            [btnCheckbox setBackgroundImage:unCheckButtonImage forState:UIControlStateNormal];
                        }
                    }
                }
                else
                {
                    UIImage* unCheckButtonImage = [UIImage imageNamed:@"unchecked_checkbox.png"];
                    [btnCheckbox setBackgroundImage:unCheckButtonImage forState:UIControlStateNormal];
                }
                [btnCheckbox addTarget:self action:@selector(btnCheckbox:) forControlEvents:UIControlEventTouchDown];
                [cell addSubview:btnCheckbox];
                y+=40;
            }
        }
        
        int y=28;
        for (int i=0 ; i < 5; i++)
        {
            UILabel *lableSeprator = [[UILabel alloc] initWithFrame:CGRectMake(0, y, 110, 1)];
            lableSeprator.backgroundColor=[UIColor lightGrayColor];
            [cell addSubview:lableSeprator];
            y+=40;
        }
    }
    return cell;
}
-(IBAction)btnCheckbox:(id)sender
{
    UIButton *btnTemp = (UIButton *)sender;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[sender tag] inSection:[sender superview].tag];
    NSMutableDictionary *itemDetailDict = [[NSMutableDictionary alloc] init];
    
    if (btnTemp.selected)
    {
        [btnTemp setBackgroundImage:[UIImage imageNamed:@"unchecked_checkbox.png"] forState:UIControlStateNormal];
        [btnTemp setSelected:NO];
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
        
        [btnTemp setBackgroundImage:[UIImage imageNamed:@"checked_checkbox.png"] forState:UIControlStateSelected];
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
                    if((iopt==0)||(iopt==1))
                    {
                        if(([lastChar isEqualToString:@"0"])||([lastChar isEqualToString:@"1"]))
                        {
                            [self.crmController.globalArrTenderConfig removeObjectAtIndex:i];
                            [self.tblTenderConf reloadData];
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

-(IBAction)btnSaveConfigClicked:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:self.crmController.globalArrTenderConfig forKey:@"TendConfig"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {};
    [self.rmsDbController popupAlertFromVC:self title:@"Inventory In" message:@"Record save successfully" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
