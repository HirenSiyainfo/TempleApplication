//
//  ManualPOSession.h
//  RapidRMS
//
//  Created by Siya on 10/02/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ManualReceivedItem;

@interface ManualPOSession : NSManagedObject

@property (nonatomic, retain) NSString * invoiceNumber;
@property (nonatomic, retain) NSNumber * manualPoId;
@property (nonatomic, retain) NSString * poRemark;
@property (nonatomic, retain) NSDate * receivedDate;
@property (nonatomic, retain) NSNumber * supplierId;
@property (nonatomic, retain) NSSet *supplierIDsession;
@end

@interface ManualPOSession (CoreDataGeneratedAccessors)

- (void)addSupplierIDsessionObject:(ManualReceivedItem *)value;
- (void)removeSupplierIDsessionObject:(ManualReceivedItem *)value;
- (void)addSupplierIDsession:(NSSet *)values;
- (void)removeSupplierIDsession:(NSSet *)values;

@end
