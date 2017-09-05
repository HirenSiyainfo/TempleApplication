//
//  Configuration+CoreDataProperties.h
//  RapidRMS
//
//  Created by Siya9 on 21/03/17.
//  Copyright © 2017 Siya Infotech. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Configuration.h"

NS_ASSUME_NONNULL_BEGIN

@interface Configuration (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *customerLoyalty;
@property (nullable, nonatomic, retain) NSNumber *ebt;
@property (nullable, nonatomic, retain) NSNumber *houseCharge;
@property (nullable, nonatomic, retain) NSNumber *invoiceNo;
@property (nullable, nonatomic, retain) NSDate *lastAccessDate;
@property (nullable, nonatomic, retain) NSDate *lastPetroUpdateDate;
@property (nullable, nonatomic, retain) NSDate *lastUpdateDate;
@property (nullable, nonatomic, retain) NSNumber *localCustomerLoyalty;
@property (nullable, nonatomic, retain) NSNumber *localEbt;
@property (nullable, nonatomic, retain) NSNumber *localShiftId;
@property (nullable, nonatomic, retain) NSNumber *localTicketSetting;
@property (nullable, nonatomic, retain) NSNumber *localTipsSetting;
@property (nullable, nonatomic, retain) NSDate *masterUpdateDate;
@property (nullable, nonatomic, retain) NSString *regPrefixNo;
@property (nullable, nonatomic, retain) NSNumber *serverShiftId;
@property (nullable, nonatomic, retain) NSNumber *subDepartment;
@property (nullable, nonatomic, retain) NSNumber *ticket;
@property (nullable, nonatomic, retain) NSNumber *tips;
@property (nullable, nonatomic, retain) NSNumber *userId;

@end

NS_ASSUME_NONNULL_END
