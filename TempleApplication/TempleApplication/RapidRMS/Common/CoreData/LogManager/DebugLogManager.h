//
//  DebugLogManager.h
//  DebugLog
//
//  Created by Siya9 on 19/01/17.
//  Copyright © 2017 Siya9. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DebugEnums.h"
#import "PetroLog.h"


@interface DebugLogManager : NSObject <NSFetchedResultsControllerDelegate>


@property (nonatomic, strong) UILabel * lblLogCount;

@property (nonatomic, strong) NSFetchedResultsController *logPetroRC;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSOperationQueue *operationQueue;

+ (DebugLogManager*)sharedDebugLogManager;

-(PetroLog *)insertNewObjectInManagedObjectContext:(NSManagedObjectContext *)moc;
-(void)addOperationInQueue:(PetroLog *) objPetroLog;
@end
