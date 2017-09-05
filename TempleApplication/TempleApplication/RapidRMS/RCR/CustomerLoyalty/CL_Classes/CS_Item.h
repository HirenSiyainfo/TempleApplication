//
//  CS_Item.h
//  RapidRMS
//
//  Created by Siya Infotech on 07/12/15.
//  Copyright © 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CS_Item : NSObject
@property (nonatomic,strong) NSNumber *custId;
@property (nonatomic,strong) NSString *invoice;
@property (nonatomic,strong) NSString *invoiceItemId;
@property (nonatomic,strong) NSString *invoicePurchased;
@property (nonatomic,strong) NSString *invoiceDate;
@property (nonatomic,strong) NSString *itemNo;
@property (nonatomic,strong) NSString *barcode;
@property (nonatomic,strong) NSString *departmentName;
@property (nonatomic,strong) NSString *vendor;
@property (nonatomic,strong) NSString *itemName;
@property (nonatomic,strong) NSNumber *itemcode;
@property (nonatomic,strong) NSString *itemDiscoutAmount;
@property (assign) CGFloat cost;
@property (assign) CGFloat price;
@property (assign) CGFloat margin;
@property (assign) CGFloat tax;
@property (assign) CGFloat avgPrice;
@property (assign) CGFloat avgDiscount;

@property (nonatomic,strong) NSString *contactNo;
@property (nonatomic,strong) NSString *email;
@property (assign) CGFloat discount;
@property (nonatomic,strong) NSString *tags;
@property (nonatomic,strong) NSString *itemQty;
-(void)setupCustomerItemDetail:(NSDictionary *)customerInvoiceDetailDictionary;

@end
