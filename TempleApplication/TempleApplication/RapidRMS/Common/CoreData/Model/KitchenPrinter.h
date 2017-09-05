//
//  KitchenPrinter.h
//  RapidRMS
//
//  Created by siya-IOS5 on 4/6/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Department;

@interface KitchenPrinter : NSManagedObject

@property (nonatomic, retain) NSString * printer_ip;
@property (nonatomic, retain) NSString * printer_Name;
@property (nonatomic, retain) NSSet *printerDepartments;
@end

@interface KitchenPrinter (CoreDataGeneratedAccessors)

- (void)addPrinterDepartmentsObject:(Department *)value;
- (void)removePrinterDepartmentsObject:(Department *)value;
- (void)addPrinterDepartments:(NSSet *)values;
- (void)removePrinterDepartments:(NSSet *)values;

@end
