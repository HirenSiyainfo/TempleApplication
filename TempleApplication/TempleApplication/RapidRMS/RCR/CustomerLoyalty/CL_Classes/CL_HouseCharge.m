//
//  CL_HouseChage.m
//  RapidRMS
//
//  Created by Siya Infotech on 26/04/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "CL_HouseCharge.h"
#import "RmsDbController.h"

@interface CL_HouseCharge ()
@property (nonatomic,strong) RmsDbController *rmsDbController;

@end


@implementation CL_HouseCharge

-(instancetype)init
{
    self = [super init];
    
    if (self) {
        self.rmsDbController = [RmsDbController sharedRmsDbController];
        [self resetHouseCharge];
    }
    return self;
}
-(void)resetHouseCharge
{
    self.houseChageDate = @"";
    self.invoice = @"";
    self.Credit = @(0);
    self.debit = @(0);
    self.balance =  @(0);
}


-(void)setupCustomerHouseChargeDetail:(NSDictionary *)customerHouseChargeDetailDictionary
{
    
    self.invoice = [NSString stringWithFormat:@"%@",[customerHouseChargeDetailDictionary valueForKey:@"RegInvoiceNo"]];
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"MM / dd / yyyy HH:mm EEEE";
    NSDate *now = [self.rmsDbController getDateFromJSONDate:[NSString stringWithFormat:@"%@",[customerHouseChargeDetailDictionary valueForKey:@"Createddate"]]];
    
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    format.timeZone = gmt;
    NSString *dateString = [format stringFromDate:now];
    
    self.houseChageDate = [NSString stringWithFormat:@"%@",dateString];
    
    self.Credit = @([[customerHouseChargeDetailDictionary valueForKey:@"CreditAmount"] floatValue]);
    self.debit = @([[customerHouseChargeDetailDictionary valueForKey:@"DebitAmount"] floatValue]);
    self.balance = @([[customerHouseChargeDetailDictionary valueForKey:@"BalanceAmount"] floatValue]);

}


- (NSMutableDictionary *) customerHouseChargeDetailDict
{
    
    NSMutableDictionary *customerHouseChargeDetailDict = [[NSMutableDictionary alloc]init];
    
    [customerHouseChargeDetailDict setValue:self.houseChageDate forKey:@"Createddate"];
    [customerHouseChargeDetailDict setValue:self.invoice forKey:@"RegInvoiceNo"];
    [customerHouseChargeDetailDict setValue:self.Credit forKey:@"CreditAmount"];
    [customerHouseChargeDetailDict setValue:self.debit forKey:@"DebitAmount"];
    [customerHouseChargeDetailDict setValue:self.balance forKey:@"BalanceAmount"];
    return customerHouseChargeDetailDict;
    
}



@end
