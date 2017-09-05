//
//  RapidPaymentMaster.m
//  RapidRMS
//
//  Created by siya-IOS5 on 9/25/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "RapidPaymentMaster.h"
#import "RmsDbController.h"

@interface RapidPaymentMaster ()

@property (nonatomic, strong) NSNumber * branchId;
@property (nonatomic, strong) NSString * payImage;
@property (nonatomic,strong) RmsDbController *rmsDbController;

@end


@implementation RapidPaymentMaster
-(instancetype)init
{
    self = [super init];
    
    if (self) {
        self.rmsDbController = [RmsDbController sharedRmsDbController];
        [self resetRapidPaymentMaster];
    }
    return self;
}
-(void)resetRapidPaymentMaster
{
    self.branchId = @(0);
    self.cardIntType = @"";
    self.chkDropAmt = @(0);
    self.payCode = @"";
    self.payId = @(0);
    self.payImage = @"";
    self.paymentName = @"";
    self.surchargeType = @"1";
    self.surchargeAmount = @(0);
    self.flgSurcharge = FALSE;
    
}
-(NSDictionary *)rapidPaymentMasterDictionary
{
    NSMutableDictionary *rapidPaymentMasterDictionary = [[NSMutableDictionary alloc] init];
    
    rapidPaymentMasterDictionary[@"CardIntType"] = [NSString stringWithFormat:@"%@",self.cardIntType];
    rapidPaymentMasterDictionary[@"ChkDropAmt"] = [NSString stringWithFormat:@"%@",self.chkDropAmt];
    rapidPaymentMasterDictionary[@"PayCode"] = [NSString stringWithFormat:@"%@",self.payCode];
   
    
    /// Update process parameter. Do not pass it in insert process......
    if (self.payId.integerValue  > 0) {
        rapidPaymentMasterDictionary[@"PayId"] = [NSString stringWithFormat:@"%@",self.payId];
        rapidPaymentMasterDictionary[@"OldPaymentName"] = @"";
        rapidPaymentMasterDictionary[@"OldPaymentCode"] = @"";
    }
    else
    {
        NSDate* date = [NSDate date];
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
        NSString *currentDateTime = [formatter stringFromDate:date];
        rapidPaymentMasterDictionary[@"localdatatime"] = currentDateTime;
    }
        
    
    rapidPaymentMasterDictionary[@"PayImage"] = [NSString stringWithFormat:@"%@",self.payImage];
    rapidPaymentMasterDictionary[@"PaymentName"] = [NSString stringWithFormat:@"%@",self.paymentName];
    rapidPaymentMasterDictionary[@"SurchargeType"] = [NSString stringWithFormat:@"%@",self.surchargeType];
    rapidPaymentMasterDictionary[@"SurchargeFixAmt"] = [NSString stringWithFormat:@"%@",self.surchargeAmount];
    if (self.flgSurcharge)
    {
        rapidPaymentMasterDictionary[@"FlgSurcharge"] = @(1);
    }
    else
        
    {
        rapidPaymentMasterDictionary[@"FlgSurcharge"] = @(0);

    }
    
    rapidPaymentMasterDictionary[@"ShortcutKeys"] = @"";
    
    rapidPaymentMasterDictionary[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    //// User id not get when add to Tendrconfiguration
    if ([(self.rmsDbController.globalDict)[@"UserInfo"] isKindOfClass:[NSMutableDictionary class]])
    {
        rapidPaymentMasterDictionary[@"CreatedBy"] = (self.rmsDbController.globalDict)[@"UserInfo"][@"UserId"];
    }
    else
    {
        rapidPaymentMasterDictionary[@"CreatedBy"] = @"1";
    }
    

    return rapidPaymentMasterDictionary;
}


-(void)setupRapidPaymentMaster:(NSDictionary *)customerDetailDictionary
{
    self.branchId = @([[customerDetailDictionary valueForKey:@"BranchId"] integerValue]);
    self.cardIntType = [NSString stringWithFormat:@"%@",[customerDetailDictionary valueForKey:@"CardIntType"]];
    self.chkDropAmt = @([[customerDetailDictionary valueForKey:@"ChkDropAmt"] integerValue]);
    self.payCode = [NSString stringWithFormat:@"%@",[customerDetailDictionary valueForKey:@"PayCode"]];
    self.payId = @([[customerDetailDictionary valueForKey:@"PayId"] integerValue]);
    self.payImage = [NSString stringWithFormat:@"%@",[customerDetailDictionary valueForKey:@"PayImage"]];
    self.paymentName = [NSString stringWithFormat:@"%@",[customerDetailDictionary valueForKey:@"PaymentName"]];
    self.surchargeType = [NSString stringWithFormat:@"%@",[customerDetailDictionary valueForKey:@"SurchargeType"]];
    self.flgSurcharge = [[customerDetailDictionary valueForKey:@"FlgSurcharge"] boolValue];

    self.surchargeAmount = @([[customerDetailDictionary valueForKey:@"SurchargeFixAmt"] floatValue]);
    }

@end
