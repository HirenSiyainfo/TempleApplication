//
//  Mix_MatchDetail.h
//  RapidRMS
//
//  Created by Siya on 10/02/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Item;

@interface Mix_MatchDetail : NSManagedObject

@property (nonatomic, retain) NSNumber * amount;
@property (nonatomic, retain) NSNumber * code;
@property (nonatomic, retain) NSNumber * discCode;
@property (nonatomic, retain) NSString * discountType;
@property (nonatomic, retain) NSNumber * isDelete;
@property (nonatomic, retain) NSString * item_Description;
@property (nonatomic, retain) NSString * itemType;
@property (nonatomic, retain) NSNumber * mix_Match_Amt;
@property (nonatomic, retain) NSNumber * mix_Match_Qty;
@property (nonatomic, retain) NSNumber * mixMatchId;
@property (nonatomic, retain) NSNumber * quantityX;
@property (nonatomic, retain) NSNumber * quantityY;
@property (nonatomic, retain) NSSet *mixMatchDiscount;
@end

@interface Mix_MatchDetail (CoreDataGeneratedAccessors)

- (void)addMixMatchDiscountObject:(Item *)value;
- (void)removeMixMatchDiscountObject:(Item *)value;
- (void)addMixMatchDiscount:(NSSet *)values;
- (void)removeMixMatchDiscount:(NSSet *)values;

@end
