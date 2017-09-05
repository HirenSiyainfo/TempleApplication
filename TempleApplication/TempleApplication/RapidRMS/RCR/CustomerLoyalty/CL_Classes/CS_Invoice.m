//
//  CS_Invoice.m
//  RapidRMS
//
//  Created by Siya Infotech on 07/12/15.
//  Copyright © 2015 Siya Infotech. All rights reserved.
//

#import "CS_Invoice.h"
#import "RmsDbController.h"

@interface CS_Invoice ()
@property (nonatomic,strong) RmsDbController *rmsDbController;

@end

@implementation CS_Invoice



-(instancetype)init
{
    self = [super init];
    
    if (self) {
        self.rmsDbController = [RmsDbController sharedRmsDbController];
        [self resetInvoiceDetail];
    }
    return self;
}
-(void)resetInvoiceDetail
{
    
    self.custId = @(0);
    self.invoice = @"";
    self.invoiceDate = @"";
    self.email = @"";
    self.contactNo = @"";
    self.loyaltyNo = @"";
    
    self.discount = 0.00;
    self.amount = @(0.00);
    self.totalTicket = 0.00;
    
    self.invoiceNo = @"";
    self.paymentType = nil;
    self.tags = nil;
    self.itemQty = @"";
    self.lastVisitDate = @"";

    
}

-(void)setupCustomerInvoiceDetail:(NSDictionary *)customerInvoiceDetailDictionary
{
    self.custId = @([[customerInvoiceDetailDictionary valueForKey:@"CustId"] integerValue]);
    self.invoice = [NSString stringWithFormat:@"%@",[customerInvoiceDetailDictionary valueForKey:@"Invoice"]];
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"MM / dd / yyyy HH:mm EEEE";
    NSDate *now = [self.rmsDbController getDateFromJSONDate:[NSString stringWithFormat:@"%@",[customerInvoiceDetailDictionary valueForKey:@"InvoiceDate"]]];
    
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    format.timeZone = gmt;
    NSString *dateString = [format stringFromDate:now];
    
    self.invoiceDate = [NSString stringWithFormat:@"%@",dateString];
    
    
    self.email = [NSString stringWithFormat:@"%@",[customerInvoiceDetailDictionary valueForKey:@"Email"]];
    
    self.contactNo = [NSString stringWithFormat:@"%@",[customerInvoiceDetailDictionary valueForKey:@"ContactNo"]];
    self.loyaltyNo = [NSString stringWithFormat:@"%@",[customerInvoiceDetailDictionary valueForKey:@"LoyalityNo"]];
    self.invoiceNo = [NSString stringWithFormat:@"%@",[customerInvoiceDetailDictionary valueForKey:@"InvoiceNo"]];
    self.itemQty = [NSString stringWithFormat:@"%@",[customerInvoiceDetailDictionary valueForKey:@"ItemQty"]];
    self.lastVisitDate = [NSString stringWithFormat:@"%@",[customerInvoiceDetailDictionary valueForKey:@"LastVisitDate"]];
    self.discount = [[customerInvoiceDetailDictionary valueForKey:@"Discount"] floatValue];
    self.amount = @([[customerInvoiceDetailDictionary valueForKey:@"Amount"] floatValue]);
    self.totalTicket = [[customerInvoiceDetailDictionary valueForKey:@"TotalTicket"] floatValue];

   // self.tags = [customerInvoiceDetailDictionary valueForKey:@"Tags"];
    
    if (![[customerInvoiceDetailDictionary valueForKey:@"Tags"] isKindOfClass:[NSNull class]] && [[customerInvoiceDetailDictionary valueForKey:@"Tags"] length] > 0 ) {
        self.tags = [[customerInvoiceDetailDictionary valueForKey:@"Tags"] componentsSeparatedByString:@","];
    }

    
    self.paymentType = [customerInvoiceDetailDictionary valueForKey:@"PaymentType"];
    
    
}

- (NSMutableDictionary *)customerInvoiceDetailDictionary
{
    NSMutableDictionary *customerInvoiceDetailDictionary = [[NSMutableDictionary alloc]init];
    
    [customerInvoiceDetailDictionary setValue:self.custId forKey:@"CustId"];
    [customerInvoiceDetailDictionary setValue:self.invoice forKey:@"Invoice"];
    
    [customerInvoiceDetailDictionary setValue:self.invoiceDate forKey:@"InvoiceDate"];
    [customerInvoiceDetailDictionary setValue:self.email forKey:@"Email"];
    [customerInvoiceDetailDictionary setValue:self.contactNo forKey:@"ContactNo"];
    [customerInvoiceDetailDictionary setValue:self.loyaltyNo forKey:@"LoyalityNo"];
    [customerInvoiceDetailDictionary setValue:self.invoiceNo forKey:@"InvoiceNo"];
    [customerInvoiceDetailDictionary setValue:self.itemQty forKey:@"ItemQty"];
    
    [customerInvoiceDetailDictionary setValue:self.lastVisitDate forKey:@"LastVisitDate"];
    [customerInvoiceDetailDictionary setValue:self.tags forKey:@"Tags"];
    [customerInvoiceDetailDictionary setValue:self.paymentType forKey:@"PaymentType"];
    
    [customerInvoiceDetailDictionary setValue:[NSString stringWithFormat:@"%f", self.discount] forKey:@"Discount"];
    [customerInvoiceDetailDictionary setValue:[NSString stringWithFormat:@"%@", self.amount] forKey:@"Amount"];
    [customerInvoiceDetailDictionary setValue:[NSString stringWithFormat:@"%f", self.totalTicket] forKey:@"TotalTicket"];
    
    return customerInvoiceDetailDictionary;
    
}

-(void)configureInvoiceDetail:(NSMutableArray *)invoiceDetailArray
{
    self.invoiceMasterDetail = [[invoiceDetailArray valueForKey:@"InvoiceMst"]firstObject];
    self.invoicePaymentDetail = [[invoiceDetailArray valueForKey:@"InvoicePaymentDetail"]firstObject];
    self.invoiceItemDetail = [self itemDetailDictionary:[[invoiceDetailArray valueForKey:@"InvoiceItemDetail"] firstObject]];
}



- (NSArray *)itemDetailDictionary:(NSArray *)itemDetailsArray
{
    if (itemDetailsArray.count > 0 ) {
        for (NSMutableDictionary *dict in itemDetailsArray) {
            NSMutableDictionary *dictToAdd = [[NSMutableDictionary alloc] init];
            dictToAdd[@"CheckCashCharge"] = [dict valueForKey:@"CheckCashAmount"];
            dictToAdd[@"ExtraCharge"] = [dict valueForKey:@"ExtraCharge"];
            if ([[dict valueForKey:@"ExtraCharge"] floatValue] > 0) {
                dictToAdd[@"isExtraCharge"] = @(1);
            }
            else
            {
                dictToAdd[@"isExtraCharge"] = @(0);
            }
            dictToAdd[@"isAgeApply"] = [dict valueForKey:@"isAgeApply"];
            dictToAdd[@"isCheckCash"] = [dict valueForKey:@"isCheckCash"];
            dictToAdd[@"isDeduct"] = [dict valueForKey:@"isDeduct"];
            dict[@"Item"] = dictToAdd;
        }
    }
    return itemDetailsArray;
}




@end
