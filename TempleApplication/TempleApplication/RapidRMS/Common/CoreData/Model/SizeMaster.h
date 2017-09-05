//
//  SizeMaster.h
//  RapidRMS
//
//  Created by Siya on 22/09/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ItemTag;

@interface SizeMaster : NSManagedObject

@property (nonatomic, retain) NSNumber * sizeId;
@property (nonatomic, retain) NSString * sizeName;
@property (nonatomic, retain) NSSet *sizeMasterToTags;
@end

@interface SizeMaster (CoreDataGeneratedAccessors)

- (void)addSizeMasterToTagsObject:(ItemTag *)value;
- (void)removeSizeMasterToTagsObject:(ItemTag *)value;
- (void)addSizeMasterToTags:(NSSet *)values;
- (void)removeSizeMasterToTags:(NSSet *)values;

@end
