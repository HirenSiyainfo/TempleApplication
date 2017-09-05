//
//  RimsController.m
//  RapidRMS
//
//  Created by Keyur Patel on 31/03/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "RimsController.h"
#import "RmsDbController.h"
#import "AppDelegate.h"
#import "UtilityManager.h"

// CoreData implementation

#import "Item+Dictionary.h"
#import "ItemTag.h"
#import "Constant.h"
#import "ItemSupplier+Dictionary.h"
#import "ItemTag+Dictionary.h"
#import "Item_Discount_MD+Dictionary.h"
#import "Item_Discount_MD2+Dictionary.h"
#import "Department+Dictionary.h"
#import "SupplierMaster+Dictionary.h"
#import "SupplierCompany+Dictionary.h"
#import "TaxMaster+Dictionary.h"
#import "SizeMaster+Dictionary.h"
#import "ItemTax+Dictionary.h"
#import "Configuration.h"
#import "ItemTag+Dictionary.h"

@interface AppDelegate ()
@property (nonatomic, strong) UpdateManager *updateManager;
@end


static RimsController *s_SharedrimController = nil;

@interface RimsController () {

}


@property (nonatomic, strong) UpdateManager *updateManager;

@end

@implementation RimsController

+ (RimsController *)sharedrimController{
    if (!s_SharedrimController) {
        @synchronized(self) {
            s_SharedrimController = [[RimsController alloc] init];
        }
    }
    
    return s_SharedrimController;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupRimController];
    }
    return self;
}

#pragma mark - App delegate methods
- (void)setupRimController
{
    RmsDbController *rmsDbController;
    rmsDbController = [RmsDbController sharedRmsDbController];
    self.managedObjectContext = rmsDbController.managedObjectContext;
    
    self.updateManager = [[UpdateManager alloc] initWithManagedObjectContext:rmsDbController.managedObjectContext delegate:self];
}

-(void)updateSupplierListFromItemTable :(NSArray *)supplierlist with:(NSString *)itemCode
{
    for(int i=0;i<supplierlist.count;i++)
    {
        ItemSupplier *itemSupplier=nil;
        NSMutableDictionary *dictTemp =supplierlist[i];
        itemSupplier = (ItemSupplier *)[self.updateManager insertEntityWithName:@"ItemSupplier" moc:self.managedObjectContext];
        [itemSupplier updateItemSupplierFromItemTable:dictTemp withItemCode:itemCode];
    }
}

-(void)updateTaxListFromItemTable :(NSArray *)taxArray with:(NSString *)itemCode
{
    for(int k=0;k<taxArray.count;k++)
    {
        NSMutableDictionary *dictTemp =taxArray[k];
        ItemTax *tax=nil;
        tax = (ItemTax *)[self.updateManager insertEntityWithName:@"ItemTax" moc:self.managedObjectContext];
        [tax updateitemTaxFromItemTable:dictTemp :itemCode];
    }
}


-(void)updateSizeListFromItemTable :(NSArray *)sizeArray with:(NSString *)itemCode
{
    for(int i=0;i<sizeArray.count;i++)
    {
        ItemTag *tag=nil;
        NSMutableDictionary *dictTemp =sizeArray[i];
        tag = (ItemTag *)[self.updateManager insertEntityWithName:@"ItemTag" moc:self.managedObjectContext];
        [tag updateItemTagFromItemTable:dictTemp withItemCode:itemCode];
    }
}


// inventory in hold record operation functions

// inventory out hold record opetation











#pragma mark - Unused code -

#ifdef USE_OLD_RIM_CODE
- (void) getMainItenInUpdate:(NSNotification *)notification
{
    if ([notification object] != nil)
    {
        if ([[[[notification object] valueForKey:@"UpdateInventoryInResult"]  valueForKey:@"IsError"] intValue] == 0)
        {
            [self.objAppInvenIn.arrScanBarDetails removeAllObjects];
            self.objAppInvenIn.tblScannedItemList.hidden=YES;
            self.objAppInvenIn.statusImage.hidden = NO;
            flgInOpenOrder = FALSE;
            [[NSNotificationCenter defaultCenter] removeObserver:self];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] removeObserver:self];
        }
    }
}

- (void) getMainInsertAddInventoryHold:(NSNotification *)notification
{
    if ([notification object] != nil)
    {
        if ([[[[notification object] valueForKey:@"AddInventoryInResult"]  valueForKey:@"IsError"] intValue] == 0)
        {
            [self.objAppInvenIn.arrScanBarDetails removeAllObjects];
            self.objAppInvenIn.tblScannedItemList.hidden=YES;
            self.objAppInvenIn.statusImage.hidden = NO;
            // txtEnterOrder.text = @"";
            [[NSNotificationCenter defaultCenter] removeObserver:self];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] removeObserver:self];
        }
    }
}
- (void) getMainItenOutUpdate:(NSNotification *)notification
{
    if ([notification object] != nil)
    {
        if ([[[[notification object] valueForKey:@"UpdateInventoryInResult"]  valueForKey:@"IsError"] intValue] == 0)
        {
            [self.objAppInvenOut.arrScanBarDetails removeAllObjects];
            self.objAppInvenOut.tblScannedItemList.hidden=YES;
            self.objAppInvenOut.statusImage.hidden = NO;
            flgInOpenOrder = FALSE;
            [[NSNotificationCenter defaultCenter] removeObserver:self];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] removeObserver:self];
        }
    }
}

- (void) getMainInvenOutInventory:(NSNotification *)notification
{
    if ([notification object] != nil)
    {
        if ([[[[notification object] valueForKey:@"AddInventoryOutResult"]  valueForKey:@"IsError"] intValue] == 0)
        {
            [self.objAppInvenOut.arrScanBarDetails removeAllObjects];
            self.objAppInvenOut.tblScannedItemList.hidden=YES;
            self.objAppInvenOut.statusImage.hidden = NO;
            self.objAppInvenOut.txtEnterOrderNo.text = @"";
            [[NSNotificationCenter defaultCenter] removeObserver:self];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] removeObserver:self];
        }
    }
}


-(void)globalInOutSaveHoldRecord {
    if([self.objAppInvenIn.arrScanBarDetails count] > 0) // item in hold record
    {
        if(self.flgInOpenOrder) // update open item in record
        {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getMainItenInUpdate:) name:@"UpdateInventoryInResult" object:nil];
            
            NSMutableDictionary *updateInvenInMain = [self UpdateInOpenDataMain];
            self.updateInventoryInWC = [self.updateInventoryInWC initWithJSONKey:nil JSONValues:updateInvenInMain actionName:WSM_UPDATE_INVENTORY_IN URL:KURL NotificationName:@"UpdateInventoryInResult"];
        }
        else // insert open item in record
        {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getMainInsertAddInventoryHold:) name:@"AddInventoryInResult" object:nil];
            
            NSMutableDictionary *addInvenIn = [self insertAddInventoryInHoldMain];
            self.addInventoryInWC = [self.addInventoryInWC initWithJSONKey:nil JSONValues:addInvenIn actionName:WSM_ADD_INVENTORY_IN URL:KURL NotificationName:@"AddInventoryInResult"];
        }
    }
    if([self.objAppInvenOut.arrScanBarDetails count] > 0) // item out hold record
    {
        if(self.flgOutOpenOrder) // update open item out record
        {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getMainItenOutUpdate:) name:@"UpdateInventoryOutResult" object:nil];
            
            NSMutableDictionary *updateInvenOut = [self UpdateOutOpenDataMain];
            self.updateInventoryOutWC = [self.updateInventoryOutWC initWithJSONKey:nil JSONValues:updateInvenOut actionName:WSM_UPDATE_INVENTORY_OUT URL:KURL NotificationName:@"UpdateInventoryOutResult"];
        }
        else // insert open item out record
        {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getMainInvenOutInventory:) name:@"InvenOutAddInventoryOutResult" object:nil];
            
            NSMutableDictionary *addInvenIn = [self outInsertAddInventoryMain];
            self.invenOutAddInventoryOutWC =[self.invenOutAddInventoryOutWC initWithJSONKey:nil JSONValues:addInvenIn actionName:WSM_ADD_INVENTORY_OUT URL:KURL NotificationName:@"InvenOutAddInventoryOutResult"];
        }
    }
}


- (NSMutableArray *) InventoryMstHoldMain
{
    NSMutableArray *arrItemMst = [[NSMutableArray alloc] init];
    NSMutableDictionary *dictItemMstData = [[NSMutableDictionary alloc] init];
    
    [dictItemMstData setObject:@"" forKey:@"OrderNo"];
    [dictItemMstData setObject:self.objAppInvenIn.txtEnterOrder.text forKey:@"Date"];
    [dictItemMstData setObject:[self.rmsDbController.globalDict objectForKey:@"BranchID"] forKey:@"BranchId"];
    NSString *userID = [[self.rmsDbController.globalDict objectForKey:@"UserInfo"] objectForKey:@"UserId"];
    [dictItemMstData setObject:[NSString stringWithFormat:@"%@",userID ] forKey:@"UserId"];
    [dictItemMstData setObject:@"OPEN" forKey:@"Type"];
    //    [dictItemMstData setObject:@"" forKey:@"ItemInId"];
    [dictItemMstData setObject:@"" forKey:@"Description"];
    [arrItemMst addObject:dictItemMstData];
    return arrItemMst;
}

- (NSMutableArray *) InventoryItemDetailHoldMain
{
    NSMutableArray *arrItemInventory = [[NSMutableArray alloc] init];
    
    if([self.objAppInvenIn.arrScanBarDetails count]>0)
    {
        for (int isup=0; isup<[self.objAppInvenIn.arrScanBarDetails count]; isup++)
        {
            NSMutableDictionary *tmpSup = [[self.objAppInvenIn.arrScanBarDetails objectAtIndex:isup] mutableCopy ];
            NSMutableDictionary *speDict = [tmpSup mutableCopy];
            NSArray *removedKeys = @[@"AddedQty",@"Barcode",@"CostPrice",@"ItemId",@"SalesPrice",@"avaibleQty"];
            [speDict removeObjectsForKeys:removedKeys];
            NSArray *speKeys = [speDict allKeys];
            [tmpSup removeObjectsForKeys:speKeys];
        }
    }
    return arrItemInventory;
    
}


- (NSMutableDictionary *) insertAddInventoryInHoldMain
{
    NSMutableDictionary * addItemInventoryIn = [[NSMutableDictionary alloc] init];
    NSMutableArray * InventoryIn = [[NSMutableArray alloc] init];
    
    NSMutableDictionary * itemDetailDict = [[NSMutableDictionary alloc] init];
    [itemDetailDict setObject:[self InventoryMstHoldMain] forKey:@"InventoryMst"];
    [itemDetailDict setObject:[self InventoryItemDetailHoldMain] forKey:@"InventoryItemDetail"];
    [InventoryIn addObject:itemDetailDict];
    [addItemInventoryIn setObject:InventoryIn forKey:@"InventoryInDetail"];
    return addItemInventoryIn;
}

- (NSMutableArray *) InventoryMstOutMain
{
    NSMutableArray *arrItemMst = [[NSMutableArray alloc] init];
    NSMutableDictionary *dictItemMstData = [[NSMutableDictionary alloc] init];
    
    [dictItemMstData setObject:@"" forKey:@"OrderNo"];
    [dictItemMstData setObject:self.objAppInvenOut.txtEnterOrderNo.text forKey:@"Date"];
    [dictItemMstData setObject:[self.rmsDbController.globalDict objectForKey:@"BranchID"] forKey:@"BranchId"];
    NSString *userID = [[self.rmsDbController.globalDict objectForKey:@"UserInfo"] objectForKey:@"UserId"];
    [dictItemMstData setObject:[NSString stringWithFormat:@"%@",userID] forKey:@"UserId"];
    [dictItemMstData setObject:@"OPEN" forKey:@"Type"];
    //    [dictItemMstData setObject:@"" forKey:@"ItemOutId"];
    [dictItemMstData setObject:@"" forKey:@"Description"];
    
    [arrItemMst addObject:dictItemMstData];
    return arrItemMst;
}

- (NSMutableArray *) InventoryItemOutMain
{
    NSMutableArray *arrItemInventory = [[NSMutableArray alloc] init];
    
    if([self.objAppInvenOut.arrScanBarDetails count]>0)
    {
        for (int isup=0; isup<[self.objAppInvenOut.arrScanBarDetails count]; isup++)
        {
            NSMutableDictionary *tmpSup=[[self.objAppInvenOut.arrScanBarDetails objectAtIndex:isup] mutableCopy ];
            
            NSMutableDictionary *speDict = [tmpSup mutableCopy];
            NSArray *removedKeys = @[@"AddedQty",@"Barcode",@"CostPrice",@"ItemId",@"SalesPrice",@"avaibleQty"];
            [speDict removeObjectsForKeys:removedKeys];
            NSArray *speKeys = [speDict allKeys];
            [tmpSup removeObjectsForKeys:speKeys];
            
            [tmpSup setValue:[tmpSup valueForKey:@"AddedQty" ] forKey:@"ReturnQty"];
            [tmpSup removeObjectForKey:@"AddedQty"];
            
            [arrItemInventory addObject:tmpSup];
        }
    }
    return arrItemInventory;
}

- (NSMutableDictionary *) outInsertAddInventoryMain
{
    NSMutableDictionary * addItemInventoryOut = [[NSMutableDictionary alloc] init];
    NSMutableArray * InventoryIn = [[NSMutableArray alloc] init];
    
    NSMutableDictionary * itemDetailDict = [[NSMutableDictionary alloc] init];
    [itemDetailDict setObject:[self InventoryMstOutMain] forKey:@"InventoryMst"];
    [itemDetailDict setObject:[self InventoryItemOutMain] forKey:@"InventoryItemDetail"];
    [InventoryIn addObject:itemDetailDict];
    [addItemInventoryOut setObject:InventoryIn forKey:@"InventoryOutDetail"];
    return addItemInventoryOut;
}

- (NSMutableArray *) updateInventoryMstMain
{
    NSMutableArray *arrItemMst = [[NSMutableArray alloc] init];
    NSMutableDictionary *dictItemMstData = [[NSMutableDictionary alloc] init];
    
    [dictItemMstData setObject:@"" forKey:@"OrderNo"];
    [dictItemMstData setObject:self.objAppInvenIn.txtEnterOrder.text forKey:@"Date"];
    [dictItemMstData setObject:[self.rmsDbController.globalDict objectForKey:@"BranchID"] forKey:@"BranchId"];
    NSString *userID = [[self.rmsDbController.globalDict objectForKey:@"UserInfo"] objectForKey:@"UserId"];
    [dictItemMstData setObject:[NSString stringWithFormat:@"%@",userID ] forKey:@"UserId"];
    [dictItemMstData setObject:@"OPEN" forKey:@"Type"];
    [dictItemMstData setObject:[self.objAppInvenIn.dictInventoryMain valueForKey:@"ItemInOutId" ] forKey:@"ItemInId"];
    [dictItemMstData setObject:[self.objAppInvenIn.dictInventoryMain valueForKey:@"Description"] forKey:@"Description"];
    
    [arrItemMst addObject:dictItemMstData];
    return arrItemMst;
}

- (NSMutableArray *) updateInventoryItemDetailMain
{
    NSMutableArray *arrItemInventory = [[NSMutableArray alloc] init];
    
    //    [self.arrScanBarDetails removeAllObjects];
    
    if([self.objAppInvenIn.arrScanBarDetails count]>0)
    {
        for (int isup=0; isup<[self.objAppInvenIn.arrScanBarDetails count]; isup++)
        {
            NSMutableDictionary *tmpSup=[[self.objAppInvenIn.arrScanBarDetails objectAtIndex:isup] mutableCopy];
            NSMutableDictionary *speDict = [tmpSup mutableCopy];
            NSArray *removedKeys = @[@"AddedQty",@"Barcode",@"CostPrice",@"ItemId",@"SalesPrice",@"avaibleQty"];
            [speDict removeObjectsForKeys:removedKeys];
            NSArray *speKeys = [speDict allKeys];
            [tmpSup removeObjectsForKeys:speKeys];
        }
    }
    return arrItemInventory;
    
}

// update item in open record

- (NSMutableDictionary *) UpdateInOpenDataMain
{
    NSMutableDictionary * addItemInventoryIn = [[NSMutableDictionary alloc] init];
    NSMutableArray * InventoryIn = [[NSMutableArray alloc] init];
    
    NSMutableDictionary * itemDetailDict = [[NSMutableDictionary alloc] init];
    [itemDetailDict setObject:[self updateInventoryMstMain] forKey:@"InventoryMst"];
    [itemDetailDict setObject:[self updateInventoryItemDetailMain] forKey:@"InventoryItemDetail"];
    [InventoryIn addObject:itemDetailDict];
    
    [addItemInventoryIn setObject:InventoryIn forKey:@"InventoryInDetail"];
    return addItemInventoryIn;
}

- (NSMutableArray *) updateInventoryOutMain
{
    NSMutableArray *arrItemMst = [[NSMutableArray alloc] init];
    NSMutableDictionary *dictItemMstData = [[NSMutableDictionary alloc] init];
    
    [dictItemMstData setObject:@"" forKey:@"OrderNo"];
    [dictItemMstData setObject:self.objAppInvenOut.txtEnterOrderNo.text forKey:@"Date"];
    [dictItemMstData setObject:[self.rmsDbController.globalDict objectForKey:@"BranchID"] forKey:@"BranchId"];
    NSString *userID = [[self.rmsDbController.globalDict objectForKey:@"UserInfo"] objectForKey:@"UserId"];
    [dictItemMstData setObject:[NSString stringWithFormat:@"%@",userID ] forKey:@"UserId"];
    [dictItemMstData setObject:@"OPEN" forKey:@"Type"];
    [dictItemMstData setObject:[self.objAppInvenOut.dictOutInventoryMain valueForKey:@"ItemInOutId" ] forKey:@"ItemOutId"];
    [dictItemMstData setObject:[self.objAppInvenOut.dictOutInventoryMain valueForKey:@"Description"] forKey:@"Description"];
    
    [arrItemMst addObject:dictItemMstData];
    return arrItemMst;
}

- (NSMutableArray *) updateInventoryItemDetailOutMain
{
    NSMutableArray *arrItemInventory = [[NSMutableArray alloc] init];
    //    [self.arrScanBarDetails removeAllObjects];
    if([self.objAppInvenOut.arrScanBarDetails count]>0)
    {
        for (int isup=0; isup<[self.objAppInvenOut.arrScanBarDetails count]; isup++)
        {
            NSMutableDictionary *tmpSup=[[self.objAppInvenOut.arrScanBarDetails objectAtIndex:isup] mutableCopy ];
            
            NSMutableDictionary *speDict = [tmpSup mutableCopy];
            NSArray *removedKeys = @[@"AddedQty",@"Barcode",@"CostPrice",@"ItemId",@"SalesPrice",@"avaibleQty"];
            [speDict removeObjectsForKeys:removedKeys];
            NSArray *speKeys = [speDict allKeys];
            [tmpSup removeObjectsForKeys:speKeys];
            
            [tmpSup setValue:[tmpSup valueForKey:@"AddedQty" ] forKey:@"ReturnQty"];
            [tmpSup removeObjectForKey:@"AddedQty"];
            
            [arrItemInventory addObject:tmpSup];        }
    }
    return arrItemInventory;
}

// update item out open record

- (NSMutableDictionary *) UpdateOutOpenDataMain
{
    NSMutableDictionary * addItemInventoryIn = [[NSMutableDictionary alloc] init];
    NSMutableArray * InventoryIn = [[NSMutableArray alloc] init];
    
    NSMutableDictionary * itemDetailDict = [[NSMutableDictionary alloc] init];
    [itemDetailDict setObject:[self updateInventoryOutMain] forKey:@"InventoryMst"];
    [itemDetailDict setObject:[self updateInventoryItemDetailOutMain] forKey:@"InventoryItemDetail"];
    [InventoryIn addObject:itemDetailDict];
    
    [addItemInventoryIn setObject:InventoryIn forKey:@"InventoryOutDetail"];
    return addItemInventoryIn;
}


#endif
@end
