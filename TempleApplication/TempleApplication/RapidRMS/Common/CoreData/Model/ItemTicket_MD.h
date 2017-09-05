//
//  ItemTicket_MD.h
//  RapidRMS
//
//  Created by siya-IOS5 on 6/24/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Item;

@interface ItemTicket_MD : NSManagedObject

@property (nonatomic, retain) NSDate * createddate;
@property (nonatomic, retain) NSNumber * expirationDays;
@property (nonatomic, retain) NSNumber * friday;
@property (nonatomic, retain) NSNumber * isExpiration;
@property (nonatomic, retain) NSNumber * isTicket;
@property (nonatomic, retain) NSNumber * itemCode;
@property (nonatomic, retain) NSNumber * monday;
@property (nonatomic, retain) NSNumber * noOfdays;
@property (nonatomic, retain) NSNumber * saturday;
@property (nonatomic, retain) NSNumber * selectedOption;
@property (nonatomic, retain) NSNumber * sunday;
@property (nonatomic, retain) NSNumber * thursday;
@property (nonatomic, retain) NSNumber * ticketId;
@property (nonatomic, retain) NSNumber * tuesday;
@property (nonatomic, retain) NSNumber * userId;
@property (nonatomic, retain) NSNumber * wednesday;
@property (nonatomic, retain) NSNumber * noOfPerson;
@property (nonatomic, retain) Item *ticketToItem;

@end
