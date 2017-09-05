//
//  Printers+CoreDataProperties.m
//  RapidRMS
//
//  Created by Siya_Testing on 16/06/17.
//  Copyright © 2017 Siya Infotech. All rights reserved.
//

#import "Printers.h"

@implementation Printers (CoreDataProperties)

+ (NSFetchRequest<Printers *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Printers"];
}

@dynamic isOnline;
@dynamic isSelected;
@dynamic macAddress;
@dynamic modelName;
@dynamic portName;
@dynamic registerId;
@dynamic userId;
@dynamic name;

@end
