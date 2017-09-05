//
//  LineItem.h
//  RapidRMS
//
//  Created by siya-IOS5 on 2/10/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Item+Dictionary.h"
#import "SubTotal.h"

@interface LineItem : NSObject

@property (nonatomic,strong) Item *anItem;

@property (nonatomic,strong) NSNumber *itemBasicPrice;
@property (nonatomic,strong) SubTotal *subTotal;

@property (nonatomic,strong) NSNumber *lineItemIndex;
@property (assign) BOOL isQtyEdited;

@property (nonatomic,strong) NSNumber *itemQty;
@property (nonatomic,strong) NSNumber *itemCode;
@property (nonatomic,strong) NSDictionary *receiptDictionary;
@property (nonatomic,strong) NSString *barcode;
@property (nonatomic,strong) NSNumber *singleQty;
@property (nonatomic,strong) NSNumber *caseQty;
@property (nonatomic,strong) NSNumber *packQty;
@property (nonatomic,strong) NSNumber *discountAppliedQty;


@property (nonatomic,strong) NSNumber *singlePrice;
@property (nonatomic,strong) NSNumber *casePrice;
@property (nonatomic,strong) NSNumber *packPrice;

@property (nonatomic,strong) NSNumber *isRefundItem;

@property (nonatomic,strong) NSMutableArray *discountArray;
@property (assign) BOOL isRefundFromInvoice;

@property (nonatomic,strong) NSString *packageType;
@property (nonatomic,strong) NSNumber *packageQty;
@property (nonatomic,strong) NSNumber *totalPackageQty;



- (instancetype)initWithLineItem:(Item *)item withBillDetail:(NSDictionary *)receiptDictionary withLineItemIndex:(NSNumber *)lineItemIndex;
-(LineItem *)mutableCopyOfLineItem;

@end
