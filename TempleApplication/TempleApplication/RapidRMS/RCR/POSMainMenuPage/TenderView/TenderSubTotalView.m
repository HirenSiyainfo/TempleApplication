//
//  TenderSubTotalView.m
//  RapidRMS
//
//  Created by siya-IOS5 on 12/11/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "TenderSubTotalView.h"
#import "RmsDbController.h"

@interface TenderSubTotalView ()
{
    
}
@property (nonatomic, weak) IBOutlet UILabel *billAmount;
@property (nonatomic, weak) IBOutlet UILabel *collectedAmount;
@property (nonatomic, weak) IBOutlet UILabel *changDue;
@property (nonatomic, weak) IBOutlet UILabel *tipAmount;
@property (nonatomic, weak) IBOutlet UILabel *changeDueLableType;

@property (strong, nonatomic) RmsDbController *rmsDbController;

@end


@implementation TenderSubTotalView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self createRmsDbControllerObject];
    }
    return self;
}

- (void)awakeFromNib
{
    [self createRmsDbControllerObject];
}

- (void)createRmsDbControllerObject
{
    self.rmsDbController = [RmsDbController sharedRmsDbController];
}

-(void)updateSubtotalViewWithBillAmount:(CGFloat )totalBillAmount withCollectedAmount:(CGFloat)collectedAmounts withChangeDue:(CGFloat )changeDue withTipAmount:(CGFloat)tip
{
    if (collectedAmounts < 0)
    {
        collectedAmounts = 0.0;
    }
    
    UIColor *balanceColor = [UIColor colorWithRed:232.0/255.0 green:31.0/255.0 blue:0.0/255.0 alpha:1];
    if (changeDue <= 0)
    {
        if (changeDue < 0) {
           changeDue = -changeDue;
        }
        balanceColor = [UIColor colorWithRed:0.0/255.0 green:123.0/255.0 blue:182.0/255.0 alpha:1.0];
    }
    _changDue.textColor = balanceColor;
    _changeDueLableType.textColor = balanceColor;
    
    if (totalBillAmount< 0) {
        totalBillAmount = -totalBillAmount;
    }
    
    _billAmount.text = [self.rmsDbController applyCurrencyFomatter:[NSString stringWithFormat:@"%f",totalBillAmount]];
    _collectedAmount.text = [self.rmsDbController applyCurrencyFomatter:[NSString stringWithFormat:@"%f",collectedAmounts]];
    _changDue.text = [self.rmsDbController applyCurrencyFomatter:[NSString stringWithFormat:@"%f",changeDue]];
    _tipAmount.text = [self.rmsDbController applyCurrencyFomatter:[NSString stringWithFormat:@"%f",tip]];
}

-(void)updateSubtotalViewWithTipAmount:(CGFloat )tipAmounts andWithCollectAmount:(CGFloat)collectedAmounts
{
    _tipAmount.text = [self.rmsDbController applyCurrencyFomatter:[NSString stringWithFormat:@"%f",tipAmounts]];
    _collectedAmount.text = [self.rmsDbController applyCurrencyFomatter:[NSString stringWithFormat:@"%f",collectedAmounts]];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
