//
//  Printers+CoreDataProperties.h
//  RapidRMS
//
//  Created by Siya_Testing on 16/06/17.
//  Copyright © 2017 Siya Infotech. All rights reserved.
//

#import "Printers.h"


NS_ASSUME_NONNULL_BEGIN

@interface Printers (CoreDataProperties)

+ (NSFetchRequest<Printers *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSNumber *isOnline;
@property (nullable, nonatomic, copy) NSNumber *isSelected;
@property (nullable, nonatomic, copy) NSString *macAddress;
@property (nullable, nonatomic, copy) NSString *modelName;
@property (nullable, nonatomic, copy) NSString *portName;
@property (nullable, nonatomic, copy) NSNumber *registerId;
@property (nullable, nonatomic, copy) NSNumber *userId;
@property (nullable, nonatomic, copy) NSString *name;

@end

NS_ASSUME_NONNULL_END
