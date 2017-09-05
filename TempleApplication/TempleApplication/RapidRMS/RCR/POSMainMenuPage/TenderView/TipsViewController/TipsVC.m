//
//  TipsVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 10/12/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "TipsVC.h"
#import "TipsViewCustomCell.h"
#import "UITableViewCell+NIB.h"

#import "TipNumberPadPopupVC.h"
#import "RmsDbController.h"
#import "TipPercentageMaster.h"

@interface TipsVC () <TipsInputDelegate>
{
    NSIndexPath *selectedTips;
    TipNumberPadPopupVC *tipNumberPadPopupVC;
}
@property (nonatomic, weak) IBOutlet UITableView *tipsTypeTableView;
@property (nonatomic, weak) IBOutlet UILabel *totalAmount;

@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) RcrController *crmController;

@property (nonatomic, strong) UIPopoverController *tipsPopoverController;

@property (nonatomic,strong) NSMutableArray *tipsArray;



@end

@implementation TipsVC
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
    [super viewDidLoad];
    
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.crmController = [RcrController sharedCrmController];
    
    self.managedObjectContext = self.crmController.managedObjectContext;
    
    
    
    tipNumberPadPopupVC = [[TipNumberPadPopupVC alloc] initWithNibName:@"TipNumberPadPopupVC" bundle:nil];
    tipNumberPadPopupVC.tipsInputDelegate = self;
    tipNumberPadPopupVC.view.frame = [self frameForTipsPopOverView];
    [self.view addSubview:tipNumberPadPopupVC.view];
    
    self.tipsArray = [[NSMutableArray alloc] init];
    self.tipsArray = [[self fetchTipFromDatabase] mutableCopy];
    
    _totalAmount.text = [NSString stringWithFormat:@"%@",[self.rmsDbController applyCurrencyFomatter:[NSString stringWithFormat:@"%f",self.billAmountForTipCalculation]]];
    
    
    [self.tipsTypeTableView reloadData];
    [self resetGrandTotal];
    
    selectedTips = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tipsTypeTableView selectRowAtIndexPath:selectedTips animated:NO scrollPosition:UITableViewScrollPositionNone];
    
    // Do any additional setup after loading the view.
}

-(NSArray *)fetchTipFromDatabase
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TipPercentageMaster" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    NSMutableArray *tipDataBaseArray = [[NSMutableArray alloc]init];
    
    for (TipPercentageMaster *tipPercentageMaster in resultSet)
    {
        NSMutableDictionary *tipPercentageMasterDict = [[NSMutableDictionary alloc]init];
        tipPercentageMasterDict[@"TipsPercentage"] = tipPercentageMaster.tipPercentage;
        
        CGFloat tipCalculatedAmount = self.billAmountForTipCalculation * tipPercentageMaster.tipPercentage.floatValue * 0.01;
        tipPercentageMasterDict[@"TipsAmount"] = [NSString stringWithFormat:@"%.2f",tipCalculatedAmount];
        [tipDataBaseArray addObject:tipPercentageMasterDict];
    }
    
    NSMutableDictionary *tip1 = [@{
                                   @"TipsPercentage":@"Custom",
                                   @"TipsAmount":@"Add Amount",
                                   } mutableCopy ];
    
    [tipDataBaseArray insertObject:[tip1 mutableCopy ] atIndex:0];
    return tipDataBaseArray;

}

# pragma mark - UITableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tipsTypeTableView) {
        return self.tipsArray.count;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // [NSString stringWithFormat:@"%@",[self.crmController.currencyFormatter stringFromNumber:@(collectAmount)]]
    static NSString *CellIdentifier = @"TipsViewCustomCell";
    TipsViewCustomCell *tipsCell = nil;
    if (tableView == self.tipsTypeTableView) {
        tipsCell = (TipsViewCustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        tipsCell.selectionStyle = UITableViewCellSelectionStyleDefault;

        UIView *selectionColor = [[UIView alloc] initWithFrame:CGRectMake(tipsCell.frame.origin.x, tipsCell.frame.origin.y -10, tipsCell.frame.size.width, 60)];
        selectionColor.backgroundColor = [UIColor colorWithRed:(20.0/255.f) green:(34.0/255.f) blue:(61.0/255.f) alpha:1.0];
        tipsCell.selectedBackgroundView = selectionColor;
        tipsCell.selectedBackgroundView.layer.cornerRadius = 32.0f;
        tipsCell.tipsType.text =[NSString stringWithFormat:@"%@",[(self.tipsArray)[indexPath.row] valueForKey:@"TipsPercentage"]] ;
        tipsCell.tipsValue.text =[NSString stringWithFormat:@"%.2f",[[(self.tipsArray)[indexPath.row] valueForKey:@"TipsAmount"] floatValue]] ;
        
        return tipsCell;

    }
    return tipsCell;
   }

-(CGRect)frameForTipsPopOverView
{
    CGRect frameForSwipeEditView = CGRectMake(630.00, 120.0, 340.0, 580.0);
    return frameForSwipeEditView;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [self.tipsPopoverController dismissPopoverAnimated:YES];
    selectedTips = [indexPath copy];
      if(indexPath.row == 0)
      {
          //          [self.tipsPopoverController dismissPopoverAnimated:NO];
          //          self.tipsPopoverController = nil;
          //        self.tipsPopoverController = [[UIPopoverController alloc] initWithContentViewController:tipNumberPadPopupVC];
          //        [self.tipsPopoverController setPopoverContentSize:CGSizeMake(260, 304)];
          //        CGRect popoverRect = [self.view convertRect:myRect fromView:self.view];
          //        [self.tipsPopoverController presentPopoverFromRect:popoverRect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
      }
    else
    {
        self.tipAmount = [[(self.tipsArray)[indexPath.row] valueForKey:@"TipsAmount"] floatValue ];
        [self resetGrandTotal];
    }
}

// Return selected Tip Type and Value
-(IBAction)tipDoneButtonClicked:(id)sender
{
    [self.tipsSelectionDeletage didSelectTip:self.tipAmount];
}
-(IBAction)tipCancelButtonClicked:(id)sender
{
    [self.tipsSelectionDeletage didCancelTip];
}

-(IBAction)tipRemoveButtonClicked:(id)sender
{
  //  [self.tipsSelectionDeletage didRemoveTip];
    
    [self.tipsSelectionDeletage didSelectTip:0.00];

}

// Get custom tip amount/value
-(void)didEnterTip:(CGFloat)tipValue
{
    selectedTips = [NSIndexPath indexPathForRow:0 inSection:0];
    self.tipAmount = tipValue;
    NSString *tipAmt = [NSString stringWithFormat:@"%.2f",tipValue];
//    [self.tipsPopoverController dismissPopoverAnimated:NO];
    NSMutableDictionary *tip1 = [self.tipsArray.firstObject mutableCopy ];
    tip1[@"TipsAmount"] = tipAmt;
    (self.tipsArray)[0] = tip1;
    [self.tipsTypeTableView reloadRowsAtIndexPaths:@[selectedTips] withRowAnimation:UITableViewRowAnimationNone ];
    [self.tipsTypeTableView selectRowAtIndexPath:selectedTips animated:NO scrollPosition:UITableViewScrollPositionNone];
    [self resetGrandTotal];
}

-(void)resetGrandTotal
{
    grandTotal.text = [NSString stringWithFormat:@"GRAND TOTAL :  %@",[self.rmsDbController applyCurrencyFomatter:[NSString stringWithFormat:@"%f",self.billAmountForTipCalculation+self.tipAmount]]];
}
-(void)didCancelTip
{
    [self.tipsPopoverController dismissPopoverAnimated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
