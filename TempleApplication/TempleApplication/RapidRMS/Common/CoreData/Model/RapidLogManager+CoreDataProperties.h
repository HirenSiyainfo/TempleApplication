//
//  RapidLogManager+CoreDataProperties.h
//  RapidRMS
//
//  Created by siya8 on 27/06/17.
//  Copyright © 2017 Siya Infotech. All rights reserved.
//

#import "RapidLogManager+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface RapidLogManager (CoreDataProperties)

+ (NSFetchRequest<RapidLogManager *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *macAddress;
@property (nullable, nonatomic, copy) NSString *serviceName;
@property (nullable, nonatomic, copy) NSString *error;
@property (nullable, nonatomic, copy) NSString *errorCode;
@property (nullable, nonatomic, copy) NSString *logMessage;

@end

NS_ASSUME_NONNULL_END
