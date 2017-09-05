//
//  CreditcardCredetnial+Dictionary.m
//  RapidRMS
//
//  Created by siya-IOS5 on 11/28/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "CreditcardCredetnial+Dictionary.h"

@implementation CreditcardCredetnial (Dictionary)

-(NSDictionary *)creditcardCredetnialDictionary
{
    NSMutableDictionary *credtCard=[[NSMutableDictionary alloc]init];
    credtCard[@"ACCOUNT_TOKEN"] = [NSString stringWithFormat:@"%@",self.aCCOUNT_TOKEN];
    credtCard[@"API_KEY"] = self.aPI_KEY;
    credtCard[@"BranchId"] = self.branchId;
    credtCard[@"CardInfoId"] = self.cardInfoId;
    credtCard[@"CreatedDate"] = self.createdDate;
    credtCard[@"Gateway"] = self.gateway;
    credtCard[@"IsManualProcess"] = [NSString stringWithFormat:@"%@",self.isManualProcess];
    credtCard[@"MerchantId"] = self.merchantId;
    credtCard[@"PaymentMode"] = @(self.paymentMode.integerValue);
    credtCard[@"URL"] = self.uRL;
    credtCard[@"Username"] = self.username;
    credtCard[@"isActive"] = self.isActive;
    credtCard[@"password"] = self.password;

    return credtCard;
}

-(void)updateCreditcardCredetnialDictionary :(NSDictionary *)creditcardCredetnialDictionary
{
    
    if (creditcardCredetnialDictionary == nil) {
        return;
    }
    
    self.aCCOUNT_TOKEN = [NSString stringWithFormat:@"%@",[creditcardCredetnialDictionary valueForKey:@"ACCOUNT_TOKEN"]] ;
    self.aPI_KEY= [NSString stringWithFormat:@"%@",[creditcardCredetnialDictionary valueForKey:@"API_KEY"]] ;
    self.branchId= [NSString stringWithFormat:@"%@",[creditcardCredetnialDictionary valueForKey:@"BranchId"]] ;
    self.cardInfoId= [NSString stringWithFormat:@"%@",[creditcardCredetnialDictionary valueForKey:@"CardInfoId"]] ;
    self.createdDate= [NSString stringWithFormat:@"%@",@""] ;
    self.gateway= [NSString stringWithFormat:@"%@",[creditcardCredetnialDictionary valueForKey:@"Address1"]] ;
    self.isManualProcess= @([[creditcardCredetnialDictionary valueForKey:@"IsManualProcess"] integerValue]) ;
    self.merchantId=  @([[creditcardCredetnialDictionary valueForKey:@"MerchantId"] integerValue]) ;
    self.paymentMode= [NSString stringWithFormat:@"%@",[creditcardCredetnialDictionary valueForKey:@"Address1"]] ;
    self.uRL= [NSString stringWithFormat:@"%@",[creditcardCredetnialDictionary valueForKey:@"Address1"]] ;
    self.username= [NSString stringWithFormat:@"%@",[creditcardCredetnialDictionary valueForKey:@"Username"]] ;
    self.isActive= @([[creditcardCredetnialDictionary valueForKey:@"isActive"] integerValue]) ;
    self.password= [NSString stringWithFormat:@"%@",[creditcardCredetnialDictionary valueForKey:@"password"]] ;

}
@end
