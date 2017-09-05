//
//  Bill.m
//  RapidRMS
//
//  Created by Siya Infotech on 02/07/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "Bill.h"
#import "LineItem.h"
#import "Item.h"
@interface Bill ()


@end

@implementation Bill

- (instancetype)initWithRecieptArray:(NSMutableArray *)receiptArray withManageObjectContext:(NSManagedObjectContext *)manageObjectContext
{
    self = [super init];
    if (self) {
        self.lineItems = [[NSMutableArray alloc] init];
        self.totalLineItems = [[NSMutableArray alloc] init];
        [self configureLineItem:receiptArray withManageObjectContext:manageObjectContext];
    }
    return self;
}
-(void)configureLineItem:(NSMutableArray *)receiptArray withManageObjectContext:(NSManagedObjectContext *)manageObjectContext
{
    NSInteger lineItemIndex = 0;
    for (NSDictionary *receiptDictionary in receiptArray) {
        Item *anItem = [self fetchItem:[receiptDictionary valueForKey:@"itemId"] withMangedObjectContext:manageObjectContext];
        LineItem *lineItem = [[LineItem alloc] initWithLineItem:anItem withBillDetail:receiptDictionary withLineItemIndex:@(lineItemIndex)];
        [self.lineItems addObject:lineItem];
        [self.totalLineItems addObject:[lineItem mutableCopyOfLineItem]];
        lineItemIndex++;
    }
}


- (Item*)fetchItem:(NSString *)itemId withMangedObjectContext:(NSManagedObjectContext *)mangedObjectContext
{
    Item *item=nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Item" inManagedObjectContext:mangedObjectContext];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemCode==%d AND active == %d", [itemId integerValue],TRUE];
    [fetchRequest setPredicate:predicate];
    
    NSArray *resultSet = [UpdateManager executeForContext:mangedObjectContext FetchRequest:fetchRequest];
    if (resultSet.count>0)
    {
        item=[resultSet firstObject];
    }
    return item;
}


@end
