//
//  PetroLog+CoreDataProperties.h
//  RapidRMS
//
//  Created by Siya9 on 19/01/17.
//  Copyright © 2017 Siya Infotech. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "PetroLog.h"

NS_ASSUME_NONNULL_BEGIN

@interface PetroLog (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *buildDetaild;
@property (nullable, nonatomic, retain) NSString *cartID;
@property (nullable, nonatomic, retain) NSNumber *cartStatus;
@property (nullable, nonatomic, retain) NSString *command;
@property (nullable, nonatomic, retain) NSString *data;
@property (nullable, nonatomic, retain) NSNumber *direction;
@property (nullable, nonatomic, retain) NSNumber *index;
@property (nullable, nonatomic, retain) NSString *invoiceNumber;
@property (nullable, nonatomic, retain) NSNumber *isPad;
@property (nullable, nonatomic, retain) NSString *parameters;
@property (nullable, nonatomic, retain) NSNumber *pumpIndex;
@property (nullable, nonatomic, retain) NSString *regInvNumber;
@property (nullable, nonatomic, retain) NSString *registerId;
@property (nullable, nonatomic, retain) NSDate *timeStamp;
@property (nullable, nonatomic, retain) NSNumber *transactionType;
@property (nullable, nonatomic, retain) NSNumber *type;
@property (nullable, nonatomic, retain) NSNumber *uploadStatus;
@property (nullable, nonatomic, retain) NSNumber *userId;

@end

NS_ASSUME_NONNULL_END
