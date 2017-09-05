//
//  RegisterInfo.h
//  RapidRMS
//
//  Created by Siya on 10/02/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface RegisterInfo : NSManagedObject

@property (nonatomic, retain) NSString * branchId;
@property (nonatomic, retain) NSString * dBName;
@property (nonatomic, retain) NSString * invPrefix;
@property (nonatomic, retain) NSString * registerId;
@property (nonatomic, retain) NSString * registerInvNo;
@property (nonatomic, retain) NSString * registerName;
@property (nonatomic, retain) NSString * tokenId;
@property (nonatomic, retain) NSString * zId;
@property (nonatomic, retain) NSNumber * zRequired;

@end
