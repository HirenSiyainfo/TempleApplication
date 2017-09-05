//
//  RimsController.h
//  RapidRMS
//
//  Created by Keyur Patel on 31/03/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UpdateManager.h"

@interface RimsController : NSObject <UpdateDelegate>



// CoreData Variables
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSString *scannerButtonCalled;

//@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
//@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;


-(void)updateSupplierListFromItemTable :(NSArray *)supplierlist with:(NSString *)itemCode;
-(void)updateTaxListFromItemTable :(NSArray *)taxArray with:(NSString *)itemCode;
-(void)updateSizeListFromItemTable :(NSArray *)sizeArray with:(NSString *)itemCode;


+ (RimsController *)sharedrimController;

#ifdef USE_OLD_RIM_CODE

-(void)globalInOutSaveHoldRecord;

#endif

@end
