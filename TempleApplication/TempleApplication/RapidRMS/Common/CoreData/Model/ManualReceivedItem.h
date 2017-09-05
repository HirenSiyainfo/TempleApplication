//
//  ManualReceivedItem.h
//  RapidRMS
//
//  Created by Siya on 10/02/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Item, ManualPOSession;

@interface ManualReceivedItem : NSManagedObject

@property (nonatomic, retain) NSNumber * caseCost;
@property (nonatomic, retain) NSNumber * caseMarkup;
@property (nonatomic, retain) NSNumber * casePrice;
@property (nonatomic, retain) NSNumber * caseQuantityReceived;
@property (nonatomic, retain) NSNumber * caseReceivedFreeGoodQty;
@property (nonatomic, retain) NSNumber * cashQtyonHand;
@property (nonatomic, retain) NSDate * createDate;
@property (nonatomic, retain) NSNumber * freeGoodCaseCost;
@property (nonatomic, retain) NSNumber * freeGoodCost;
@property (nonatomic, retain) NSNumber * freeGoodPackCost;
@property (nonatomic, retain) NSNumber * isReturn;
@property (nonatomic, retain) NSNumber * packCost;
@property (nonatomic, retain) NSNumber * packMarkup;
@property (nonatomic, retain) NSNumber * packPrice;
@property (nonatomic, retain) NSNumber * packQtyonHand;
@property (nonatomic, retain) NSNumber * packQuantityReceived;
@property (nonatomic, retain) NSNumber * packReceivedFreeGoodQty;
@property (nonatomic, retain) NSNumber * receivedItemId;
@property (nonatomic, retain) NSNumber * singleReceivedFreeGoodQty;
@property (nonatomic, retain) NSNumber * unitCost;
@property (nonatomic, retain) NSNumber * unitMarkup;
@property (nonatomic, retain) NSNumber * unitPrice;
@property (nonatomic, retain) NSNumber * unitQtyonHand;
@property (nonatomic, retain) NSNumber * unitQuantityReceived;
@property (nonatomic, retain) Item *item;
@property (nonatomic, retain) ManualPOSession *supplierIDitems;

@end
