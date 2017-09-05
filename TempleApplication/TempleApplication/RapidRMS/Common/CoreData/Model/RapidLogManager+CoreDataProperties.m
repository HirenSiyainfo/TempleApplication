//
//  RapidLogManager+CoreDataProperties.m
//  RapidRMS
//
//  Created by siya8 on 27/06/17.
//  Copyright © 2017 Siya Infotech. All rights reserved.
//

#import "RapidLogManager+CoreDataProperties.h"

@implementation RapidLogManager (CoreDataProperties)

+ (NSFetchRequest<RapidLogManager *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"RapidLogManager"];
}

@dynamic macAddress;
@dynamic serviceName;
@dynamic error;
@dynamic errorCode;
@dynamic logMessage;

@end
