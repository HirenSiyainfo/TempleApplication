//
//  TipsAdjustmentVC.m
//  RapidRMS
//
//  Created by siya-IOS5 on 12/16/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "TipsAdjustmentVC.h"
#import "TipsAdjustmentCell.h"
#import "RmsDbController.h"


@interface TipsAdjustmentVC ()<UITableViewDataSource,UITableViewDelegate,UIPopoverControllerDelegate>
{
    NSMutableArray *tempArray;

}
@property (nonatomic,weak) IBOutlet UIView *tenderTypeView;
@property (nonatomic,weak) IBOutlet UIButton *tenderTypeButton;
@property (nonatomic,weak) IBOutlet  UITableView *tenderPaymentType;

@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) RcrController *crmController;

@end

@implementation TipsAdjustmentVC

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
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.crmController = [RcrController sharedCrmController];
    
    _tenderTypeView.hidden = YES;
    

    
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    tempArray = [[NSMutableArray alloc]init];
    tempArray = self.paymentTypeArray;
    
    [super viewDidAppear:animated];
    self.tenderPaymentType.delegate = self;
    self.tenderPaymentType.dataSource = self;
    [self.tenderPaymentType reloadData];
    
    for (int i = 0; i < self.paymentTypeArray.count; i++) {
        
        NSString *carIntType = [(self.paymentTypeArray)[i] valueForKey:@"CardIntType"];
        
        if ([carIntType isEqualToString:@"Credit"] )
        {
            [self.tenderPaymentType selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:TRUE scrollPosition:UITableViewScrollPositionNone];
            NSString *paymentType ;
            if ((self.paymentTypeArray)[i][@"PaymentName"])
            {
                paymentType = (self.paymentTypeArray)[i][@"PaymentName"];
            }
            else
            {
                paymentType = (self.paymentTypeArray)[i][@"PayMode"];
            }
            [_tenderTypeButton setTitle:paymentType forState:UIControlStateNormal];
            self.tipAmount = [[(self.paymentTypeArray)[i] valueForKey:@"TipsAmount"] floatValue];
            [self resetGrandTotal];
            break;
        }
    }
    
    
}


# pragma mark - UITableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tenderPaymentType)
    {
       return tempArray.count;
    }
    else
    {
        return [super tableView:tableView numberOfRowsInSection:section];
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tenderPaymentType)
    {
        return 65.0;
    }
    return 65.0;
}

- (UIColor *)backGroundColorAtIndexPath:(NSIndexPath *)indexPath
{
    UIColor *backGroundColor;
    if ([[self.paymentTypeArray [indexPath.row] valueForKey:@"BillAmount"] floatValue] != 0)
    {
        backGroundColor = [UIColor lightGrayColor];
    }
    else
    {
        backGroundColor = [UIColor whiteColor];
    }
    return backGroundColor;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell ;
    if (tableView == self.tenderPaymentType)
    {
        static NSString *CellIdentifier = @"TipsAdjustmentCell";
        TipsAdjustmentCell *tipsAdjustmentCell = nil;
        tipsAdjustmentCell = (TipsAdjustmentCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        tipsAdjustmentCell.selectionStyle = UITableViewCellSelectionStyleDefault;
        
        tipsAdjustmentCell.paymentName.text = [(self.paymentTypeArray)[indexPath.row] valueForKey:@"PaymentName"];
        if (tipsAdjustmentCell.paymentName.text.length == 0) {
            tipsAdjustmentCell.paymentName.text = [(self.paymentTypeArray)[indexPath.row] valueForKey:@"PayMode"];
        }
        
        UIView *selectionColor = [[UIView alloc] initWithFrame:CGRectMake(tipsAdjustmentCell.frame.origin.x, tipsAdjustmentCell.frame.origin.y -10, tipsAdjustmentCell.frame.size.width, 60)];
        selectionColor.backgroundColor = [UIColor colorWithRed:(20.0/255.f) green:(34.0/255.f) blue:(61.0/255.f) alpha:1.0];
        tipsAdjustmentCell.selectedBackgroundView = selectionColor;
        tipsAdjustmentCell.selectedBackgroundView.layer.cornerRadius = 32.0;
        
//        UIView *backGroundColorView = [[UIView alloc] init];
//        backGroundColorView.backgroundColor = [UIColor colorWithRed:(242.0/255.f) green:(240.0/255.f) blue:(240.0/255.f) alpha:1.0];
//        tipsAdjustmentCell.backgroundView = backGroundColorView;
        
        tipsAdjustmentCell.billAmount.text = @"";
        tipsAdjustmentCell.tipsAmount.text = @"";

        CGFloat billAmount = [[(self.paymentTypeArray)[indexPath.row] valueForKey:@"BillAmount"] floatValue];
        CGFloat tipAmount = [[(self.paymentTypeArray)[indexPath.row] valueForKey:@"TipsAmount"] floatValue];

        if (billAmount + tipAmount>0) {
            tipsAdjustmentCell.billAmount.text = [NSString stringWithFormat:@"BillAmount %@",[self.rmsDbController applyCurrencyFomatter:[NSString stringWithFormat:@"%f",billAmount]]];
            tipsAdjustmentCell.tipsAmount.text = [NSString stringWithFormat:@"Tip %@",[self.rmsDbController applyCurrencyFomatter:[NSString stringWithFormat:@"%f",tipAmount]]];
        }
        return tipsAdjustmentCell;
    }
    else
    {
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tenderPaymentType)
    {
        NSString *carIntType = [(self.paymentTypeArray)[indexPath.row] valueForKey:@"CardIntType"];
        NSString *transactionNo = [(self.paymentTypeArray)[indexPath.row] valueForKey:@"TransactionNo"];

        if ([carIntType isEqualToString:@"Credit"] )
        {
            if (transactionNo.length == 0)
            {
                BOOL isCreditCardApplicable = [self.crmController isSpecOptionApplicableCreditCardForCommon:3];
                if (isCreditCardApplicable) {
                    [tableView deselectRowAtIndexPath:indexPath animated:NO];
                    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                    {
                    };
                    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Please select Other PaymentType For Tip Adjustment" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                    
                    return;
                }
            }
        }
        
        NSString *paymentType ;
        if ((self.paymentTypeArray)[indexPath.row][@"PaymentName"]) {
            paymentType = (self.paymentTypeArray)[indexPath.row][@"PaymentName"];
        }
        else
        {
            paymentType = (self.paymentTypeArray)[indexPath.row][@"PayMode"];
        }
        
        [_tenderTypeButton setTitle:paymentType forState:UIControlStateNormal];
        _tenderTypeView.hidden = YES;
    }
    else
    {
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

-(CGRect)frameForTipsPopOverView
{
    CGRect frameForSwipeEditView = CGRectMake(630.0, 120.0, 380.0, 580.0);
    return frameForSwipeEditView;
}

-(IBAction)selectTip:(id)sender{
    
    NSArray *selectedType = self.tenderPaymentType.indexPathsForSelectedRows;
    if (selectedType.count == 0) {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Please select PaymentType" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        
        return;
    }
    NSIndexPath *indexpath = selectedType.firstObject;
    [self.tipsAdjustmentVcDelegate addTipAtPaymentTypeWithDetail:(self.paymentTypeArray)[indexpath.row] withTipAmount:self.tipAmount];
}
-(IBAction)cancelTip:(id)sender{
    [self.tipsAdjustmentVcDelegate didCancelAdjustTip];
}
-(IBAction)removeTip:(id)sender{
    [self.tipsAdjustmentVcDelegate didRemoveAdjustTip];
}
-(void)resetGrandTotal
{
    grandTotal.text = [NSString stringWithFormat:@"GRAND TOTAL :  %@",[self.rmsDbController applyCurrencyFomatter:[NSString stringWithFormat:@"%f",self.billAmountForTipCalculation + self.tipAmount]]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)showTenderTypeList:(id)sender
{
    _tenderTypeView.hidden = NO;
}


@end
