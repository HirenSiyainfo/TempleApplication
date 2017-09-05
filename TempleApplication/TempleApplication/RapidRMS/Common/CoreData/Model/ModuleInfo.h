//
//  ModuleInfo.h
//  RapidRMS
//
//  Created by Siya on 10/02/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ModuleInfo : NSManagedObject

@property (nonatomic, retain) NSString * companyId;
@property (nonatomic, retain) NSString * dBName;
@property (nonatomic, retain) NSNumber * isActive;
@property (nonatomic, retain) NSNumber * isCustomerDisplay;
@property (nonatomic, retain) NSNumber * isRCRGAS;
@property (nonatomic, retain) NSString * macAdd;
@property (nonatomic, retain) NSNumber * moduleAccessId;
@property (nonatomic, retain) NSString * moduleCode;
@property (nonatomic, retain) NSNumber * moduleId;
@property (nonatomic, retain) NSString * moduleType;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * registerName;
@property (nonatomic, retain) NSNumber * registerNo;
@property (nonatomic, retain) NSString * tokenId;
@property (nonatomic, retain) NSNumber * isRelease;

@end
