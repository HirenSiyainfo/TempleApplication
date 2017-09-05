//
//  DebugLogManager.m
//  DebugLog
//
//  Created by Siya9 on 19/01/17.
//  Copyright © 2017 Siya9. All rights reserved.
//

#import "DebugLogManager.h"
#import "RapidLogOperation.h"
#import "UpdateLogManager.h"
#import "RmsDbController.h"

static DebugLogManager * g_SharedDebugLogManager = nil;

@interface DebugLogManager ()

@property (atomic) BOOL isUpoading;
@property (nonatomic, strong) NSLock * managedOCLockLock;
@property (nonatomic, strong) NSLock * indexUpdateLock;
@property (nonatomic, strong) NSLock * logUpdateLock;

@property (nonatomic, strong) NSMutableArray * arrOpretionQueue;

@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation DebugLogManager

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


+ (DebugLogManager*)sharedDebugLogManager {
    @synchronized(self) {
        if (!g_SharedDebugLogManager) {
            g_SharedDebugLogManager = [[DebugLogManager alloc] init];
            g_SharedDebugLogManager.operationQueue = [NSOperationQueue new];
            g_SharedDebugLogManager.operationQueue.maxConcurrentOperationCount = 1;
            g_SharedDebugLogManager.operationQueue.qualityOfService = NSQualityOfServiceBackground;
            g_SharedDebugLogManager.operationQueue.name = @"PetroLogUpload";

            g_SharedDebugLogManager.indexUpdateLock = [[NSLock alloc] init];
            g_SharedDebugLogManager.logUpdateLock = [[NSLock alloc] init];
            g_SharedDebugLogManager.managedOCLockLock = [[NSLock alloc] init];
            g_SharedDebugLogManager.arrOpretionQueue = [NSMutableArray array];
        }
    }
    return g_SharedDebugLogManager;
}

#pragma mark - Core Data Saving support -

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"DebugLog" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"DebugLog.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {

        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];

        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
//    
//    
//    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
//    NSOperationQueue *currentQueue = [NSOperationQueue currentQueue];
//    
//    //    if ([mainQueue isEqual:currentQueue]) {
//    //    if ([NSThread currentThread].isMainThread) {
//    //        sleep(10);
//    //    }
//    
//    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
//    NSLog(@". %ld", (long)[NSThread currentThread].qualityOfService);
//    RapidAutoLock *debugLogContextLock = [[RapidAutoLock alloc] initWithLock:_managedOCLockLock];
//    
//    NSLog(@"..");
//    if (_managedObjectContext != nil) {
//        return _managedObjectContext;
//    }
//    
//    NSLog(@"moc nil");
//    
//    
//    NSBlockOperation *contextCreationBlock = [NSBlockOperation blockOperationWithBlock:^{
//        if (!self.persistentStoreCoordinator) {
//            NSLog(@"psc nil -> moc nil");
//            return;
//        }
//        
//        NSLog(@"Should add now");
//        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
//        NSLog(@"moc = %@", _managedObjectContext);
//        [_managedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
//        NSLog(@"moc store set");
//    }];
//    
//    if (![NSThread currentThread].isMainThread) {
//        //    if (![mainQueue isEqual:currentQueue]) {
//        NSLog(@"not main queue");
//        [mainQueue addOperations:@[contextCreationBlock] waitUntilFinished:YES];
//    } else {
//        NSLog(@"main queue");
//        [mainQueue addOperations:@[contextCreationBlock] waitUntilFinished:YES];
//    }
//    
//    [debugLogContextLock unlock];
//    NSLog(@"moc done");
//    return _managedObjectContext;
}

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Insert new Log  -
-(PetroLog *)insertNewObjectInManagedObjectContext:(NSManagedObjectContext *)moc{
    
    [self.indexUpdateLock lock];
    PetroLog * anObject = [NSEntityDescription insertNewObjectForEntityForName:@"PetroLog" inManagedObjectContext:moc];
    anObject.index = [self getNewIndex];
    
    
    NSString  *buildVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    NSString *appVersion = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
    
    NSMutableDictionary * dictBuildDetail = [NSMutableDictionary dictionary];
    
    dictBuildDetail[@"AppVersion"] = appVersion;
    dictBuildDetail[@"BuildVersion"] = buildVersion;
    
    anObject.buildDetaild = [[RmsDbController sharedRmsDbController] jsonStringFromObject:dictBuildDetail];
    
    NSString *userID = @"0";
    if([[RmsDbController sharedRmsDbController].globalDict[@"UserInfo"] isKindOfClass:[NSDictionary class]]){
        userID = [NSString stringWithFormat:@"%@",[RmsDbController sharedRmsDbController].globalDict[@"UserInfo"][@"UserId"]];
    }    
    anObject.userId = @(userID.integerValue);
    
    NSString *registerId = [NSString stringWithFormat:@"%@",[RmsDbController sharedRmsDbController].globalDict[@"RegisterId"]];
    
    anObject.registerId = registerId;
    
    anObject.timeStamp = [NSDate date];
    [self updateLogIndexNumber:anObject.index];
    [self.indexUpdateLock unlock];
    return anObject;
}
-(NSNumber *)getNewIndex{
    NSNumber * nextIndex;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"logIndex"]) {
        nextIndex = [[NSUserDefaults standardUserDefaults] objectForKey:@"logIndex"];
    }
    else{
        nextIndex = @(0);
    }
    nextIndex = @(nextIndex.integerValue + 1);
    return nextIndex;
}
- (void)updateLogIndexNumber:(NSNumber *)nextIndex{
    [[NSUserDefaults standardUserDefaults] setObject:nextIndex forKey:@"logIndex"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

#pragma mark - Insert New log Into Queue -

- (NSFetchedResultsController *)logPetroRC {
    if (!_logPetroRC) {
        @try {
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"PetroLog" inManagedObjectContext:self.managedObjectContext];
            fetchRequest.entity = entity;
            
            fetchRequest.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"index" ascending:TRUE]];
            _logPetroRC = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
            [_logPetroRC performFetch:nil];
            _logPetroRC.delegate = self;
        } @catch (NSException *exception) {
            NSLog(@"NSFetchedResultsController Get Error %@",exception.debugDescription);
        }
    }
    return _logPetroRC;
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    if ([controller isEqual:self.logPetroRC]) {
        switch(type) {
            case NSFetchedResultsChangeInsert:
                [self addOperationInQueue:(PetroLog *)anObject];
                break;
            case NSFetchedResultsChangeDelete:
                break;
            case NSFetchedResultsChangeUpdate:
                break;
            case NSFetchedResultsChangeMove:
                break;
        }
        [self updateLogCount:self.logPetroRC.fetchedObjects.count];
    }
}
-(void)addOperationInQueue:(PetroLog *) objPetroLog{
    [self.logUpdateLock lock];
    if (objPetroLog) {
        [self.arrOpretionQueue addObject:objPetroLog];
        if (self.arrOpretionQueue.count >=10) {
            [self addListOfOperationInQueue:self.arrOpretionQueue.mutableCopy];
            [self.arrOpretionQueue removeAllObjects];
        }
    }
    [self.logUpdateLock unlock];
    //    RapidLogOperation * newLog = [[RapidLogOperation alloc] initWithRequestPumpData:objPetroLog.petroUploadDictionary dataTaskCompletionHandler:^(id response, NSError *error) {
    //        NSDictionary * dictResponce = (NSDictionary *)response;
    //        if (dictResponce && [[dictResponce valueForKey:@"IsError"] integerValue] == 0) {
    //            [self.managedObjectContext deleteObject:objPetroLog];
    //        }
    //        else {
    //            objPetroLog.uploadStatus = @(UpdateStatusSentError);
    //            [self addOperationInQueue:objPetroLog];
    //        }
    //        [UpdateLogManager saveContext:self.managedObjectContext];
    //    }];
    //    [self.operationQueue addOperation:newLog];
}
-(void)addListOfOperationInQueue:(NSMutableArray *) arrOpretions{
    RapidLogOperation * newLog = [[RapidLogOperation alloc] initWithRequestOpretions:arrOpretions dataTaskCompletionHandler:^(id response, NSError *error) {
        
        NSBlockOperation * op = [NSBlockOperation blockOperationWithBlock:^{
            NSDictionary * dictResponce = (NSDictionary *)response;
            if (dictResponce && [[dictResponce valueForKey:@"IsError"] integerValue] == 0) {
                NSManagedObjectContext * privateMOC = [UpdateLogManager privateConextFromParentContext:self.managedObjectContext];
                for (PetroLog * objPetroLog in arrOpretions) {
                    [UpdateLogManager deleteFromContext:privateMOC objectId:objPetroLog.objectID];
                }
                [UpdateLogManager saveContext:privateMOC];
            }
            else if(dictResponce && [[dictResponce valueForKey:@"IsError"] integerValue] != 0){
                NSManagedObjectContext * privateMOC = [UpdateLogManager privateConextFromParentContext:self.managedObjectContext];
                for (PetroLog * objPetroLog in arrOpretions) {
                    PetroLog * objPRVpl = [privateMOC objectWithID:objPetroLog.objectID];
                    objPRVpl.uploadStatus = @(UpdateStatusSentError);
                }
                [UpdateLogManager saveContext:privateMOC];
                NSMutableArray * arrNewUpdatedObjects = [NSMutableArray array];
                for (PetroLog * objPetroLog in arrOpretions) {
                    PetroLog * objPRVpl = (PetroLog *)[self.managedObjectContext objectWithID:objPetroLog.objectID];
                    [arrNewUpdatedObjects addObject:objPRVpl];
                }
                [self addListOfOperationInQueue:arrNewUpdatedObjects];            }
            
        }];
        [op setQueuePriority:NSOperationQueuePriorityVeryHigh];
        [op setQualityOfService:NSQualityOfServiceUserInitiated];
        [self.operationQueue addOperation:op];
    }];
    [newLog setQueuePriority:NSOperationQueuePriorityNormal];
    [newLog setQualityOfService:NSQualityOfServiceBackground];
    [self.operationQueue addOperation:newLog];
}
-(void)updateLogCount:(NSUInteger)logCount{
    if (self.lblLogCount) {
        self.lblLogCount.text = [NSString stringWithFormat:@"Log Count\n%ld",(long)logCount];
    }
}
@end
