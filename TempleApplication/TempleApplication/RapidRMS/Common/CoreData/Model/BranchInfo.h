//
//  BranchInfo.h
//  RapidRMS
//
//  Created by Siya on 10/02/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface BranchInfo : NSManagedObject

@property (nonatomic, retain) NSString * address1;
@property (nonatomic, retain) NSString * address2;
@property (nonatomic, retain) NSString * branchId;
@property (nonatomic, retain) NSString * branchName;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * filePath;
@property (nonatomic, retain) NSNumber * is_Deleted;
@property (nonatomic, retain) NSString * objmodule;
@property (nonatomic, retain) NSString * phoneNo1;
@property (nonatomic, retain) NSString * phoneNo2;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSString * zipCode;
@property (nonatomic, retain) NSString * helpMessage1;
@property (nonatomic, retain) NSString * helpMessage2;
@property (nonatomic, retain) NSString * helpMessage3;
@property (nonatomic, retain) NSString * supportEmail;



@end
