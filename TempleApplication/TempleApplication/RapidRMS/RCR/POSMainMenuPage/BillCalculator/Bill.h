//
//  Bill.h
//  RapidRMS
//
//  Created by Siya Infotech on 02/07/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Bill : NSObject

@property (nonatomic,strong) NSMutableArray *lineItems;

@property (nonatomic,strong) NSMutableArray *totalLineItems;

- (instancetype)initWithRecieptArray:(NSMutableArray *)receiptArray withManageObjectContext:(NSManagedObjectContext *)manageObjectContext;


@end
