//
//  CS_Item.m
//  RapidRMS
//
//  Created by Siya Infotech on 07/12/15.
//  Copyright © 2015 Siya Infotech. All rights reserved.
//

#import "CS_Item.h"
#import "RmsDbController.h"

@interface CS_Item ()
@property (nonatomic,strong) RmsDbController *rmsDbController;

@end


@implementation CS_Item

-(instancetype)init
{
    self = [super init];
    
    if (self) {
        self.rmsDbController = [RmsDbController sharedRmsDbController];
        [self resetItemDetail];
    }
    return self;
}
-(void)resetItemDetail
{
    
    self.custId = @(0);
    self.invoice = @"";
    self.invoiceDate = @"";
    self.email = @"";
    self.contactNo = @"";
    self.invoiceItemId = @"";
    self.invoicePurchased = @"";
    self.itemNo = @"";
    self.barcode = @"";
    self.departmentName = @"";
    self.vendor = @"";
    self.itemcode = @(0);
    self.itemDiscoutAmount = @"";
    self.itemQty = @"";
    
    self.cost = 0.00;
    self.price = 0.00;
    self.margin = 0.00;
    self.tax = 0.00;
    self.avgDiscount = 0.00;
    self.avgPrice = 0.00;
    self.discount = 0.00;

    self.tags = nil;
    
}

-(void)setupCustomerItemDetail:(NSDictionary *)customerInvoiceDetailDictionary
{
    
    self.custId = @([[customerInvoiceDetailDictionary valueForKey:@"CustId"] integerValue]);
    self.itemName = [NSString stringWithFormat:@"%@",[customerInvoiceDetailDictionary valueForKey:@"ItemName"]];

    self.invoice = [NSString stringWithFormat:@"%@",[customerInvoiceDetailDictionary valueForKey:@"Invoice"]];
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"MM / dd / yyyy HH:mm EEEE";
    NSDate *now = [self.rmsDbController getDateFromJSONDate:[NSString stringWithFormat:@"%@",[customerInvoiceDetailDictionary valueForKey:@"InvoiceDate"]]];
    
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    format.timeZone = gmt;
    NSString *dateString = [format stringFromDate:now];
    
    self.invoiceDate = [NSString stringWithFormat:@"%@",dateString];
    self.email = [NSString stringWithFormat:@"%@",[customerInvoiceDetailDictionary valueForKey:@"Email"]];
    self.invoicePurchased = [NSString stringWithFormat:@"%@",[customerInvoiceDetailDictionary valueForKey:@"ItemPurchased"]];
    self.invoiceItemId = [NSString stringWithFormat:@"%@",[customerInvoiceDetailDictionary valueForKey:@"InvoiceItemId"]];

 //   self.contactNo = [NSString stringWithFormat:@"%@",[customerInvoiceDetailDictionary valueForKey:@"ContactNo"]];
    self.itemNo = [NSString stringWithFormat:@"%@",[customerInvoiceDetailDictionary valueForKey:@"ItemNo"]];
    self.barcode = [NSString stringWithFormat:@"%@",[customerInvoiceDetailDictionary valueForKey:@"Barcode"]];
    self.departmentName = [NSString stringWithFormat:@"%@",[customerInvoiceDetailDictionary valueForKey:@"DeptName"]];

    self.vendor = [NSString stringWithFormat:@"%@",[customerInvoiceDetailDictionary valueForKey:@"Vendors"]];
    self.itemcode = @([[customerInvoiceDetailDictionary valueForKey:@"ItemCode"] integerValue]);
    self.itemDiscoutAmount = [NSString stringWithFormat:@"%@",[customerInvoiceDetailDictionary valueForKey:@"ItemDiscountAmount"]];
    self.itemQty = [NSString stringWithFormat:@"%@",[customerInvoiceDetailDictionary valueForKey:@"ItemQty"]];
    
    self.discount = [[customerInvoiceDetailDictionary valueForKey:@"Discount"] floatValue];
    self.cost = [[customerInvoiceDetailDictionary valueForKey:@"Cost"] floatValue];
    self.price = [[customerInvoiceDetailDictionary valueForKey:@"Price"] floatValue];
    self.margin = [[customerInvoiceDetailDictionary valueForKey:@"Margin"] floatValue];
    self.tax = [[customerInvoiceDetailDictionary valueForKey:@"Taxes"] floatValue];
    self.avgPrice = [[customerInvoiceDetailDictionary valueForKey:@"AveragePrice"] floatValue];
    self.avgDiscount = [[customerInvoiceDetailDictionary valueForKey:@"AverageDiscount"] floatValue];

    self.tags = [customerInvoiceDetailDictionary valueForKey:@"Tags"];
    
}

- (NSMutableDictionary *)customerInvoiceDetailDictionary
{
    NSMutableDictionary *customerInvoiceDetailDictionary = [[NSMutableDictionary alloc]init];
    
    [customerInvoiceDetailDictionary setValue:self.custId forKey:@"CustomerName"];
    [customerInvoiceDetailDictionary setValue:self.invoice forKey:@"LoyaltyNo"];
    [customerInvoiceDetailDictionary setValue:self.invoiceDate forKey:@"ContactNo"];
    [customerInvoiceDetailDictionary setValue:self.email forKey:@"Email"];
    [customerInvoiceDetailDictionary setValue:self.contactNo forKey:@"dob"];
    
    return customerInvoiceDetailDictionary;
    
}


@end
