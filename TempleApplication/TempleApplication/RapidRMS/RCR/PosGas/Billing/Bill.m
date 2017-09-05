//
//  Bill.m
//  RapidRMS
//
//  Created by Siya Infotech on 02/07/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "Bill.h"
#import "BillItem.h"
#import "BillAmountComponents.h"

@interface Bill ()

@property (nonatomic, strong) NSMutableArray *billItems;

@end

@implementation Bill

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.billItems = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)addItem:(Item *)ringupItem
{
    BillItem *billItem = [[BillItem alloc] initWithItem:ringupItem ];
    [self.billItems addObject:billItem];
}

-(NSInteger)numberOfItems
{
    return self.billItems.count;
}

-(BillItem *)itemAtIndex:(NSInteger)itemAtIndex
{
    return (self.billItems)[itemAtIndex];
}

-(BillAmountComponents *)billAmountComponents
{
    BillAmountComponents *billAmountComponent = [[BillAmountComponents alloc] init];

    for (BillItem *billItem in self.billItems) {
        BillAmountComponents *billAmountComponent2 = billItem.billAmountComponents;
        billAmountComponent.totalTax += billAmountComponent2.totalTax;
        billAmountComponent.totalDiscount +=billAmountComponent2.totalDiscount;
        billAmountComponent.subTotal += billAmountComponent2.subTotal;
        billAmountComponent.billAmount += billAmountComponent2.billAmount;
    }
    return billAmountComponent;
}

@end
