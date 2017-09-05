//
//  PetroLog.h
//  DebugLog
//
//  Created by Siya9 on 19/01/17.
//  Copyright © 2017 Siya9. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface PetroLog : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

-(void)updateLogObjectFrom:(NSDictionary *)dictLogInfo;
-(NSDictionary *)petroUploadDictionary;
@end

NS_ASSUME_NONNULL_END

#import "PetroLog+CoreDataProperties.h"

