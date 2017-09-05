//
//  CS_Statistics.m
//  RapidRMS
//
//  Created by Siya Infotech on 07/12/15.
//  Copyright © 2015 Siya Infotech. All rights reserved.
//

#import "CS_Statistics.h"
#import "RmsDbController.h"

@interface CS_Statistics ()
@property (nonatomic,strong) RmsDbController *rmsDbController;

@end

@implementation CS_Statistics


-(instancetype)init
{
    self = [super init];
    
    if (self) {
        self.rmsDbController = [RmsDbController sharedRmsDbController];
        [self resetStatistics];
    }
    return self;
}
-(void)resetStatistics
{
   self.customerName = @"";
    self.loyaltyNo = @"";
    self.contactNo = @"";
    self.email = @"";
    self.dob = @"";
    self.address = @"";
    self.lastPurchaseDateTime = @"";
    self.avgTickets = @"";
    self.customerNo = @"";
    self.avgQty = @(0);
    self.purchaseItem = @(0);

    
    self.topTags = nil;
    self.topItems = nil;
    self.paymentType = nil;
    self.departmentArray = nil;
    
}

-(void)setupCustomerStatisticsDetail:(NSDictionary *)customerStatisticDetailDictionary
{
    
    self.customerName = [NSString stringWithFormat:@"%@",[customerStatisticDetailDictionary valueForKey:@"CustomerName"]];
    self.loyaltyNo = [NSString stringWithFormat:@"%@",[customerStatisticDetailDictionary valueForKey:@"LoyaltyNo"]];
    self.contactNo = [NSString stringWithFormat:@"%@",[customerStatisticDetailDictionary valueForKey:@"ContactNo"]];
    self.email = [NSString stringWithFormat:@"%@",[customerStatisticDetailDictionary valueForKey:@"Email"]];

    self.dob = [NSString stringWithFormat:@"%@",[customerStatisticDetailDictionary valueForKey:@"DOB"]];
    self.address = [NSString stringWithFormat:@"%@",[customerStatisticDetailDictionary valueForKey:@"Address"]];
    self.lastPurchaseDateTime = [NSString stringWithFormat:@"%@",[customerStatisticDetailDictionary valueForKey:@"LastPurchaseDateTime"]];
    self.avgTickets = [NSString stringWithFormat:@"%@",[customerStatisticDetailDictionary valueForKey:@"AvgTicket"]];
    self.customerNo = [NSString stringWithFormat:@"%@",[customerStatisticDetailDictionary valueForKey:@"CustomerNo"]];
    self.avgQty = @([[customerStatisticDetailDictionary valueForKey:@"AvgQty"] floatValue]);
    self.purchaseItem = @([[customerStatisticDetailDictionary valueForKey:@"PurchaseItem"] floatValue]);

    
    if (![[customerStatisticDetailDictionary valueForKey:@"TopTags"] isKindOfClass:[NSNull class]] && [[customerStatisticDetailDictionary valueForKey:@"TopTags"] length] > 0 ) {
        self.topTags = [[customerStatisticDetailDictionary valueForKey:@"TopTags"] componentsSeparatedByString:@","];
    }
    
    if (![[customerStatisticDetailDictionary valueForKey:@"TopItems"] isKindOfClass:[NSNull class]] && [[customerStatisticDetailDictionary valueForKey:@"TopItems"] length] > 0 ) {
        self.topItems = [[customerStatisticDetailDictionary valueForKey:@"TopItems"] componentsSeparatedByString:@","];
    }
    
    self.paymentType = [customerStatisticDetailDictionary valueForKey:@"PaymentInfo"];
    self.departmentArray = [customerStatisticDetailDictionary valueForKey:@"DepartmentInfo"];
}


- (NSMutableDictionary *)customerStatisticDetailDictionary
{
    
    NSMutableDictionary *customerStatisticDetailDictionary = [[NSMutableDictionary alloc]init];
    
    [customerStatisticDetailDictionary setValue:self.customerName forKey:@"CustomerName"];
    [customerStatisticDetailDictionary setValue:self.loyaltyNo forKey:@"LoyaltyNo"];
    [customerStatisticDetailDictionary setValue:self.contactNo forKey:@"ContactNo"];
    [customerStatisticDetailDictionary setValue:self.email forKey:@"Email"];
    [customerStatisticDetailDictionary setValue:self.dob forKey:@"dob"];
    [customerStatisticDetailDictionary setValue:self.address forKey:@"Address"];
    [customerStatisticDetailDictionary setValue:self.customerNo forKey:@"CustomerNo"];
    [customerStatisticDetailDictionary setValue:self.lastPurchaseDateTime forKey:@"LastPurchaseDateTime"];
    [customerStatisticDetailDictionary setValue:self.avgTickets forKey:@"AvgTickets"];
    [customerStatisticDetailDictionary setValue:self.topItems forKey:@"TopItems"];
    [customerStatisticDetailDictionary setValue:self.topTags forKey:@"TopTags"];
    [customerStatisticDetailDictionary setValue:self.avgQty forKey:@"AvgQty"];
    [customerStatisticDetailDictionary setValue:self.purchaseItem forKey:@"PurchaseItem"];


    return customerStatisticDetailDictionary;
    
}


@end
