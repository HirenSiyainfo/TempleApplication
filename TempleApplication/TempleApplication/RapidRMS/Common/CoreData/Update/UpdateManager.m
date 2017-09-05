//
//  UpdateManager.m
//  POSRetail
//
//  Created by Siya Infotech on 21/03/14.
//  Copyright (c) 2014 Nirav Patel. All rights reserved.
//

#import "UpdateManager.h"
#import "Item+Dictionary.h"
#import "ItemSupplier+Dictionary.h"
#import "ItemTag+Dictionary.h"
#import "Item_Discount_MD+Dictionary.h"
#import "Item_Discount_MD2+Dictionary.h"
#import "ItemTax+Dictionary.h"
#import "Department+Dictionary.h"
#import "TaxMaster+Dictionary.h"
#import "SupplierMaster+Dictionary.h"
#import "SizeMaster+Dictionary.h"
#import "Configuration.h"
#import "DepartmentTax+Dictionary.h"
#import "TenderPay+Dictionary.h"
#import "InvoiceData_T+Dictionary.h"
#import "Configuration+Dictionary.h"
#import "RmsDbController.h"
#import "Keychain.h"
#import "GroupMaster+Dictionary.h"
#import "Mix_MatchDetail+Dictionary.h"
#import "ItemBarCode_Md+Dictionary.h"
#import "Item_Price_MD+Dictionary.h"
#import "LoadingViewController.h"
#import "LastInvoiceData+NSDictionary.h"
#import "WeightScaleUnit+Dictionary.h"
#import "UnitConversion+Dictionary.h"
#import "SubDepartment+Dictionary.h"
#import "ModuleInfo+Dictionary.h"
#import "RegisterInfo+Dictionary.h"
#import "BranchInfo+Dictionary.h"
#import "CreditcardCredetnial+Dictionary.h"
#import "ItemVariation_M+Dictionary.h"
#import "ItemVariation_Md+Dictionary.h"
#import "Variation_Master+Dictionary.h"
#import "Vendor_Item+Dictionary.h"
#import "Modifire_M+Dictionary.h"
#import "ModifireList_M+Dictionary.h"
#import "TipPercentageMaster+Dictionary.h"
#import "ItemInventoryCountSession+Dictionary.h"
#import "ItemInventoryCount+Dictionary.h"
#import "ItemInventoryReconcileCount+Dictionary.h"
#import "ManualPOSession+Dictionary.h"
#import "ManualReceivedItem+Dictionary.h"
#import "VPurchaseOrder+Dictionary.h"
#import "Vendor_Item+Dictionary.h"
#import "VPurchaseOrderItem+Dictionary.h"

#import "UserInfo+Dictionary.h"
#import "RightInfo+Dictionary.h"
#import "RoleInfo+Dictionary.h"
#import "CredentialInfo+Dictionary.h"
#import "HoldInvoice+Dictionary.h"
#import "NoSale+Dictionary.h"
#import "ShiftDetail+Dictionary.h"
#import "SupplierCompany+Dictionary.h"
#import "SupplierRepresentative+Dictionary.h"
#import "KitchenPrinter+Dictionary.h"

#import "RestaurantOrder+Dictionary.h"
#import "RestaurantItem+Dictionary.h"
#import "DiscountMaster+Dictionary.h"
#import "ItemTicket_MD+Dictionary.h"
#import "BarCodeSearch+Dictionary.h"
#import "TaxMaster+Dictionary.h"
#import "TenderPay+Dictionary.h"

#import "Discount_M.h"
#import "Discount_Primary_MD.h"
#import "Discount_Secondary_MD.h"
#import "Customer.h"
#import "RapidWebServiceConnection.h"

#define PVTCTX(x)   [UpdateManager privateConextFromParentContext:x]

@interface UpdateManager ()
@property (strong, nonatomic) NsmoContext *parentManagedObjectContext__Sec;
//@property (strong, nonatomic) NsmoContext *privateManagedObjectContext;
@property (readonly, weak, nonatomic) id<UpdateDelegate> updateDelegate;

@end

@implementation UpdateManager
- (instancetype)initWithManagedObjectContext:(NsmoContext*)managedObjectContext delegate:(id<UpdateDelegate>)delegate {
    
    self = [super init];
    if (self) {
        self.parentManagedObjectContext__Sec = managedObjectContext;
        _updateDelegate = delegate;
    }
    return self;
}

- (void)dealloc {
    _parentManagedObjectContext__Sec = nil;
    _updateDelegate = nil;
}

// Not sure when to relase the queue and how.
- (void)releaseDispatchQueue:(dispatch_queue_t)dispatchQueue {
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //        dispatch_release(dispatchQueue);
    });
}

#pragma mark - Update Process
- (void)insertObjectsFromResponseDictionary:(NSDictionary*)responseDictionary {
    dispatch_queue_t dispatchQueue = nil; //dispatch_queue_create("Item Insert Queue", NULL);
    //    dispatch_async(dispatchQueue, ^{
    [self asynchronousInsertObjectsFromResponseDictionary:responseDictionary dispatchQueue:dispatchQueue];
    //    });
}

- (void)linkItemToDepartmentFromResponseDictionary:(NSDictionary*)updateResponseDictionary {
    dispatch_queue_t dispatchQueue = dispatch_queue_create("Link Item To Department", NULL);
    dispatch_async(dispatchQueue, ^{
        [self asynchronousLinkItemToDepartmentFromResponseDictionary:updateResponseDictionary dispatchQueue:dispatchQueue];
    });
}

- (void)liveUpdateFromResponseDictionary:(NSDictionary*)updateResponseDictionary
{
    [self asynchronousUpdateObjectsFromResponseDictionary:updateResponseDictionary dispatchQueue:nil];
}

- (void)updateObjectsFromResponseDictionary:(NSDictionary*)updateResponseDictionary {
    dispatch_queue_t dispatchQueue = dispatch_queue_create("Item Update Queue", NULL);
//    dispatch_async(dispatchQueue, ^{
        [self asynchronousUpdateObjectsFromResponseDictionary:updateResponseDictionary dispatchQueue:dispatchQueue];
//    });
}

- (void)insertObjectsFromMasterResponseDictionary:(NSDictionary*)masterResponseDictionary {
    //dispatch_queue_attr_t backgroundPriorityAttr = dispatch_queue_attr_make_with_qos_class (DISPATCH_QUEUE_CONCURRENT, QOS_CLASS_BACKGROUND, DISPATCH_QUEUE_PRIORITY_BACKGROUND);

    dispatch_queue_t dispatchQueue = dispatch_queue_create("Master Insert Queue", DISPATCH_QUEUE_CONCURRENT);
//    dispatch_async(dispatchQueue, ^{
        [self asynchronousInsertObjectsFromMasterResponseDictionary:masterResponseDictionary dispatchQueue:dispatchQueue];
//    });
}

- (void)UpdateObjectsFromMasterResponseDictionary:(NSDictionary*)masterResponseDictionary {
    dispatch_queue_t dispatchQueue = dispatch_queue_create("Master Update Queue", NULL);
    dispatch_async(dispatchQueue, ^{
        [self asynchronousUpdateObjectsFromMasterResponseDictionary:masterResponseDictionary dispatchQueue:dispatchQueue];
    });
}

- (void)deleteObjectsFromTable:(NSDictionary*)deleteDictionary {
    dispatch_queue_t dispatchQueue = dispatch_queue_create("Delete Update Queue", NULL);
    dispatch_async(dispatchQueue, ^{
        [self asynchronousDeleteObjectsFromDataBaseTable:deleteDictionary dispatchQueue:dispatchQueue];
    });
}

- (void)deleteTaxMaster:(NSDictionary *)deleteDictionary
{
    dispatch_queue_t dispatchQueue = dispatch_queue_create("Delete Tax Master Queue", NULL);
    dispatch_async(dispatchQueue, ^{
        
        NSArray *taxMasterArray = [deleteDictionary valueForKey:@"TAX_MArray"];
        if (taxMasterArray !=nil && taxMasterArray.count > 0) {
            NsmoContext *privateManagedObjectContext = PVTCTX(self.parentManagedObjectContext__Sec);
            for (NSDictionary *dictTaxMaster in taxMasterArray) {
                NSString *taxId = [NSString stringWithFormat:@"%@",[dictTaxMaster valueForKey:@"TaxId"]];
                [self deleteTaxMaster:taxId moc:privateManagedObjectContext];
            }
            [UpdateManager saveContext:privateManagedObjectContext];
        }
    });
}

#pragma mark - Asynchronous method
+ (NsmoContext *)privateConextFromParentContext:(NsmoContext*)parentContext {
    // Create Provate context for this queue
    NsmoContext *privateManagedObjectContext = [[NsmoContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    privateManagedObjectContext.parentContext = parentContext;
    [privateManagedObjectContext setUndoManager:nil];
    return privateManagedObjectContext;
}

-(void)linkPriceBarcodewith :(NSArray *)barcode_Md_List withPriceMdList:(NSArray *)price_Md_List
{
    for (Item_Price_MD *itemPrice in price_Md_List)
    {
        NSPredicate *itemBarcodePredicate = [NSPredicate predicateWithFormat:@"packageType = %@", itemPrice.priceqtytype];
        NSArray *barcodeListForItem = [barcode_Md_List filteredArrayUsingPredicate:itemBarcodePredicate];
        [itemPrice linkToBarcodePrice:barcodeListForItem];
    }
}

- (NSArray *)insertBarcodeForItem:(Item *)item barcodeArray:(NSMutableArray *)itemBarcodeArray moc:(NsmoContext *)privateManagedObjectContext {
    NSMutableArray *itemBarcode_Md = [[NSMutableArray alloc]init];
    
    NSPredicate *itemPredicate = [NSPredicate predicateWithFormat:@"ItemId = %@", item.itemCode];
    NSArray *barcodeListForItem = [itemBarcodeArray filteredArrayUsingPredicate:itemPredicate];
    
    for (NSDictionary *barcodeDictionary in barcodeListForItem) {
        ItemBarCode_Md *itemBarcode = [self insertBarcodeWithBarcodeDictionary:barcodeDictionary moc:privateManagedObjectContext];
        [item linkToBarcode:itemBarcode];
        [itemBarcode_Md addObject:itemBarcode];
    }
    return itemBarcode_Md;
}

- (NSArray *)insertItemTicketItem:(Item *)item ticketArray:(NSMutableArray *)itemTicketArray moc:(NsmoContext *)privateManagedObjectContext {
    NSMutableArray *itemTickets = [[NSMutableArray alloc]init];
    
    NSPredicate *itemPredicate = [NSPredicate predicateWithFormat:@"ItemCode = %@", item.itemCode];
    NSArray *ticketListForItem = [itemTicketArray filteredArrayUsingPredicate:itemPredicate];
    
    for (NSDictionary *itemTicketDictionary in ticketListForItem) {
        ItemTicket_MD *itemTicket = [self insertItemTicketDictionary:itemTicketDictionary moc:privateManagedObjectContext];
        [itemTicket updateItemTicketlDictionary:itemTicketDictionary];
        itemTicket.ticketToItem = item;
        item.itemTicket = itemTicket;
    }
    return itemTickets;
}
- (NSArray *)insertPriceForItem:(Item *)item barcodeArray:(NSMutableArray *)itemBarcodeArray moc:(NsmoContext *)privateManagedObjectContext {
    NSPredicate *itemPredicate = [NSPredicate predicateWithFormat:@"ItemCode = %@", item.itemCode];
    NSArray *priceListForItem = [itemBarcodeArray filteredArrayUsingPredicate:itemPredicate];

    NSMutableArray *priceList = [[NSMutableArray alloc] init];
    for (NSDictionary *priceDictionary in priceListForItem) {
        Item_Price_MD *itemPrice = [self insertPriceWithPriceDictionary:priceDictionary moc:privateManagedObjectContext];
        [priceList addObject:itemPrice];
    }
    [item linkToPrice:priceList];
    return  priceList;
}

- (void)insertMD2ForDiscountMD:(Item_Discount_MD *)itemDiscount_MD arrayDiscount_Md2:(NSMutableArray *)arrayDiscount_Md2 moc:(NsmoContext *)privateManagedObjectContext
{
    // Link Item_Discount_MD2
    NSPredicate *itemPredicate_MD2 = [NSPredicate predicateWithFormat:@"DiscountId = %@", itemDiscount_MD.iDisNo];
    NSArray *arrayDiscount_Md2List = [arrayDiscount_Md2 filteredArrayUsingPredicate:itemPredicate_MD2];
    NSMutableArray *discountMd2List = [[NSMutableArray alloc] init];

    for (NSDictionary *discount_MD2Dictionary in arrayDiscount_Md2List) {
        Item_Discount_MD2 *itemDiscount_MD2 = [self insertDiscount_MD2FromDiscountDictionary:discount_MD2Dictionary moc:privateManagedObjectContext];
        [discountMd2List addObject:itemDiscount_MD2];
        itemDiscount_MD2.md2Tomd = itemDiscount_MD;
    }
    [itemDiscount_MD addMdTomd2:[NSSet setWithArray:discountMd2List]];
}

// Variation MD

- (void)insertVariationForItemVariation_Md:(ItemVariation_M *)itemVariation_M arrayVariation_Md:(NSMutableArray *)arrayVariation_Md moc:(NsmoContext *)privateManagedObjectContext
{
    // Link Item_Variation_MD
    
    NSPredicate *itemPredicate_MD = [NSPredicate predicateWithFormat:@"VarianceId = %@", itemVariation_M.variationMasterId];
    NSArray *arrayVariation_MdList = [arrayVariation_Md filteredArrayUsingPredicate:itemPredicate_MD];
    NSMutableArray *variationMd2List = [[NSMutableArray alloc] init];
    for (NSDictionary *variation_MD2Dictionary in arrayVariation_MdList) {
        ItemVariation_Md *itemVariation_MD = [self fetchVariation_MDFromVariationDictionary:variation_MD2Dictionary moc:privateManagedObjectContext];
        [variationMd2List addObject:itemVariation_MD];
        //itemVariation_MD.variationM = itemVariation_M;
    }
   // [itemVariation_M addVariationMds:[NSSet setWithArray:variationMd2List]];
}


- (void)insertDiscountForItem:(Item *)item arrayDiscount_Md:(NSMutableArray *)arrayDiscount_Md arrayDiscount_Md2:(NSMutableArray *)arrayDiscount_Md2 moc:(NsmoContext *)privateManagedObjectContext
{
    // Link Item_Discount_MD
    NSPredicate *itemPredicate = [NSPredicate predicateWithFormat:@"ITEMCode = %@", item.itemCode];
    NSArray *arrayDiscount_MdList = [arrayDiscount_Md filteredArrayUsingPredicate:itemPredicate];
    NSMutableArray *discountMdList = [[NSMutableArray alloc] init];

    for (NSDictionary *discount_MDDictionary in arrayDiscount_MdList) {
        Item_Discount_MD *itemDiscount_MD = [self insertDiscount_MDFromDiscountDictionary:discount_MDDictionary moc:privateManagedObjectContext];
        [discountMdList addObject:itemDiscount_MD];
        itemDiscount_MD.mdToItem = item;
        // Link Item_Discount_MD2
        [self insertMD2ForDiscountMD:itemDiscount_MD arrayDiscount_Md2:arrayDiscount_Md2 moc:privateManagedObjectContext];
    }
    [item addItemToDisMd:[NSSet setWithArray:discountMdList]];
}

// Variation

- (void)insertVariationForItem:(Item *)item arrayVariationM:(NSMutableArray *)arryVariationM arrayVariationMd:(NSMutableArray *)arrayVariationMD moc:(NsmoContext *)privateManagedObjectContext
{
    NSPredicate *itemPredicate = [NSPredicate predicateWithFormat:@"ItemCode = %@", item.itemCode];
    NSArray *arrayVariation_MList = [arryVariationM filteredArrayUsingPredicate:itemPredicate];
    for (NSDictionary *variation_MDictionary in arrayVariation_MList) {
        ItemVariation_M * variation_m = (ItemVariation_M *)[self insertEntityWithName:@"ItemVariation_M" moc:privateManagedObjectContext];
        [variation_m updateitemVariationMDictionary:variation_MDictionary];
        [item addItemVariationsObject:variation_m];//
        variation_m.variationItem = item;
        NSPredicate *itemPredicateMD = [NSPredicate predicateWithFormat:@"VarianceId = %@", variation_m.varianceId];
        NSArray *arrayVariation_MDList = [arrayVariationMD filteredArrayUsingPredicate:itemPredicateMD];
        
        for (NSDictionary *variation_MDDictionary in arrayVariation_MDList)
        {
            ItemVariation_Md * variation_md = (ItemVariation_Md *)[self insertEntityWithName:@"ItemVariation_Md" moc:privateManagedObjectContext];
            [variation_md updateitemVariationMdDictionary:variation_MDDictionary];
            variation_md.variationMdVariationM = variation_m;
            [variation_m addVariationMVariationMdsObject:variation_md];
        }
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Variation_Master" inManagedObjectContext:privateManagedObjectContext];
        fetchRequest.entity = entity;
        
        NSPredicate *masterPredicate = [NSPredicate predicateWithFormat:@"vid = %@", variation_m.variationMasterId];
        fetchRequest.predicate = masterPredicate;
        
        NSArray *variationMasterList = [UpdateManager executeForContext:privateManagedObjectContext FetchRequest:fetchRequest];
        for (Variation_Master *variationMaster in variationMasterList) {
            [variationMaster addMasterVariationMsObject:variation_m];
            variation_m.variationMMaster = variationMaster;
        }
    }
}

- (void)asynchronousInsertObjectsFromResponseDictionary:(NSDictionary*)responseDictionary dispatchQueue:(dispatch_queue_t)dispatchQueue
{
#if 1
    NSDictionary *phase1Dict = [responseDictionary dictionaryWithValuesForKeys:@[@"ItemArray", @"ItemBarcodeArray"]];
    
    NSDictionary *phase2Dict = [responseDictionary dictionaryWithValuesForKeys:@[@"ItemPriceArray", @"Item_Discount_MDArray",@"Item_Discount_MD2Array"]];
    
    NSDictionary *phase3Dict = [responseDictionary dictionaryWithValuesForKeys:@[@"Item_SupplierArray", @"ITMTAX_MDArray",@"ItemSizeArray",@"VariationArray",@"VariationItemArray"]];

   //  NSDictionary *phase4Dict = [responseDictionary dictionaryWithValuesForKeys:@[@"Supplier_Hackney_Item_MArray"]];

    [self insertPhase1:phase1Dict];
    [self insertPhase2:phase2Dict];
    [self insertPhase3:phase3Dict];
   // [self insertPhase4:phase4Dict];
    {
        double delayInSeconds = 0.1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            // This method has to be called on main queue
            [self.updateDelegate insertDidFinish];
        });
    }
#else
    NsmoContext *privateManagedObjectContext = PVTCTX(self.parentManagedObjectContext__Sec);
    // Item
    NSMutableArray *itemArray = [responseDictionary valueForKey:@"ItemArray"];
    NSMutableArray *itemBarcodeArray = [responseDictionary valueForKey:@"ItemBarcodeArray"];
    NSMutableArray *itemPriceArray = [responseDictionary valueForKey:@"ItemPriceArray"];
    NSMutableArray *arrayDiscount_Md = [responseDictionary valueForKey:@"Item_Discount_MDArray"];
    NSMutableArray *arrayDiscount_Md2 = [responseDictionary valueForKey:@"Item_Discount_MD2Array"];
    NSMutableArray *variationM = [responseDictionary valueForKey:@"VariationArray"];
    NSMutableArray *variationMD = [responseDictionary valueForKey:@"VariationItemArray"];
    
    // Supplier
    NSMutableArray *itemSupplierArray = [responseDictionary valueForKey:@"Item_SupplierArray"];
    // Size
    NSMutableArray *arrayTag = [responseDictionary valueForKey:@"ItemSizeArray"];
    // Tax
    NSMutableArray *arrayTaxDetail = [responseDictionary valueForKey:@"ITMTAX_MDArray"];
    
    // Vendor Array
     NSMutableArray *vendorItem = [responseDictionary valueForKey:@"Supplier_Hackney_Item_MArray"];
    
    //BOOL debugFlage = TRUE;
    int totalitemcount=0;
//    int currentIndex=1;
    for (NSDictionary *itemDictionary in itemArray)
    {
        if ([[[itemDictionary valueForKey:@"isDeleted"] stringValue]isEqualToString:@"1"])
        {
            continue;
        }

        @autoreleasepool
        {

//        if (currentIndex == 2000) {
//            break;
//        }
//        if((currentIndex % 100) == 0){
////
////            currentIndex=0;
////            [[NSNotificationCenter defaultCenter] postNotificationName:kConfigurationMessageNotification object:nil userInfo:@{kConfigurationMessageKey:[NSString stringWithFormat:@"%d/%d items configured", currentIndex, itemArray.count], kConfigurationStatusCodeKey:@(0)}];
//            [UpdateManager saveContext:privateManagedObjectContext];
//            [privateManagedObjectContext processPendingChanges];
//             
//            privateManagedObjectContext = [self privateConextFromParentContext:self.parentManagedObjectContext__Sec];
//        }
//        currentIndex++;

            Item *item = [self insertItemWithItemDictionary:itemDictionary moc:privateManagedObjectContext];
        
            // Item Barcode
            NSArray *barcode_mdList = [self insertBarcodeForItem:item barcodeArray:itemBarcodeArray moc:privateManagedObjectContext];
            // Item PriceArray
            NSArray *priceMD_List =  [self insertPriceForItem:item barcodeArray:itemPriceArray moc:privateManagedObjectContext];
            // price Barcode Linking........
            [self linkPriceBarcodewith:barcode_mdList withPriceMdList:priceMD_List];
            // Link Item_Discount_MD
            [self insertDiscountForItem:item arrayDiscount_Md:arrayDiscount_Md arrayDiscount_Md2:arrayDiscount_Md2 moc:privateManagedObjectContext];
            // Link Insert Variation For Item
            [self insertVariationForItem:item arrayVariationM:variationM arrayVariationMd:variationMD moc:privateManagedObjectContext];
            totalitemcount++;
//            int intPercentage = totalitemcount*100/[itemArray count];
//            [self stepProgressnotification:0 message:@"2" progress:intPercentage];
        }
    }
    
    [self insertSuppliersFromSupplierlist:itemSupplierArray moc:privateManagedObjectContext];
    
    // Size
    [self insertTagsFromTaglist:arrayTag moc:privateManagedObjectContext];
    // Tax
    [self insertTaxlist:arrayTaxDetail moc:privateManagedObjectContext];
    
    // Modifier_M and ModifierItem_M
    NSMutableArray *itemModifierMGroup = [[self modifier_MStaticArray] mutableCopy ];
    NSMutableArray *itemModifierItemM = [[self modifierItem_MStaticArray] mutableCopy ];
//    NSMutableArray *itemModifierMGroup = [responseDictionary valueForKey:@"Modifier_MArray"];
//    NSMutableArray *itemModifierItemM = [responseDictionary valueForKey:@"ModifierItem_MArray"];
    [self insertModifier_MAndModifierItem_M:itemModifierMGroup arrayModifireItem_M:itemModifierItemM moc:privateManagedObjectContext];
    
    // Weightscale
    NSArray * arrayWeightScale = [self weightScaleArray] ;
    [self insertWightScaleUnit:arrayWeightScale moc:privateManagedObjectContext];
    // unit conversation
    NSArray * arrayUnitConversionScale = [self unitConversionScaleArray] ;
    [self insertUnitConversionScaleUnit:arrayUnitConversionScale moc:privateManagedObjectContext];
    
    // Vendor Array
    [self insertVendorItemlist:vendorItem moc:privateManagedObjectContext];
    [UpdateManager saveContext:privateManagedObjectContext];
    
    // Release the dispatch queue object
    // Inform updateDelegate that insert did finish
    //    if ([self.updateDelegate respondsToSelector:@selector(insertDidFinish)])
    {
        double delayInSeconds = 0.1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            // This method has to be called on main queue
            [self.updateDelegate insertDidFinish];
        });
    }
#endif
}

-(void)storeCurrentStep:(NSInteger)currentStep{
    
    [[NSUserDefaults standardUserDefaults]setObject:[NSString stringWithFormat:@"%ld",(long)currentStep]  forKey:@"ConfigurationStep"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
}

- (NSMutableArray *)filteredArray:(NSMutableArray *)array forItem:(Item *)item at:(NSUInteger*)p_StartIndex itemCodeKey:(NSString*)itemCodeKey {
    // NOTE:
    // This algorithm will work only if "array" is an array of dictionaries sorted on key "ItemCode".
    
    NSInteger givenItemCode = item.itemCode.integerValue;

    // Take the start index
    NSUInteger startIndex = *p_StartIndex;
    NSRange arrayRange;

    arrayRange.location = startIndex;
    arrayRange.length = array.count - startIndex;

    // Get sub-array from startIndex
    NSArray *subArray = [array subarrayWithRange:arrayRange];

    // Look for endIndex
    NSUInteger endIndex = [subArray indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *dict = (NSDictionary*)obj;
        NSNumber *num1 = dict[itemCodeKey];

        if (num1.integerValue > givenItemCode) {
            return YES;
        }
        return NO;
    }];

    // filterRange
    NSRange filterRange;
    filterRange.location = 0;
    if (endIndex == NSNotFound) {
        filterRange.length = 0;
    } else {
        filterRange.length = endIndex;
        startIndex += endIndex;
    }

    // Get sub-array. It is filtered list.
    NSMutableArray *arrayFilteredOnItemCode = [[subArray subarrayWithRange:filterRange] mutableCopy];

    // Update startIndex pointer for next iteration
    *p_StartIndex = startIndex;
    return arrayFilteredOnItemCode;
}

- (void)sortArray:(NSMutableArray *)array onKey:(NSString *)keyToSort {
    [array sortUsingComparator:^(id obj1, id obj2) {
        NSDictionary *dict1 = (NSDictionary*)obj1;
        NSDictionary *dict2 = (NSDictionary*)obj2;
        NSNumber *num1 = dict1[keyToSort];
        NSNumber *num2 = dict2[keyToSort];
        if (num1.integerValue > num2.integerValue) {
            return (NSComparisonResult)NSOrderedDescending;
        }

        if (num1.integerValue < num2.integerValue) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
}

-(void)insertPhase1:(NSDictionary *)responseDictionary {

    NsmoContext *privateManagedObjectContext = PVTCTX(self.parentManagedObjectContext__Sec);
    // Item
    
    NSMutableArray *itemArray = [responseDictionary valueForKey:@"ItemArray"];
    NSMutableArray *itemBarcodeArray = [responseDictionary valueForKey:@"ItemBarcodeArray"];


//    NSString *keyToSort = @"ItemCode";
    [self sortArray:itemArray onKey:@"ITEMCode"];
    [self sortArray:itemBarcodeArray onKey:@"ItemId"];

    NSUInteger currentItemIndex=0;
    NSUInteger totalCount = itemArray.count;


    NSUInteger startPriceIndex = 0;

    for (NSDictionary *itemDictionary in itemArray) {
        if ([[[itemDictionary valueForKey:@"isDeleted"] stringValue]isEqualToString:@"1"])
        {
            currentItemIndex++;
            continue;
        }
        @autoreleasepool
        {
            Item *item = [self insertItemWithItemDictionary:itemDictionary moc:privateManagedObjectContext];
            // Item Barcode

            NSMutableArray *tempBarcodeArray = [self filteredArray:itemBarcodeArray forItem:item at:&startPriceIndex itemCodeKey:@"ItemId"];


           [self insertBarcodeForItem:item barcodeArray:tempBarcodeArray moc:privateManagedObjectContext];

            currentItemIndex++;
            float intPercentage = currentItemIndex*100.0;
            intPercentage = intPercentage/totalCount;
            [self stepProgressnotification:0 message:@"2" progress:intPercentage];
        }

//        if ((currentItemIndex % 100) == 0) {
//            [UpdateManager saveContext:privateManagedObjectContext];
//             
//        }
    }
    if([[responseDictionary valueForKey:@"UTCTime"] length] > 0 && [responseDictionary valueForKey:@"UTCTime"] != nil)
    {
        NSLog(@"UTC Date from the server at insert = %@", [responseDictionary valueForKey:@"UTCTime"]);
        [self insertItemUpdateDate:[responseDictionary valueForKey:@"UTCTime"]];
    }
    [UpdateManager saveContext:privateManagedObjectContext];
    [self storeCurrentStep:2];
}

-(void)insertPhase2:(NSDictionary *)responseDictionary{
    
    NsmoContext *privateManagedObjectContext = PVTCTX(self.parentManagedObjectContext__Sec);

    NSMutableArray *itemPriceArray = [responseDictionary valueForKey:@"ItemPriceArray"];
    NSMutableArray *arrayDiscount_Md = [responseDictionary valueForKey:@"Item_Discount_MDArray"];
    NSMutableArray *arrayDiscount_Md2 = [responseDictionary valueForKey:@"Item_Discount_MD2Array"];
    NSArray *arrayItems = [self fetchAllItems:privateManagedObjectContext];

    arrayItems = [arrayItems sortedArrayUsingComparator:^(id obj1, id obj2) {
        Item *dict1 = (Item*)obj1;
        Item *dict2 = (Item*)obj2;
        NSNumber *num1 = dict1.itemCode;
        NSNumber *num2 = dict2.itemCode;
        if (num1.integerValue > num2.integerValue) {
            return (NSComparisonResult)NSOrderedDescending;
        }

        if (num1.integerValue < num2.integerValue) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];

    NSDate *previousDate = [NSDate date];

    NSString *keyToSort = @"ItemCode";
    [self sortArray:itemPriceArray onKey:keyToSort];
    NSDate *currentDate = [NSDate date];
    NSLog(@"time = %f", [currentDate timeIntervalSinceDate:previousDate]);


    NSArray *priceMD_List;

    int totalitemcount=0;
    [self stepProgressnotification:0 message:@"2" progress:totalitemcount];


    NSUInteger startPriceIndex = 0;

    for (Item *item in arrayItems) {

        if (item.isDelete.integerValue == 1)
        {
            totalitemcount++;
            continue;
        }
        
         @autoreleasepool {

             NSMutableArray *tempBarcodeArray = [self filteredArray:itemPriceArray forItem:item at:&startPriceIndex itemCodeKey:@"ItemCode"];

             // Item PriceArray
            priceMD_List =  [self insertPriceForItem:item barcodeArray:tempBarcodeArray moc:privateManagedObjectContext];
            
            // Link Item_Discount_MD
            [self insertDiscountForItem:item arrayDiscount_Md:arrayDiscount_Md arrayDiscount_Md2:arrayDiscount_Md2 moc:privateManagedObjectContext];
             

             totalitemcount++;
             float intPercentage = totalitemcount*100;
             intPercentage = intPercentage/arrayItems.count;
             //NSLog(@"intPercentage %f",intPercentage);
             [self stepProgressnotification:0 message:@"2" progress:intPercentage];
         }
    }
    NSArray *barcode_mdList = [self fetchAllBarcodeList:privateManagedObjectContext];
    // price Barcode Linking........
    [self linkPriceBarcodewith:barcode_mdList withPriceMdList:priceMD_List];

    [UpdateManager saveContext:privateManagedObjectContext];
    [self storeCurrentStep:4];
}

-(void)insertPhase3:(NSDictionary *)responseDictionary{
    
    NsmoContext *privateManagedObjectContext = PVTCTX(self.parentManagedObjectContext__Sec);
    
    // Supplier
    NSMutableArray *itemSupplierArray = [responseDictionary valueForKey:@"Item_SupplierArray"];
    // Tax
    NSMutableArray *arrayTaxDetail = [responseDictionary valueForKey:@"ITMTAX_MDArray"];
    // Size
    NSMutableArray *arrayTag = [responseDictionary valueForKey:@"ItemSizeArray"];
    
    NSMutableArray *variationM = [responseDictionary valueForKey:@"VariationArray"];
    NSMutableArray *variationMD = [responseDictionary valueForKey:@"VariationItemArray"];
    NSMutableArray *itemTicketArray = [responseDictionary valueForKey:@"ItemTicketArray"];
    
    //Discount
    NSMutableArray *itemDiscountArray = [responseDictionary valueForKey:@"DiscountMasterArray"];
    NSMutableArray *itemDiscountPrimaryArray = [responseDictionary valueForKey:@"DiscountPrimaryArray"];
    NSMutableArray *itemDiscountSecondaryArray = [responseDictionary valueForKey:@"DiscountSecondaryArray"];

    // Modifier_M and ModifierItem_M
   // NSMutableArray *itemModifierMGroup = [[self modifier_MStaticArray] mutableCopy ];
   // NSMutableArray *itemModifierItemM = [[self modifierItem_MStaticArray] mutableCopy ];
    
    NSArray *arrayItems = [self fetchAllItems:privateManagedObjectContext];
    
    NSInteger itemcount = arrayItems.count+arrayTaxDetail.count+itemSupplierArray.count + itemDiscountArray.count+ itemDiscountPrimaryArray.count+ itemDiscountSecondaryArray.count;
    int totalitemcount=0;
    [self stepProgressnotification:0 message:@"2" progress:totalitemcount];

    for (Item *item in arrayItems) {
        
        if (item.isDelete.integerValue == 1)
        {
            totalitemcount++;
            continue;
        }
         @autoreleasepool {
        
            // Link Insert Variation For Item
            [self insertVariationForItem:item arrayVariationM:variationM arrayVariationMd:variationMD moc:privateManagedObjectContext];
             [self insertItemTicketItem:item ticketArray:itemTicketArray moc:privateManagedObjectContext];
             
             // Size
             [self insertTagsFromTaglist:arrayTag moc:privateManagedObjectContext withItem:item];
             
             totalitemcount++;
             float intPercentage = totalitemcount * 100;
             intPercentage = intPercentage/itemcount;
            // NSLog(@"intPercentage %f",intPercentage);
             [self stepProgressnotification:0 message:@"2" progress:intPercentage];
         }
    }
    
   // [self insertModifier_MAndModifierItem_M:itemModifierMGroup arrayModifireItem_M:itemModifierItemM moc:privateManagedObjectContext];
    
   // [self insertSuppliersFromSupplierlist:itemSupplierArray moc:privateManagedObjectContext];
    
   NSInteger RemainItemtotalitemcount = [self insertSuppliersFromSupplierlist:itemSupplierArray moc:privateManagedObjectContext withCount:itemcount withRemainItemCount:totalitemcount];

    //mmdDiscount
    
//    if (itemDiscountArray.count > 0) {
//        [self deleteAllObjectFromEntityName:@[@"Discount_M",@"Discount_Primary_MD",@"Discount_Secondary_MD"] with:privateManagedObjectContext];
//    }
//    [self isDeletedDiscountData:arrIdList with:privateManagedObjectContext];
    
    RemainItemtotalitemcount = [self insertDiscountFromlist:itemDiscountArray moc:privateManagedObjectContext withCount:itemcount withRemainItemCount:RemainItemtotalitemcount];

    RemainItemtotalitemcount = [self insertDiscountPrimaryArrayFromlist:itemDiscountPrimaryArray moc:privateManagedObjectContext withCount:itemcount withRemainItemCount:RemainItemtotalitemcount];

    RemainItemtotalitemcount = [self insertDiscountSecondaryArrayFromlist:itemDiscountSecondaryArray moc:privateManagedObjectContext withCount:itemcount withRemainItemCount:RemainItemtotalitemcount];
    // Tax
    [self insertTaxlist:arrayTaxDetail moc:privateManagedObjectContext withCount:itemcount withRemainItemCount:RemainItemtotalitemcount];
    // Size
  //  [self insertTagsFromTaglist:arrayTag moc:privateManagedObjectContext withCount:itemcount withRemainItemCount:RemainItemtotalitemcount1];
    
    
    // Weightscale
    NSArray * arrayWeightScale = [self weightScaleArray] ;
    [self insertWightScaleUnit:arrayWeightScale moc:privateManagedObjectContext];
    // unit conversation
    NSArray * arrayUnitConversionScale = [self unitConversionScaleArray] ;
    [self insertUnitConversionScaleUnit:arrayUnitConversionScale moc:privateManagedObjectContext];
    // Configuration
    
    [UpdateManager saveContext:privateManagedObjectContext];
     [self storeCurrentStep:6];
}

-(void)insertPhase4:(NSMutableArray *)vendorItem{
    
    NsmoContext *privateManagedObjectContext = PVTCTX(self.parentManagedObjectContext__Sec);
    
//    // Vendor Array
//    NSMutableArray *vendorItem = [responseDictionary valueForKey:@"Supplier_Hackney_Item_MArray"];
    // Vendor Array
    
    [self insertVendorItemlist:vendorItem moc:privateManagedObjectContext];
    
    [UpdateManager saveContext:privateManagedObjectContext];
     [self storeCurrentStep:8];
}

-(NSArray *)fetchAllBarcodeList:(NsmoContext *)moc
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"ItemBarCode_Md" inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    NSArray *resultSet = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    return resultSet;
}

-(NSArray *)fetchAllItems:(NsmoContext *)moc
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Item" inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    NSArray *resultSet = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    return resultSet;
}

- (void)cleanUpDbForItem:(NSMutableDictionary *)itemDictionary updateResponseDictionary:(NSDictionary *)updateResponseDictionary moc:(NsmoContext *)moc
{
    NSNumber *itemCode = @([[itemDictionary valueForKey:@"ITEMCode"]integerValue]);
    // DELETE BARCODES, PRICING, SUPPLIER, TAX, DISCOUNT, TAG
//    if ([[[itemDictionary valueForKey:@"Qty_Discount"] stringValue]isEqualToString:@"0"])
//    {
//        NSArray *mdArray=[self fetcObjectsWithItemCodeName:@"Item_Discount_MD" key:@"itemCode" value:itemCode moc:moc];
//        for (NSManagedObject *productMd in mdArray)
//        {
//
//            NSArray *md2Array=[self fetcDiscountMD2ObjectsWithItemCodeName:@"Item_Discount_MD2" key:@"discountId" value:@([[[mdArray firstObject]valueForKey:@"iDisNo"]integerValue]) moc:moc];
//            
//            for (NSManagedObject *productMD2 in md2Array)
//            {
//                [UpdateManager deleteFromContext:moc object:productMD2];
//            }
//            [UpdateManager deleteFromContext:moc object:productMd];
//        }
//    }
    
    // DELETE ITEM BARCODE
    NSArray *barcodeArray=[self fetcObjectsWithItemCodeName:@"ItemBarCode_Md" key:@"itemCode" value:itemCode moc:moc];
    for (NSManagedObject *product in barcodeArray)
    {
        [UpdateManager deleteFromContext:moc object:product];
    }
    
    // DELETE PRICING
    NSArray *itemPriceSubArray=[self fetchPriceObjectsWithItemCode:@"Item_Price_MD" key:@"itemcode" value:itemCode moc:moc];
    for (NSManagedObject *product in itemPriceSubArray)
    {
        [UpdateManager deleteFromContext:moc object:product];
    }
    
    // DELETE SUPPLIER
    NSArray *supplierArray=[self fetcObjectsWithItemCodeName:@"ItemSupplier" key:@"itemCode" value:itemCode moc:moc];
    for (NSManagedObject *product in supplierArray)
    {
        [UpdateManager deleteFromContext:moc object:product];
    }
    
    // DELETE TAG
    NSArray *sizeArray=[self fetcObjectsWithName:@"ItemTag" key:@"itemId" value:itemCode moc:moc];
    for (NSManagedObject *product in sizeArray)
    {
        [UpdateManager deleteFromContext:moc object:product];
    }
    
//    // DELETE DISCOUNT
//    NSArray *discountArray=[self fetcObjectsWithItemCodeName:@"Item_Discount_MD" key:@"itemCode" value:itemCode moc:moc];
//    for (NSManagedObject *product in discountArray)
//    {
//        [UpdateManager deleteFromContext:moc object:product];
//    }
//    
//    // DELETE DISCOUNT MD2
//    NSMutableArray *arrayDiscount_Md2 = [updateResponseDictionary valueForKey:@"Item_Discount_MD2Array"];
//    for (NSMutableDictionary *itemDiscountMD2 in arrayDiscount_Md2)
//    {
//        NSArray *taxArray=[self fetcDiscountMD2ObjectsWithItemCodeName:@"Item_Discount_MD2" key:@"discountId" value:@([[itemDiscountMD2 valueForKey:@"DiscountId"]integerValue]) moc:moc];
//        for (NSManagedObject *product in taxArray)
//        {
//            [UpdateManager deleteFromContext:moc object:product];
//        }
//    }
    
    NSArray *mdArray=[self fetcObjectsWithItemCodeName:@"Item_Discount_MD" key:@"itemCode" value:itemCode moc:moc];
    for (NSManagedObject *productMd in mdArray)
    {
        NSArray *md2Array=[self fetcDiscountMD2ObjectsWithItemCodeName:@"Item_Discount_MD2" key:@"discountId" value:@([[mdArray.firstObject valueForKey:@"iDisNo"]integerValue]) moc:moc];
        
        for (NSManagedObject *productMD2 in md2Array)
        {
            [UpdateManager deleteFromContext:moc object:productMD2];
        }
        [UpdateManager deleteFromContext:moc object:productMd];
    }
    
    // DELETE TAX DATA
    NSArray *taxArray=[self fetcObjectsWithName:@"ItemTax" key:@"itemId" value:itemCode moc:moc];
    for (NSManagedObject *product in taxArray)
    {
        [UpdateManager deleteFromContext:moc object:product];
    }
    
    // DELETE VARIATION MD
    Item *anitem = [self fetchItemFromDBWithItemId:itemCode.stringValue shouldCreate:NO moc:moc];
    for (ItemVariation_M *itemVariationM in anitem.itemVariations) {
        NSSet *variationMds = itemVariationM.variationMVariationMds;
        [anitem removeItemVariations:variationMds ];
    }

    // DELETE VARIATION M
    
    NSArray *variationM=[self fetcObjectsWithItemCodeName:@"ItemVariation_M" key:@"itemCode" value:itemCode moc:moc];
    for (NSManagedObject *product in variationM)
    {
        [UpdateManager deleteFromContext:moc object:product];
    }
    
    NSArray *itemTicket = [self fetcObjectsWithItemCodeName:@"ItemTicket_MD" key:@"itemCode" value:itemCode moc:moc];
    for (NSManagedObject *product in itemTicket)
    {
        [UpdateManager deleteFromContext:moc object:product];
    }
    
    }

- (void)asynchronousUpdateObjectsFromResponseDictionary:(NSDictionary*)updateResponseDictionary dispatchQueue:(dispatch_queue_t)dispatchQueue {
    // Create Provate context for this queue
    NsmoContext *privateManagedObjectContext = PVTCTX(self.parentManagedObjectContext__Sec);
    
    NSMutableArray *itemList = [updateResponseDictionary valueForKey:@"ItemArray"];
//    NSLog(@"Item count in update : %ld", (long)itemList.count);
    
    NSMutableArray *itemBarcodeArray = [updateResponseDictionary valueForKey:@"ItemBarcodeArray"];
    NSMutableArray *itemPriceArray = [updateResponseDictionary valueForKey:@"ItemPriceArray"];
    NSMutableArray *arrayDiscount_Md = [updateResponseDictionary valueForKey:@"Item_Discount_MDArray"];
    NSMutableArray *arrayDiscount_Md2 = [updateResponseDictionary valueForKey:@"Item_Discount_MD2Array"];
    NSMutableArray *variationM = [updateResponseDictionary valueForKey:@"VariationArray"];
    NSMutableArray *variationMD =[updateResponseDictionary valueForKey:@"VariationItemArray"];
    // Supplier
    NSMutableArray *itemSupplierArray = [updateResponseDictionary valueForKey:@"Item_SupplierArray"];
    
    // Size
    NSMutableArray *arrayTag = [updateResponseDictionary valueForKey:@"ItemSizeArray"];
    // Tax
    NSMutableArray *arrayTaxDetail = [updateResponseDictionary valueForKey:@"ITMTAX_MDArray"];
    NSMutableArray *itemTicketArray = [updateResponseDictionary valueForKey:@"ItemTicketArray"];

    NSMutableArray *arrayDepartment=[updateResponseDictionary valueForKey:@"Department_MArray"];
    
    NSArray *subDepartment_MArray = [updateResponseDictionary valueForKey:@"SubDepartment_Array"];
    
    NSMutableArray *fuelType_Array = [updateResponseDictionary valueForKey:@"FuelTypeArray"];
    
    NSMutableArray *fuelTypePrice_Array = [updateResponseDictionary valueForKey:@"FuelTypePriceArray"];
    NSMutableArray *customerInfo = [updateResponseDictionary valueForKey:@"CustomerArray"];

    
    [self configureMasterDataWithContex:privateManagedObjectContext andChangedData:updateResponseDictionary];
    
    for (NSMutableDictionary *departmentDictionary in arrayDepartment){
        
        NSNumber *numDeptID = @([[departmentDictionary valueForKey:@"DeptId"]integerValue]) ;
        Department *department = [self fetchDepartmentWithDepartmentId:numDeptID moc:privateManagedObjectContext];
        
        if ([[[departmentDictionary valueForKey:@"IsDeleted"] stringValue]isEqualToString:@"1"])
        {
            [UpdateManager deleteFromContext:privateManagedObjectContext object:department];
        }
        else{

            if(department != nil){
                [department updateDepartmentFromDictionary:departmentDictionary];
            }
            else{
                Department *department = (Department*)[self insertEntityWithName:@"Department" moc:privateManagedObjectContext];
                [department updateDepartmentFromDictionary:departmentDictionary];
            }
            
        }
    
    }
    
    for (NSMutableDictionary *subdepartmentDictionary in subDepartment_MArray){
        
        NSNumber *numsubDeptID = @([[subdepartmentDictionary valueForKey:@"BrnSubDeptID"]integerValue]) ;
        SubDepartment *subDepartment=[self fetchSubDepartmentWithSubDepartmentId:numsubDeptID moc:privateManagedObjectContext];
        
        if ([[[subdepartmentDictionary valueForKey:@"IsDeleted"] stringValue]isEqualToString:@"1"])
        {
            [UpdateManager deleteFromContext:privateManagedObjectContext object:subDepartment];
        }
        else{
            
            if(subDepartment != nil){
                [subDepartment updateSubDepartmentDictionary:subdepartmentDictionary];
                
            }
            else{
                SubDepartment *subDepartment = (SubDepartment*)[self insertEntityWithName:@"SubDepartment" moc:privateManagedObjectContext];
                [subDepartment updateSubDepartmentDictionary:subdepartmentDictionary];
            }
        }
    }
    
    for (NSMutableDictionary *itemDictionary in itemList)
    {
        Item *item = (Item*)[self fetchEntityWithName:@"Item" key:@"itemCode" value:@([[itemDictionary valueForKey:@"ITEMCode"] integerValue]) shouldCreate:YES moc:privateManagedObjectContext];
        if ([[[itemDictionary valueForKey:@"isDeleted"] stringValue]isEqualToString:@"1"])
        {
            [UpdateManager deleteFromContext:privateManagedObjectContext object:item];
        }
        else
        {
            [item updateItemFromDictionary:itemDictionary];
            
            Department *department=[self fetchDepartmentWithDepartmentId:item.deptId moc:privateManagedObjectContext];
            [item linkToDepartment:department];

            SubDepartment *subDepartment=[self fetchSubDepartmentWithSubDepartmentId:item.subDeptId moc:privateManagedObjectContext];
            [item linkToSubDepartment:subDepartment];

            NSNumber *mixmatchId = 0;
            if (item.cate_MixMatchFlg.boolValue==TRUE)
            {
                mixmatchId = item.cate_MixMatchId;
            }
            else
            {
                mixmatchId = item.mixMatchId;
            }
            Mix_MatchDetail *mix_MatchDetail = [self fetchMixMatchWithItemMixMatchId:mixmatchId moc:privateManagedObjectContext];
            [item linkToMixMatch:mix_MatchDetail];
            
            GroupMaster *groupMaster = [self fetchGroupWithGroupId:item.catId moc:privateManagedObjectContext];
            [item linkToGroup:groupMaster];
        }
        
        [self cleanUpDbForItem:itemDictionary updateResponseDictionary:updateResponseDictionary moc:privateManagedObjectContext];
        
        // INSERT THE ITEM'S SUPPLIER, TAX, DISCOUNT, TAG, PRICING, BARCODES IF ITEM IS NOT DELETED FROM SERVER
        if ([[[itemDictionary valueForKey:@"isDeleted"] stringValue]isEqualToString:@"0"])
        {
           
            // Item Barcode
            NSArray *barcode_mdList = [self insertBarcodeForItem:item barcodeArray:itemBarcodeArray moc:privateManagedObjectContext];
            
            // Item PriceArray
            NSArray *priceMD_List =  [self insertPriceForItem:item barcodeArray:itemPriceArray moc:privateManagedObjectContext];
            
            // price Barcode Linking........
            [self linkPriceBarcodewith:barcode_mdList withPriceMdList:priceMD_List];
            
            // Link Item_Discount_MD
            [self insertDiscountForItem:item arrayDiscount_Md:arrayDiscount_Md arrayDiscount_Md2:arrayDiscount_Md2 moc:privateManagedObjectContext];
            
            NSPredicate *suppPredicate = [NSPredicate predicateWithFormat:@"ITEMCODE == %@", item.itemCode];
            NSArray *suppierArray = [itemSupplierArray filteredArrayUsingPredicate:suppPredicate];
            [self insertSuppliersFromSupplierlist:suppierArray moc:privateManagedObjectContext];
            
            
            [self updateTagsFromTaglist:arrayTag moc:privateManagedObjectContext withItem:item];
            
            NSPredicate *taxPredicate = [NSPredicate predicateWithFormat:@"ITEMCode == %@", item.itemCode];
            NSArray *fetchTaxArray = [arrayTaxDetail filteredArrayUsingPredicate:taxPredicate];
            [self insertTaxlist:fetchTaxArray moc:privateManagedObjectContext];
            
            // Insert & Link  Variation For Item
            [self insertVariationForItem:item arrayVariationM:variationM arrayVariationMd:variationMD moc:privateManagedObjectContext];
            
            [self insertItemTicketItem:item ticketArray:itemTicketArray moc:privateManagedObjectContext];
        }
    }
    
    //MMD in LiveUpdate
    [self configureMMDDataWithContex:privateManagedObjectContext andChangedData:updateResponseDictionary];
    //Pump Carts
    
    if([self checkGasPumpisActive]){
      //  [self insertOrUpdatePumpCartChangedData:updateResponseDictionary];
        [self insertOrUpdatePumpCartInvoiceChangedData:updateResponseDictionary];
        
//        if (![RmsDbController sharedRmsDbController].rapidPetroPos) {
//            [RmsDbController sharedRmsDbController].rapidPetroPos = [RapidPetroPOS createInstance];
//        }
//        NSManagedObjectContext *privateGasManagedObjectContext = [RmsDbController sharedRmsDbController].rapidPetroPos.petroMOC;
//        
//        [self updateMasterFuelTypeInLocalDatabase:fuelType_Array moc:privateGasManagedObjectContext];
//        
//        [self updateMasterFuelPricingLivUpdate:fuelTypePrice_Array moc:privateGasManagedObjectContext];
//        
//        if(fuelTypePrice_Array.count > 0){
//            if([RmsDbController sharedRmsDbController].fuelCountList){
//                [[RmsDbController sharedRmsDbController].fuelCountList resetDisplayContextReloadData];
//            }
//        }
        
    }
    
    [self updateCustomerInfo:customerInfo moc:privateManagedObjectContext];
    [UpdateManager saveContext:privateManagedObjectContext];

    
    NSString *strDate = [updateResponseDictionary valueForKey:@"utcdatetimeVal"];
    if (strDate.length > 0 && strDate!= nil) {
        NSLog(@"Update date from live update = %@", strDate);
        [self insertItemUpdateDate:strDate];
    }
    [UpdateManager saveContext:privateManagedObjectContext];
}

-(BOOL)checkGasPumpisActive{
    NSPredicate *deactive = [NSPredicate predicateWithFormat:@"MacAdd == %@ AND IsRelease == 0", ([RmsDbController sharedRmsDbController].globalDict)[@"DeviceId"]];
    
    NSArray *activeModulesArray = [[[RmsDbController sharedRmsDbController].appsActvDeactvSettingarray filteredArrayUsingPredicate:deactive] mutableCopy];
    
    return [self isRcrGasActive:activeModulesArray];
}
-(BOOL)isRcrGasActive:(NSArray *)array
{
    BOOL isRcrActive = FALSE;
    NSPredicate *rcrActive = [NSPredicate predicateWithFormat:@"ModuleCode == %@",@"RCRGAS"];
    NSArray *rcrArray = [array filteredArrayUsingPredicate:rcrActive];
    if (rcrArray.count > 0) {
        isRcrActive = TRUE;
    }
    return isRcrActive;
}

-(void)configureMasterDataWithContex:(NsmoContext *)privateManagedObjectContext andChangedData:(NSDictionary*)updateResponseDictionary{
    // For Supplier Company
    NSMutableArray *SupplierCompanyArray=[updateResponseDictionary valueForKey:@"SupplierCompany_Array"];
    [self updateSupplierCompanylist:SupplierCompanyArray moc:privateManagedObjectContext];
    
    // For Company Representative
    NSMutableArray *SupplierRepresentativeArray=[updateResponseDictionary valueForKey:@"supplierArray"];
    [self updateSupplierRepresentativelist:SupplierRepresentativeArray moc:privateManagedObjectContext];
    
    // For Tax
     NSMutableArray *taxMasterList=[updateResponseDictionary valueForKey:@"TAX_MArray"];
    [self updateTaxMaster:taxMasterList moc:privateManagedObjectContext];
    
    
    // Dept Tax
    NSMutableArray *arrayDepartmentTax=[updateResponseDictionary valueForKey:@"DeptTax_MArray"];
    NSArray * department = [arrayDepartmentTax valueForKey:@"DeptId"];
    NSSet * uniqeDeptId = [NSSet setWithArray:department];
    
    NSArray * arrDepartmentListToDelete = [self fetchAllEntityWithName:@"DepartmentTax" key:@"deptId" value:uniqeDeptId.allObjects moc:privateManagedObjectContext];
    for (DepartmentTax *depTax in arrDepartmentListToDelete)
    {
        [UpdateManager deleteFromContext:privateManagedObjectContext object:depTax];
    }
    [self insertDepartmentTaxMaster:arrayDepartmentTax moc:privateManagedObjectContext];
    
    
    // For Tax Payment
    NSMutableArray *arrayPayment=[updateResponseDictionary valueForKey:@"Payment_MArray"];
    [self updatePaymentMaster:arrayPayment moc:privateManagedObjectContext];
    
    // For SIZE (tag)
    NSMutableArray *arraysize=[updateResponseDictionary valueForKey:@"SIZE_MArray"];
    [self updateSizeMaster:arraysize moc:privateManagedObjectContext];
    
    // For group
    NSMutableArray *arrayGroupMaster=[updateResponseDictionary valueForKey:@"GroupMaster_Array"];
    [self updateGroupMaster:arrayGroupMaster moc:privateManagedObjectContext];
}

-(NSString *)dateStringFromJsonDate:(NSString *)string
{
    NSRange range = NSMakeRange(6, string.length - 8);
    NSString *substring = [string substringWithRange:range];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSNumber *milliseconds = [formatter numberFromString:substring];
    NSTimeInterval seconds = milliseconds.longLongValue / 1000;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:seconds];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM/dd/yyyy HH:mm:ss";
    return [dateFormatter stringFromDate:date];
}

// Modifier_M
- (NSArray *)modifier_MStaticArray
{
    NSArray *modifier_MArray =
    @[@{
          @"BrnModifierId":@(1),
          @"Name":@"Pizza",
          @"BranchId":@(1),
          @"CreatedBy":@(1),
          @"IsDeleted":@(0),
          @"CreatedDate":@"",
          },
      @{
          @"BrnModifierId":@(2),
          @"Name":@"Soup",
          @"BranchId":@(1),
          @"CreatedBy":@(1),
          @"IsDeleted":@(0),
          @"CreatedDate":@"",
          }];
    return modifier_MArray;
}

// ModifierItem_M
- (NSArray *)modifierItem_MStaticArray
{
    NSArray *modifierItem_MArray =
    @[@{
          @"BrnModifierItemId":@(1),
          @"BranchId":@(1),
          @"ModifierId":@(1),
          @"ModifireItem":@"Cheess",
          @"Price":@(2.49),
          @"CalcInPOS":@(1),
		  @"CreatedBy":@(1),
          @"IsDeleted":@(0),
          @"CreatedDate":@"",
          },
      @{
          @"BrnModifierItemId":@(2),
          @"BranchId":@(1),
          @"ModifierId":@(1),
          @"ModifireItem":@"Onion",
          @"Price":@(1.99),
          @"CalcInPOS":@(1),
		  @"CreatedBy":@(1),
          @"IsDeleted":@(0),
          @"CreatedDate":@"",
          },
      @{
          @"BrnModifierItemId":@(3),
          @"BranchId":@(1),
          @"ModifierId":@(2),
          @"ModifireItem":@"Tomato",
          @"Price":@(1.79),
          @"CalcInPOS":@(1),
		  @"CreatedBy":@(1),
          @"IsDeleted":@(0),
          @"CreatedDate":@"",
          },
      @{
          @"BrnModifierItemId":@(4),
          @"BranchId":@(1),
          @"ModifierId":@(2),
          @"ModifireItem":@"Sweet Corn",
          @"Price":@(2.79),
          @"CalcInPOS":@(1),
		  @"CreatedBy":@(1),
          @"IsDeleted":@(0),
          @"CreatedDate":@"",
          }
      ];
    return modifierItem_MArray;
}

-(void)linkItemVariationMToVariationMaster:(Variation_Master *)variationMaster moc:(NsmoContext *)moc
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ItemVariation_M" inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"variationMasterId == %@", variationMaster.vid];
    fetchRequest.predicate = predicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    
    for (ItemVariation_M *itemVariation_M in resultSet)
    {
        [variationMaster addMasterVariationMsObject:itemVariation_M];
        itemVariation_M.variationMMaster = variationMaster;
    }
}

- (void)asynchronousLinkItemToDepartmentFromResponseDictionary:(NSDictionary*)updateResponseDictionary dispatchQueue:(dispatch_queue_t)dispatchQueue {
    // Create Provate context for this queue
    NsmoContext *privateManagedObjectContext = PVTCTX(self.parentManagedObjectContext__Sec);
    
    NSArray *responseItemArray = [updateResponseDictionary valueForKey:@"ItemArray"];
    
    [self linkItemWithItemDepartment:responseItemArray moc:privateManagedObjectContext];
    
    [UpdateManager saveContext:privateManagedObjectContext];
}

- (void)asynchronousUpdateObjectsFromMasterResponseDictionary:(NSDictionary*)masterResponseDictionary dispatchQueue:(dispatch_queue_t)dispatchQueue {
    
    NsmoContext *privateManagedObjectContext = PVTCTX(self.parentManagedObjectContext__Sec);
    
    NSMutableArray *taxMasterList=[masterResponseDictionary valueForKey:@"TAX_MArray"];
    NSMutableArray *SupplierArray=[masterResponseDictionary valueForKey:@"supplierArray"];
    NSMutableArray *arraysize=[masterResponseDictionary valueForKey:@"SIZE_MArray"];
    NSMutableArray *arrayDepartment=[masterResponseDictionary valueForKey:@"Department_MArray"];
    NSArray *subDepartment_MArray = [masterResponseDictionary valueForKey:@"SubDepartment_Array"];
    NSMutableArray *arrayDepartmentTax=[masterResponseDictionary valueForKey:@"DeptTax_MArray"];
    NSMutableArray *arrayPaymentData=[masterResponseDictionary valueForKey:@"Payment_MArray"];
    NSMutableArray *groupMasterList=[masterResponseDictionary valueForKey:@"GroupMaster_Array"];
    NSMutableArray *mixMatchMasterList=[masterResponseDictionary valueForKey:@"Mix_MatchDisc_Array"];
    NSMutableArray *tipsMasterList = [masterResponseDictionary valueForKey:@"TipPercentage_Array"];
    NSMutableArray *variationMasterList = [masterResponseDictionary valueForKey:@"Variation_Array"];
    NSMutableArray *configurationArray = [masterResponseDictionary valueForKey:@"Configuration_Array"];
    NSMutableArray *customerInfo = [masterResponseDictionary valueForKey:@"Customer_Array"];

    if (taxMasterList.count >0) {
        
        for (NSMutableDictionary *taxMasterDictionary in taxMasterList)
        {
            NSArray *taxArray=[self taXFetch:@"TaxMaster" key:@"taxId" value:@([[taxMasterDictionary valueForKey:@"TaxId"] integerValue]) moc:privateManagedObjectContext];
            for (NSManagedObject *product in taxArray)
            {
                [UpdateManager deleteFromContext:privateManagedObjectContext object:product];
            }
            [UpdateManager saveContext:privateManagedObjectContext];
        }
        [self insertTaxMaster:taxMasterList moc:privateManagedObjectContext];
    }
    if (SupplierArray.count>0) {
        for (NSMutableDictionary *supplierDictionary in SupplierArray)
        {
            NSArray *taxArray=[self supplierFetch:@"SupplierMaster" key:@"brnSupplierId" value:@([[supplierDictionary valueForKey:@"BrnSupplierId"] integerValue]) moc:privateManagedObjectContext];
            for (NSManagedObject *product in taxArray)
            {
                [UpdateManager deleteFromContext:privateManagedObjectContext object:product];
            }
            [UpdateManager saveContext:privateManagedObjectContext];
        }
        [self insertSupplierMaster:SupplierArray moc:privateManagedObjectContext];
    }
    if (arraysize.count>0) {
        
        for (NSMutableDictionary *sizeDictionary in arraysize)
        {
            NSArray *taxArray=[self SizeFetch:@"SizeMaster" key:@"sizeId" value:@([[sizeDictionary valueForKey:@"SizeId"] integerValue]) moc:privateManagedObjectContext];
            for (NSManagedObject *product in taxArray)
            {
                [UpdateManager deleteFromContext:privateManagedObjectContext object:product];
            }
            [UpdateManager saveContext:privateManagedObjectContext];
        }
        [self insertSizeMaster:arraysize moc:privateManagedObjectContext];
    }

    if (customerInfo.count >0) {
        
        for (NSMutableDictionary *customerDictionary in customerInfo)
        {
            NSArray *custArry=[self customerFetch:@"Customer" key:@"custId" value:@([[customerDictionary valueForKey:@"CustId"] integerValue]) moc:privateManagedObjectContext];
            for (NSManagedObject *product in custArry)
            {
                [UpdateManager deleteFromContext:privateManagedObjectContext object:product];
            }
            [UpdateManager saveContext:privateManagedObjectContext];
        }
        [self insertCustomer:customerInfo moc:privateManagedObjectContext];
    }
    
    if (arrayDepartment.count>0) {
        
        for (NSMutableDictionary *departmentDictionary in arrayDepartment)
        {
            NSArray *taxArray=[self DepartmentFetch:@"Department" key:@"deptId" value:@([[departmentDictionary valueForKey:@"DeptId"] integerValue]) moc:privateManagedObjectContext];
            for (NSManagedObject *product in taxArray)
            {
                [UpdateManager deleteFromContext:privateManagedObjectContext object:product];
            }
            [UpdateManager saveContext:privateManagedObjectContext];
        }
        [self insertDepartmentFromDepartmentlist:arrayDepartment moc:privateManagedObjectContext];
        
        NSMutableArray *arrayKitechSetting = [[NSUserDefaults standardUserDefaults]valueForKey:@"KitchenPrinter_Setting"];
        
        for(NSMutableDictionary *dictTemp in  arrayKitechSetting){
            
            NSMutableDictionary *dictPrinter = [[NSMutableDictionary alloc]init];
            dictPrinter[@"printer_ip"] = [dictTemp valueForKey:@"printer_ip"];
            dictPrinter[@"printer_Name"] = [dictTemp valueForKey:@"printer_Name"];
            
            KitchenPrinter *kitchenPrinter = [self getPrinter:[dictTemp valueForKey:@"printer_ip"] withMoc:privateManagedObjectContext];
            
            NSMutableArray *selectedDeptArray = [dictTemp valueForKey:@""];
            
            if(kitchenPrinter){
            
                [self updatePrinterDictionary:dictPrinter withDepartment:selectedDeptArray withMoc:privateManagedObjectContext];
            }
            else{
                [self addPrinterDictionary:dictPrinter withDepartment:selectedDeptArray];
            }
            
        }
    }
    // Delete SubDepartment
    for (NSMutableDictionary *subDepartmentDictionary in subDepartment_MArray)
    {
        NSArray *deptArray=[self SubDepartmentFetch:@"SubDepartment" key:@"brnSubDeptID" value:@([[subDepartmentDictionary valueForKey:@"BrnSubDeptID"] integerValue]) moc:privateManagedObjectContext];
        
        for (NSManagedObject *product in deptArray)
        {
            [UpdateManager deleteFromContext:privateManagedObjectContext object:product];
        }
        [UpdateManager saveContext:privateManagedObjectContext];
    }
    [UpdateManager saveContext:privateManagedObjectContext];
    
    
    [self insertSubDepartmentFromSubDepartmentlist:subDepartment_MArray moc:privateManagedObjectContext];

    if (arrayDepartmentTax.count>0) {
        
        for (NSMutableDictionary *departmentTaxDictionary in arrayDepartmentTax)
        {
            NSArray *taxArray=[self DepartmentFetch:@"DepartmentTax" key:@"deptId" value:@([[departmentTaxDictionary valueForKey:@"DeptId"] integerValue]) moc:privateManagedObjectContext];
            for (NSManagedObject *product in taxArray)
            {
                [UpdateManager deleteFromContext:privateManagedObjectContext object:product];
            }
            [UpdateManager saveContext:privateManagedObjectContext];
        }
        [self insertDepartmentTaxMaster:arrayDepartmentTax moc:privateManagedObjectContext];
        
    }
    if (arrayPaymentData.count>0) {
        
        for (NSMutableDictionary *paymentDictionary in arrayPaymentData)
        {
            NSArray *taxArray=[self PaymentFetch:@"TenderPay" key:@"payId" value:@([[paymentDictionary valueForKey:@"PayId"] integerValue]) moc:privateManagedObjectContext];
            for (NSManagedObject *product in taxArray)
            {
                [UpdateManager deleteFromContext:privateManagedObjectContext object:product];
            }
            [UpdateManager saveContext:privateManagedObjectContext];
        }
        [self insertPaymentMaster:arrayPaymentData moc:privateManagedObjectContext];
    }
    
    if (groupMasterList.count >0) {
        
        for (NSMutableDictionary *groupMasterDict in groupMasterList)
        {
            NSArray *taxArray=[self groupFetch:@"GroupMaster" key:@"groupId" value:@([[groupMasterDict valueForKey:@"GroupId"] integerValue]) moc:privateManagedObjectContext];
            for (NSManagedObject *product in taxArray)
            {
                [UpdateManager deleteFromContext:privateManagedObjectContext object:product];
            }
            [UpdateManager saveContext:privateManagedObjectContext];
        }
        [self insertGroupMaster:groupMasterList moc:privateManagedObjectContext];
    }
   
    if (mixMatchMasterList.count >0) {
        
        for (NSMutableDictionary *mixmatchDictionary in mixMatchMasterList)
        {
            NSArray *mixMatchArray=[self mixmatchFetch:@"Mix_MatchDetail" key:@"mixMatchId" value:@([[mixmatchDictionary valueForKey:@"MixMatchId"] integerValue]) moc:privateManagedObjectContext];
            for (NSManagedObject *product in mixMatchArray)
            {
                [UpdateManager deleteFromContext:privateManagedObjectContext object:product];
            }
            [UpdateManager saveContext:privateManagedObjectContext];
        }
        [self insertMixMatchMaster:mixMatchMasterList moc:privateManagedObjectContext];
    }
    
    if (tipsMasterList.count >0) {
        
        for (NSMutableDictionary *tipsDictionary in tipsMasterList)
        {
            NSArray *tipArray=[self tipPercentageFetch:@"TipPercentageMaster" key:@"brnTipPercentageId" value:@([[tipsDictionary valueForKey:@"BrnTipPercentageId"] integerValue]) moc:privateManagedObjectContext];
            for (NSManagedObject *tip in tipArray)
            {
                [UpdateManager deleteFromContext:privateManagedObjectContext object:tip];
            }
            [UpdateManager saveContext:privateManagedObjectContext];
        }
        [self insertTipsMaster:tipsMasterList moc:privateManagedObjectContext];
    }
    
    if (variationMasterList.count >0) {
        
        for (NSMutableDictionary *variationDictionary in variationMasterList)
        {
            NSArray *tipArray=[self variationFetch:@"Variation_Master" key:@"vid" value:@([[variationDictionary valueForKey:@"vid"] integerValue]) moc:privateManagedObjectContext];
            for (NSManagedObject *variation in tipArray)
            {
                [UpdateManager deleteFromContext:privateManagedObjectContext object:variation];
            }
            [UpdateManager saveContext:privateManagedObjectContext];
        }
        [self insertVariationMasterlist:variationMasterList moc:privateManagedObjectContext];
    }
    // Configuration
    Configuration *configuration = [self insertConfigurationMoc:privateManagedObjectContext];
   
    if(configurationArray.count > 0)
    {
        NSNumber *tips = [configurationArray.firstObject valueForKey:@"Tips" ];
        configuration.tips = tips;
        if (tips.boolValue == FALSE)
        {
            configuration.localTipsSetting = tips;
        }
        
        NSNumber *ebt = [configurationArray.firstObject valueForKey:@"EBT" ];
        configuration.ebt = ebt;
        configuration.localEbt = ebt;

        
        NSNumber *ticket = [configurationArray.firstObject valueForKey:@"Ticket" ];
        configuration.ticket = ticket;
        configuration.localTicketSetting = ticket;
        
      //  NSNumber *customerLoyalty = [configurationArray.firstObject valueForKey:@"CustomerLoyalty" ];
        configuration.customerLoyalty = @(1);
        configuration.localCustomerLoyalty = @(1);
        
        NSNumber *isHouseCharge = [configurationArray.firstObject valueForKey:@"HouseChagre"];
        configuration.houseCharge = isHouseCharge;
       
        NSNumber *isSubDepartment = [configurationArray.firstObject valueForKey:@"IsSubDepartment"];
        configuration.subDepartment = isSubDepartment;
    }
    [UpdateManager saveContext:privateManagedObjectContext];
}

-(NSArray *)weightScaleArray
{
    NSMutableArray *weightScaleArray = [[NSMutableArray alloc]init];
    
    NSMutableDictionary *gramdictionary = [[NSMutableDictionary alloc]init];
    gramdictionary[@"weightScaleType"] = @"weight";
    gramdictionary[@"unitType"] = @"gr";
    gramdictionary[@"unitScale"] = @"small";
    [weightScaleArray addObject:gramdictionary];
    
    
    NSMutableDictionary *kiloGramdictionary = [[NSMutableDictionary alloc]init];
    kiloGramdictionary[@"weightScaleType"] = @"weight";
    kiloGramdictionary[@"unitType"] = @"kg";
    kiloGramdictionary[@"unitScale"] = @"large";
    [weightScaleArray addObject:kiloGramdictionary];

    
    NSMutableDictionary *poundDictionary = [[NSMutableDictionary alloc]init];
    poundDictionary[@"weightScaleType"] = @"weight";
    poundDictionary[@"unitType"] = @"lb";
    poundDictionary[@"unitScale"] = @"large";
    [weightScaleArray addObject:poundDictionary];
    
    
    NSMutableDictionary *ozDictionary = [[NSMutableDictionary alloc]init];
    ozDictionary[@"weightScaleType"] = @"weight";
    ozDictionary[@"unitType"] = @"oz";
    ozDictionary[@"unitScale"] = @"small";
    [weightScaleArray addObject:ozDictionary];
    
    
    NSMutableDictionary *ltrDictionary = [[NSMutableDictionary alloc]init];
    ltrDictionary[@"weightScaleType"] = @"liquid";
    ltrDictionary[@"unitType"] = @"ltr";
    ltrDictionary[@"unitScale"] = @"large";
    [weightScaleArray addObject:ltrDictionary];
    

    NSMutableDictionary *mlDictionary = [[NSMutableDictionary alloc]init];
    mlDictionary[@"weightScaleType"] = @"liquid";
    mlDictionary[@"unitType"] = @"ml";
    mlDictionary[@"unitScale"] = @"small";
    [weightScaleArray addObject:mlDictionary];
    
    
    NSMutableDictionary *gallonDictionary = [[NSMutableDictionary alloc]init];
    gallonDictionary[@"weightScaleType"] = @"liquid";
    gallonDictionary[@"unitType"] = @"gal";
    gallonDictionary[@"unitScale"] = @"Medium";
    [weightScaleArray addObject:gallonDictionary];
  
    
    NSMutableDictionary *bblDictionary = [[NSMutableDictionary alloc]init];
    bblDictionary[@"weightScaleType"] = @"liquid";
    bblDictionary[@"unitType"] = @"bbl";
    bblDictionary[@"unitScale"] = @"large";
    [weightScaleArray addObject:bblDictionary];
    
    
    return weightScaleArray;
}


-(NSArray *)unitConversionScaleArray
{
    NSMutableArray *unitScaleArray = [[NSMutableArray alloc]init];
    
    NSMutableDictionary *gramToKgdictionary = [[NSMutableDictionary alloc]init];
    gramToKgdictionary[@"fromUnitType"] = @"gr";
    gramToKgdictionary[@"toUnitType"] = @"kg";
    gramToKgdictionary[@"factor"] = @(0.001);
    [unitScaleArray addObject:gramToKgdictionary];
    
    
    NSMutableDictionary *gramToPoundDictionary = [[NSMutableDictionary alloc]init];
    gramToPoundDictionary[@"fromUnitType"] = @"gr";
    gramToPoundDictionary[@"toUnitType"] = @"lb";
    gramToPoundDictionary[@"factor"] = @(0.0022046244);
    [unitScaleArray addObject:gramToPoundDictionary];
    
    
    NSMutableDictionary *gramToOzDictionary = [[NSMutableDictionary alloc]init];
    gramToOzDictionary[@"fromUnitType"] = @"gr";
    gramToOzDictionary[@"toUnitType"] = @"oz";
    gramToOzDictionary[@"factor"] = @(0.0352739907);
    [unitScaleArray addObject:gramToOzDictionary];
    
    
    
    
    NSMutableDictionary *kgToGramDictionary = [[NSMutableDictionary alloc]init];
    kgToGramDictionary[@"fromUnitType"] = @"kg";
    kgToGramDictionary[@"toUnitType"] = @"gr";
    kgToGramDictionary[@"factor"] = @(1000.00);
    [unitScaleArray addObject:kgToGramDictionary];
    
    
    NSMutableDictionary *kgToPoundDictionary = [[NSMutableDictionary alloc]init];
    kgToPoundDictionary[@"fromUnitType"] = @"kg";
    kgToPoundDictionary[@"toUnitType"] = @"lb";
    kgToPoundDictionary[@"factor"] = @(2.2046244202);
    [unitScaleArray addObject:kgToPoundDictionary];

    
    NSMutableDictionary *kgToOzDictionary = [[NSMutableDictionary alloc]init];
    kgToOzDictionary[@"fromUnitType"] = @"kg";
    kgToOzDictionary[@"toUnitType"] = @"oz";
    kgToOzDictionary[@"factor"] = @(35.273990723);
    [unitScaleArray addObject:kgToOzDictionary];
    
    
    
    NSMutableDictionary *poundToGramDictionary = [[NSMutableDictionary alloc]init];
    poundToGramDictionary[@"fromUnitType"] = @"lb";
    poundToGramDictionary[@"toUnitType"] = @"gr";
    poundToGramDictionary[@"factor"] = @(453.592);
    [unitScaleArray addObject:poundToGramDictionary];
    
    
    NSMutableDictionary *poundToKgDictionary = [[NSMutableDictionary alloc]init];
    poundToKgDictionary[@"fromUnitType"] = @"lb";
    poundToKgDictionary[@"toUnitType"] = @"kg";
    poundToKgDictionary[@"factor"] = @(0.453592);
    [unitScaleArray addObject:poundToKgDictionary];
    
    
    NSMutableDictionary *poundToOzDictionary = [[NSMutableDictionary alloc]init];
    poundToOzDictionary[@"fromUnitType"] = @"lb";
    poundToOzDictionary[@"toUnitType"] = @"oz";
    poundToOzDictionary[@"factor"] = @(16);
    [unitScaleArray addObject:poundToOzDictionary];

    
    NSMutableDictionary *ozToGramDictionary = [[NSMutableDictionary alloc]init];
    ozToGramDictionary[@"fromUnitType"] = @"oz";
    ozToGramDictionary[@"toUnitType"] = @"gr";
    ozToGramDictionary[@"factor"] = @(28.3495);
    [unitScaleArray addObject:ozToGramDictionary];
    
    
    NSMutableDictionary *ozToKgDictionary = [[NSMutableDictionary alloc]init];
    ozToKgDictionary[@"fromUnitType"] = @"oz";
    ozToKgDictionary[@"toUnitType"] = @"kg";
    ozToKgDictionary[@"factor"] = @(0.0283495);
    [unitScaleArray addObject:ozToKgDictionary];
    
    
    NSMutableDictionary *ozToPoundDictionary = [[NSMutableDictionary alloc]init];
    ozToPoundDictionary[@"fromUnitType"] = @"oz";
    ozToPoundDictionary[@"toUnitType"] = @"lb";
    ozToPoundDictionary[@"factor"] = @(0.0625);
    [unitScaleArray addObject:ozToPoundDictionary];


    
    
    return unitScaleArray;
}


- (NSArray*)PaymentFetch:(NSString*)entityName key:(NSString*)key value:(id)value moc:(NsmoContext*)moc
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"payId==%@",value];
    fetchRequest.predicate = predicate;
    NSArray *arryTemp = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    
    //NSManagedObject *anObject = nil;
    if (arryTemp.count == 0)
    {
    }
    else
    {
        //anObject = [arryTemp firstObject];
    }
    return arryTemp;
}
- (LastInvoiceData *)fetchLastInvoiceRecordFromTable:(NsmoContext *)privateManagedObjectContext
{
    LastInvoiceData *lastInvoiceData;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"LastInvoiceData" inManagedObjectContext:self.parentManagedObjectContext__Sec];
    fetchRequest.entity = entity;
    NSArray *arryTemp = [UpdateManager executeForContext:self.parentManagedObjectContext__Sec FetchRequest:fetchRequest];
    if (arryTemp.count == 0)
    {
        lastInvoiceData = (LastInvoiceData *)[self insertEntityWithName:@"LastInvoiceData" moc:privateManagedObjectContext];
    }
    else
    {
        lastInvoiceData = arryTemp.firstObject;
    }
    return lastInvoiceData;
}

-(void)insertLastinvoiceDataFromDictionary :(NSDictionary *)invoiceDictionary withSubDictionary:(NSDictionary *)subDictionary
{
    /// test code change........
    NsmoContext *privateManagedObjectContext = PVTCTX(self.parentManagedObjectContext__Sec);
    
    // Update Invoice Number in Configuration
    Configuration *configuration = [UpdateManager getConfigurationMoc:privateManagedObjectContext ];
    
    LastInvoiceData *lastInvoiceData;
    
    NSString *keyChainInvoiceNo = [Keychain getStringForKey:@"tenderInvoiceNo"];
    
    
    lastInvoiceData = [self fetchLastInvoiceRecordFromTable:privateManagedObjectContext];
    
    // set value in InvoiceData_T table
    
    lastInvoiceData.branchId = @([[subDictionary valueForKey:@"branchId"] integerValue]);
    lastInvoiceData.regiterid = @([[subDictionary valueForKey:@"registerId"] integerValue]);
    lastInvoiceData.zId = @([[subDictionary valueForKey:@"zId"] integerValue]);
    lastInvoiceData.collectAmount = @([[subDictionary valueForKey:@"collectAmount"] floatValue]);
    lastInvoiceData.changeDue = @([[subDictionary valueForKey:@"changeDue"] floatValue]);
    lastInvoiceData.tenderAmount = @([[subDictionary valueForKey:@"tenderAmount"] floatValue]);
    lastInvoiceData.paymentType = [subDictionary valueForKey:@"paymentType"];
    // Update regInvoiceNo
    lastInvoiceData.regInvoiceNo = [NSString stringWithFormat:@"%@%@",configuration.regPrefixNo,keyChainInvoiceNo ];
    
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *strInvoiceDate = [formatter stringFromDate:date];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    dateFormatter.timeZone = sourceTimeZone;
    lastInvoiceData.invoiceDate = [dateFormatter dateFromString:strInvoiceDate];
    
    [lastInvoiceData updateInvoiceFromDictionary:invoiceDictionary];
    
    // Save data now
    [UpdateManager saveContext:privateManagedObjectContext];
    
}
- (InvoiceData_T *)insertTenderPaymentDataFromDictionary:(NSDictionary*)responseDictionary withContext:(NsmoContext*)privateManagedObjectContext {
    // branchId registerId zId msgCode message
    //NsmoContext *privateManagedObjectContext = PVTCTX(self.parentManagedObjectContext__Sec);
   // NsmoContext *privateManagedObjectContext = self.parentManagedObjectContext__Sec;

    // Update Invoice Number in Configuration
    Configuration *configuration = [UpdateManager getConfigurationMoc:privateManagedObjectContext ];
    //    [configuration incrementInvoiceNo];
    //    [UpdateManager saveContext:privateManagedObjectContext];
    
    NSString *keyChainInvoiceNo = [Keychain getStringForKey:@"tenderInvoiceNo"];
    /*   NSInteger number = [keyChainInvoiceNo integerValue];
     number++;
     NSString *updatedTenderInvoiceNo = [NSString stringWithFormat: @"%d", (int)number];
     [Keychain saveString:updatedTenderInvoiceNo forKey:@"tenderInvoiceNo"];*/
    
    // set value in InvoiceData_T table
    InvoiceData_T *invoiceData = (InvoiceData_T *)[self insertEntityWithName:@"InvoiceData_T" moc:privateManagedObjectContext];
    
    invoiceData.branchId = @([[responseDictionary valueForKey:@"branchId"] integerValue]);
    invoiceData.regiterid = @([[responseDictionary valueForKey:@"registerId"] integerValue]);
    invoiceData.zId = @([[responseDictionary valueForKey:@"zId"] integerValue]);
    invoiceData.msgCode = @([[responseDictionary valueForKey:@"msgCode"] integerValue]);
    invoiceData.message = [responseDictionary valueForKey:@"message"];
    invoiceData.userId = @([[responseDictionary valueForKey:@"UserId"] integerValue]);

    // Update regInvoiceNo
    invoiceData.regInvoiceNo = [NSString stringWithFormat:@"%@%@",configuration.regPrefixNo,keyChainInvoiceNo ];
    
    if (configuration.serverShiftId)
    {
        invoiceData.serverShiftId = configuration.serverShiftId;
    }

    invoiceData.isUpload = @(FALSE);
    
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *strInvoiceDate = [formatter stringFromDate:date];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    dateFormatter.timeZone = sourceTimeZone;
    invoiceData.invoiceDate = [dateFormatter dateFromString:strInvoiceDate];
    
    [invoiceData updateInvoiceFromDictionary:responseDictionary];
 //   [self logForInvoiceDataWithMethodName:@"UpdateManager Before save" withInvoiceData:invoiceData];

    // Save data now
    [UpdateManager saveContext:privateManagedObjectContext];
    
    // [self logForInvoiceDataWithMethodName:@"UpdateManager After save" withInvoiceData:invoiceData];
    return invoiceData;
}

/*-(void)logForInvoiceDataWithMethodName:(NSString *)methodName withInvoiceData:(InvoiceData_T*)invoiceData
{
    NSLog(@"invoiceData in %@  %@",methodName,invoiceData);
    NSLog(@"invoiceData.invoiceItemData in %@  %@",methodName,invoiceData.invoiceItemData);
    NSLog(@"invoiceData.invoiceMstData in %@ %@",methodName,invoiceData.invoiceMstData);
    NSLog(@"invoiceData.invoicePaymentData in %@  %@",methodName,invoiceData.invoicePaymentData);
}*/
- (InvoiceData_T *)updateDataToDataTableWithObject :(NSManagedObjectID *)invoiceDataId withInvoiceDetail:(NSDictionary*)responseDictionary
{
    
    
    NsmoContext *privateManagedObjectContext = PVTCTX(self.parentManagedObjectContext__Sec);
    
    // Update Invoice Number in Configuration
    Configuration *configuration = [UpdateManager getConfigurationMoc:privateManagedObjectContext ];
    
    
    NSString *keyChainInvoiceNo = [Keychain getStringForKey:@"tenderInvoiceNo"];
    
    // set value in InvoiceData_T table
    InvoiceData_T * invoiceData = (InvoiceData_T *)[privateManagedObjectContext objectWithID:invoiceDataId];
    
    invoiceData.branchId = @([[responseDictionary valueForKey:@"branchId"] integerValue]);
    invoiceData.regiterid = @([[responseDictionary valueForKey:@"registerId"] integerValue]);
    invoiceData.zId = @([[responseDictionary valueForKey:@"zId"] integerValue]);
    invoiceData.msgCode = @([[responseDictionary valueForKey:@"msgCode"] integerValue]);
    invoiceData.message = [responseDictionary valueForKey:@"message"];
    
    // Update regInvoiceNo
    invoiceData.regInvoiceNo = [NSString stringWithFormat:@"%@%@",configuration.regPrefixNo,keyChainInvoiceNo ];
    invoiceData.userId = @([[responseDictionary valueForKey:@"UserId"] integerValue]);

    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *strInvoiceDate = [formatter stringFromDate:date];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    dateFormatter.timeZone = sourceTimeZone;
    invoiceData.invoiceDate = [dateFormatter dateFromString:strInvoiceDate];
    
    [invoiceData updateInvoiceFromDictionary:responseDictionary];
    
    // Save data now
    [UpdateManager saveContext:privateManagedObjectContext];
    
    return invoiceData;
}

- (NSArray*)taXFetch:(NSString*)entityName key:(NSString*)key value:(id)value moc:(NsmoContext*)moc
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"taxId==%@",value];
    fetchRequest.predicate = predicate;
    NSArray *arryTemp = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    
    
    return arryTemp;
}

- (NSArray*)customerFetch:(NSString*)entityName key:(NSString*)key value:(id)value moc:(NsmoContext*)moc
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"custId==%@",value];
    fetchRequest.predicate = predicate;
    NSArray *arryTemp = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    
    
    return arryTemp;
}


- (NSArray*)supplierFetch:(NSString*)entityName key:(NSString*)key value:(id)value moc:(NsmoContext*)moc
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"brnSupplierId==%@",value];
    fetchRequest.predicate = predicate;
    NSArray *arryTemp = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    return arryTemp;
}

- (NSArray*)DepartmentFetch:(NSString*)entityName key:(NSString*)key value:(id)value moc:(NsmoContext*)moc
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"deptId==%@",value];
    fetchRequest.predicate = predicate;
    NSArray *arryTemp = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    return arryTemp;
}

- (NSArray*)SubDepartmentFetch:(NSString*)entityName key:(NSString*)key value:(id)value moc:(NsmoContext*)moc
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@",key,value];
    fetchRequest.predicate = predicate;
    NSArray *arryTemp = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    return arryTemp;
}

- (NSArray*)SizeFetch:(NSString*)entityName key:(NSString*)key value:(id)value moc:(NsmoContext*)moc
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sizeId==%@",value];
    fetchRequest.predicate = predicate;
    NSArray *arryTemp = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    return arryTemp;
}

- (NSArray*)groupFetch:(NSString*)entityName key:(NSString*)key value:(id)value moc:(NsmoContext*)moc
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"groupId==%@",value];
    fetchRequest.predicate = predicate;
    NSArray *arryTemp = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    return arryTemp;
}

- (NSArray*)mixmatchFetch:(NSString*)entityName key:(NSString*)key value:(id)value moc:(NsmoContext*)moc
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"mixMatchId==%@",value];
    fetchRequest.predicate = predicate;
    NSArray *arryTemp = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    return arryTemp;
}

- (NSArray*)tipPercentageFetch:(NSString*)entityName key:(NSString*)key value:(id)value moc:(NsmoContext*)moc
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"brnTipPercentageId==%@",value];
    fetchRequest.predicate = predicate;
    NSArray *arryTemp = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    return arryTemp;
}

- (NSArray*)variationFetch:(NSString*)entityName key:(NSString*)key value:(id)value moc:(NsmoContext*)moc
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"vid==%@",value];
    fetchRequest.predicate = predicate;
    NSArray *arryTemp = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    return arryTemp;
}

-(void)insertMasterDate
{
    NsmoContext *privateManagedObjectContext = PVTCTX(self.parentManagedObjectContext__Sec);
    Configuration *configuration = [self insertConfigurationMoc:privateManagedObjectContext];
    NSString *configDateString = @"";
    NSDate *destinationDate = [self ludFromString:configDateString];
    configuration.masterUpdateDate = destinationDate;
    [UpdateManager saveContext:privateManagedObjectContext];
}

-(void)insertMasterDate:(NSString *)strDate
{
    NsmoContext *privateManagedObjectContext = PVTCTX(self.parentManagedObjectContext__Sec);
    Configuration *configuration = [self insertConfigurationMoc:privateManagedObjectContext];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"MM/dd/yyyy HH:mm:ss";
    NSDate *date = [formatter dateFromString:strDate];
    NSLog(@"Converted Master date = %@", date);
    configuration.masterUpdateDate = date;
    [UpdateManager saveContext:privateManagedObjectContext];
}

-(void)insertItemUpdateDate:(NSString *)strDate
{
    NsmoContext *privateManagedObjectContext = PVTCTX(self.parentManagedObjectContext__Sec);
    Configuration *configuration = [self insertConfigurationMoc:privateManagedObjectContext];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"MM/dd/yyyy HH:mm:ss";
    NSDate *date = [formatter dateFromString:strDate];
    NSLog(@"Converted date = %@", date);
    configuration.lastUpdateDate = date;
    [UpdateManager saveContext:privateManagedObjectContext];
}

-(void)insertPetroUpdateDate:(NSString *)strDate
{
    NsmoContext *privateManagedObjectContext = PVTCTX(self.parentManagedObjectContext__Sec);
    Configuration *configuration = [self insertConfigurationMoc:privateManagedObjectContext];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"MM/dd/yyyy HH:mm:ss";
    NSDate *date = [formatter dateFromString:strDate];
    NSLog(@"Converted Petro date = %@", date);
    configuration.lastPetroUpdateDate = date;
    [UpdateManager saveContext:privateManagedObjectContext];
}


-(void)linkItemWithItemDepartment:(NSArray*)itemList moc:(NsmoContext*)moc
{
    for (NSMutableDictionary *itemDictionary in itemList)
    {
        NSNumber *itemId = [itemDictionary valueForKey:@"ITEMCode"];
        Item *item = [self fetchItemFromDBWithItemId:itemId.stringValue shouldCreate:NO moc:moc];
        [self linkWithDepartmentFromItem:item moc:moc];
    }
}

- (void)asynchronousInsertObjectsFromMasterResponseDictionary:(NSDictionary*)masterResponseDictionary dispatchQueue:(dispatch_queue_t)dispatchQueue {

    // Create Provate context for this queue
    NsmoContext *privateManagedObjectContext = PVTCTX(self.parentManagedObjectContext__Sec);

    NSMutableArray *taxMasterList=[masterResponseDictionary valueForKey:@"TAX_MArray"];
    NSMutableArray *SupplierArray=[masterResponseDictionary valueForKey:@"supplierArray"];
    // For Supplier Company
    NSMutableArray *SupplierCompanyArray=[masterResponseDictionary valueForKey:@"SupplierCompany_Array"];
    // For Company Representative
    NSMutableArray *SupplierRepresentativeArray=[masterResponseDictionary valueForKey:@"supplierArray"];
    NSMutableArray *arraysize=[masterResponseDictionary valueForKey:@"SIZE_MArray"];
    NSMutableArray *arrayDepartment=[masterResponseDictionary valueForKey:@"Department_MArray"];
    NSArray *subDepartment_MArray = [masterResponseDictionary valueForKey:@"SubDepartment_Array"];
    NSMutableArray *arrayDepartmentTax=[masterResponseDictionary valueForKey:@"DeptTax_MArray"];
    NSMutableArray *arrayPayment=[masterResponseDictionary valueForKey:@"Payment_MArray"];
    NSMutableArray *arrayGroupMaster=[masterResponseDictionary valueForKey:@"GroupMaster_Array"];
    NSMutableArray *arrayMixMatchMaster=[masterResponseDictionary valueForKey:@"Mix_MatchDisc_Array"];
    NSMutableArray *variationMaster = [masterResponseDictionary valueForKey:@"Variation_Array"];
    NSMutableArray *tipsMasterArray = [masterResponseDictionary valueForKey:@"TipPercentage_Array"];
    NSMutableArray *discountMasterArray = [masterResponseDictionary valueForKey:@"Discount_M"];
    NSMutableArray *configurationArray = [masterResponseDictionary valueForKey:@"Configuration_Array"];
    NSMutableArray *fuelType_Array = [masterResponseDictionary valueForKey:@"FuelType_Array"];
    NSMutableArray *fuelTypePrice_Array = [masterResponseDictionary valueForKey:@"FuelTypePrice_Array"];
    NSMutableArray *tank_Array = [masterResponseDictionary valueForKey:@"Tank_Array"];
    NSMutableArray *pump_Array = [masterResponseDictionary valueForKey:@"Pump_Array"];
    NSMutableArray *customer_Array = [masterResponseDictionary valueForKey:@"Customer_Array"];

    [self updateDepartmentFromDepartmentlist:arrayDepartment moc:privateManagedObjectContext];
    

    NSMutableArray *arrayKitechSetting = [[NSUserDefaults standardUserDefaults]valueForKey:@"KitchenPrinter_Setting"];
    
    for(NSMutableDictionary *dictTemp in  arrayKitechSetting){
        
        NSMutableDictionary *dictPrinter = [[NSMutableDictionary alloc]init];
        dictPrinter[@"printer_ip"] = [dictTemp valueForKey:@"printer_ip"];
        dictPrinter[@"printer_Name"] = [dictTemp valueForKey:@"printer_Name"];
        
        KitchenPrinter *kitchenPrinter = [self getPrinter:[dictTemp valueForKey:@"printer_ip"] withMoc:privateManagedObjectContext];
        
        NSMutableArray *selectedDeptArray = [dictTemp valueForKey:@"SelectedDepartments"];
        
        if(kitchenPrinter){
            
            [self updatePrinterDictionary:dictPrinter withDepartment:selectedDeptArray withMoc:privateManagedObjectContext];
        }
        else{
            [self addPrinterDictionary:dictPrinter withDepartment:selectedDeptArray];
        }
        
    }
    
    [UpdateManager saveContext:privateManagedObjectContext];
     
//    NSLog(@"insertDepartmentFromDepartmentlist => %f", [[NSDate date] timeIntervalSinceDate:startDate]);
//    startDate = [NSDate date];

    [self updateSubDepartmentFromSubDepartmentlist:subDepartment_MArray moc:privateManagedObjectContext];
    [UpdateManager saveContext:privateManagedObjectContext];
     
//    NSLog(@"insertSubDepartmentFromSubDepartmentlist => %f", [[NSDate date] timeIntervalSinceDate:startDate]);
//    startDate = [NSDate date];

    [self updateTaxMaster:taxMasterList moc:privateManagedObjectContext];
    [UpdateManager saveContext:privateManagedObjectContext];
     
//    NSLog(@"insertTaxMaster => %f", [[NSDate date] timeIntervalSinceDate:startDate]);
//    startDate = [NSDate date];

    [self insertDepartmentTaxMaster:arrayDepartmentTax moc:privateManagedObjectContext];
    [UpdateManager saveContext:privateManagedObjectContext];
     
//    NSLog(@"insertDepartmentTaxMaster => %f", [[NSDate date] timeIntervalSinceDate:startDate]);
//    startDate = [NSDate date];

    [self updateVariationMasterlist:variationMaster moc:privateManagedObjectContext];
    [UpdateManager saveContext:privateManagedObjectContext];
     
//    NSLog(@"insertVariationMasterlist => %f", [[NSDate date] timeIntervalSinceDate:startDate]);
//    startDate = [NSDate date];

    [self updateGroupMaster:arrayGroupMaster moc:privateManagedObjectContext];
    [UpdateManager saveContext:privateManagedObjectContext];
     
//    NSLog(@"insertGroupMaster => %f", [[NSDate date] timeIntervalSinceDate:startDate]);
//    startDate = [NSDate date];

    [self updateMixMatchMaster:arrayMixMatchMaster moc:privateManagedObjectContext];
    [UpdateManager saveContext:privateManagedObjectContext];
    
    
    [self updateCustomerInfo:customer_Array moc:privateManagedObjectContext];
    [UpdateManager saveContext:privateManagedObjectContext];
    
//    NSLog(@"insertMixMatchMaster => %f", [[NSDate date] timeIntervalSinceDate:startDate]);
//    startDate = [NSDate date];
//    NSLog(@"XXXXXXXXXXXX OOOOOOOOOOOOOOO XXXXXXXXXXXXX OOOOOOOOOOOOOOOO");

    if([self checkGasPumpisActive]){
        arrayPayment = [self updateGasAmountLimitandDeleteOjbect:arrayPayment moc:privateManagedObjectContext];
    }
    else{
        [self deletePayamentMaster:privateManagedObjectContext];
    }
    
    
    [self updatePaymentMaster:arrayPayment moc:privateManagedObjectContext];
    [UpdateManager saveContext:privateManagedObjectContext];
     
//    NSLog(@"insertPaymentMaster => %f", [[NSDate date] timeIntervalSinceDate:startDate]);
//    startDate = [NSDate date];

    [self updateSupplierMaster:SupplierArray moc:privateManagedObjectContext];
    [UpdateManager saveContext:privateManagedObjectContext];
     
//    NSLog(@"insertSupplierMaster => %f", [[NSDate date] timeIntervalSinceDate:startDate]);
//    startDate = [NSDate date];

    [self updateSupplierCompanylist:SupplierCompanyArray moc:privateManagedObjectContext];
    [UpdateManager saveContext:privateManagedObjectContext];
     
//    NSLog(@"insertSupplierCompanylist => %f", [[NSDate date] timeIntervalSinceDate:startDate]);
//    startDate = [NSDate date];

    [self updateSupplierRepresentativelist:SupplierRepresentativeArray moc:privateManagedObjectContext];
    [UpdateManager saveContext:privateManagedObjectContext];
     
//    NSLog(@"insertSupplierRepresentativelist => %f", [[NSDate date] timeIntervalSinceDate:startDate]);
//    startDate = [NSDate date];

    [self updateSizeMaster:arraysize moc:privateManagedObjectContext];
    [UpdateManager saveContext:privateManagedObjectContext];
     
//    NSLog(@"insertSizeMaster => %f", [[NSDate date] timeIntervalSinceDate:startDate]);
//    startDate = [NSDate date];

    [self updateTipsMaster:tipsMasterArray moc:privateManagedObjectContext];
    [UpdateManager saveContext:privateManagedObjectContext];
     
//    NSLog(@"insertTipsMaster => %f", [[NSDate date] timeIntervalSinceDate:startDate]);
//    startDate = [NSDate date];
    
    [self updateDiscountMaster:discountMasterArray moc:privateManagedObjectContext];
    [UpdateManager saveContext:privateManagedObjectContext];
     
//    startDate = [NSDate date];

    if([self checkGasPumpisActive]){
    
//        if (![RmsDbController sharedRmsDbController].rapidPetroPos) {
//            [RmsDbController sharedRmsDbController].rapidPetroPos = [RapidPetroPOS createInstance];
//            [RmsDbController sharedRmsDbController].pumpMasterArray = pump_Array;
//            [RmsDbController sharedRmsDbController].tankMasterArray = tank_Array;
//        }
//        else{
//            [RmsDbController sharedRmsDbController].pumpMasterArray = pump_Array;
//            [RmsDbController sharedRmsDbController].tankMasterArray = tank_Array;
//        }
//        
//        NSManagedObjectContext *gasprivatemoc = [UpdateManager privateConextFromParentContext:[RmsDbController sharedRmsDbController].rapidPetroPos.petroMOC];
        
        //[self deleteGasMaster:gasprivatemoc];
        
//        [self updateMasterFuelTypeInLocalDatabase:fuelType_Array moc:gasprivatemoc];
//        
//        [self updateMasterFuelPricingInLocalDatabase:fuelTypePrice_Array moc:gasprivatemoc];
//        
//        [self updateFuelMasterTankInLocalDatabase:tank_Array moc:gasprivatemoc];
//        
//        [self updateFuelPumpMasterInLocalDatabase:pump_Array moc:gasprivatemoc];
        
    }

    // Configuration
    Configuration *configuration = [self insertConfigurationMoc:privateManagedObjectContext];

    if(configurationArray.count > 0)
    {
        NSNumber *tips = [configurationArray.firstObject valueForKey:@"Tips" ];
        configuration.tips = tips;
        if (tips.boolValue == FALSE) {
            configuration.localTipsSetting = tips;
        }
        
        NSNumber *ticket = [configurationArray.firstObject valueForKey:@"Ticket" ];
        configuration.ticket = ticket;
        configuration.localTicketSetting = ticket;
        
        NSNumber *ebt = [configurationArray.firstObject valueForKey:@"EBT" ];
        configuration.ebt = ebt;
        configuration.localEbt = ebt;
        
     //   NSNumber *isCustomerLoyalty = [configurationArray.firstObject valueForKey:@"CustomerLoyalty" ];
        configuration.customerLoyalty = @(1);
        configuration.localCustomerLoyalty = @(1);
        
        NSNumber *isHouseCharge = [configurationArray.firstObject valueForKey:@"HouseChagre" ];
        configuration.houseCharge = isHouseCharge;
        
        NSNumber *isSubDepartment = [configurationArray.firstObject valueForKey:@"IsSubDepartment"];
        configuration.subDepartment = isSubDepartment;

    }
    [UpdateManager saveContext:privateManagedObjectContext];
}


-(void)deleteGasMaster:(NSManagedObjectContext *)moc
{
    NSManagedObjectContext *privateManagedObjectContext = [UpdateManager privateConextFromParentContext:moc];
    
    NSArray *masterArray = @[@"FuelType",@"PayMode",@"ServiceType",@"FuelTank"];
    for (int i = 0; i<masterArray.count; i++)
    {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entity = [NSEntityDescription
                                       entityForName:masterArray[i] inManagedObjectContext:privateManagedObjectContext];
        fetchRequest.entity = entity;
        //    NSError *error;
        NSArray *arryTemp = [UpdateManager executeForContext:privateManagedObjectContext FetchRequest:fetchRequest];
        for (NSManagedObject *product in arryTemp)
        {
            [UpdateManager deleteFromContext:privateManagedObjectContext object:product];
        }
    }
    [UpdateManager saveContext:privateManagedObjectContext];
    
}


- (void)asynchronousDeleteObjectsFromDataBaseTable:(NSDictionary*)deleteDictionary dispatchQueue:(dispatch_queue_t)dispatchQueue {
    
    // Create Private context for this queue
    NsmoContext *privateManagedObjectContext = PVTCTX(self.parentManagedObjectContext__Sec);
    
    NSMutableArray *itemList = [deleteDictionary valueForKey:@"ItemArray"];
    for (NSMutableDictionary *itemDictionary in itemList)
    {
        if ([[[itemDictionary valueForKey:@"isDeleted"] stringValue] isEqualToString:@"1"])
        {
            Item *item = (Item*)[self fetchEntityWithName:@"Item" key:@"itemCode" value:@([[itemDictionary valueForKey:@"ITEMCode"] integerValue]) shouldCreate:YES moc:privateManagedObjectContext];
            [UpdateManager deleteFromContext:privateManagedObjectContext object:item];
            
            [self cleanUpDbForItem:itemDictionary updateResponseDictionary:deleteDictionary moc:privateManagedObjectContext];
        }
    }
    [UpdateManager saveContext:privateManagedObjectContext];
}

#pragma mark - Core Data
#pragma mark - Insert
- (Item *)insertItemWithItemDictionary:(NSDictionary *)itemDictionary moc:(NsmoContext *)moc
{
    Item *item = nil;
    item = (Item *)[self insertEntityWithName:@"Item" moc:moc];
    [item updateItemFromDictionary:itemDictionary];
    return item;
}

#pragma mark - Core Data
#pragma mark - Vendor Insert
- (Vendor_Item *)insertVendorItemWithItemDictionary:(NSDictionary *)itemDictionary moc:(NsmoContext *)moc
{
    Vendor_Item *vitem = nil;
    vitem = (Vendor_Item *)[self insertEntityWithName:@"Vendor_Item" moc:moc];
    [vitem updatevendorItemDictionary:itemDictionary];

    return vitem;
}

-(void)insertVendorItemWithItem:(NSDictionary *)itemDictionary moc:(NsmoContext *)moc
{
    Vendor_Item *vitem = (Vendor_Item*)[self insertEntityWithName:@"Vendor_Item" moc:moc];
    [vitem updatevendorItemDictionary:itemDictionary];
    [UpdateManager saveContext:moc];
    
}


-(void)insertItemsFromItemlist:(NSArray *)itemList moc:(NsmoContext*)moc
{
    for (NSMutableDictionary *itemDictionary in itemList)
    {
        if ([[[itemDictionary valueForKey:@"isDeleted"] stringValue]isEqualToString:@"0"])
        {
            Item *item;
            item = [self insertItemWithItemDictionary:itemDictionary moc:moc];
            // Barcode linking and Price_MD linking
            NsmoContext *barcodeObjectContext = moc;
            [self linkWithBarcodeFromItem:item moc:barcodeObjectContext];
            NsmoContext *priceObjectContext = moc;
            [self linkWithPriceFromItem:item moc:priceObjectContext];
        }
    }
}

- (ItemBarCode_Md *)insertBarcodeWithBarcodeDictionary:(NSDictionary *)barcodeDictionary moc:(NsmoContext *)moc
{
    ItemBarCode_Md *itemBarcode = nil;
    itemBarcode = (ItemBarCode_Md *)[self insertEntityWithName:@"ItemBarCode_Md" moc:moc];
    [itemBarcode updateItemBarcodeDictionary:barcodeDictionary];
    return itemBarcode;
}


- (ItemTicket_MD *)insertItemTicketDictionary:(NSDictionary *)itemTicketDictionary moc:(NsmoContext *)moc
{
    ItemTicket_MD *itemTicket = nil;
    itemTicket = (ItemTicket_MD *)[self insertEntityWithName:@"ItemTicket_MD" moc:moc];
    [itemTicket updateItemTicketlDictionary:itemTicketDictionary];
    return itemTicket;
}
-(void)insertBarcodessFromBarcodelist:(NSArray *)barcodeList moc:(NsmoContext*)moc
{
    for (NSMutableDictionary *barcodeDictionary in barcodeList)
    {
        [self insertBarcodeWithBarcodeDictionary:barcodeDictionary moc:moc];
    }
}

- (Item_Price_MD *)insertPriceWithPriceDictionary:(NSDictionary *)pricelistDictionary moc:(NsmoContext *)moc
{
    Item_Price_MD *itemPrice = nil;
    itemPrice = (Item_Price_MD *)[self insertEntityWithName:@"Item_Price_MD" moc:moc];
    [itemPrice updateItem_Price_Md_Dictionary:pricelistDictionary];
    return itemPrice;
}

-(void)insertPriceFromPricelist:(NSArray *)pricelist moc:(NsmoContext*)moc
{
    for (NSMutableDictionary *pricelistDictionary in pricelist)
    {
        [self insertPriceWithPriceDictionary:pricelistDictionary moc:moc ];
    }
}

- (void)insertSuppliersWithSupplierDictionary:(NSMutableDictionary *)supplierDictionary moc:(NsmoContext *)moc
{
    ItemSupplier *itemSupplier = nil;
    itemSupplier = (ItemSupplier*)[self insertEntityWithName:@"ItemSupplier" moc:moc];
    [itemSupplier updateItemSupplierFromDictionary:supplierDictionary];
}

-(void)insertSuppliersFromSupplierlist:(NSArray *)supplierlist moc:(NsmoContext*)moc
{
    NSSet * SupplierSet = [NSSet setWithArray:supplierlist];
    supplierlist = SupplierSet.allObjects;
    for (NSMutableDictionary *supplierDictionary in supplierlist)
    {
        [self insertSuppliersWithSupplierDictionary:supplierDictionary moc:moc];
    }
}
-(NSInteger)insertSuppliersFromSupplierlist:(NSArray *)supplierlist moc:(NsmoContext*)moc withCount:(NSInteger)totalcount withRemainItemCount:(NSInteger)remainingItemCount
{
    NSSet * SupplierSet = [NSSet setWithArray:supplierlist];
    supplierlist = SupplierSet.allObjects;
    
    for (NSMutableDictionary *supplierDictionary in supplierlist)
    {
        [self insertSuppliersWithSupplierDictionary:supplierDictionary moc:moc];
        
        remainingItemCount++;
        float intPercentage = remainingItemCount*100;
        intPercentage = intPercentage/totalcount;
        //NSLog(@"intPercentage %f",intPercentage);
        [self stepProgressnotification:0 message:@"2" progress:intPercentage];
    }
    return remainingItemCount;
}

// Modifier_M
- (Modifire_M *)insertModifierMWithModifierMDictionary:(NSMutableDictionary *)modifierMDictionary moc:(NsmoContext *)moc
{
    Modifire_M *modifireM = nil;
    modifireM = (Modifire_M *)[self insertEntityWithName:@"Modifire_M" moc:moc];
    [modifireM updateitemModifireMDictionary:modifierMDictionary];
    return modifireM;
}
//// ModifierItem_M
- (ModifireList_M *)insertModifierItemMWithModifierItemMDictionary:(NSMutableDictionary *)modifierItemMDictionary moc:(NsmoContext *)moc
{
    ModifireList_M *modifireList_M = nil;
    modifireList_M = (ModifireList_M *)[self insertEntityWithName:@"ModifireList_M" moc:moc];
    [modifireList_M updateitemModifireItemMDictionary:modifierItemMDictionary];
    return modifireList_M;
}

- (void)insertModifier_MAndModifierItem_M:(NSMutableArray *)modifierMlist arrayModifireItem_M:(NSMutableArray *)modifierItemMlist moc:(NsmoContext *)privateManagedObjectContext
{
    for (NSMutableDictionary *modifierMDictionary in modifierMlist)
    {
        [self insertModifierMWithModifierMDictionary:modifierMDictionary moc:privateManagedObjectContext];
    }
    for (NSMutableDictionary *modifierItemDictionary in modifierItemMlist)
    {
         [self insertModifierItemMWithModifierItemMDictionary:modifierItemDictionary moc:privateManagedObjectContext];
    }
}

- (void)insertTagsWithTagDictionary:(NSMutableDictionary *)tagDictionary moc:(NsmoContext *)moc
{
    
    ItemTag *itemTag = nil;
    itemTag = (ItemTag *)[self insertEntityWithName:@"ItemTag" moc:moc];
    [itemTag updateItemTagFromDictionary:tagDictionary];
    
}

-(void)insertTagsFromTaglist:(NSArray *)taglist moc:(NsmoContext*)moc
{
    for (NSMutableDictionary *tagDictionary in taglist)
    {
        [self insertTagsWithTagDictionary:tagDictionary moc:moc];
    }
}

//-(void)insertTagsFromTaglist:(NSArray *)taglist moc:(NsmoContext*)moc withItem:(Item *)anItem
//{
//    for (NSMutableDictionary *tagDictionary in taglist)
//    {
//        [self insertTagsWithTagDictionary:tagDictionary moc:moc];
//    }
//}


-(void)insertTagsFromTaglist:(NSArray *)taglist moc:(NsmoContext*)moc withCount:(NSInteger)totalcount
         withRemainItemCount:(NSInteger)remainingItemCount
{
    
    for (NSMutableDictionary *tagDictionary in taglist)
    {
        [self insertTagsWithTagDictionary:tagDictionary moc:moc];
        
        remainingItemCount++;
        float intPercentage = remainingItemCount*100;
        intPercentage = intPercentage/totalcount;
        //NSLog(@"intPercentage %f",intPercentage);
        [self stepProgressnotification:0 message:@"2" progress:intPercentage];
    }
}

-(NSArray *)insertTagsFromTaglist:(NSArray *)taglist moc:(NsmoContext*)moc withItem:(Item *)item

{
    NSMutableArray *itemTags = [[NSMutableArray alloc]init];
    
    NSPredicate *itemPredicate = [NSPredicate predicateWithFormat:@"ItemId = %@", item.itemCode];
    NSArray *tagListForItem = [taglist filteredArrayUsingPredicate:itemPredicate];
    
    for (NSDictionary *tagDictionary in tagListForItem) {
        
        ItemTag *itemTag = nil;
        itemTag = (ItemTag *)[self insertEntityWithName:@"ItemTag" moc:moc];
        [itemTag updateItemTagFromDictionary:tagDictionary];
        [itemTag addTagToItemObject:item];
        [item addItemTagsObject:itemTag];
    }
    return itemTags;
}

-(NSArray *)updateTagsFromTaglist:(NSArray *)taglist moc:(NsmoContext*)moc withItem:(Item *)item

{
    NSMutableArray *itemTags = [[NSMutableArray alloc]init];
    
    NSPredicate *itemPredicate = [NSPredicate predicateWithFormat:@"ItemId = %@", item.itemCode];
    NSArray *tagListForItem = [taglist filteredArrayUsingPredicate:itemPredicate];
   NSSet *tagSet = [NSSet setWithArray:tagListForItem];
    
    for (NSDictionary *tagDictionary in tagSet) {
        
        ItemTag *itemTag = nil;
        itemTag = (ItemTag *)[self insertEntityWithName:@"ItemTag" moc:moc];
        [itemTag updateItemTagFromDictionary:tagDictionary];
        [itemTag addTagToItemObject:item];
        [item addItemTagsObject:itemTag];

        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"SizeMaster" inManagedObjectContext:moc];
        fetchRequest.entity = entity;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sizeId == %@", itemTag.sizeId];
        fetchRequest.predicate = predicate;
        
        NSArray *resultSet = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
        
        for (SizeMaster *sizeMater in resultSet)
        {
            [sizeMater addSizeMasterToTagsObject:itemTag];
            itemTag.tagToSizeMaster = sizeMater;
        }

    
    }
    return itemTags;
}


- (Item_Discount_MD *)insertDiscount_MDFromDiscountDictionary:(NSDictionary *)discountMdDictionary moc:(NsmoContext *)moc
{
    Item_Discount_MD *discount_md = nil;
    discount_md = (Item_Discount_MD *)[self insertEntityWithName:@"Item_Discount_MD" moc:moc];
    [discount_md updateItemDiscount_MdFromDictionary:discountMdDictionary];
    return discount_md;
}


// Item Variation

- (ItemVariation_M *)fetchItemVariation_MFromVariationDictionary:(NSDictionary *)itemVariatonMDictionary moc:(NsmoContext *)moc
{
    ItemVariation_M *variation_m = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ItemVariation_M" inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"varianceId == %@", [itemVariatonMDictionary valueForKey:@"Id"]];
    fetchRequest.predicate = predicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];

    if(resultSet.count>0)
    {
        variation_m = resultSet.firstObject;
    }
    else{
        variation_m = (ItemVariation_M *)[self insertEntityWithName:@"ItemVariation_M" moc:moc];
    }
    [variation_m updateitemVariationMDictionary:itemVariatonMDictionary];
    
    return variation_m;
}

// Item Variation

- (ItemVariation_M *)insertItemVariation_MFromVariationDictionary:(NSDictionary *)itemVariatonMDictionary moc:(NsmoContext *)moc
{
    ItemVariation_M *variation_m = nil;
    variation_m = (ItemVariation_M *)[self insertEntityWithName:@"ItemVariation_M" moc:moc];
    [variation_m updateitemVariationMDictionary:itemVariatonMDictionary];
    return variation_m;
}

-(void)insertDiscount_MDFromDiscounlist:(NSArray *)discountList moc:(NsmoContext*)moc
{
    for (NSMutableDictionary *discountMdDictionary in discountList)
    {
        Item_Discount_MD *discount_md = [self insertDiscount_MDFromDiscountDictionary:discountMdDictionary moc:moc];
        [self linkWithItemsDiscMd:discount_md moc:moc];
    }
}

- (Item_Discount_MD2 *)insertDiscount_MD2FromDiscountDictionary:(NSDictionary *)discountMd2Dictionary moc:(NsmoContext *)moc
{
    Item_Discount_MD2 *discount_md2 = nil;
    discount_md2 = (Item_Discount_MD2 *)[self insertEntityWithName:@"Item_Discount_MD2" moc:moc];
    [discount_md2 updateItemDiscount_Md2FromDictionary:discountMd2Dictionary];
    return discount_md2;
}

// Variation M

- (ItemVariation_Md *)insertVariation_MDFromVariationDictionary:(NSDictionary *)variationMdDictionary moc:(NsmoContext *)moc
{
    ItemVariation_Md *variation_md = nil;
    variation_md = (ItemVariation_Md *)[self insertEntityWithName:@"ItemVariation_Md" moc:moc];
    [variation_md updateitemVariationMdDictionary:variationMdDictionary];
    return variation_md;
}

// Variation M

- (ItemVariation_Md *)fetchVariation_MDFromVariationDictionary:(NSDictionary *)variationMdDictionary moc:(NsmoContext *)moc
{
    ItemVariation_Md *variation_md = nil;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ItemVariation_Md" inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"varianceId == %@ && itemCode = %@", [variationMdDictionary valueForKey:@"VarianceId"],[variationMdDictionary valueForKey:@"ItemCode"]];
    fetchRequest.predicate = predicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    
    if(resultSet.count>0)
    {
        
        variation_md = resultSet.firstObject;
    }
    else{
        
        variation_md = (ItemVariation_Md *)[self insertEntityWithName:@"ItemVariation_Md" moc:moc];
    }
    [variation_md updateitemVariationMdDictionary:variationMdDictionary];
    return variation_md;

}


-(void)insertDiscount_MD2FromDiscounlist:(NSArray *)discountList moc:(NsmoContext*)moc
{
    for (NSMutableDictionary *discountMd2Dictionary in discountList)
    {
        Item_Discount_MD2 *discount_md2;
        discount_md2 = [self insertDiscount_MD2FromDiscountDictionary:discountMd2Dictionary moc:moc];
        [self linkWitDiscMdToMd2:discount_md2 moc:moc];
    }
}

- (void)insertTaxesWithTaxDictionary:(NSMutableDictionary *)taxDictionary moc:(NsmoContext *)moc
{
    ItemTax *tax = nil;
    tax = (ItemTax *)[self insertEntityWithName:@"ItemTax" moc:moc];
    [tax updateitemTaxFromDictionary:taxDictionary];
}

-(void)insertTaxlist :(NSArray *)taxList moc:(NsmoContext*)moc
{
    NSSet * taxSet = [NSSet setWithArray:taxList];
    taxList = taxSet.allObjects;
    for (NSMutableDictionary *taxDictionary in taxList)
    {
        [self insertTaxesWithTaxDictionary:taxDictionary moc:moc];
    }
}


-(NSInteger)insertTaxlist :(NSArray *)taxList moc:(NsmoContext*)moc withCount:(NSInteger)totalcount
withRemainItemCount:(NSInteger)remainingItemCount
{
    NSSet * taxSet = [NSSet setWithArray:taxList];
    taxList = taxSet.allObjects;
    for (NSMutableDictionary *taxDictionary in taxList)
    {
        [self insertTaxesWithTaxDictionary:taxDictionary moc:moc];
        remainingItemCount++;
        float intPercentage = remainingItemCount*100;
        intPercentage = intPercentage/totalcount;
       // NSLog(@"intPercentage %f",intPercentage);
        [self stepProgressnotification:0 message:@"2" progress:intPercentage];

    }
    return remainingItemCount;
}

//Vendor Item
-(void)insertVendorItemlist :(NSArray *)vendorList moc:(NsmoContext*)moc
{
    int totalitemcount=0;
    for (NSMutableDictionary *venderDictionary in vendorList)
    {
        [self insertVendorItemWithItemDictionary:venderDictionary moc:moc];
        totalitemcount++;
        float intPercentage = totalitemcount*100;
        intPercentage = intPercentage/vendorList.count;
        //NSLog(@"intPercentage %f",intPercentage);
        [self stepProgressnotification:0 message:@"2" progress:intPercentage];
    }
}



-(void)insertDepartmentFromDepartmentlist:(NSArray *)departmentList moc:(NsmoContext*)moc
{
    for (NSMutableDictionary *departmentDictionary in departmentList)
    {
         if ([[[departmentDictionary valueForKey:@"IsDeleted"] stringValue]isEqualToString:@"0"]){
            
             Department *department = (Department*)[self insertEntityWithName:@"Department" moc:moc];
             [department updateDepartmentFromDictionary:departmentDictionary];
             [self linkWithItemsDepartment:department moc:moc];

         }
        
    }
    [UpdateManager saveContext:moc];
}

-(void)updateDepartmentFromDepartmentlist:(NSArray *)departmentList moc:(NsmoContext*)moc
{
    for (NSMutableDictionary *departmentDictionary in departmentList)
    {
        Department *department = (Department*)[self __fetchEntityWithName:@"Department" key:@"deptId" value:@([[departmentDictionary valueForKey:@"DeptId"] integerValue]) shouldCreate:YES moc:moc];
        [department updateDepartmentFromDictionary:departmentDictionary];
        [self linkWithItemsDepartment:department moc:moc];
    }
    [UpdateManager saveContext:moc];
}


-(void)insertVariationMasterlist :(NSArray *)vMaseterList moc:(NsmoContext*)moc
{
    for (NSMutableDictionary *vMasterDictionary in vMaseterList)
    {
        Variation_Master *variationMaster = (Variation_Master*)[self insertEntityWithName:@"Variation_Master" moc:moc];
        [variationMaster updateMasterVariationMDictionary:vMasterDictionary];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"ItemVariation_M" inManagedObjectContext:moc];
        fetchRequest.entity = entity;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"variationMasterId == %@", variationMaster.vid];
        fetchRequest.predicate = predicate;
        
        NSArray *resultSet = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
        
        for (ItemVariation_M *itemVariation_M in resultSet)
        {
            [variationMaster addMasterVariationMsObject:itemVariation_M];
            itemVariation_M.variationMMaster = variationMaster;
        }
    }
    [UpdateManager saveContext:moc];
}

-(void)updateVariationMasterlist :(NSArray *)vMaseterList moc:(NsmoContext*)moc
{
    for (NSMutableDictionary *vMasterDictionary in vMaseterList)
    {
        Variation_Master *variationMaster = (Variation_Master*)[self __fetchEntityWithName:@"Variation_Master" key:@"vid" value:@([[vMasterDictionary valueForKey:@"vid"] integerValue]) shouldCreate:YES moc:moc];
        [variationMaster updateMasterVariationMDictionary:vMasterDictionary];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"ItemVariation_M" inManagedObjectContext:moc];
        fetchRequest.entity = entity;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"variationMasterId == %@", variationMaster.vid];
        fetchRequest.predicate = predicate;
        
        NSArray *resultSet = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
        
        for (ItemVariation_M *itemVariation_M in resultSet)
        {
            [variationMaster addMasterVariationMsObject:itemVariation_M];
            itemVariation_M.variationMMaster = variationMaster;
        }
    }
    [UpdateManager saveContext:moc];
}


//-(void)insertSupplierCompanylist :(NSArray *)supplierCompanyList moc:(NsmoContext*)moc
//{
//    for (NSMutableDictionary *supplierCompanyDictionary in supplierCompanyList)
//    {
//        SupplierCompany *supplierCompany = (SupplierCompany*)[self insertEntityWithName:@"SupplierCompany" moc:moc];
//        [supplierCompany updateSupplierCompanyDictionary:supplierCompanyDictionary];
//    }
//    [UpdateManager saveContext:moc];
//}

-(void)updateSupplierCompanylist :(NSArray *)supplierCompanyList moc:(NsmoContext*)moc
{
//    NSLog(@"updateSupplierCompanylist %@",supplierCompanyList);
    for (NSMutableDictionary *supplierCompanyDictionary in supplierCompanyList)
    {
        SupplierCompany *supplierCompany = (SupplierCompany*)[self __fetchEntityWithName:@"SupplierCompany" key:@"companyId" value:@([[supplierCompanyDictionary valueForKey:@"Id"] integerValue]) shouldCreate:YES moc:moc];
        if ([[supplierCompanyDictionary valueForKey:@"IsDeleted"] integerValue] == 1) {
            if (supplierCompanyDictionary!=nil) {
                [UpdateManager deleteFromContext:moc object:supplierCompany];
            }
        }
        else{
            [supplierCompany updateSupplierCompanyDictionary:supplierCompanyDictionary];
        }
    }
    [UpdateManager saveContext:moc];
}



-(void)insertSupplierRepresentativelist :(NSArray *)supplierRepresentativeList moc:(NsmoContext*)moc
{
    for (NSMutableDictionary *supplierRepresentativeDictionary in supplierRepresentativeList)
    {
        SupplierRepresentative *supplierRepresentative = (SupplierRepresentative*)[self insertEntityWithName:@"SupplierRepresentative" moc:moc];
        [supplierRepresentative updateSupplierRepresentativeDictionary:supplierRepresentativeDictionary];
        [self linkWithSupplierCompany:supplierRepresentative moc:moc];
    }
    [UpdateManager saveContext:moc];
}

-(void)updateSupplierRepresentativelist :(NSArray *)supplierRepresentativeList moc:(NsmoContext*)moc
{
//     NSLog(@"updateSupplierRepresentativelist %@",supplierRepresentativeList);
    for (NSMutableDictionary *supplierRepresentativeDictionary in supplierRepresentativeList)
    {
        SupplierRepresentative *supplierRepresentative = (SupplierRepresentative*)[self __fetchEntityWithName:@"SupplierRepresentative" key:@"brnSupplierId" value:@([[supplierRepresentativeDictionary valueForKey:@"BrnSupplierId"] integerValue]) shouldCreate:YES moc:moc];
        if ([[supplierRepresentativeDictionary valueForKey:@"IsDeleted"] integerValue] == 1) {
            if (supplierRepresentative!=nil) {
                [UpdateManager deleteFromContext:moc object:supplierRepresentative];
            }
        }
        else{
            [supplierRepresentative updateSupplierRepresentativeDictionary:supplierRepresentativeDictionary];
            [self linkWithSupplierCompany:supplierRepresentative moc:moc];
        }
    }
    [UpdateManager saveContext:moc];
}




- (void)linkWithSupplierCompany:(SupplierRepresentative*)theSupplierRepresentative moc:(NsmoContext*)moc
{
    NSNumber *companyId = theSupplierRepresentative.companyId;
    NSArray *companyList = [self fetchCompanyWithCompnayId:companyId moc:moc];
    for (SupplierCompany *scompany in companyList)
    {
        theSupplierRepresentative.company=scompany;
        [scompany addRepresentativesObject:theSupplierRepresentative];
    }
}

-(void)insertSubDepartmentFromSubDepartmentlist :(NSArray *)subDepartmentList moc:(NsmoContext*)moc
{
    for (NSMutableDictionary *subDepartmentDictionary in subDepartmentList)
    {
        if ([[[subDepartmentDictionary valueForKey:@"IsDeleted"] stringValue]isEqualToString:@"0"]){
           
            SubDepartment *subDepartment = (SubDepartment*)[self insertEntityWithName:@"SubDepartment" moc:moc];
            [subDepartment updateSubDepartmentDictionary:subDepartmentDictionary];
            [self linkWithItemsSubDepartment:subDepartment moc:moc];
        }

    }
    [UpdateManager saveContext:moc];
}

-(void)updateSubDepartmentFromSubDepartmentlist :(NSArray *)subDepartmentList moc:(NsmoContext*)moc
{
    for (NSMutableDictionary *subDepartmentDictionary in subDepartmentList)
    {
        SubDepartment *subdepartment = (SubDepartment *)[self __fetchEntityWithName:@"SubDepartment" key:@"brnSubDeptID" value:@([[subDepartmentDictionary valueForKey:@"BrnSubDeptID"] integerValue]) shouldCreate:YES moc:moc];
        [subdepartment updateSubDepartmentDictionary:subDepartmentDictionary];
        [self linkWithItemsSubDepartment:subdepartment moc:moc];
    }
    [UpdateManager saveContext:moc];
}


-(void)insertSubDepartmentWithDictionary:(NSDictionary *)subDepartmentDictionary
{
    NsmoContext *privateManagedObjectContext = PVTCTX(self.parentManagedObjectContext__Sec);
    SubDepartment *subDepartment = (SubDepartment*)[self insertEntityWithName:@"SubDepartment" moc:privateManagedObjectContext];
    [subDepartment updateSubDepartmentDictionary:subDepartmentDictionary];
    [self linkWithItemsSubDepartment:subDepartment moc:privateManagedObjectContext];
    [UpdateManager saveContext:privateManagedObjectContext];
}

-(ManualPOSession *)insertManualPOWithDictionary:(NSDictionary *)PoDictionary
{
    NsmoContext *privateManagedObjectContext = PVTCTX(self.parentManagedObjectContext__Sec);
    ManualPOSession *manulPO = (ManualPOSession*)[self insertEntityWithName:@"ManualPOSession" moc:privateManagedObjectContext];
    [manulPO updateManualPoDictionary:PoDictionary];
    [UpdateManager saveContext:privateManagedObjectContext];
    
    return manulPO;
}

-(void)addPrinterDictionary:(NSDictionary *)printerDictionary withDepartment:(NSMutableArray *)deptArray
{
    NsmoContext *privateManagedObjectContext = PVTCTX(self.parentManagedObjectContext__Sec);
    KitchenPrinter *kitchenPrinter = (KitchenPrinter*)[self insertEntityWithName:@"KitchenPrinter" moc:privateManagedObjectContext];
    [kitchenPrinter updatePrinterDictionary:printerDictionary];
    
    for(int i = 0;i<deptArray.count;i++){
        
        NSMutableDictionary *dictdept = deptArray[i];
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        f.numberStyle = kCFNumberFormatterNoStyle;
        NSNumber *deptid = [f numberFromString:[NSString stringWithFormat:@"%@", [dictdept valueForKey:@"DeptId"]]];
        
        Department *dept = [self fetchDepartmentWithDepartmentId:deptid moc:privateManagedObjectContext];
        
        [kitchenPrinter addPrinterDepartmentsObject:dept];
        dept.departmentPrinter = kitchenPrinter;
    }
    
    [UpdateManager saveContext:privateManagedObjectContext];
    
}



-(void)updatePrinterDictionary:(NSDictionary *)printerDictionary withDepartment:(NSMutableArray *)deptArray withMoc:(NsmoContext *)moc
{

    KitchenPrinter *kitchenPrinter = [self getPrinter:[printerDictionary valueForKey:@"printer_ip"] withMoc:moc];
    
    [kitchenPrinter updatePrinterDictionary:printerDictionary];
    
    NSSet *departments = kitchenPrinter.printerDepartments;
    [kitchenPrinter removePrinterDepartments:departments];
    
    for (Department *dept in departments) {
        dept.departmentPrinter = nil;
    }
    
    for(int i = 0;i<deptArray.count;i++){
        
        NSMutableDictionary *dictdept = deptArray[i];
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        f.numberStyle = kCFNumberFormatterNoStyle;
        NSNumber *deptid = [f numberFromString:[NSString stringWithFormat:@"%@", [dictdept valueForKey:@"DeptId"]]];
        
        Department *dept = [self fetchDepartmentWithDepartmentId:deptid moc:moc];
        [kitchenPrinter addPrinterDepartmentsObject:dept];
        dept.departmentPrinter = kitchenPrinter;
    }
    
    [UpdateManager saveContext:moc];
    
}
-(KitchenPrinter *)getPrinter:(NSString *)strPrinterIp withMoc:(NsmoContext *)moc{
    
    KitchenPrinter *kitchenPrinter;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"KitchenPrinter" inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"printer_ip == %@", strPrinterIp];
    fetchRequest.predicate = predicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    
    if(resultSet.count>0){
        
        kitchenPrinter = resultSet.firstObject;
    }
    return kitchenPrinter;
}


-(VPurchaseOrder *)insertVendorPoDictionary:(NSDictionary *)vendorPoDictionary
{
    NsmoContext *privateManagedObjectContext = PVTCTX(self.parentManagedObjectContext__Sec);
    VPurchaseOrder *vendorPO = (VPurchaseOrder*)[self insertEntityWithName:@"VPurchaseOrder" moc:privateManagedObjectContext];
    [vendorPO updateVendorPoDictionary:vendorPoDictionary];
    [UpdateManager saveContext:privateManagedObjectContext];
    
    return vendorPO;
}

-(VPurchaseOrder *)fetchVendorPurchaseOrder:(NSInteger)poid withManageObjectContext:(NsmoContext *)moc
{
    VPurchaseOrder *anObject;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"VPurchaseOrder" inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"poId==%@",@(poid)];
    fetchRequest.predicate = predicate;
    NSArray *arryTemp = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    
    //NSManagedObject *anObject = nil;
    if (arryTemp.count == 0)
    {
        return nil;
    }
    else
    {
        anObject = arryTemp.firstObject;
    }
    
    return anObject;
}



-(ManualPOSession *)fetchManualPOWithDictionary:(NSInteger)poid withManageObjectContext:(NsmoContext *)moc
{
    ManualPOSession *anObject;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ManualPOSession" inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"manualPoId==%@",@(poid)];
    fetchRequest.predicate = predicate;
    NSArray *arryTemp = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    
    //NSManagedObject *anObject = nil;
    if (arryTemp.count == 0)
    {
        return nil;
    }
    else
    {
        anObject = arryTemp.firstObject;
    }

    return anObject;
}

-(void)insertManualPOItemWithDictionary:(NSDictionary *)PoitemDictionary
{
    NsmoContext *privateManagedObjectContext = PVTCTX(self.parentManagedObjectContext__Sec);
    ManualReceivedItem *manulPOItem = (ManualReceivedItem*)[self insertEntityWithName:@"ManualReceivedItem" moc:privateManagedObjectContext];
    [manulPOItem updateManualPoitemDictionary:PoitemDictionary];
    [UpdateManager saveContext:privateManagedObjectContext];
}

-(void)updateSubDepartmentWithDictionary:(NSDictionary *)subDepartmentDictionary
{
    NsmoContext *privateManagedObjectContext = PVTCTX(self.parentManagedObjectContext__Sec);
    SubDepartment *subDepartment = [self fetchSubDepartmentFromDBWithBrnSubDeptID:[subDepartmentDictionary valueForKey:@"BrnSubDeptID"] shouldCreate:YES moc:privateManagedObjectContext];
    [subDepartment updateSubDepartmentDictionary:subDepartmentDictionary];
    [UpdateManager saveContext:privateManagedObjectContext];
}

-(void)insertTaxMaster:(NSArray *)taxMasterList moc:(NsmoContext*)moc
{
    for (NSMutableDictionary *taxMasterDictionary in taxMasterList)
    {
        TaxMaster *tax=nil;
        tax = (TaxMaster *)[self insertEntityWithName:@"TaxMaster" moc:moc];
        [tax updateTaxMasterFromDictionary:taxMasterDictionary];
    }
}
-(void)insertCustomer:(NSArray *)customerList moc:(NsmoContext*)moc
{
    for (NSMutableDictionary *customerDictionary in customerList)
    {
        Customer *customer=nil;
        customer = (Customer *)[self insertEntityWithName:@"Customer" moc:moc];
        [customer updateCustomerDetailDictionary:customerDictionary];
    }
}

-(void)updateTaxMaster:(NSArray *)taxMasterList moc:(NsmoContext*)moc
{
    for (NSMutableDictionary *taxMasterDictionary in taxMasterList)
    {
        
        TaxMaster *tax= (TaxMaster *)[self __fetchEntityWithName:@"TaxMaster" key:@"taxId" value:@([[taxMasterDictionary valueForKey:@"TaxId"] integerValue]) shouldCreate:YES moc:moc];
        if ([[taxMasterDictionary valueForKey:@"IsDeleted"] integerValue] == 1) {
            if (tax!=nil) {
                [UpdateManager deleteFromContext:moc object:tax];

            }
        }
        else{
            [tax updateTaxMasterFromDictionary:taxMasterDictionary];
        }
    }
}

-(void)updateCustomerInfo:(NSArray *)customerInfoList moc:(NsmoContext*)moc
{
    for (NSMutableDictionary *customerInfoDictionary in customerInfoList)
    {
        Customer *customer= (Customer *)[self __fetchEntityWithName:@"Customer" key:@"custId" value:@([[customerInfoDictionary valueForKey:@"CustId"] integerValue]) shouldCreate:YES moc:moc];
        if ([[customerInfoDictionary valueForKey:@"IsDeleted"] integerValue] == 1) {
            if (customer!=nil) {
                [UpdateManager deleteFromContext:moc object:customer];
            }
        }
        else{
            [customer updateCustomerDetailDictionary:customerInfoDictionary];
        }
    }
}

-(void)insertDepartmentTaxMaster:(NSArray *)departmentMasterList moc:(NsmoContext*)moc
{
    for (NSMutableDictionary *departmentTaxDictionary in departmentMasterList)
    {
        DepartmentTax *depTax=nil;
        depTax = (DepartmentTax *)[self insertEntityWithName:@"DepartmentTax" moc:moc];
        [depTax updatedepartmentTaxFromDictionary:departmentTaxDictionary];
    }
}

-(void)updateDepartmentTaxMaster:(NSArray *)departmentMasterList moc:(NsmoContext*)moc
{
    for (NSMutableDictionary *departmentTaxDictionary in departmentMasterList)
    {
        DepartmentTax *depTax=(DepartmentTax *)[self __fetchEntityWithName:@"DepartmentTax" key:@"deptId" value:@([[departmentTaxDictionary valueForKey:@"DeptId"] integerValue]) shouldCreate:YES moc:moc];
        [depTax updatedepartmentTaxFromDictionary:departmentTaxDictionary];
    }
}


-(void)updateDepartmentTaxForList :(NSArray *)departmentTaxList
{
    NsmoContext *privateManagedObjectContext = PVTCTX(self.parentManagedObjectContext__Sec);
    
    if (departmentTaxList.count>0) {
        
        for (NSMutableDictionary *departmentTaxDictionary in departmentTaxList)
        {
            NSArray *taxArray=[self DepartmentFetch:@"DepartmentTax" key:@"deptId" value:@([[departmentTaxDictionary valueForKey:@"DeptId"] integerValue]) moc:privateManagedObjectContext];
            for (NSManagedObject *product in taxArray)
            {
                [UpdateManager deleteFromContext:privateManagedObjectContext object:product];
            }
            [UpdateManager saveContext:privateManagedObjectContext];
        }
        [self insertDepartmentTaxMaster:departmentTaxList moc:privateManagedObjectContext];
        [UpdateManager saveContext:privateManagedObjectContext];
    }
}


-(DepartmentTax *)departmentTaxForDepartmentId:(NSString *)departmentId
{
    NsmoContext *privateManagedObjectContext = PVTCTX(self.parentManagedObjectContext__Sec);
    
    DepartmentTax *departmnetTax = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DepartmentTax" inManagedObjectContext:privateManagedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"deptId == %d", departmentId.integerValue];
    fetchRequest.predicate = predicate;
    NSArray *resultSet = [UpdateManager executeForContext:privateManagedObjectContext FetchRequest:fetchRequest];
    if (resultSet.count>0)
    {
        departmnetTax=resultSet.firstObject;
    }
    else
    {
        departmnetTax = (DepartmentTax *)[self insertEntityWithName:@"DepartmentTax" moc:privateManagedObjectContext];
    }
    return departmnetTax;
}

-(void)insertWightScaleUnit:(NSArray*)weightScaleUnitList moc:(NsmoContext*)moc
{
    for (NSMutableDictionary *dictTemp in weightScaleUnitList)
    {
        WeightScaleUnit *weightScaleUnit = nil;
        weightScaleUnit = (WeightScaleUnit*)[self insertEntityWithName:@"WeightScaleUnit" moc:moc];
        [weightScaleUnit updateWeightScaleUnitDictionary:dictTemp];
    }
}
-(void)insertUnitConversionScaleUnit:(NSArray*)unitConversionList moc:(NsmoContext*)moc
{
    for (NSMutableDictionary *dictTemp in unitConversionList)
    {
        UnitConversion *unitConversion = nil;
        unitConversion = (UnitConversion*)[self insertEntityWithName:@"UnitConversion" moc:moc];
        [unitConversion updateUnitScaleUnitDictionary:dictTemp];
    }
}

-(void)insertSupplierMaster:(NSArray*)supplierMasterList moc:(NsmoContext*)moc
{
    for (NSMutableDictionary *dictTemp in supplierMasterList)
    {
        SupplierMaster *supplier = nil;
        supplier = (SupplierMaster*)[self insertEntityWithName:@"SupplierMaster" moc:moc];
        [supplier updateSupplierMasterFromDictionary:dictTemp];
    }
}
-(void)updateSupplierMaster:(NSArray*)supplierMasterList moc:(NsmoContext*)moc
{
    for (NSMutableDictionary *dictTemp in supplierMasterList)
    {
        SupplierMaster *supplier = (SupplierMaster*)[self __fetchEntityWithName:@"SupplierMaster" key:@"brnSupplierId" value:@([[dictTemp valueForKey:@"BrnSupplierId"]integerValue]) shouldCreate:YES moc:moc];
        [supplier updateSupplierMasterFromDictionary:dictTemp];
    }
}



-(void)insertPaymentMaster:(NSArray*)paymentMasterList moc:(NsmoContext*)moc
{
    for (NSMutableDictionary *dictTemp in paymentMasterList)
    {
        TenderPay *tender = nil;
        tender = (TenderPay *)[self insertEntityWithName:@"TenderPay" moc:moc];
        [tender updateTenderPayFromDictionary:dictTemp];
    }
}

-(void)deletePayamentMaster:(NsmoContext*)moc{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"TenderPay" inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    //    NSError *error;
    NSArray *arryTemp = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    for (NSManagedObject *product in arryTemp)
    {
        [UpdateManager deleteFromContext:moc object:product];
    }
    [UpdateManager saveContext:moc];
}

-(NSMutableArray *)updateGasAmountLimitandDeleteOjbect:(NSMutableArray *)paymentMasterList moc:(NsmoContext*)moc{
    
    for (NSMutableDictionary *dictTemp in paymentMasterList)
    {
        TenderPay *tender = (TenderPay *)[self __fetchEntityWithName:@"TenderPay" key:@"payId" value:@([[dictTemp valueForKey:@"PayId"] integerValue]) shouldCreate:NO moc:moc];
        dictTemp[@"GasAmountLimit"] = tender.gasAmountLimit;
        [UpdateManager deleteFromContext:moc object:tender];
    }
    return paymentMasterList;
}

-(void)updatePaymentMaster:(NSArray *)paymentMasterList moc:(NsmoContext*)moc
{

//    NSLog(@"updatePaymentMaster %@",paymentMasterList);
    for (NSMutableDictionary *dictTemp in paymentMasterList)
    {
        TenderPay *tender = (TenderPay *)[self __fetchEntityWithName:@"TenderPay" key:@"payId" value:@([[dictTemp valueForKey:@"PayId"] integerValue]) shouldCreate:YES moc:moc];
        if ([[dictTemp valueForKey:@"IsDeleted"] integerValue] == 1) {
            if (tender!=nil) {
                [UpdateManager deleteFromContext:moc object:tender];
            }
        }
        else{
            [tender updateTenderPayFromDictionary:dictTemp];
        }
    }
}

-(void)deletePaymentMaster:(NSString*)paymentId moc:(NsmoContext*)moc
{
    TenderPay *tenderPay = [self fetchPayMasterWithPayId:paymentId shouldCreate:NO moc:moc];
    if (tenderPay) {
        [UpdateManager deleteFromContext:moc object:tenderPay];
    }
}

-(void)deleteTaxMaster:(NSString*)taxId moc:(NsmoContext*)moc
{
    TaxMaster *taxMaster = [self fetchTaxMastertWithTaxId:taxId shouldCreate:NO moc:moc];
    if (taxMaster) {
        [UpdateManager deleteFromContext:moc object:taxMaster];
    }
}

-(void)deleteCustomerInfo:(NSString*)custId moc:(NsmoContext*)moc
{
    Customer *customer = [self fetchCustomerWithCustId:custId shouldCreate:NO moc:moc];
    if (customer) {
        [UpdateManager deleteFromContext:moc object:customer];
    }
}

-(void)insertSizeMaster:(NSArray*)sizeMasterList moc:(NsmoContext*)moc
{
    for (NSMutableDictionary *sizeMasterDictionary in sizeMasterList)
    {
        SizeMaster *size = (SizeMaster *)[self insertEntityWithName:@"SizeMaster" moc:moc];
        [size updateSizeMasterFromDictionary:sizeMasterDictionary];
    }
}

-(void)updateSizeMaster:(NSArray*)sizeMasterList moc:(NsmoContext*)moc
{
//    NSLog(@"updateSizeMaster %@",sizeMasterList);
    for (NSMutableDictionary *sizeMasterDictionary in sizeMasterList)
    {
        SizeMaster *size = (SizeMaster *)[self __fetchEntityWithName:@"SizeMaster" key:@"sizeId" value:@([[sizeMasterDictionary valueForKey:@"SizeId"] integerValue]) shouldCreate:YES moc:moc];
        
        if ([[sizeMasterDictionary valueForKey:@"IsDeleted"] integerValue] == 1) {
            if (size!=nil) {
                [UpdateManager deleteFromContext:moc object:size];
            }
        }
        else{
            [size updateSizeMasterFromDictionary:sizeMasterDictionary];
            
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"ItemTag" inManagedObjectContext:moc];
            fetchRequest.entity = entity;
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sizeId == %@", size.sizeId];
            fetchRequest.predicate = predicate;
            
            NSArray *resultSet = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
            
            for (ItemTag *itemTag in resultSet)
            {
                [size addSizeMasterToTagsObject:itemTag];
                itemTag.tagToSizeMaster = size;
            }
        }
    }
}

-(void)insertGroupMaster:(NSArray*)paymentMasterList moc:(NsmoContext*)moc
{
    for (NSMutableDictionary *dictTemp in paymentMasterList)
    {
        GroupMaster *groupMst = nil;
        groupMst = (GroupMaster *)[self insertEntityWithName:@"GroupMaster" moc:moc];
        [groupMst updateGroupMasterFromDictionary:dictTemp];
        [self linkWithItemsGroup:groupMst moc:moc];
        
    }
}
-(void)updateGroupMaster:(NSArray*)paymentMasterList moc:(NsmoContext*)moc
{
//    NSLog(@"updateGroupMaster %@",paymentMasterList);
    for (NSMutableDictionary *dictTemp in paymentMasterList)
    {
        GroupMaster *groupMst = (GroupMaster *)[self __fetchEntityWithName:@"GroupMaster" key:@"groupId" value:@([[dictTemp valueForKey:@"GroupId"] integerValue]) shouldCreate:YES moc:moc];
        
        if ([[dictTemp valueForKey:@"IsDeleted"] integerValue] == 1) {
            if (groupMst!=nil) {
                [UpdateManager deleteFromContext:moc object:groupMst];
            }
        }
        else{
            [groupMst updateGroupMasterFromDictionary:dictTemp];
            [self linkWithItemsGroup:groupMst moc:moc];
        }
    }
}


-(void)insertMixMatchMaster:(NSArray*)groupMixMatchMasterList moc:(NsmoContext*)moc
{
    for (NSMutableDictionary *dictTemp in groupMixMatchMasterList)
    {
        Mix_MatchDetail *mixMatchMst = nil;
        mixMatchMst = (Mix_MatchDetail *)[self insertEntityWithName:@"Mix_MatchDetail" moc:moc];
        [mixMatchMst updateMixMatchDetailFromDictionary:dictTemp];
        [self linkWithItemsMixMatch:mixMatchMst moc:moc];
    }
}
-(void)updateMixMatchMaster:(NSArray*)groupMixMatchMasterList moc:(NsmoContext*)moc
{
    for (NSMutableDictionary *dictTemp in groupMixMatchMasterList)
    {
        Mix_MatchDetail *mixMatchMst = (Mix_MatchDetail *)[self __fetchEntityWithName:@"Mix_MatchDetail" key:@"mixMatchId" value:@([[dictTemp valueForKey:@"MixMatchId"] integerValue]) shouldCreate:YES moc:moc];
        [mixMatchMst updateMixMatchDetailFromDictionary:dictTemp];
        [self linkWithItemsMixMatch:mixMatchMst moc:moc];
    }
}

-(void)insertTipsMaster:(NSArray*)tipsMasterList moc:(NsmoContext*)moc
{
    for (NSMutableDictionary *dictTips in tipsMasterList)
    {
        TipPercentageMaster *tipPercentageMaster = nil;
        if([[[dictTips valueForKey:@"IsDeleted"] stringValue]isEqualToString:@"0"])
        {
            tipPercentageMaster = (TipPercentageMaster *)[self insertEntityWithName:@"TipPercentageMaster" moc:moc];
            [tipPercentageMaster updateTipPercentageMasterDictionary:dictTips];
        }
    }
}

-(void)updateTipsMaster:(NSArray*)tipsMasterList moc:(NsmoContext*)moc
{
    for (NSMutableDictionary *dictTips in tipsMasterList)
    {
        TipPercentageMaster *tipPercentageMaster = nil;
        if([[[dictTips valueForKey:@"IsDeleted"] stringValue]isEqualToString:@"0"])
        {
            tipPercentageMaster = (TipPercentageMaster *)[self __fetchEntityWithName:@"TipPercentageMaster" key:@"brnTipPercentageId" value:@([[dictTips valueForKey:@"BrnTipPercentageId"] integerValue]) shouldCreate:YES moc:moc];
            [tipPercentageMaster updateTipPercentageMasterDictionary:dictTips];
        }
    }
}

-(void)insertDiscountMaster:(NSArray*)discountMasterList moc:(NsmoContext*)moc
{
    for (NSMutableDictionary *discountMasterDictionary in discountMasterList)
    {
        DiscountMaster *discountMaster = (DiscountMaster *)[self insertEntityWithName:@"DiscountMaster" moc:moc];
        [discountMaster updateDiscountMasterFromDictionary:discountMasterDictionary];
    }
}
-(void)updateDiscountMaster:(NSArray*)discountMasterList moc:(NsmoContext*)moc
{
    for (NSMutableDictionary *discountMasterDictionary in discountMasterList)
    {
        DiscountMaster *discountMaster = (DiscountMaster *)[self __fetchEntityWithName:@"DiscountMaster" key:@"discountId" value:@([[discountMasterDictionary valueForKey:@"DiscountId"]integerValue]) shouldCreate:YES moc:moc];
        [discountMaster updateDiscountMasterFromDictionary:discountMasterDictionary];
    }
}


-(Configuration *)insertConfigurationMoc:(NsmoContext*)moc
{
    Configuration *configuration = nil;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Configuration" inManagedObjectContext:moc];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    fetchRequest.entity = entity;
    NSArray *arryTemp = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    
    if (arryTemp.count == 0)
    {
        configuration = (Configuration *)[self insertEntityWithName:@"Configuration" moc:moc];
    }
    else
    {
        configuration = arryTemp.firstObject;
    }
    return configuration;
}

-(ModuleInfo *)updateModuleInfoMoc:(NsmoContext*)moc
{
    ModuleInfo *moduleInfo = nil;
    moduleInfo = (ModuleInfo *)[self insertEntityWithName:@"ModuleInfo" moc:moc];

//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ModuleInfo" inManagedObjectContext:moc];
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    
//    [fetchRequest setEntity:entity];
//    NSArray *arryTemp = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
//    
//    if (arryTemp.count == 0)
//    {
//        moduleInfo = (ModuleInfo *)[self insertEntityWithName:@"ModuleInfo" moc:moc];
//    }
//    else
//    {
//        moduleInfo = [arryTemp firstObject];
//    }
    return moduleInfo;
}


-(void)updateZidWithRegisrterInfo :(NSString *)zid withContext:(NsmoContext *)manageObjectContext
{
    NsmoContext *privateContextObject = PVTCTX(manageObjectContext);

    RegisterInfo *registerInfo = [self updateRegisterInfoMoc:privateContextObject];
    if (registerInfo != nil) {
        registerInfo.zId = [NSString stringWithFormat:@"%@",zid];
    }
    [UpdateManager saveContext:privateContextObject];
    
}

-(NSArray *)moduleInfoMoc:(NsmoContext*)moc
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ModuleInfo" inManagedObjectContext:moc];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    fetchRequest.entity = entity;
    NSArray *arryTemp = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
   
    return arryTemp;
}



-(void)updateCreditcardCredentialWithDetail :(NSMutableArray *)credentialDetail withContext:(NsmoContext*)context
{
    if(credentialDetail.count > 0)
    {
        NsmoContext *privateContextObject = PVTCTX(context);
        CreditcardCredetnial * credential = [self updateCreditcardCredetnialMoc:privateContextObject];
        [credential updateCreditcardCredetnialDictionary:credentialDetail.firstObject];
        [UpdateManager saveContext:privateContextObject];
    }
}

-(CreditcardCredetnial *)updateCreditcardCredetnialMoc:(NsmoContext*)moc
{
    CreditcardCredetnial *creditcardCredetnial = nil;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CreditcardCredetnial" inManagedObjectContext:moc];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    fetchRequest.entity = entity;
    NSArray *arryTemp = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    
    if (arryTemp.count == 0)
    {
        creditcardCredetnial = (CreditcardCredetnial *)[self insertEntityWithName:@"CreditcardCredetnial" moc:moc];
    }
    else
    {
        creditcardCredetnial = arryTemp.firstObject;
    }
    return creditcardCredetnial;
}

-(CreditcardCredetnial *)fetchCreditcardCredetnialMoc:(NsmoContext*)moc
{
    CreditcardCredetnial *creditcardCredetnial = nil;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CreditcardCredetnial" inManagedObjectContext:moc];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    fetchRequest.entity = entity;
    NSArray *arryTemp = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    
    if (arryTemp.count > 0)
    {
        creditcardCredetnial = arryTemp.firstObject;
    }
    return creditcardCredetnial;
}


-(ModuleInfo *)fetchModuleInfoMoc:(NsmoContext*)moc withDiviceId:(NSString *)deviceId
{
    ModuleInfo *moduleInfo = nil;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ModuleInfo" inManagedObjectContext:moc];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    fetchRequest.entity = entity;
    NSPredicate *filterRcrPredicate = [NSPredicate predicateWithFormat:@"(moduleCode = %@ OR moduleCode = %@ OR moduleCode == %@ OR moduleCode == %@ ) AND macAdd = %@ ",@"RCR",@"RRRCR",@"RRCR",@"RCRGAS" ,deviceId];
    fetchRequest.predicate = filterRcrPredicate;

    NSArray *arryTemp = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    
    if (arryTemp.count > 0)
    {
        moduleInfo = arryTemp.firstObject;

    }
    return moduleInfo;
}


-(void)deleteModuleInfoFromDatabaseWithContext:(NsmoContext *)moc
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ModuleInfo" inManagedObjectContext:moc];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    fetchRequest.entity = entity;
    NSArray *arryTemp = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    for (ModuleInfo *moduleInfo  in arryTemp) {
        if (moduleInfo)
        {
            [UpdateManager deleteFromContext:moc object:moduleInfo];
        }
    }
    [UpdateManager saveContext:moc];
}

-(NSArray *)fetchEntityFromDatabase:(NsmoContext *)moc withEntityName:(NSString *)entityname
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityname inManagedObjectContext:moc];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    fetchRequest.entity = entity;
    NSArray *arryTemp = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    
    return arryTemp;
}



-(RegisterInfo *)updateRegisterInfoMoc:(NsmoContext*)moc
{
    RegisterInfo *registerInfo = nil;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"RegisterInfo" inManagedObjectContext:moc];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    fetchRequest.entity = entity;
    NSArray *arryTemp = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    
    if (arryTemp.count == 0)
    {
        registerInfo = (RegisterInfo *)[self insertEntityWithName:@"RegisterInfo" moc:moc];
    }
    else
    {
        registerInfo = arryTemp.firstObject;
    }
    return registerInfo;
}

-(BranchInfo *)updateBranchInfoMoc:(NsmoContext*)moc
{
    BranchInfo *branchInfo = nil;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"BranchInfo" inManagedObjectContext:moc];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    fetchRequest.entity = entity;
    NSArray *arryTemp = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    
    if (arryTemp.count == 0)
    {
        branchInfo = (BranchInfo *)[self insertEntityWithName:@"BranchInfo" moc:moc];
    }
    else
    {
        branchInfo = arryTemp.firstObject;
    }
    return branchInfo;
}

-(BarCodeSearch *)updateBarcodeSearchInfo:(NsmoContext*)moc
{
    BarCodeSearch *barcodeSearch;
    
    barcodeSearch = (BarCodeSearch *)[self insertEntityWithName:@"BarCodeSearch" moc:moc];
    barcodeSearch.foundOnServer = @(FALSE);
    barcodeSearch.serverLookup = @(FALSE);
    
    return barcodeSearch;

}

+(Configuration *)getConfigurationMoc:(NsmoContext*)moc
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Configuration" inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    NSError *error;
    NSArray *arryTemp = [moc executeFetchRequest:fetchRequest error:&error];
    Configuration *configuration = nil;
    if(arryTemp.count > 0)
    {
        configuration = arryTemp.firstObject;
    }
    
    return configuration;
}

-(NSInteger)deleteHoldInvoiceForRecallInvoiceID:(NSString *)recallInvoiceId
{
    NsmoContext *privateManagedObjectContext = PVTCTX(self.parentManagedObjectContext__Sec);
    
    NSArray *holdInvoiceToDelete = [self fetchHoldInvoiceFromInvoiceId:@(recallInvoiceId.integerValue) withManageObjectContext:privateManagedObjectContext];
    for (HoldInvoice *holdInvoice in holdInvoiceToDelete) {
        [UpdateManager deleteFromContext:privateManagedObjectContext object:holdInvoice];
    }
    [UpdateManager saveContext:privateManagedObjectContext];
    return holdInvoiceToDelete.count;
}
-(NSArray*)fetchHoldInvoiceFromInvoiceId:(NSNumber *)invoiceId withManageObjectContext:(NsmoContext *)moc
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"HoldInvoice" inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    NSPredicate *filterHoldPredicate = [NSPredicate predicateWithFormat:@"transActionNo = %@",invoiceId];
    fetchRequest.predicate = filterHoldPredicate;
    NSArray *arryTemp = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    
    return arryTemp;
}

-(NSUInteger )fetchEntityObjectsCounts :(NSString *)entityName withManageObjectContext:(NsmoContext *)moc
{
    NSUInteger count=0;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:entityName inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    count = [UpdateManager countForContext:moc FetchRequest:fetchRequest];
    return count;
}



-(NSManagedObject *)manageObjectForEntity:(NSString *)entityName withContext:(NsmoContext*)moc
{
    NSManagedObject *manageObject = nil;
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:moc];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    fetchRequest.entity = entity;
    NSArray *arryTemp = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    
    if (arryTemp.count == 0)
    {
        manageObject = (NSManagedObject *)[self insertEntityWithName:entityName moc:moc];
    }
    else
    {
        manageObject = arryTemp.firstObject;
    }
    return manageObject;
}


#pragma mark - CoreData wrappers

+ (void)__save:(NsmoContext *)theContext {
//    if (theContext.parentContext == nil) {
//        NSLog(@"This is writer context");
//    } else if (theContext.parentContext.parentContext == nil) {
//        NSLog(@"This is main context");
//    } else {
//        NSLog(@"Update Context (private context)");
//    }

    // Save context
    @try {
        NSError *error = nil;
        if (![theContext save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", error.localizedDescription);
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Save: Non recoverable error occured. %@", exception);
    }
    @finally {
        
    }
    // push to parent
    // save parent to disk asynchronously
    [self saveContext:theContext.parentContext];
}

+ (void)saveContext:(NsmoContext*)theContext {
//    NSDate *startDate = [NSDate date];
    if (theContext == nil) {
        return;
    }

    if (theContext.parentContext == nil) {
//        NSLog(@"This is writer context");
        [theContext performBlock:^{
            [self __save:theContext];
        }];
    } else {
        [theContext performBlockAndWait:^{
            [self __save:theContext];
        }];
    }


//    if (theContext.parentContext.parentContext == nil) {
//        NSLog(@"Time to save %f", [[NSDate date] timeIntervalSinceDate:startDate]);
//    }

}

+ (NSArray*)executeForContext:(NsmoContext*)theContext FetchRequest:(NSFetchRequest*)fetchRequest {
    NSArray *result = nil;
    NSError *error = nil;
    @try
    {
        result = [theContext executeFetchRequest:fetchRequest error:&error];
    }
    @catch (NSException *exception)
    {
        NSLog(@"Error while executing fetch request occured. %@", exception);
        result = nil;
    }
    @finally {
    }
    
    return result;
}

+ (NSUInteger)countForContext:(NsmoContext*)theContext FetchRequest:(NSFetchRequest*)fetchRequest {
    NSUInteger result = 0;
    NSError *error = nil;
    
    @try {
        result = [theContext countForFetchRequest:fetchRequest error:&error];
    }
    @catch (NSException *exception) {
        NSLog(@"Error while executing fetch request occured. %@", exception);
        result = 0;
    }
    @finally {
    }
    
    return result;
}

+ (void)deleteFromContext:(NsmoContext*)theContext object:(NSManagedObject*)anObject {
    if (anObject != nil) {
        @try {
            [theContext deleteObject:anObject];
        }
        @catch (NSException *exception) {
            NSLog(@"Non recoverable error occured while deleting. %@", exception);
        }
        @finally {
            
        }
    }
}
+ (void)deleteFromContext:(NsmoContext*)theContext objectId:(NSManagedObjectID*)anObjectId {
    @try {
        NSManagedObject * anObject = [theContext objectWithID:anObjectId];
        [UpdateManager deleteFromContext:theContext object:anObject];
    }
    @catch (NSException *exception) {
        NSLog(@"Non recoverable error occured while deleting. %@", exception);
    }
    @finally {
        
    }
    
}
#pragma mark - Update
- (void)updateItemFromDict:(NSDictionary*)itemDict moc:(NsmoContext*)moc {
    NSString *itemId = itemDict[@"ItemId"];
    
    [self fetchItemFromDBWithItemId:itemId shouldCreate:NO moc:moc];
    
    // anIem.id = from Dict
    // anItem.name = from name
    
    
    //    [self attachSuppliers:supplierList toItem:anIem];
}

#pragma mark - Link
- (void)linkWithItemsDiscMd:(Item_Discount_MD*)itemDiscMD moc:(NsmoContext*)moc
{
    Item *anItem = [self fetchItemFromDBWithItemId:itemDiscMD.itemCode.stringValue shouldCreate:NO moc:moc];
    if (anItem == nil) {
        return;
    }
    [anItem addItemToDisMdObject:itemDiscMD];
    itemDiscMD.mdToItem = anItem;
}

- (void)linkWitDiscMdToMd2:(Item_Discount_MD2*)itemDiscMD2 moc:(NsmoContext*)moc
{
    NSArray *md2List = [self fetchDiscMDDBWithDiscId:itemDiscMD2.discountId.stringValue shouldCreate:NO moc:moc];
    for (Item_Discount_MD *discMd in md2List)
    {
        [discMd addMdTomd2Object:itemDiscMD2];
        itemDiscMD2.md2Tomd = discMd;
    }
}

- (void)linkWithItemsDepartment:(Department*)theDepartment moc:(NsmoContext*)moc
{
    NSNumber *departmentId = theDepartment.deptId;
    NSArray *itemList = [self fetchItemsWithDepartmentId:departmentId moc:moc];
    for (Item *anItem in itemList)
    {
        [anItem linkToDepartment:theDepartment];
    }
}

- (void)linkWithItemsSubDepartment:(SubDepartment*)subDepartment moc:(NsmoContext*)moc
{
    NSNumber *subDepartmentId = subDepartment.brnSubDeptID;
    NSArray *itemList = [self fetchItemsWithSubDepartmentId:subDepartmentId moc:moc];
    for (Item *anItem in itemList)
    {
        [anItem.itemDepartment addDepartmentSubDepartmentsObject:subDepartment];
        [anItem linkToSubDepartment:subDepartment];
        if (anItem.itemDepartment) {
            [subDepartment addSubDepartmentDepartmentsObject:anItem.itemDepartment];
        }
    }
}

- (void)linkWithItemsGroup:(GroupMaster*)groupMaster moc:(NsmoContext*)moc
{
    NSNumber *groupId = groupMaster.groupId;
    NSArray *itemList = [self fetchItemsWithGroupId:groupId moc:moc];
    for (Item *anItem in itemList)
    {
        [anItem linkToGroup:groupMaster];
    }
}

- (void)linkWithItemsMixMatch:(Mix_MatchDetail*)mixmatchDetail moc:(NsmoContext*)moc
{
    NSNumber *mixMatchId = mixmatchDetail.mixMatchId;
    
    NSArray *itemList = [self fetchItemsWithMixMatchId:mixMatchId moc:moc];
    for (Item *anItem in itemList)
    {
        [anItem linkToMixMatch:mixmatchDetail];
    }
}

- (void)linkWithDepartmentFromItem:(Item*)item moc:(NsmoContext*)moc
{
    NSNumber *departmentId = item.deptId;
    Department *depart = [self fetchDepartmentWithDepartmentId:departmentId moc:moc];
    //    [depart addDepartmentItemsObject:item];
    //    item.itemDepartment=depart;
    [item linkToDepartment:depart];
}

- (void)linkWithBarcodeFromItem:(Item *)item moc:(NsmoContext*)moc
{
    NSNumber *itemCode = item.itemCode;
    NSArray *barcode_Md = [self fetchBarcodeWithItemId:itemCode moc:moc];
    [item linkToBarcodes:barcode_Md];
    
    //    Alternate code to link barcode, comment above calling when we use this method
    //    for(int i = 0; i< [barcode_Md count];i++)
    //    {
    //        [item linkToBarcode:[barcode_Md objectAtIndex:i]];
    //    }
}

- (void)linkWithPriceFromItem:(Item *)item moc:(NsmoContext*)moc
{
    if (item.itemCode.integerValue == 127699)
    {
        
    }
    NSNumber *itemCode = item.itemCode;
    NSArray *barcode_Md = [self fetchPriceWithItemId:itemCode moc:moc];
    [item linkToPrice:barcode_Md];
}

//- (void)linkWithItemFromBarcode:(ItemBarCode_Md *)itemBarCode moc:(NsmoContext*)moc
//{
//    NSNumber *itemCode = item.itemCode;
//    NSArray *barcode_Md = [self fetchBarcodeWithItemId:itemCode moc:moc];
//    [item linkToBarcodes:barcode_Md];
//
//    //    Alternate code to link barcode, comment above calling when we use this method
//    //    for(int i = 0; i< [barcode_Md count];i++)
//    //    {
//    //        [item linkToBarcode:[barcode_Md objectAtIndex:i]];
//    //    }
//}


#pragma mark - Fetch methods
- (NSManagedObject*)fetchEntityWithName:(NSString*)entityName key:(NSString*)key value:(id)value shouldCreate:(BOOL)shouldCreate moc:(NsmoContext*)moc
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemCode==%@",value];
    fetchRequest.predicate = predicate;
    NSArray *arryTemp = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    
    NSManagedObject *anObject = nil;
    if (arryTemp.count == 0) {
        if (shouldCreate) {
            anObject = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:moc];
        }
    }
    else
    {
        anObject =arryTemp.firstObject;
    }
    
    return anObject;
}

#pragma mark - Fetch methods
- (NSManagedObject*)__fetchEntityWithName:(NSString*)entityName key:(NSString*)key value:(id)value shouldCreate:(BOOL)shouldCreate moc:(NsmoContext*)moc
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:moc];
    fetchRequest.entity = entity;
   // NSString *strPredicate = [NSString stringWithFormat:@"%K==%@",key,value];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@",key,value];
    fetchRequest.predicate = predicate;
    NSArray *arryTemp = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    
    NSManagedObject *anObject = nil;
    if (arryTemp.count == 0) {
        if (shouldCreate) {
            anObject = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:moc];
        }
    }
    else
    {
        anObject =arryTemp.firstObject;
    }
    
    return anObject;
}
+ (NSArray <NSManagedObject*> *)fetchEntityWithName:(NSString*)entityName withPredicate:(NSPredicate *)predicate moc:(NsmoContext*)moc {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    fetchRequest.predicate = predicate;
    return [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
}

- (NSManagedObject*)__fetchEntityWithName:(NSString*)entityName keysAndValue:(NSDictionary *)dictKeyValue shouldCreate:(BOOL)shouldCreate moc:(NsmoContext*)moc
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    // NSString *strPredicate = [NSString stringWithFormat:@"%K==%@",key,value];
    NSMutableArray *arrPredicates = [NSMutableArray array];
    NSArray *arrKeys = dictKeyValue.allKeys;
    for (NSString *key in arrKeys) {
        if([key isEqualToString:@"amountLimit"]){
            [arrPredicates addObject:[[RmsDbController sharedRmsDbController] predicateForKey:@"amountLimit" floatValue:[dictKeyValue[key] floatValue]]];
        }
        else{
            [arrPredicates addObject:[NSPredicate predicateWithFormat:@"%K = %@",key,dictKeyValue[key]]];

        }
    }
    fetchRequest.predicate  = [NSCompoundPredicate andPredicateWithSubpredicates:arrPredicates];
    NSArray *arryTemp = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    
    NSManagedObject *anObject = nil;
    if (arryTemp.count == 0) {
        if (shouldCreate) {
            anObject = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:moc];
        }
    }
    else
    {
        anObject =arryTemp.firstObject;
    }
    
    return anObject;
}

- (NSManagedObject*)__fetchEntityWithName:(NSString*)entityName key:(NSString*)key value:(id)value  key2:(NSString*)key2 value2:(id)value2 shouldCreate:(BOOL)shouldCreate moc:(NsmoContext*)moc
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    // NSString *strPredicate = [NSString stringWithFormat:@"%K==%@",key,value];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@ && %K = %@",key,value,key2,value2];
    fetchRequest.predicate = predicate;
    NSArray *arryTemp = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    
    NSManagedObject *anObject = nil;
    if (arryTemp.count == 0) {
        if (shouldCreate) {
            anObject = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:moc];
        }
    }
    else
    {
        anObject =arryTemp.lastObject;
    }
    
    return anObject;
}



- (NSArray *)fetchAllEntityWithName:(NSString*)entityName key:(NSString*)key value:(NSArray *)value moc:(NsmoContext*)moc
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K IN %@",key,value];
    fetchRequest.predicate = predicate;
    return [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
}

- (NSManagedObject*)fetchTagEntity:(NSString*)entityName key:(NSString*)key value:(id)value shouldCreate:(BOOL)shouldCreate moc:(NsmoContext*)moc
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemId==%@",value];
    fetchRequest.predicate = predicate;
    NSArray *arryTemp = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    
    NSManagedObject *anObject = nil;
    if (arryTemp.count == 0) {
        if (shouldCreate) {
            anObject = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:moc];
        }
    }
    else
    {
        anObject =arryTemp.firstObject;
    }
    
    return anObject;
}


- (NSArray*)fetcObjectsWithName:(NSString*)entityName key:(NSString*)key value:(id)value moc:(NsmoContext*)moc
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemId==%@",value];
    fetchRequest.predicate = predicate;
    NSArray *arryTemp = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    
    //NSManagedObject *anObject = nil;
    if (arryTemp.count == 0)
    {
    }
    else
    {
        //anObject = [arryTemp firstObject];
    }
    return arryTemp;
}

- (NSArray*)fetcObjectsWithItemCodeName:(NSString*)entityName key:(NSString*)key value:(id)value moc:(NsmoContext*)moc
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemCode==%@",value];
    fetchRequest.predicate = predicate;
    NSArray *arryTemp = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    
    
    //NSManagedObject *anObject = nil;
    if (arryTemp.count == 0)
    {
    }
    else
    {
        //anObject = [arryTemp firstObject];
    }
    return arryTemp;
}
- (NSArray*)fetchPriceObjectsWithItemCode:(NSString*)entityName key:(NSString*)key value:(id)value moc:(NsmoContext*)moc
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemcode==%@",value];
    fetchRequest.predicate = predicate;
    NSArray *arryTemp = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    
    
    //NSManagedObject *anObject = nil;
    if (arryTemp.count == 0)
    {
    }
    else
    {
        //anObject = [arryTemp firstObject];
    }
    return arryTemp;
}
- (NSArray*)fetcDiscountMD2ObjectsWithItemCodeName:(NSString*)entityName key:(NSString*)key value:(id)value moc:(NsmoContext*)moc
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"discountId == %@",value];
    fetchRequest.predicate = predicate;
    NSArray *arryTemp = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    
    
    //NSManagedObject *anObject = nil;
    if (arryTemp.count == 0)
    {
    }
    else
    {
        //anObject = [arryTemp firstObject];
    }
    return arryTemp;
}

- (Item*)fetchItemFromDBWithItemId:(NSString*)itemId shouldCreate:(BOOL)shouldCreate moc:(NsmoContext*)moc
{
    //    return (Item*)[self fetchEntityWithName:@"Item" key:@"itemCode" value:itemId shouldCreate:shouldCreate];
    
    
    // Entity Description
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:moc];
    
    // Fetch Request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    fetchRequest.entity = entity;
    
    // Prediucate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemCode == %d", itemId.integerValue];
    fetchRequest.predicate = predicate;
    
    // Execute Fetch Request
    NSArray *arryTemp = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    
    NSManagedObject *anObject = nil;
    if (arryTemp.count == 0) {
        // No data found
        if (shouldCreate) {
            // Create new object
            anObject = [NSEntityDescription insertNewObjectForEntityForName:@"Item" inManagedObjectContext:moc];
        }
    }
    else
    {
        // Get the first object
        anObject = arryTemp.firstObject;
    }
    
    return (Item*)anObject;
}

- (SubDepartment*)fetchSubDepartmentFromDBWithBrnSubDeptID:(NSString*)subDepartmentId shouldCreate:(BOOL)shouldCreate moc:(NsmoContext*)moc
{
    // Entity Description
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SubDepartment" inManagedObjectContext:moc];
    
    // Fetch Request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = entity;
    
    // Predicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"brnSubDeptID == %d", subDepartmentId.integerValue];
    fetchRequest.predicate = predicate;
    
    // Execute Fetch Request
    NSArray *arryTemp = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    
    NSManagedObject *anObject = nil;
    if (arryTemp.count == 0) {
        // No data found
        if (shouldCreate) {
            // Create new object
            anObject = [NSEntityDescription insertNewObjectForEntityForName:@"SubDepartment" inManagedObjectContext:moc];
        }
    }
    else
    {
        // Get the first object
        anObject = arryTemp.firstObject;
    }
    return (SubDepartment *)anObject;
}

- (NSArray*)fetchDiscMDDBWithDiscId:(NSString*)discId shouldCreate:(BOOL)shouldCreate moc:(NsmoContext*)moc
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item_Discount_MD" inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"iDisNo == %d", discId.integerValue];
    fetchRequest.predicate = predicate;
    NSArray *arryTemp = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    
    //NSManagedObject *anObject = nil;
    if (arryTemp.count == 0) {
        if (shouldCreate) {
            //anObject = [NSEntityDescription insertNewObjectForEntityForName:@"Item_Discount_MD" inManagedObjectContext:moc];
        }
    }
    else
    {
        //anObject = [arryTemp firstObject];
    }
    return arryTemp;
    
}

- (NSManagedObject*)fetchMasterEntityWithName:(NSString*)entityName key:(NSString*)key value:(id)value shouldCreate:(BOOL)shouldCreate moc:(NsmoContext*)moc
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%@==%@",key,value];
    fetchRequest.predicate = predicate;
    NSArray *arryTemp = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    
    NSManagedObject *anObject = nil;
    if (arryTemp.count == 0) {
        if (shouldCreate) {
            anObject = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:moc];
        }
    }
    else
    {
        anObject =arryTemp.firstObject;
    }
    
    return anObject;
}


- (NSArray*)fetchCompanyWithCompnayId:(NSNumber*)companyId moc:(NsmoContext*)moc
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SupplierCompany" inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"companyId == %@", companyId];
    fetchRequest.predicate = predicate;
    NSArray *resultSet = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    
    return resultSet;
}

- (NSArray*)fetchItemsWithDepartmentId:(NSNumber*)departmentId moc:(NsmoContext*)moc
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"deptId == %d", departmentId.integerValue];
    fetchRequest.predicate = predicate;
    NSArray *resultSet = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    
    return resultSet;
}

- (NSArray*)fetchItemsWithSubDepartmentId:(NSNumber*)subDepartmentId moc:(NsmoContext*)moc
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"subDeptId == %@", subDepartmentId];
    fetchRequest.predicate = predicate;
    NSArray *resultSet = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    return resultSet;
}

- (NSArray*)fetchItemsWithMixMatchId:(NSNumber*)mixMatchId moc:(NsmoContext*)moc
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"mixMatchId == %d", mixMatchId.integerValue];
    fetchRequest.predicate = predicate;
    NSArray *resultSet = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    
    return resultSet;
}
- (NSArray*)fetchItemsWithGroupId:(NSNumber*)mixMatchId moc:(NsmoContext*)moc
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"catId == %d", mixMatchId.integerValue];
    fetchRequest.predicate = predicate;
    NSArray *resultSet = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    
    return resultSet;
}

- (Mix_MatchDetail*)fetchMixMatchWithItemMixMatchId:(NSNumber*)mixMatchId moc:(NsmoContext*)moc
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Mix_MatchDetail" inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"mixMatchId == %d", mixMatchId.integerValue];
    fetchRequest.predicate = predicate;
    NSArray *resultSet = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    Mix_MatchDetail *mix_MatchDetail=nil;
    if (resultSet.count>0) {
        mix_MatchDetail=resultSet.firstObject;
    }
    return mix_MatchDetail;
}

- (Department*)fetchDepartmentWithDepartmentId:(NSNumber*)departmentId moc:(NsmoContext*)moc
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Department" inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"deptId == %d", departmentId.integerValue];
    fetchRequest.predicate = predicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    Department *department=nil;
    if (resultSet.count>0) {
        department=resultSet.firstObject;
    }
    return department;
}

- (SubDepartment*)fetchSubDepartmentWithSubDepartmentId:(NSNumber*)subDepartmentId moc:(NsmoContext*)moc
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SubDepartment" inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"brnSubDeptID == %d", subDepartmentId.integerValue];
    fetchRequest.predicate = predicate;

    NSArray *resultSet = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    SubDepartment *subDepartment=nil;
    if (resultSet.count>0) {
        subDepartment=resultSet.firstObject;
    }
    return subDepartment;
}

- (GroupMaster*)fetchGroupWithGroupId:(NSNumber*)groupId moc:(NsmoContext*)moc
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"GroupMaster" inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"groupId == %d", groupId.integerValue];
    fetchRequest.predicate = predicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    GroupMaster *groupMaster=nil;
    if (resultSet.count>0) {
        groupMaster=resultSet.firstObject;
    }
    return groupMaster;
}

- (NSArray *)fetchBarcodeWithItemId:(NSNumber*)itemCode moc:(NsmoContext*)moc
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ItemBarCode_Md" inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemCode == %d", itemCode.integerValue];
    fetchRequest.predicate = predicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    return resultSet;
}
- (NSArray *)fetchPriceWithItemId:(NSNumber*)itemCode moc:(NsmoContext*)moc
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item_Price_MD" inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemcode == %d", itemCode.integerValue];
    fetchRequest.predicate = predicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    return resultSet;
}
-(NSManagedObject*)insertEntityWithName:(NSString*)entityName moc:(NsmoContext*)moc
{
    return [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:moc];
}

#pragma mark - Other Utility methods
- (NSDate *)ludFromString:(NSString *)configDateString
{
    NSDate *dateUpdate = [[NSDate alloc]init];
    NSDateFormatter *format = [[NSDateFormatter alloc]init];
    format.dateFormat = @"MM/dd/yyyy hh:mm:ss a";
    
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:dateUpdate];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:dateUpdate];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    NSDate* destinationDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:dateUpdate];
    return destinationDate;
}

#pragma mark -
-(void)updateSupplierListFromItemTable :(NSArray *)supplierlist with:(NSString *)itemCode
{
    NsmoContext *privateManagedObjectContext = PVTCTX(self.parentManagedObjectContext__Sec);
    for(int i=0;i<supplierlist.count;i++)
    {
        ItemSupplier *itemSupplier=nil;
        NSMutableDictionary *dictTemp =supplierlist[i];
        itemSupplier = (ItemSupplier *)[self insertEntityWithName:@"ItemSupplier" moc:privateManagedObjectContext];
        [itemSupplier updateItemSupplierFromItemTable:dictTemp withItemCode:itemCode];
    }
    // Save data now
    [UpdateManager saveContext:privateManagedObjectContext];
}

-(void)updateTaxListFromItemTable :(NSArray *)taxArray with:(NSString *)itemCode
{
    NsmoContext *privateManagedObjectContext = PVTCTX(self.parentManagedObjectContext__Sec);
    
    for(int k=0;k<taxArray.count;k++)
    {
        NSMutableDictionary *dictTemp =taxArray[k];
        ItemTax *tax=nil;
        tax = (ItemTax *)[self insertEntityWithName:@"ItemTax" moc:privateManagedObjectContext];
        [tax updateitemTaxFromItemTable:dictTemp :itemCode];
    }
    // Save data now
    [UpdateManager saveContext:privateManagedObjectContext];
}


-(void)updateSizeListFromItemTable :(NSArray *)sizeArray with:(NSString *)itemCode
{
    NsmoContext *privateManagedObjectContext = PVTCTX(self.parentManagedObjectContext__Sec);
    for(int i=0;i<sizeArray.count;i++)
    {
        ItemTag *tag=nil;
        NSMutableDictionary *dictTemp =sizeArray[i];
        tag = (ItemTag *)[self insertEntityWithName:@"ItemTag" moc:privateManagedObjectContext];
        [tag updateItemTagFromItemTable:dictTemp withItemCode:itemCode];
    }
    // Save data now
    [UpdateManager saveContext:privateManagedObjectContext];
}

-(void)deleteItemWithItemCode:(NSNumber*)itemCode
{
    NsmoContext *privateManagedObjectContext = PVTCTX(self.parentManagedObjectContext__Sec);
    
    Item *item = [self fetchItemFromDBWithItemId:itemCode.stringValue shouldCreate:NO moc:privateManagedObjectContext];
    
    if(item)
    {
        [UpdateManager deleteFromContext:privateManagedObjectContext object:item];
    }
    
    // Save data now
    [UpdateManager saveContext:privateManagedObjectContext];
}

-(void)deleteSubDepartmentWithSubDepartmentId:(NSNumber*)subDepartmentId
{
    NsmoContext *privateManagedObjectContext = PVTCTX(self.parentManagedObjectContext__Sec);
    SubDepartment *subDepartment = [self fetchSubDepartmentFromDBWithBrnSubDeptID:subDepartmentId.stringValue shouldCreate:NO moc:privateManagedObjectContext];
    if(subDepartment)
    {
        [UpdateManager deleteFromContext:privateManagedObjectContext object:subDepartment];
    }
    // Save data now
    [UpdateManager saveContext:privateManagedObjectContext];
}

-(void)deleteDepartmentWithSubDepartmentId:(NSNumber*)subDepartmentId
{
    NsmoContext *privateManagedObjectContext = PVTCTX(self.parentManagedObjectContext__Sec);
    Department *department = (Department *)[self __fetchEntityWithName:@"Department" key:@"deptId" value:subDepartmentId shouldCreate:NO moc:privateManagedObjectContext];
    if(department)
    {
        [UpdateManager deleteFromContext:privateManagedObjectContext object:department];
    }
    // Save data now
    [UpdateManager saveContext:privateManagedObjectContext];
}


#pragma mark - check Multiple Barcode for Item in ItemBarCode_Md

- (BOOL)doesBarcodeExist:(NSString *)barCode forItemCode:(NSString *)itemCode
{
    NsmoContext *privateManagedObjectContext = PVTCTX(self.parentManagedObjectContext__Sec);
    BOOL isBarcodeExist = FALSE;
    // Find barcode in ItemBarCode_Md(Multiple barcode table) and display as item barcode
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ItemBarCode_Md" inManagedObjectContext:privateManagedObjectContext];
    fetchRequest.entity = entity;
    
    NSPredicate *barcodePredicate = [NSPredicate predicateWithFormat:@"barCode == %@",barCode];
    NSPredicate *itemPredicate = [NSPredicate predicateWithFormat:@"itemCode == %@", itemCode];
    NSPredicate *compundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[barcodePredicate,itemPredicate]];
    fetchRequest.predicate = compundPredicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:privateManagedObjectContext FetchRequest:fetchRequest];
    if(resultSet.count > 0)
    {
        isBarcodeExist = TRUE;
    }
    return isBarcodeExist;
}

#pragma mark - Gas Pump Insert Process

-(void)insertGasPumpDataFromXmlList:(NSData *)gasPumpData moc:(NsmoContext*)moc
{
//    FuelPump *fuelPumpXml = nil;
//    fuelPumpXml = (FuelPump*)[self insertEntityWithName:@"FuelPump" moc:moc];
//    [fuelPumpXml updateWithXmlData:gasPumpData];
}
//hiten
- (void)stepProgressnotification:(int)statusCode message:(NSString *)errorMsg progress:(float)Progress{
    [[NSNotificationCenter defaultCenter] postNotificationName:kStepWiseProgressNotification object:nil userInfo:@{kStepWiseConfigurationMessageKey:errorMsg, kStepWiseConfigurationStatusCodeKey:@(statusCode),kStepItemUpdateProgress:@(Progress)}];
    
}

-(void)insertCustomVariationMasterToCoreData:(NSMutableArray *)customVariationList
{
    NsmoContext *moc = PVTCTX(self.parentManagedObjectContext__Sec);
    for (NSMutableDictionary *vMasterDictionary in customVariationList)
    {
        Variation_Master *variationMaster = (Variation_Master*)[self insertEntityWithName:@"Variation_Master" moc:moc];
        [variationMaster updateMasterVariationMDictionary:vMasterDictionary];
    }
    [UpdateManager saveContext:moc];
}

-(void)updateSizeMasterToCoreData:(NSMutableArray *)sizeList
{
    NsmoContext *moc = PVTCTX(self.parentManagedObjectContext__Sec);
    for (NSMutableDictionary *sizeMasterDict in sizeList)
    {
        SizeMaster *size = (SizeMaster *)[self __fetchEntityWithName:@"SizeMaster" key:@"sizeId" value:@([[sizeMasterDict valueForKey:@"SizeId"] integerValue]) shouldCreate:YES moc:moc];
        [size updateSizeMasterFromDictionary:sizeMasterDict];
    }
    [UpdateManager saveContext:moc];
}


-(void)reconcileInventoryCountForObject :(ItemInventoryReconcileCount *)itemInventoryReconcileCount
{
    NSInteger singleCount = 0;
    NSInteger caseCount = 0;
    NSInteger packCount = 0;
    
    NSInteger singleQuntity = itemInventoryReconcileCount.singleQuantity.integerValue;
    NSInteger caseQuntity = itemInventoryReconcileCount.caseQuantity.integerValue;
    NSInteger packQuntity = itemInventoryReconcileCount.packQuantity.integerValue;
    
    
    for (ItemInventoryCount *itemInventoryCount in itemInventoryReconcileCount.itemInventoryCounts)
    {
        singleCount +=itemInventoryCount.singleCount.integerValue;
        caseCount +=itemInventoryCount.caseCount.integerValue;
        packCount +=itemInventoryCount.packCount.integerValue;
    }
    
    itemInventoryReconcileCount.singleCount = @(singleCount);
    itemInventoryReconcileCount.caseCount = @(caseCount);
    itemInventoryReconcileCount.packCount = @(packCount);
    
    NSInteger totalCount = (singleCount * singleQuntity) + (caseCount*caseQuntity) + (packCount*packQuntity);
    
    if (totalCount == itemInventoryReconcileCount.expectedQuantity.integerValue)
    {
        itemInventoryReconcileCount.isMatching = @(YES);
    }
    else
    {
        itemInventoryReconcileCount.isMatching = @(NO);
    }
}
-(void)reconcileInventoryCountForHistoryObject :(ItemInventoryReconcileCount *)itemInventoryReconcileCount
{
    NSInteger singleCount = 0;
    NSInteger caseCount = 0;
    NSInteger packCount = 0;
    
    for (ItemInventoryCount *itemInventoryCount in itemInventoryReconcileCount.itemInventoryCounts)
    {
        singleCount +=itemInventoryCount.singleCount.integerValue;
        caseCount +=itemInventoryCount.caseCount.integerValue;
        packCount +=itemInventoryCount.packCount.integerValue;
    }
    
    itemInventoryReconcileCount.singleCount = @(singleCount);
    itemInventoryReconcileCount.caseCount = @(caseCount);
    itemInventoryReconcileCount.packCount = @(packCount);

    
    NSInteger totalCount = singleCount + caseCount + packCount;

    
    if (totalCount == itemInventoryReconcileCount.expectedQuantity.integerValue)
    {
        itemInventoryReconcileCount.isMatching = @(YES);
    }
    else
    {
        itemInventoryReconcileCount.isMatching = @(NO);
    }
}


-(void)updateItemForInventoryCountListwithDetail:(NSDictionary *)inventoryCountDictionary withItem:(Item *)item withitemInventoryCount:(ItemInventoryCount *)itemInventoryCount withItemInventorySession:(ItemInventoryCountSession *)itemInventoryCountSession withManageObjectContext:(NsmoContext *)context
{
    if (itemInventoryCount == nil)
    {
        itemInventoryCount = (ItemInventoryCount*)[self insertEntityWithName:@"ItemInventoryCount" moc:context];
        ItemInventoryReconcileCount *itemInventoryReconcileCount = [self fetchItemInventoryReconcileCount:itemInventoryCountSession.sessionId.stringValue withItemCode:item.itemCode moc:context];
        itemInventoryCount.itemInventoryReconcileCount = itemInventoryReconcileCount;
        [itemInventoryReconcileCount addItemInventoryCountsObject:itemInventoryCount];
    }
    [itemInventoryCount updateItemInventoryCountDictionary:inventoryCountDictionary];
    
    [itemInventoryCount.itemCountItem addItemItemCountObject:itemInventoryCount];
    itemInventoryCount.itemCountItem = item;
    [itemInventoryCount.itemInventoryCountSession addSessionItemCountObject:itemInventoryCount];
     itemInventoryCount.itemInventoryCountSession = itemInventoryCountSession;
    [self reconcileInventoryCountForObject:itemInventoryCount.itemInventoryReconcileCount];
    
    [UpdateManager saveContext:context];
    
//    itemInventoryCount.itemCountItem = nil;
//    [itemInventoryCount.itemCountItem removeItemItemCountObject:itemInventoryCount];
//    NsmoContext *moc = PVTCTX(self.parentManagedObjectContext__Sec);
//    NSManagedObjectID *itemManagedObjectID = item.objectID;
//    Item *newItemObject = (Item *)[moc objectWithID:itemManagedObjectID];
//    NSManagedObjectID *itemInventoryCountSessionManagedObjectID = itemInventoryCountSession.objectID;
//    ItemInventoryCountSession *newItemInventoryCountSession = (ItemInventoryCountSession *)[moc objectWithID:itemInventoryCountSessionManagedObjectID];
}



-(void)modifidedServerUpdateItemForInventoryCountHistoryListwithDetail:(NSDictionary *)inventoryCountDictionary withItem:(Item *)item withitemInventoryCount:(ItemInventoryCount *)itemInventoryCount withItemInventorySession:(ItemInventoryCountSession *)itemInventoryCountSession withInventoryCountSessionDetail:(NSDictionary *)inventoryCountSessionDictionary withManageObjectContext:(NsmoContext *)context
{
//    NSLog(@"Start Time to INSERT DATA = %@" ,[NSDate date]);
    
    ItemInventoryReconcileCount *itemInventoryReconcileCount = nil;
    if (itemInventoryCount == nil)
    {
        itemInventoryCount = (ItemInventoryCount*)[self insertEntityWithName:@"ItemInventoryCount" moc:context];
        itemInventoryReconcileCount = (ItemInventoryReconcileCount*) [self modifidedFetchItemInventoryReconcileCount:itemInventoryCountSession.sessionId.stringValue withItemCode:item.itemCode withItem:item withItemInventoryCountSession:itemInventoryCountSession witjInventoryCountSessionDetail:[inventoryCountDictionary mutableCopy] moc:context  isHistory:YES];
        itemInventoryCount.itemInventoryReconcileCount = itemInventoryReconcileCount;
        [itemInventoryReconcileCount addItemInventoryCountsObject:itemInventoryCount];
    }
    [itemInventoryCount updateItemInventoryCountDictionaryOfServer:inventoryCountDictionary];
    
    [itemInventoryCount.itemCountItem addItemItemCountObject:itemInventoryCount];
    itemInventoryCount.itemCountItem = item;
    [itemInventoryCount.itemInventoryCountSession addSessionItemCountObject:itemInventoryCount];
    itemInventoryCount.itemInventoryCountSession = itemInventoryCountSession;
    [self reconcileInventoryCountForHistoryObject:itemInventoryCount.itemInventoryReconcileCount];
   // itemInventoryReconcileCount.createDate = [NSDate date];
   [UpdateManager saveContext:context];
    
}

-(void)modifidedServerUpdateItemForInventoryCountListwithDetail:(NSDictionary *)inventoryCountDictionary withItem:(Item *)item withitemInventoryCount:(ItemInventoryCount *)itemInventoryCount withItemInventorySession:(ItemInventoryCountSession *)itemInventoryCountSession withInventoryCountSessionDetail:(NSDictionary *)inventoryCountSessionDictionary withManageObjectContext:(NsmoContext *)context
{
    //    NSLog(@"Start Time to INSERT DATA = %@" ,[NSDate date]);
    
    ItemInventoryReconcileCount *itemInventoryReconcileCount = nil;
    if (itemInventoryCount == nil)
    {
        itemInventoryCount = (ItemInventoryCount*)[self insertEntityWithName:@"ItemInventoryCount" moc:context];
        itemInventoryReconcileCount = (ItemInventoryReconcileCount*) [self modifidedFetchItemInventoryReconcileCount:itemInventoryCountSession.sessionId.stringValue withItemCode:item.itemCode withItem:item withItemInventoryCountSession:itemInventoryCountSession witjInventoryCountSessionDetail:[inventoryCountSessionDictionary mutableCopy] moc:context isHistory:NO];
        itemInventoryCount.itemInventoryReconcileCount = itemInventoryReconcileCount;
        [itemInventoryReconcileCount addItemInventoryCountsObject:itemInventoryCount];
    }
    [itemInventoryCount updateItemInventoryCountDictionaryOfServer:inventoryCountDictionary];
    
    [itemInventoryCount.itemCountItem addItemItemCountObject:itemInventoryCount];
    itemInventoryCount.itemCountItem = item;
    [itemInventoryCount.itemInventoryCountSession addSessionItemCountObject:itemInventoryCount];
    itemInventoryCount.itemInventoryCountSession = itemInventoryCountSession;
    [self reconcileInventoryCountForObject:itemInventoryCount.itemInventoryReconcileCount];
    
    [UpdateManager saveContext:context];
    
    
    
    //    NSLog(@"END Time to INSERT DATA = %@" ,[NSDate date]);
    
    
    //    itemInventoryCount.itemCountItem = nil;
    //    [itemInventoryCount.itemCountItem removeItemItemCountObject:itemInventoryCount];
    //    NsmoContext *moc = PVTCTX(self.parentManagedObjectContext__Sec);
    //    NSManagedObjectID *itemManagedObjectID = item.objectID;
    //    Item newItemObject = (Item )[moc objectWithID:itemManagedObjectID];
    //    NSManagedObjectID *itemInventoryCountSessionManagedObjectID = itemInventoryCountSession.objectID;
    //    ItemInventoryCountSession newItemInventoryCountSession = (ItemInventoryCountSession )[moc objectWithID:itemInventoryCountSessionManagedObjectID];
}

-(void)modifidedUpdateItemForInventoryCountListwithDetail:(NSDictionary *)inventoryCountDictionary withItem:(Item *)item withitemInventoryCount:(ItemInventoryCount *)itemInventoryCount withItemInventorySession:(ItemInventoryCountSession *)itemInventoryCountSession withInventoryCountSessionDetail:(NSDictionary *)inventoryCountSessionDictionary withManageObjectContext:(NsmoContext *)context
{
    
    ItemInventoryReconcileCount *itemInventoryReconcileCount = nil;
    if (itemInventoryCount == nil)
    {
        itemInventoryCount = (ItemInventoryCount*)[self insertEntityWithName:@"ItemInventoryCount" moc:context];
        itemInventoryReconcileCount = (ItemInventoryReconcileCount*) [self modifidedFetchItemInventoryReconcileCount:itemInventoryCountSession.sessionId.stringValue withItemCode:item.itemCode withItem:item withItemInventoryCountSession:itemInventoryCountSession witjInventoryCountSessionDetail:[inventoryCountSessionDictionary mutableCopy] moc:context isHistory:NO];
        itemInventoryCount.itemInventoryReconcileCount = itemInventoryReconcileCount;
        [itemInventoryReconcileCount addItemInventoryCountsObject:itemInventoryCount];
    }
    [itemInventoryCount updateItemInventoryCountDictionary:inventoryCountDictionary];
    
    [itemInventoryCount.itemCountItem addItemItemCountObject:itemInventoryCount];
    itemInventoryCount.itemCountItem = item;
    [itemInventoryCount.itemInventoryCountSession addSessionItemCountObject:itemInventoryCount];
    itemInventoryCount.itemInventoryCountSession = itemInventoryCountSession;
    [self reconcileInventoryCountForObject:itemInventoryCount.itemInventoryReconcileCount];
    
    [UpdateManager saveContext:context];
    
    //    itemInventoryCount.itemCountItem = nil;
    //    [itemInventoryCount.itemCountItem removeItemItemCountObject:itemInventoryCount];
    //    NsmoContext *moc = PVTCTX(self.parentManagedObjectContext__Sec);
    //    NSManagedObjectID *itemManagedObjectID = item.objectID;
    //    Item *newItemObject = (Item *)[moc objectWithID:itemManagedObjectID];
    //    NSManagedObjectID *itemInventoryCountSessionManagedObjectID = itemInventoryCountSession.objectID;
    //    ItemInventoryCountSession *newItemInventoryCountSession = (ItemInventoryCountSession *)[moc objectWithID:itemInventoryCountSessionManagedObjectID];
}



-(void)updateItemReceiveListwithDetail:(NSDictionary *)receiveItemDictionary withItem:(Item *)item withitemReceive:(ManualReceivedItem *)itemreceive withManualPoSession:(ManualPOSession *)posession withManageObjectContext:(NsmoContext *)context
{
    if (itemreceive == nil)
    {
        itemreceive = (ManualReceivedItem *)[self insertEntityWithName:@"ManualReceivedItem" moc:context];
        itemreceive.item=item;
        itemreceive.supplierIDitems=posession;
        [posession addSupplierIDsessionObject:itemreceive];
        [item addManualEntriesObject:itemreceive];
        
    }
     [itemreceive updateManualPoitemDictionary:receiveItemDictionary];
    [UpdateManager saveContext:context];

}


-(void)updatePurchaseOrderItemListwithDetail:(NSDictionary *)receivePOItemDictionary withVendorItem:(Vendor_Item *)vitem withpurchaseOrderItem:(VPurchaseOrderItem *)vPoitemreceive withPurchaseOrder:(VPurchaseOrder *)vPurchaseOrder withManageObjectContext:(NsmoContext *)context
{
    if (vPoitemreceive == nil)
    {
        vPoitemreceive = (VPurchaseOrderItem *)[self insertEntityWithName:@"VPurchaseOrderItem" moc:context];
        vPoitemreceive.vitems=vitem;
        vPoitemreceive.vpoId=vPurchaseOrder;
        [vPurchaseOrder addPoIdItemObject:vPoitemreceive];
        [vitem addVpoitemsObject:vPoitemreceive];
        
    }
    [vPoitemreceive updateVendorPoItemDictionary:receivePOItemDictionary];
    [UpdateManager saveContext:context];
    
}
-(VPurchaseOrderItem *)updatePurchaseOrderItemListwithDetailReturn:(NSDictionary *)receivePOItemDictionary withVendorItem:(Vendor_Item *)vitem withpurchaseOrderItem:(VPurchaseOrderItem *)vPoitemreceive withPurchaseOrder:(VPurchaseOrder *)vPurchaseOrder withManageObjectContext:(NsmoContext *)context
{
    if (vPoitemreceive == nil)
    {
        vPoitemreceive = (VPurchaseOrderItem *)[self insertEntityWithName:@"VPurchaseOrderItem" moc:context];
        vPoitemreceive.vitems=vitem;
        vPoitemreceive.vpoId=vPurchaseOrder;
        [vPurchaseOrder addPoIdItemObject:vPoitemreceive];
        [vitem addVpoitemsObject:vPoitemreceive];
        
    }
    [vPoitemreceive updateVendorPoItemDictionary:receivePOItemDictionary];
    [UpdateManager saveContext:context];
    
    return vPoitemreceive;
    
}



-(ManualReceivedItem *)updateItemReceiveListwithDetailReturn:(NSDictionary *)receiveItemDictionary withItem:(Item *)item withitemReceive:(ManualReceivedItem *)itemreceive withManualPoSession:(ManualPOSession *)posession withManageObjectContext:(NsmoContext *)context
{
    if (itemreceive == nil)
    {
        itemreceive = (ManualReceivedItem *)[self insertEntityWithName:@"ManualReceivedItem" moc:context];
        itemreceive.item=item;
        itemreceive.supplierIDitems=posession;
        [posession addSupplierIDsessionObject:itemreceive];
        [item addManualEntriesObject:itemreceive];
        
    }
    [itemreceive updateManualPoitemDictionary:receiveItemDictionary];
    [UpdateManager saveContext:context];
    
    return itemreceive;
}


-(void)updateItemForInventoryCountListwithServerDetail:(NSDictionary *)inventoryCountDictionary withItem:(Item *)item withitemInventoryCount:(ItemInventoryCount *)itemInventoryCount withItemInventorySession:(ItemInventoryCountSession *)itemInventoryCountSession withManageObjectContext:(NsmoContext *)context
{
    if (itemInventoryCount == nil)
    {
        itemInventoryCount = (ItemInventoryCount*)[self insertEntityWithName:@"ItemInventoryCount" moc:context];
        ItemInventoryReconcileCount *itemInventoryReconcileCount = [self fetchItemInventoryReconcileCount:itemInventoryCountSession.sessionId.stringValue withItemCode:item.itemCode moc:context];
        itemInventoryCount.itemInventoryReconcileCount = itemInventoryReconcileCount;
        [itemInventoryReconcileCount addItemInventoryCountsObject:itemInventoryCount];
    }
    [itemInventoryCount updateItemInventoryCountDictionaryOfServer:inventoryCountDictionary];
    
    [itemInventoryCount.itemCountItem addItemItemCountObject:itemInventoryCount];
    itemInventoryCount.itemCountItem = item;
    [itemInventoryCount.itemInventoryCountSession addSessionItemCountObject:itemInventoryCount];
    itemInventoryCount.itemInventoryCountSession = itemInventoryCountSession;
    
    if([inventoryCountDictionary valueForKey:@"QtyOnHand"] != nil)
    {
        itemInventoryCount.itemInventoryReconcileCount.expectedQuantity = @([[inventoryCountDictionary valueForKey:@"QtyOnHand"] integerValue]);
    }
    
    [self reconcileInventoryCountForObject:itemInventoryCount.itemInventoryReconcileCount];
    [UpdateManager saveContext:context];
    
    //    itemInventoryCount.itemCountItem = nil;
    //    [itemInventoryCount.itemCountItem removeItemItemCountObject:itemInventoryCount];
    //    NsmoContext *moc = PVTCTX(self.parentManagedObjectContext__Sec);
    //    NSManagedObjectID *itemManagedObjectID = item.objectID;
    //    Item *newItemObject = (Item *)[moc objectWithID:itemManagedObjectID];
    //    NSManagedObjectID *itemInventoryCountSessionManagedObjectID = itemInventoryCountSession.objectID;
    //    ItemInventoryCountSession *newItemInventoryCountSession = (ItemInventoryCountSession *)[moc objectWithID:itemInventoryCountSessionManagedObjectID];
}

-(void)removeItemInventoryCount:(ItemInventoryCount *)itemInventoryCount withManageObjectContext:(NsmoContext *)context
{
    ItemInventoryReconcileCount *reConcileObject = itemInventoryCount.itemInventoryReconcileCount;
    [UpdateManager deleteFromContext:context object:itemInventoryCount];
    [UpdateManager saveContext:context];
    [self reconcileInventoryCountForObject:reConcileObject];
    [UpdateManager saveContext:context];
}


- (ItemInventoryCountSession*)insertInventoryCountSessionInLocalDataBaseWithDetail :(NSDictionary *)inventoryCountSessionDetail withContext:(NsmoContext *)context
{
    ItemInventoryCountSession *itemInventoryCountSession=nil;
    itemInventoryCountSession = (ItemInventoryCountSession*)[self insertEntityWithName:@"ItemInventoryCountSession" moc:context];
    [itemInventoryCountSession updateItemInventoryCountDictionary:inventoryCountSessionDetail];
    
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:context];
//    [fetchRequest setEntity:entity];
//    NSArray *resultSet = [UpdateManager executeForContext:context FetchRequest:fetchRequest];
//    if(resultSet.count > 0)
//    {
//        for (Item *item in resultSet)
//        {
//            ItemInventoryReconcileCount *itemInventoryReconcileCount = nil;
//            itemInventoryReconcileCount = (ItemInventoryReconcileCount*)[self insertEntityWithName:@"ItemInventoryReconcileCount" moc:context];
//            [itemInventoryReconcileCount resetItemInventoryCountSessionWithDictionary:inventoryCountSessionDetail withItem:item];
//            [itemInventoryReconcileCount.itemInventoryReconcileSession addSessionReconcileCountsObject:itemInventoryReconcileCount];
//            itemInventoryReconcileCount.itemInventoryReconcileSession = itemInventoryCountSession;
//        }
//    }
    
    [UpdateManager saveContext:context];
    return itemInventoryCountSession;
}

- (ItemInventoryCountSession*)fetchItemInventoryCountSession:(NSString *)sessionId moc:(NsmoContext*)moc
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ItemInventoryCountSession" inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sessionId == %d", sessionId.integerValue];
    fetchRequest.predicate = predicate;
    NSArray *resultSet = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    ItemInventoryCountSession *itemInventoryCountSession=nil;
    if (resultSet.count>0) {
        itemInventoryCountSession=resultSet.firstObject;
    }
    return itemInventoryCountSession;
}

- (ItemInventoryReconcileCount*)modifidedFetchItemInventoryReconcileCount:(NSString *)sessionId withItemCode:(NSNumber *)itemId withItem:(Item*)item withItemInventoryCountSession:(ItemInventoryCountSession *)itemInventoryCountSession witjInventoryCountSessionDetail:(NSMutableDictionary *)inventoryCountSessionDetail moc:(NsmoContext*)moc isHistory:(BOOL)isHistory
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ItemInventoryReconcileCount" inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sessionId == %d AND itemCode == %@", sessionId.integerValue, itemId];
    fetchRequest.predicate = predicate;
    NSArray *resultSet = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    ItemInventoryReconcileCount *itemInventoryReconcileCount = nil;
    if (resultSet.count>0) {
        itemInventoryReconcileCount = resultSet.firstObject;
    }
    else
    {
        
        itemInventoryReconcileCount = (ItemInventoryReconcileCount*)[self insertEntityWithName:@"ItemInventoryReconcileCount" moc:moc];
        if (isHistory) {
            [itemInventoryReconcileCount resetItemInventoryCountSessionForHistoryWithDictionary:inventoryCountSessionDetail withItem:item];

        }
        else{
            [itemInventoryReconcileCount resetItemInventoryCountSessionWithDictionary:inventoryCountSessionDetail withItem:item];
        }
        [itemInventoryReconcileCount.itemInventoryReconcileSession addSessionReconcileCountsObject:itemInventoryReconcileCount];
        itemInventoryReconcileCount.itemInventoryReconcileSession = itemInventoryCountSession;
//        [UpdateManager saveContext:moc];

    }
    return itemInventoryReconcileCount;
}
-(void)insertReconcileCountForItem:(Item *)item withDetail:(NSMutableDictionary *)reconcileSessionlistDictionary withReconcileSession:(ItemInventoryCountSession *)itemInventoryCountSession withContext:(NsmoContext *)moc
{
    ItemInventoryReconcileCount  *itemInventoryReconcileCount = (ItemInventoryReconcileCount*)[self insertEntityWithName:@"ItemInventoryReconcileCount" moc:moc];
    [itemInventoryReconcileCount resetItemInventoryCountSessionWithDictionary:reconcileSessionlistDictionary withItem:item];
    [itemInventoryReconcileCount.itemInventoryReconcileSession addSessionReconcileCountsObject:itemInventoryReconcileCount];
    itemInventoryReconcileCount.itemInventoryReconcileSession = itemInventoryCountSession;

}

- (ItemInventoryReconcileCount*)fetchItemInventoryReconcileCount:(NSString *)sessionId withItemCode:(NSNumber *)itemId moc:(NsmoContext*)moc
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ItemInventoryReconcileCount" inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sessionId == %d AND itemCode == %@", sessionId.integerValue, itemId];
    fetchRequest.predicate = predicate;
    NSArray *resultSet = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    ItemInventoryReconcileCount *itemInventoryCountSession=nil;
    if (resultSet.count>0) {
        itemInventoryCountSession=resultSet.firstObject;
    }
    return itemInventoryCountSession;
}

-(void)cleanUptheManaulPoTables:(NsmoContext *)moc{

    
    NSArray *manulPOsession=[self fetchAllPoDetails:moc];
    for (NSManagedObject *posession in manulPOsession)
    {
        [UpdateManager deleteFromContext:moc object:posession];
    }

    
    NSArray *manulPOsessionitem=[self fetchAllPoitemDetails:moc];
    for (NSManagedObject *posessionItem in manulPOsessionitem)
    {
        [UpdateManager deleteFromContext:moc object:posessionItem];
    }
    
    [UpdateManager saveContext:moc];

}

- (NSArray*)fetchAllPoDetails:(NsmoContext *)moc
{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ManualPOSession" inManagedObjectContext:moc];
    fetchRequest.entity = entity;

    NSArray *arryTemp = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    
    return arryTemp;
}
- (NSArray*)fetchAllPoitemDetails:(NsmoContext *)moc
{

    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ManualReceivedItem" inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    
    NSArray *arryTemp = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    
    return arryTemp;
}
- (NSArray*)fetchAllPoitemDetailsFromID:(NsmoContext *)moc withItemID:(NSString *)strID;
{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ManualReceivedItem" inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"receivedItemId==%d", strID.integerValue];
    fetchRequest.predicate = predicate;
    
    NSArray *arryTemp = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    
    return arryTemp;
}

- (NSArray*)getPurchaseOrderItem:(NsmoContext *)moc withItemID:(NSString *)stritemID andPoID:(NSString *)strpoId;
{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"VPurchaseOrderItem" inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"poItemId==%d && vpoId.poId = %d", stritemID.integerValue,strpoId.integerValue];
    fetchRequest.predicate = predicate;
    
    NSArray *arryTemp = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    
    return arryTemp;
}

-(void)insertDepartmentWithDictionary:(NSDictionary *)departmentDictionary
{
    NsmoContext *privateManagedObjectContext = PVTCTX(self.parentManagedObjectContext__Sec);
    
    Department *department = (Department*)[self insertEntityWithName:@"Department" moc:privateManagedObjectContext];
    [department updateDepartmentFromDictionary:departmentDictionary];
    [self linkWithItemsDepartment:department moc:privateManagedObjectContext];
    [UpdateManager saveContext:privateManagedObjectContext];
}
//// Change It
-(void)insertTaxMasterWithDictionary:(NSDictionary *)taxMasterDictionary
{
    NsmoContext *privateManagedObjectContext = PVTCTX(self.parentManagedObjectContext__Sec);
    
    TaxMaster *taxMaster = (TaxMaster*)[self insertEntityWithName:@"TaxMaster" moc:privateManagedObjectContext];
    [taxMaster updateTaxMasterFromDictionary:taxMasterDictionary];
    [UpdateManager saveContext:privateManagedObjectContext];
}

-(void)insertCustomerWithDictionary:(NSDictionary *)customerDictionary
{
    NsmoContext *privateManagedObjectContext = PVTCTX(self.parentManagedObjectContext__Sec);
    
    Customer *customer = (Customer*)[self insertEntityWithName:@"Customer" moc:privateManagedObjectContext];
    [customer updateCustomerDetailDictionary:customerDictionary];
    [UpdateManager saveContext:privateManagedObjectContext];
}

-(void)insertPayMasterWithDictionary:(NSDictionary *)payMasterDictionary
{
    NsmoContext *privateManagedObjectContext = PVTCTX(self.parentManagedObjectContext__Sec);
    
    TenderPay *tenderPay = (TenderPay*)[self insertEntityWithName:@"TenderPay" moc:privateManagedObjectContext];
    [tenderPay updateTenderPayFromDictionary:payMasterDictionary];
    [UpdateManager saveContext:privateManagedObjectContext];
}
-(void)insertSupplierCompanyWithDictionary:(NSDictionary *)departmentDictionary
{
    NsmoContext *privateManagedObjectContext = PVTCTX(self.parentManagedObjectContext__Sec);
    SupplierCompany *department = (SupplierCompany*)[self insertEntityWithName:@"SupplierCompany" moc:privateManagedObjectContext];
    [department updateSupplierCompanyDictionary:departmentDictionary];
    [UpdateManager saveContext:privateManagedObjectContext];
}

 -(void)updateDepartmentWithDictionary:(NSDictionary *)departmentDictionary
{
    NsmoContext *privateManagedObjectContext = PVTCTX(self.parentManagedObjectContext__Sec);
    Department *department = [self fetchDepartmentWithDepartmentId:[departmentDictionary valueForKey:@"DeptId"] shouldCreate:YES moc:privateManagedObjectContext];
    [department updateDepartmentFromDictionary:departmentDictionary];
    [UpdateManager saveContext:privateManagedObjectContext];
}
//// Change it
-(void)updateTaxMasterWithDictionary:(NSDictionary *)taxMasterDictionary
{
    NsmoContext *privateManagedObjectContext = PVTCTX(self.parentManagedObjectContext__Sec);
    TaxMaster *taxMaster = [self fetchTaxMastertWithTaxId:[taxMasterDictionary valueForKey:@"TaxId"] shouldCreate:YES moc:privateManagedObjectContext];
    [taxMaster updateTaxMasterFromDictionary:taxMasterDictionary];
    [UpdateManager saveContext:privateManagedObjectContext];
}

-(void)updatePayMasterWithDictionary:(NSDictionary *)payMasterDictionary
{
    NsmoContext *privateManagedObjectContext = PVTCTX(self.parentManagedObjectContext__Sec);
    TenderPay *tenderPay = [self fetchPayMasterWithPayId:[payMasterDictionary valueForKey:@"payId"] shouldCreate:YES moc:privateManagedObjectContext];
    [tenderPay updateTenderPayFromDictionary:payMasterDictionary];
    [UpdateManager saveContext:privateManagedObjectContext];
}

-(void)updateCustomerWithDictionary:(NSDictionary *)customerDictionary
{
    NsmoContext *privateManagedObjectContext = PVTCTX(self.parentManagedObjectContext__Sec);
    Customer *customer = [self fetchCustomerWithCustId:[customerDictionary valueForKey:@"CustId"] shouldCreate:YES moc:privateManagedObjectContext];
    [customer updateCustomerDetailDictionary:customerDictionary];
    [UpdateManager saveContext:privateManagedObjectContext];
}

- (Department*)fetchDepartmentWithDepartmentId:(NSString*)departmentId shouldCreate:(BOOL)shouldCreate moc:(NsmoContext*)moc
{
    // Entity Description
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Department" inManagedObjectContext:moc];
    
    // Fetch Request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = entity;
    
    // Predicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"deptId == %d", departmentId.integerValue];
    fetchRequest.predicate = predicate;
    
    // Execute Fetch Request
    NSArray *arryTemp = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    
    NSManagedObject *anObject = nil;
    if (arryTemp.count == 0) {
        // No data found
        if (shouldCreate) {
            // Create new object
            anObject = [NSEntityDescription insertNewObjectForEntityForName:@"Department" inManagedObjectContext:moc];
        }
    }
    else
    {
        // Get the first object
        anObject = arryTemp.firstObject;
    }
    return (Department *)anObject;
}


/////////////////// Change it

- (TaxMaster *)fetchTaxMastertWithTaxId:(NSString*)taxId shouldCreate:(BOOL)shouldCreate moc:(NsmoContext*)moc
{
    // Entity Description
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TaxMaster" inManagedObjectContext:moc];
    
    // Fetch Request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = entity;
    
    // Predicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"taxId == %d", taxId.integerValue];
    fetchRequest.predicate = predicate;
    
    // Execute Fetch Request
    NSArray *arryTemp = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    
    NSManagedObject *anObject = nil;
    if (arryTemp.count == 0) {
        // No data found
        if (shouldCreate) {
            // Create new object
            anObject = [NSEntityDescription insertNewObjectForEntityForName:@"TaxMaster" inManagedObjectContext:moc];
        }
    }
    else
    {
        // Get the first object
        anObject = arryTemp.firstObject;
    }
    return (TaxMaster *)anObject;
}

- (Customer *)fetchCustomerWithCustId:(NSString*)custId shouldCreate:(BOOL)shouldCreate moc:(NsmoContext*)moc
{
    // Entity Description
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Customer" inManagedObjectContext:moc];
    
    // Fetch Request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = entity;
    
    // Predicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"custId == %d", custId.integerValue];
    fetchRequest.predicate = predicate;
    
    // Execute Fetch Request
    NSArray *arryTemp = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    
    NSManagedObject *anObject = nil;
    if (arryTemp.count == 0) {
        // No data found
        if (shouldCreate) {
            // Create new object
            anObject = [NSEntityDescription insertNewObjectForEntityForName:@"Customer" inManagedObjectContext:moc];
        }
    }
    else
    {
        // Get the first object
        anObject = arryTemp.firstObject;
    }
    return (Customer *)anObject;
}

- (TenderPay *)fetchPayMasterWithPayId:(NSString*)payId shouldCreate:(BOOL)shouldCreate moc:(NsmoContext*)moc
{
    // Entity Description
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TenderPay" inManagedObjectContext:moc];
    
    // Fetch Request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = entity;
    
    // Predicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"payId == %d", payId.integerValue];
    fetchRequest.predicate = predicate;
    
    // Execute Fetch Request
    NSArray *arryTemp = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    
    NSManagedObject *anObject = nil;
    if (arryTemp.count == 0) {
        // No data found
        if (shouldCreate) {
            // Create new object
            anObject = [NSEntityDescription insertNewObjectForEntityForName:@"TenderPay" inManagedObjectContext:moc];
        }
    }
    else
    {
        // Get the first object
        anObject = arryTemp.firstObject;
    }
    return (TenderPay *)anObject;
}


//

-(void)deleteAllPurchaseOrders:(NsmoContext *)moc{
    
    NSArray *purchaseOrder=[self fetchAllPurchaseOrderDetails:moc];
    for (NSManagedObject *podetail in purchaseOrder)
    {
        [UpdateManager deleteFromContext:moc object:podetail];
    }
    [UpdateManager saveContext:moc];
}
-(void)deleteAllPurchaseOrdersItems:(NsmoContext *)moc{
    
    NSArray *purchaseOrderitem=[self fetchAllPOItems:moc];
    for (NSManagedObject *poItem in purchaseOrderitem)
    {
        [UpdateManager deleteFromContext:moc object:poItem];
    }
    
    [UpdateManager saveContext:moc];
}

- (NSArray*)fetchAllPurchaseOrderDetails:(NsmoContext *)moc
{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"VPurchaseOrder" inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    
    NSArray *arryTemp = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    
    return arryTemp;
}
- (NSArray*)fetchAllPOItems:(NsmoContext *)moc
{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"VPurchaseOrderItem" inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    
    NSArray *arryTemp = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    
    return arryTemp;
}

- (Vendor_Item *)fetchVendorItem :(NSInteger)itemId manageObjectContext:(NsmoContext *)context
{
    Vendor_Item *vitem=nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Vendor_Item" inManagedObjectContext:context];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"vin==%d", itemId];
    fetchRequest.predicate = predicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:context FetchRequest:fetchRequest];
    if (resultSet.count>0)
    {
        vitem=resultSet.firstObject;
    }
    return vitem;
}




#pragma mark - Offline Management For Database

- (NSArray *)fetchManageObjectWithUserId:(NSNumber *)userId intheEntity:(NSString *)entityName manageObjectContext:(NsmoContext *)context
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:entityName inManagedObjectContext:context];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId==%@", userId];
    fetchRequest.predicate = predicate;
        NSArray *resultSet = [UpdateManager executeForContext:context FetchRequest:fetchRequest];
    return resultSet;
}

- (void)deleteDetailOfUserInfoWithUserId:(NSNumber *)userId withContext:(NsmoContext *)privateContextObject
{
    NSArray *deleteTableDetail = @[@"UserInfo" ,@"RightInfo",@"CredentialInfo"];
    for (NSString *tableName in deleteTableDetail)
    {
         NSArray *resultSet = [self fetchManageObjectWithUserId:userId intheEntity:tableName manageObjectContext:privateContextObject];
        for (NSManagedObject *product in resultSet)
        {
            [UpdateManager deleteFromContext:privateContextObject object:product];
        }
    }
    [UpdateManager saveContext:privateContextObject];
}

- (void)deleteDetailOfUserInfo:(NsmoContext *)privateContextObject
{
    NSArray *deleteTableDetail = @[@"UserInfo" ,@"RightInfo",@"CredentialInfo"];
    for (NSString *tableName in deleteTableDetail)
    {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entity = [NSEntityDescription
                                       entityForName:tableName inManagedObjectContext:privateContextObject];
        fetchRequest.entity = entity;
        NSArray *arryTemp = [UpdateManager executeForContext:privateContextObject FetchRequest:fetchRequest];
        for (NSManagedObject *product in arryTemp)
        {
            [UpdateManager deleteFromContext:privateContextObject object:product];
        }
    }
       [UpdateManager saveContext:privateContextObject];
}

-(void)updateDetailWithUserInfo:(NSDictionary *)allUserInfoDictionary withmoc:(NsmoContext *)context
{
    NSArray *totalUserInfoDetail = [allUserInfoDictionary valueForKey:@"UserInfo"];
    NSArray *totalRightInfoDetail = [allUserInfoDictionary valueForKey:@"RightInfo"];
    //NSArray *totalRoleInfoDetail = [[allUserInfoDictionary valueForKey:@"RoleInfo"] firstObject];
    
    for (NSDictionary *userInfoDictionary  in totalUserInfoDetail)
    {
        UserInfo *userInfo = nil;
        userInfo = (UserInfo *)[self insertEntityWithName:@"UserInfo" moc:context];
        [userInfo updateUserInfoDictionary:userInfoDictionary];
        [self updateRightInfoWithDetail:totalRightInfoDetail forUser:userInfo withContext:context];
       // [self updateRoleInfoWithDetail:totalRoleInfoDetail forUser:userInfo withContext:context];
        [self updateCredentialWithDetail:userInfoDictionary forUser:userInfo withContext:context];
    }
}

- (UserInfo *)fetchUserInfo:(NSNumber *)userId usingMOC:(NsmoContext *)context usingPredicate:(NSPredicate *)predicate
{
    UserInfo *userInfo = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"UserInfo" inManagedObjectContext:context];
    fetchRequest.entity = entity;
    fetchRequest.predicate = predicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:context FetchRequest:fetchRequest];
    if (resultSet.count == 0)
    {
        userInfo = (UserInfo *)[self insertEntityWithName:@"UserInfo" moc:context];
    }
    else
    {
        userInfo = resultSet.firstObject;
    }
    return userInfo;
}

- (void)deleteUserRights:(NsmoContext *)privateContextObject usingPredicate:(NSPredicate *)predicate
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"RightInfo" inManagedObjectContext:privateContextObject];
    fetchRequest.entity = entity;
    fetchRequest.predicate = predicate;
    
    NSArray *arryTemp = [UpdateManager executeForContext:privateContextObject FetchRequest:fetchRequest];
    for (NSManagedObject *product in arryTemp)
    {
        [UpdateManager deleteFromContext:privateContextObject object:product];
    }
    [UpdateManager saveContext:privateContextObject];
}

-(void)updateRightInfoWithDetail:(NSArray *)allUserRightInfo forUser:(UserInfo *)userInfo withContext:(NsmoContext *)context
{
    NSPredicate *predicateForRightInfo = [NSPredicate predicateWithFormat:@"UserId = %d",userInfo.userId.integerValue
                                          ];
    NSArray *rightInfoDetail = [allUserRightInfo filteredArrayUsingPredicate:predicateForRightInfo];
    for (NSDictionary *rightInfoDictionary in rightInfoDetail) {
        RightInfo *rightInfo = nil;
        rightInfo = (RightInfo *)[self insertEntityWithName:@"RightInfo" moc:context];
        [rightInfo updateRightInfoDictionary:rightInfoDictionary];
        [userInfo addUserRightObject:rightInfo];
        rightInfo.userInfo = userInfo;
    }
}

-(void)updateRoleInfoWithDetail:(NSArray *)allUserRoleInfo forUser:(UserInfo *)userInfo withContext:(NsmoContext *)context
{
    NSPredicate *predicateForRoleInfo = [NSPredicate predicateWithFormat:@"UserId = %d",userInfo.userId];
    NSArray *roleInfoDetail = [allUserRoleInfo filteredArrayUsingPredicate:predicateForRoleInfo];

    for (NSDictionary *roleInfoDictionary in roleInfoDetail) {
        RoleInfo *roleInfo = nil;
        roleInfo = (RoleInfo *)[self insertEntityWithName:@"RoleInfo" moc:context];
        [roleInfo updateRoleInfoDictionary:roleInfoDictionary];
        [userInfo addUserRoleObject:roleInfo];
        roleInfo.roleToUser = userInfo;
    }
}

-(void)updateCredentialWithDetail:(NSDictionary *)credntialInformation forUser:(UserInfo *)userInfo withContext:(NsmoContext *)context
{
    CredentialInfo *credentialInfo = nil;
    credentialInfo = (CredentialInfo *)[self insertEntityWithName:@"CredentialInfo" moc:context];
    [credentialInfo updateCredetnialDictionary:credntialInformation];
    [userInfo addUserCredentialObject:credentialInfo];
    credentialInfo.credentialToUser = userInfo;
}

-(void)insertHoldTransctionInLocalDataBase:(NSDictionary *)holdDictionary withContext:(NsmoContext *)context
{
    HoldInvoice *holdInvoice = nil;
    holdInvoice = (HoldInvoice *)[self insertEntityWithName:@"HoldInvoice" moc:context];
    [holdInvoice updateholdInvoiceFromDictionary:holdDictionary];
    [UpdateManager saveContext:context];
}

-(void)updateHoldTransctionInLocalDataBase:(NSDictionary *)holdDictionary withContext:(NsmoContext *)context
{
    HoldInvoice *holdInvoice = (HoldInvoice *)[self __fetchEntityWithName:@"HoldInvoice" key:@"transActionNo" value:@([[holdDictionary valueForKey:@"HoldTransActionNo"] integerValue]) shouldCreate:NO moc:context];
    [holdInvoice updateholdInvoiceFromDictionary:holdDictionary];
    [UpdateManager saveContext:context];
}

-(void)insertNoSaleToLocalDatabase:(NSDictionary *)noSaleDictionary withContext:(NsmoContext *)context
{
    NoSale *noSale = nil;
    noSale = (NoSale *)[self insertEntityWithName:@"NoSale" moc:context];
    [noSale updateNoSaleDictionary:noSaleDictionary];
    [UpdateManager saveContext:context];
}

-(RestaurantOrder *)fetchRestaurantOrderForInvoiceNo:(NSString *)invoiceNo withContext:(NSManagedObjectContext *)moc
{
    RestaurantOrder *restaurantOrder = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"RestaurantOrder" inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"invoiceNo = %@", invoiceNo];
    fetchRequest.predicate = predicate;
    NSArray *resultSet = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    if (resultSet.count > 0) {
        restaurantOrder = resultSet.firstObject;
    }
    return restaurantOrder;
}



-(RestaurantOrder *)insertRestaurantOrderListInLocalDataBase:(NSDictionary *)restaurantOrderListDictionary withContext:(NsmoContext *)context
{
//    RestaurantOrder *restaurantOrder = [self fetchRestaurantOrderForInvoiceNo:restaurantOrderListDictionary[@"InvoiceNo"] withContext:context];
    RestaurantOrder *restaurantOrder;
    if (restaurantOrder == nil) {
        restaurantOrder = (RestaurantOrder *)[self insertEntityWithName:@"RestaurantOrder" moc:context];
    }
    
    [restaurantOrder updateRestaurantOrderDictionary:restaurantOrderListDictionary];
    [UpdateManager saveContext:context];
    
    return restaurantOrder;
}
-(RestaurantItem *)insertRestaurantItemInLocalDataBase:(NSDictionary *)restaurantOrderItemDictionary withContext:(NsmoContext *)context withItemRestaurantOrder:(RestaurantOrder *)restaurantOrder withItem:(Item *)anitem
{
    RestaurantItem *restaurantItem = nil;
    restaurantItem = (RestaurantItem *)[self insertEntityWithName:@"RestaurantItem" moc:context];
    [restaurantItem updateRestaurantItemDictionary:restaurantOrderItemDictionary];
    [restaurantOrder addRestaurantOrderItemObject:restaurantItem];
    restaurantOrder.paymentData = nil;
    restaurantItem.itemToOrderRestaurant = restaurantOrder;
    restaurantItem.restaurantItemToItem = anitem;
    [anitem addItemToRestaurantItemObject:restaurantItem];
    [UpdateManager saveContext:context];
    return restaurantItem;
}

-(void)insertShiftDetailToLocalDatabase:(NSDictionary *)shiftDictionary withContext:(NsmoContext *)context
{
    ShiftDetail *shiftDetail = nil;
    shiftDetail = (ShiftDetail * )[self manageObjectForEntity:@"ShiftDetail" withContext:context];
    [shiftDetail updateShiftDetailDictionary:shiftDictionary];
}


+ (NSManagedObject*)objectCopy:(NSManagedObject*)object fromContext:(NsmoContext *)context {
    return (object==nil)?nil:[context objectWithID:object.objectID];
}

#pragma mark - MixMatch Discount -

/*!
 *  @author Siya Infotech, 16-02-03 10:02:15
 *
 *  Delete updated MMD detail and new insert data and linking data
 *
 *  @param privateManagedObjectContext moc
 *  @param updateResponseDictionary    responce disctionary
 */
-(void)configureMMDDataWithContex:(NsmoContext *)privateManagedObjectContext andChangedData:(NSDictionary*)updateResponseDictionary {

    NSMutableArray *discountArray=[updateResponseDictionary valueForKey:@"DiscountMasterArray"];
    
    if (discountArray.count > 0) {
//        [self deleteAllObjectFromEntityName:@[@"Discount_M",@"Discount_Primary_MD",@"Discount_Secondary_MD"] with:privateManagedObjectContext];
//        [self deleteAllObjectFromEntityName:@[@"Discount_Primary_MD",@"Discount_Secondary_MD"] with:privateManagedObjectContext];

        
        NSMutableArray * arrIdList = [[discountArray valueForKey:@"DiscountId"] mutableCopy];
        [arrIdList addObject:@(0)];
        //    [self deleteObjectFromEntityName:@"Discount_M" withKey:@"id" value:arrIdList with:privateManagedObjectContext];
        
        [self insertDiscountFromlist:discountArray moc:privateManagedObjectContext withCount:0 withRemainItemCount:0];
        
        
        // For Primary Item Detail
        NSMutableArray *primaryArray=[updateResponseDictionary valueForKey:@"DiscountPrimaryArray"];
        [self deleteObjectFromEntityName:@"Discount_Primary_MD" withKey:@"discountId" value:arrIdList with:privateManagedObjectContext];
        
        [self insertDiscountPrimaryArrayFromlist:primaryArray moc:privateManagedObjectContext withCount:0 withRemainItemCount:0];
        
        // For Secondary Item Detail
        NSMutableArray *secondaryArray=[updateResponseDictionary valueForKey:@"DiscountSecondaryArray"];
        
        [self deleteObjectFromEntityName:@"Discount_Secondary_MD" withKey:@"discountId" value:arrIdList with:privateManagedObjectContext];
        
        [self insertDiscountSecondaryArrayFromlist:secondaryArray moc:privateManagedObjectContext withCount:0 withRemainItemCount:0];
    }
}
/*!
 *  @author Siya Infotech, 16-02-03 10:02:33
 *
 *  Delete all object of any entity
 *
 *  @param arrEntityList Entity Name List
 *  @param moc           moc
 */
-(void)deleteObjectFromEntityName:(NSString *)strEntityList withKey:(NSString *)strKey value:(NSArray *) arrvalue with:(NsmoContext *)moc {

    NSSet * uniqueIds = [NSSet setWithArray:arrvalue];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"%K IN %@",strKey, uniqueIds.allObjects];
    request.predicate = predicate;
    request.entity = [NSEntityDescription entityForName:strEntityList inManagedObjectContext:moc];
    [request setIncludesPropertyValues:NO];
    NSArray *allObject = [moc executeFetchRequest:request error:nil];
    for (NSManagedObject * obj in allObject) {
        [moc deleteObject:obj];
    }
}
-(void)deleteAllObjectFromEntityName:(NSArray *)arrEntityList with:(NsmoContext *)moc {

//    if ([[UIDevice currentDevice].systemVersion floatValue] >= 9) {
//        for (NSString * strEntity in arrEntityList) {
//            NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:strEntity];
//            NSBatchDeleteRequest *delete = [[NSBatchDeleteRequest alloc] initWithFetchRequest:request];
//            [moc.persistentStoreCoordinator executeRequest:delete withContext:moc error:nil];
//        }
//    }
//    else {
        for (NSString * strEntity in arrEntityList) {
            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            request.entity = [NSEntityDescription entityForName:strEntity inManagedObjectContext:moc];
            [request setIncludesPropertyValues:NO]; //only fetch the managedObjectID
            
            NSArray *allObject = [moc executeFetchRequest:request error:nil];
            for (NSManagedObject * obj in allObject) {
                [moc deleteObject:obj];
            }
        }
//    }
}

/*!
 *  @author Siya Infotech, 16-02-03 10:02:40
 *
 *  insert Discount entity and linking with item
 *
 *  @param discountList       array<dictionary> of discount list
 *  @param moc                moc
 *  @param totalcount         if devide phase configure then pass all items count in phase3
 *  @param remainingItemCount if devide phase configure then pass all items inserted count in phase3
 *
 *  @return items inserted count in phase3
 */
-(NSInteger)insertDiscountFromlist:(NSArray *)discountList moc:(NsmoContext*)moc withCount:(NSInteger)totalcount withRemainItemCount:(NSInteger)remainingItemCount
{
    NSInteger totalItemsCount = discountList.count;
    NSSet * discountSet = [NSSet setWithArray:discountList];
    discountList = discountSet.allObjects;
    totalItemsCount = totalItemsCount - discountList.count;
    remainingItemCount = remainingItemCount + totalItemsCount;

    for (NSMutableDictionary *discountDictionary in discountList)
    {
        //        [self insertEntityWithName:@"Discount_M" moc:moc];
//        Discount_M * itemDiscount = (Discount_M *) [self insertEntityWithName:@"Discount_M" moc:moc];
        Discount_M * itemDiscount = (Discount_M *) [self __fetchEntityWithName:@"Discount_M" key:@"discountId" value:discountDictionary[@"DiscountId"] shouldCreate:YES moc:moc];

        if ([discountDictionary[@"IsDelete"] boolValue]) {
            [UpdateManager deleteFromContext:moc objectId:itemDiscount.objectID];
        }
        else {
            [itemDiscount updateDiscountFromDictionary:discountDictionary];
        }
        
        //only for First time not when live update
        if (totalcount > 0) {
            remainingItemCount++;
            float intPercentage = remainingItemCount*100;
            intPercentage = intPercentage/totalcount;
            [self stepProgressnotification:0 message:@"2" progress:intPercentage];
//            NSLog(@"intPercentage %f",intPercentage);
        }
    }
    return remainingItemCount;
}

/*!
 *  @author Siya Infotech, 16-02-03 10:02:43
 *
 *  insert Discount Primary entity and linking with item and Discount
 *
 *  @param discountPrimaryArray array<dictionary> of discount primary list
 *  @param moc                  moc
 *  @param totalcount           if devide phase configure then pass all items count in phase3
 *  @param remainingItemCount   if devide phase configure then pass all items inserted count in phase3
 *
 *  @return items inserted count in phase3
 */
-(NSInteger)insertDiscountPrimaryArrayFromlist:(NSArray *)discountPrimaryArray moc:(NsmoContext*)moc withCount:(NSInteger)totalcount withRemainItemCount:(NSInteger)remainingItemCount
{
    NSInteger totalItemsCount = discountPrimaryArray.count;
    NSSet * discountSet = [NSSet setWithArray:discountPrimaryArray];
    discountPrimaryArray = discountSet.allObjects;
    totalItemsCount = totalItemsCount - discountPrimaryArray.count;
    remainingItemCount = remainingItemCount + totalItemsCount;

    for (NSMutableDictionary *discountPrimaryDictionary in discountPrimaryArray) {
        if ([[discountPrimaryDictionary objectForKey:@"IsDelete"] intValue] == 0) {
            Discount_Primary_MD * itemDiscount = (Discount_Primary_MD *) [self insertEntityWithName:@"Discount_Primary_MD" moc:moc];
            [itemDiscount updateDiscountPrimaryMDFromDictionary:discountPrimaryDictionary];
            
            Item *item = (Item*)[self fetchEntityWithName:@"Item" key:@"itemCode" value:@([[discountPrimaryDictionary valueForKey:@"ItemCode"] integerValue]) shouldCreate:NO moc:moc];
            if (item != nil)
            {
                itemDiscount.itemDetail = item;
                [item addPrimaryItemDetailObject:itemDiscount];
            }
            else{
                NSLog(@"Primary Item Delete :%@",[discountPrimaryDictionary valueForKey:@"ItemCode"]);
            }
            
            Discount_M * discount = (Discount_M*)[self __fetchEntityWithName:@"Discount_M" key:@"discountId" value:@([[discountPrimaryDictionary valueForKey:@"DiscountId"] integerValue]) shouldCreate:NO moc:moc];
            itemDiscount.primaryItem = discount;
            [discount addPrimaryItemsObject:itemDiscount];
            
            //only for First time not when live update
            if (totalcount > 0) {
                remainingItemCount++;
                float intPercentage = remainingItemCount*100;
                intPercentage = intPercentage/totalcount;
                [self stepProgressnotification:0 message:@"2" progress:intPercentage];
            }
        }
    }
    return remainingItemCount;
}
/*!
 *  @author Siya Infotech, 16-02-03 10:02:45
 *
 *  insert Discount Secondary entity and linking with item and Discount
 *
 *  @param discountSecondaryArray array<dictionary> of discount primary list
 *  @param moc                    moc
 *  @param totalcount             if devide phase configure then pass all items count in phase3
 *  @param remainingItemCount     if devide phase configure then pass all items inserted count in phase3
 *
 *  @return items inserted count in phase3
 */
-(NSInteger)insertDiscountSecondaryArrayFromlist:(NSArray *)discountSecondaryArray moc:(NsmoContext*)moc withCount:(NSInteger)totalcount withRemainItemCount:(NSInteger)remainingItemCount
{
    NSInteger totalItemsCount = discountSecondaryArray.count;
    NSSet * secondarySet = [NSSet setWithArray:discountSecondaryArray];
    discountSecondaryArray = secondarySet.allObjects;
    totalItemsCount = totalItemsCount - discountSecondaryArray.count;
    remainingItemCount = remainingItemCount + totalItemsCount;

    for (NSMutableDictionary *discountPrimaryDictionary in discountSecondaryArray) {
        if ([[discountPrimaryDictionary objectForKey:@"IsDelete"] intValue] == 0) {
            Discount_Secondary_MD * itemDiscount = (Discount_Secondary_MD *) [self insertEntityWithName:@"Discount_Secondary_MD" moc:moc];
            [itemDiscount updateDiscountSecondaryMDFromDictionary:discountPrimaryDictionary];
            
            Item *item = (Item*)[self fetchEntityWithName:@"Item" key:@"itemCode" value:@([[discountPrimaryDictionary valueForKey:@"ItemCode"] integerValue]) shouldCreate:NO moc:moc];
            if (item != nil)
            {
                itemDiscount.itemDetail = item;
                [item addSecondaryItemDetailObject:itemDiscount];
            }
            else{
                NSLog(@"Secondary Item Delete :%@",[discountPrimaryDictionary valueForKey:@"ItemCode"]);
            }
            
            Discount_M * discount = (Discount_M*)[self __fetchEntityWithName:@"Discount_M" key:@"discountId" value:@([[discountPrimaryDictionary valueForKey:@"DiscountId"] integerValue]) shouldCreate:NO moc:moc];
            itemDiscount.secondaryItem = discount;
            [discount addSecondaryItemsObject:itemDiscount];
            
            //only for First time not when live update
            if (totalcount > 0) {
                remainingItemCount++;
                float intPercentage = remainingItemCount*100;
                intPercentage = intPercentage/totalcount;
                [self stepProgressnotification:0 message:@"2" progress:intPercentage];
            }
        }
    }
    return remainingItemCount;
}
#pragma mark - GAS PUMP MANAGER METHOD

-(void)insertOrUpdatePumpCartChangedData:(NSDictionary*)updateResponseDictionary {
    
//    if (![RmsDbController sharedRmsDbController].rapidPetroPos) {
//        [RmsDbController sharedRmsDbController].rapidPetroPos = [RapidPetroPOS createInstance];
//        if ([[RmsDbController sharedRmsDbController] getGasPumpUrlEnabled]) {
//            [RmsDbController sharedRmsDbController].rapidPetroPos.onSiteStopListing = YES;
//        }
//    }
    NSArray * arrPumpCarts = updateResponseDictionary[@"PumpCartObjectArray"];
    [self updateLiveCartDetailInLocalDatabase:arrPumpCarts];
    [self updatePetroUpdateTime:updateResponseDictionary];
}

-(void)updatePetroUpdateTime:(NSDictionary*)updateResponseDictionary {
    if([[updateResponseDictionary valueForKey:@"utcdatetimeVal"] length] > 0 && [updateResponseDictionary valueForKey:@"utcdatetimeVal"] != nil)
    {
        NSLog(@"UTC Date from the server at insert PumpCart = %@", [updateResponseDictionary valueForKey:@"utcdatetimeVal"]);
        [self insertPetroUpdateDate:[updateResponseDictionary valueForKey:@"utcdatetimeVal"]];
    }
}

-(void)updateLiveCartDetailInLocalDatabase:(NSArray *)pumpCartArray {
    
    NSBlockOperation * op = [NSBlockOperation blockOperationWithBlock:^{
        NsmoContext *privateManagedObjectContext = [[NsmoContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
//        privateManagedObjectContext.parentContext = [RmsDbController sharedRmsDbController].rapidPetroPos.petroMOC;
        [privateManagedObjectContext setUndoManager:nil];
        
        for (NSDictionary *cartDetail in pumpCartArray) {
            PumpCart * pumpCart;
            NSString * strSequenceNumber = cartDetail[@"SequenceNumber"];
            if (strSequenceNumber && ![strSequenceNumber isKindOfClass:[NSNull class]] && strSequenceNumber.length > 0) {
                pumpCart = (PumpCart *)[self __fetchEntityWithName:@"PumpCart" key:@"pumpIndex" value:@([[cartDetail valueForKey:@"PumpId"] integerValue]) key2:@"sequenceNumber" value2:[cartDetail valueForKey:@"SequenceNumber"] shouldCreate:TRUE moc:privateManagedObjectContext];
            }
            else{
                pumpCart = (PumpCart *)[self __fetchEntityWithName:@"PumpCart" key:@"pumpIndex" value:@([[cartDetail valueForKey:@"PumpId"] integerValue]) key2:@"cartId" value2:[cartDetail valueForKey:@"CartId"] shouldCreate:NO moc:privateManagedObjectContext];
            }
            
            if(pumpCart!=nil){
                if([cartDetail[@"IsDeleted"]integerValue] == 0){
//                    [pumpCart updateCartDictDictionaryFromLive:cartDetail];
//                    [pumpCart addLiveUpdatePumpCartLogInCoreDataWithResponce:cartDetail];
                }
                else
                {
//                    [UpdateManager deleteFromContext:privateManagedObjectContext objectId:pumpCart.objectID];
                }
            }
            [UpdateManager saveContext:privateManagedObjectContext];
        }
    }];
    [op setQueuePriority:NSOperationQueuePriorityVeryHigh];
//    [[RmsDbController sharedRmsDbController].rapidPetroPos.pumpOperation addOperation:op];
}

-(void)insertOrUpdatePumpCartInvoiceChangedData:(NSDictionary*)updateResponseGasInvoiceDictionary
{
//    if (![RmsDbController sharedRmsDbController].rapidPetroPos) {
//        [RmsDbController sharedRmsDbController].rapidPetroPos = [RapidPetroPOS createInstance];
//        if ([[RmsDbController sharedRmsDbController] getGasPumpUrlEnabled]) {
//            [RmsDbController sharedRmsDbController].rapidPetroPos.onSiteStopListing = YES;
//        }
//    }
//    NSManagedObjectContext * privateManagedObjectContext = [RmsDbController sharedRmsDbController].rapidPetroPos.petroMOC;
//    NSArray *arrPumpCartsInvoice = updateResponseGasInvoiceDictionary[@"GasAdjustmentArray"];
//    
//    if (privateManagedObjectContext) {
//        [self updateLiveGasInvoiceDetailInLocalDatabase:arrPumpCartsInvoice moc:privateManagedObjectContext];
//    }
}


-(void)updateFuelPumpMasterInLocalDatabase:(NSArray *)fuelpumpArray moc:(NsmoContext*)moc
{
//    for (NSDictionary *pumpdict in fuelpumpArray)
//    {
//        FuelPump *fuelpump = (FuelPump *)[self __fetchEntityWithName:@"FuelPump" key:@"pumpIndex" value:@([[pumpdict valueForKey:@"PumpId"] integerValue]) shouldCreate:NO moc:moc];
//        if(fuelpump){
//            if(fuelpump.fuelType == 0){
//                [pumpdict setValue:[pumpdict valueForKey:@"FuelType"] forKey:@"FuelType"];
//            }
//            [pumpdict setValue:fuelpump.isDiaplay forKey:@"IsDisplay"];
//            [pumpdict setValue:fuelpump.pumpOrder forKey:@"PumpOrder"];
//            [fuelpump updatefuelPumpMasterDictDictionary:pumpdict];
//        }
//        else
//        {
//            FuelPump *fuelpumpTemp = [NSEntityDescription insertNewObjectForEntityForName:@"FuelPump" inManagedObjectContext:moc];
//            [pumpdict setValue:@"1" forKey:@"IsDisplay"];
//            [pumpdict setValue:[pumpdict valueForKey:@"PumpId"] forKey:@"PumpOrder"];
//            [fuelpumpTemp updatefuelPumpMasterDictDictionary:pumpdict];
//        }
//        fuelpump.isDelete = @(1);
//    }
//    [UpdateManager saveContext:moc];
}

-(void)updateFuelPumpInLocalDatabase:(NSArray *)fuelpumpArray moc:(NsmoContext*)moc
{
//    for (NSDictionary *pumpdict in fuelpumpArray)
//    {
//        FuelPump *fuelpump = (FuelPump *)[self __fetchEntityWithName:@"FuelPump" key:@"pumpIndex" value:@([[pumpdict valueForKey:@"Key"] integerValue]) shouldCreate:NO moc:moc];
//        if(fuelpump){
//            if([fuelpump.fuelType isEqualToString:@"(null)"]){
//                [pumpdict setValue:[pumpdict valueForKey:@"FuelType"] forKey:@"FuelType"];
//            }
//            [pumpdict setValue:fuelpump.isDiaplay forKey:@"IsDisplay"];
//            [pumpdict setValue:fuelpump.pumpOrder forKey:@"PumpOrder"];
//            [fuelpump updatefuelPumpDictDictionary:pumpdict];
//        }
//        else
//        {
//            FuelPump *fuelpumpTemp = (FuelPump *)[self __fetchEntityWithName:@"FuelPump" key:@"pumpIndex" value:@([[pumpdict valueForKey:@"Key"] integerValue]) shouldCreate:YES moc:moc];
//            [pumpdict setValue:@"1" forKey:@"IsDisplay"];
//            [pumpdict setValue:[pumpdict valueForKey:@"PumpIndex"] forKey:@"PumpOrder"];
//            [fuelpumpTemp updatefuelPumpDictDictionary:pumpdict];
//        }
//    }
//    [UpdateManager saveContext:moc];
}

-(void)fuelPumpinReserveMode:(int)pumpIndex moc:(NsmoContext*)moc
{
//    FuelPump *fuelpump = (FuelPump *)[self __fetchEntityWithName:@"FuelPump" key:@"pumpIndex" value:@(pumpIndex) shouldCreate:NO moc:moc];
//    fuelpump.isReserved = @(1);
//    fuelpump.reserveTime = [NSDate date];
//    [UpdateManager saveContext:moc];
}

-(void)fuelPumpinunReserveMode:(int)pumpIndex moc:(NsmoContext*)moc
{
//    FuelPump *fuelpump = (FuelPump *)[self __fetchEntityWithName:@"FuelPump" key:@"pumpIndex" value:@(pumpIndex) shouldCreate:NO moc:moc];
//    fuelpump.isReserved = @(0);
//    [UpdateManager saveContext:moc];
}


-(void)updateFuelTankInLocalDatabase:(NSArray *)fueltank moc:(NsmoContext*)moc
{
//    for (NSDictionary *fueltankdict in fueltank)
//    {
//        FuelTank *fueltankInfo = (FuelTank *)[self __fetchEntityWithName:@"FuelTank" key:@"fuelTankIndex" value:@([[fueltankdict valueForKey:@"FuelTankIndex"] integerValue]) shouldCreate:NO moc:moc];
//        if(fueltankInfo==nil){
//            fueltankInfo = [NSEntityDescription insertNewObjectForEntityForName:@"FuelTank" inManagedObjectContext:moc];
//
//        }
//        [fueltankInfo updateFuelTankDictionary:fueltankdict];
//    }
//    [UpdateManager saveContext:moc];
}

-(void)updateFuelMasterTankInLocalDatabase:(NSArray *)fueltank moc:(NsmoContext*)moc
{
//    for (NSDictionary *fueltankdict in fueltank)
//    {
//        FuelTank *fueltankInfo = (FuelTank *)[self __fetchEntityWithName:@"FuelTank" key:@"fuelTankIndex" value:@([[fueltankdict valueForKey:@"TankId"] integerValue]) shouldCreate:NO moc:moc];
//        if(fueltankInfo==nil){
//            fueltankInfo = [NSEntityDescription insertNewObjectForEntityForName:@"FuelTank" inManagedObjectContext:moc];
//            
//        }
//        [fueltankInfo updateFuelTankMasterDictionary:fueltankdict];
//    }
//    [UpdateManager saveContext:moc];
}

-(void)updateFuelTypeInLocalDatabase:(NSArray *)fueltype moc:(NsmoContext*)moc
{
//    for (NSDictionary *fueltypedict in fueltype)
//    {
//        FuelType *fueltypeTemp = (FuelType *)[self __fetchEntityWithName:@"FuelType" key:@"fuelTypeIndex" value:@([[fueltypedict valueForKey:@"FuelTypeIndex"] integerValue]) shouldCreate:NO moc:moc];
//
//        if(fueltypeTemp == nil){
//            fueltypeTemp = [NSEntityDescription insertNewObjectForEntityForName:@"FuelType" inManagedObjectContext:moc];
//        }
//        [fueltypeTemp updateFuelTypeDictionary:fueltypedict];
//        
//        NSArray *payMode = @[@"Cash",@"Credit"];
//        [self updatePayModeInLocalDatabase:fueltypedict withPaymode:payMode andFuelType:fueltypeTemp moc:moc];
//    }
//    [UpdateManager saveContext:moc];
//    
}

-(void)updateMasterFuelTypeInLocalDatabase:(NSArray *)fueltype moc:(NsmoContext*)moc
{
//    for (NSDictionary *fueltypedict in fueltype)
//    {
//        FuelType *fueltypeTemp = (FuelType *)[self __fetchEntityWithName:@"FuelType" key:@"fuelTypeIndex" value:@([[fueltypedict valueForKey:@"FuelTypeId"] integerValue]) shouldCreate:NO moc:moc];
//        if(fueltypeTemp == nil){
//            fueltypeTemp = [NSEntityDescription insertNewObjectForEntityForName:@"FuelType" inManagedObjectContext:moc];
//        }
//        [fueltypeTemp updateMasterFuelTypeDictionary:fueltypedict];
//
//    }
//    [UpdateManager saveContext:moc];
}


-(void)updateMasterFuelPricingLivUpdate:(NSArray *)fueltypePricingArray moc:(NsmoContext*)moc
{
    [self updatePayModeMasterLiveUpdate:fueltypePricingArray moc:moc];
   // [self updateFuelTypePriceinRapidOnSite:fueltypePricingArray];
    
    [UpdateManager saveContext:moc];
    
}

-(void)updateFuelTypePriceinRapidOnSite:(NSArray *)fueltypePricingArray{
    if(fueltypePricingArray.count>0){
        int index = 0;
        NSMutableArray *query = [self getPriceQueryString:fueltypePricingArray];
        [self updatePricOnRapidOnSite:query withIndex:index];
    }
}
-(void)updatePricOnRapidOnSite:(NSMutableArray *)queryArray withIndex:(int)index{
    
//    NSString *fuelCountString = [NSString stringWithFormat:@"%@:6631",[RmsDbController sharedRmsDbController].rapidPetroPos.ipAddress];
//    if ([[RmsDbController sharedRmsDbController] getGasPumpUrlEnabled]) {
//        fuelCountString = [[RmsDbController sharedRmsDbController] getGasPumpUrl];
//    }
//
//    fuelCountString = [fuelCountString stringByAppendingFormat:@"RapidOnSite,%@",queryArray[index]];
//    RapidGasWebserviceConnection *rapidGasWebConnection = [[RapidGasWebserviceConnection alloc]init];
//    NSMutableString *result = [rapidGasWebConnection callWebServiceForUrl:fuelCountString];
//    if(result){
//        index++;
//        if(queryArray.count > index){
//           [self updatePricOnRapidOnSite:queryArray[index] withIndex:index];
//        }
//    }
//
}
-(NSMutableArray *)getPriceQueryString:(NSArray *)fueltypePricingArray{
    
    NSMutableArray *arrayPriceQuery = [[NSMutableArray alloc]init];
    NSString *queryString;
    for (NSDictionary *dictPrice in fueltypePricingArray) {
        
        NSString *fuelString = [NSString stringWithFormat:@"Fuel+%@.AdHoc?",dictPrice[@"FuelTypeId"]];
        NSString *priceString;
        if([dictPrice[@"PayId"] integerValue] == 1){
            
            if([dictPrice[@"PayId"] integerValue] == 1){
                priceString = [NSString stringWithFormat:@"Price_Item_Amount~Cash_Self=%@",dictPrice[@"Price"]];
            }
            else{
                priceString = [NSString stringWithFormat:@"Price_Item_Amount~Cash_Full=%@",dictPrice[@"Price"]];
            }
        }
        if([dictPrice[@"PayId"] integerValue] == 2){
            
            if([dictPrice[@"PayId"] integerValue] == 2){
                priceString = [NSString stringWithFormat:@"Price_Item_Amount~Credit_Self=%@",dictPrice[@"Price"]];
            }
            else{
                priceString = [NSString stringWithFormat:@"Price_Item_Amount~Credit_Full=%@",dictPrice[@"Price"]];
            }
        }
        queryString = [NSString stringWithFormat:@"%@%@",fuelString,priceString];
    }
    [arrayPriceQuery addObject:queryString];
    return arrayPriceQuery;
}

-(void)updatePayModeMasterLiveUpdate:(NSArray *)fueltypeArray moc:(NsmoContext*)moc
{
//    for (NSDictionary *fueltypedict in fueltypeArray)
//    {
//        FuelType *fueltypeTemp = (FuelType *)[self __fetchEntityWithName:@"FuelType" key:@"fuelTypeIndex" value:@([[fueltypedict valueForKey:@"FuelTypeId"] integerValue]) shouldCreate:NO moc:moc];
//        
//        PayMode *payMode = [fueltypeTemp getPayModeFromPayType:[fueltypedict[@"PayId"] integerValue]];
//
//        if(payMode){
//           
//            ServiceType *serviceType = [payMode getServiceTypeForelectedIndex:[fueltypedict[@"ServiceType"] integerValue]];
//            if(serviceType){
//                NSString * strPrice = [NSString stringWithFormat:@"%@",fueltypedict[@"Price"]];
//                serviceType.price = @(strPrice.floatValue);
//            }
//        }
//    }
}



-(void)updateMasterFuelPricingInLocalDatabase:(NSArray *)fueltypePricingArray moc:(NsmoContext*)moc
{
    [self updatePayModeMasterInLocalDatabase:fueltypePricingArray moc:moc];

    [UpdateManager saveContext:moc];
    
}


-(void)updatePayModeMasterInLocalDatabase:(NSArray *)fueltypeArray moc:(NsmoContext*)moc
{
//    for (NSDictionary *fueltypedict in fueltypeArray)
//    {
//        FuelType *fueltypeTemp = (FuelType *)[self __fetchEntityWithName:@"FuelType" key:@"fuelTypeIndex" value:@([[fueltypedict valueForKey:@"FuelTypeId"] integerValue]) shouldCreate:NO moc:moc];
//        
//        if(fueltypeTemp != nil){
//        
//            NSArray *arrayPayMode = [NSArray arrayWithObjects:@"Cash",@"Credit", nil];
//            
//            int i = 1;
//            
//            for (NSString *payMode in arrayPayMode) {
//                
//                PayMode *payModeTemp = [self getPayMode:fueltypedict withPayMode:payMode withMoc:moc];
//                
//                payModeTemp.payName = payMode;
//                payModeTemp.payIndex = @(i);
//                [fueltypeTemp addPayModesObject:payModeTemp];
//                payModeTemp.fuelType = fueltypeTemp;
//                
//                NSArray *serviceType = @[@"Self",@"Full"];
//            
//                [self updateServiceModeMasterInLocalDatabase:i withServiceType:serviceType andPayMode:payModeTemp withFuelTypeId:[fueltypeTemp.fuelTypeIndex intValue] withPriceArray:fueltypeArray moc:moc];
//                 i++;
//            }
//            
//        }
//        
//    }
}
//-(PayMode *)getPayMode:(NSDictionary *)fuelDict withPayMode:(NSString *)payMode withMoc:(NSManagedObjectContext *)moc{
//    
//    PayMode *payModeTemp = (PayMode *)[self __fetchEntityWithName:@"PayMode" key:@"fuelType.fuelTypeIndex" value:@([[fuelDict valueForKey:@"FuelTypeId"] integerValue]) key2:@"payName" value2:payMode shouldCreate:NO moc:moc];
//    
//    if(payModeTemp == nil){
//        payModeTemp = [NSEntityDescription insertNewObjectForEntityForName:@"PayMode" inManagedObjectContext:moc];
//    }
//    
//    return payModeTemp;
//    
//    
//}



//-(void)updatePayModeInLocalDatabase:(NSDictionary *)fueltypedict withPaymode:(NSArray *)payModeArray andFuelType:(FuelType *)pfuelType moc:(NsmoContext*)moc
//{
//    int i = 1;
//    
//    for (NSString *payName in payModeArray)
//    {
//        PayMode *payModeTemp = (PayMode *)[self __fetchEntityWithName:@"PayMode" key:@"fuelType.fuelTypeIndex" value:@([[fueltypedict valueForKey:@"FuelTypeIndex"] integerValue]) key2:@"payName" value2:payName shouldCreate:NO moc:moc];
//    
//        if(payModeTemp == nil){
//            payModeTemp = [NSEntityDescription insertNewObjectForEntityForName:@"PayMode" inManagedObjectContext:moc];
//        }
//        
//        payModeTemp.payName = payName;
//        payModeTemp.payIndex = @(i);
//        [pfuelType addPayModesObject:payModeTemp];
//        payModeTemp.fuelType = pfuelType;
//
//        NSArray *serviceType = @[@"Full",@"Self"];
//        
//        [self updateServiceModeInLocalDatabase:i withServiceType:serviceType andPayMode:payModeTemp withPricedict:fueltypedict moc:moc];
//       i++;
//    }
//
//}

//-(void)updateServiceModeMasterInLocalDatabase:(int)payModeId withServiceType:(NSArray *)serviceTypeArray andPayMode:(PayMode *)pPayMode withFuelTypeId:(int)fuelTypeId withPriceArray:(NSArray *)priceArray moc:(NsmoContext*)moc{
//    
//    int i = 1;
//    NSArray *serviceTypes = pPayMode.serviceType.allObjects;
//    
//    for (NSString *servicename in serviceTypeArray)
//    {
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"serviceName = %@",servicename];
//        ServiceType *serviceTypeTemp = [serviceTypes filteredArrayUsingPredicate:predicate].firstObject;
//        if(serviceTypeTemp == nil){
//            serviceTypeTemp = [NSEntityDescription insertNewObjectForEntityForName:@"ServiceType" inManagedObjectContext:moc];
//        }
//        
//        NSPredicate *pricePredicate = [NSPredicate predicateWithFormat:@"PayId = %d AND ServiceType = %d AND FuelTypeId = %d",payModeId,i,fuelTypeId];
//        NSArray *arrayPrice = [priceArray filteredArrayUsingPredicate:pricePredicate];
//        if (arrayPrice.count > 0)
//        {
//            NSDictionary *priceDict = arrayPrice[0];
//            
//            serviceTypeTemp.price = @([[priceDict valueForKey:@"Price"] floatValue]);
//            
//            if(!serviceTypeTemp.oldPrice){
//                serviceTypeTemp.oldPrice = @([[priceDict valueForKey:@"Price"] floatValue]);
//                
//            }
//            serviceTypeTemp.serviceName = servicename;
//            serviceTypeTemp.serviceIndex = @(i);
//            [pPayMode addServiceTypeObject:serviceTypeTemp];
//            serviceTypeTemp.spayMode = pPayMode;
//            i++;
//
//        }
//    }
//}



//-(void)updateServiceModeInLocalDatabase:(int)payModeId withServiceType:(NSArray *)serviceTypeArray andPayMode:(PayMode *)pPayMode withPricedict:(NSDictionary *)priceDict moc:(NsmoContext*)moc{
//    
//    int i = 1;
//    NSArray *serviceTypes = pPayMode.serviceType.allObjects;
//    
//    for (NSString *servicename in serviceTypeArray)
//    {
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"serviceName = %@",servicename];
//        ServiceType *serviceTypeTemp = [serviceTypes filteredArrayUsingPredicate:predicate].firstObject;
//        if(serviceTypeTemp == nil){
//            serviceTypeTemp = [NSEntityDescription insertNewObjectForEntityForName:@"ServiceType" inManagedObjectContext:moc];
//        }
//        
//        if([servicename isEqualToString:@"Full"] && [pPayMode.payName isEqualToString:@"Cash"])
//        {
//            if([priceDict valueForKey:@"OldCashFull"]){
//                
//                serviceTypeTemp.oldPrice = @([[priceDict valueForKey:@"OldCashFull"]floatValue]);
//            }
//            else{
//                if(!serviceTypeTemp.oldPrice){
//                    serviceTypeTemp.oldPrice = serviceTypeTemp.price;
//                }
//                
//            }
//            
//            serviceTypeTemp.price = @([[priceDict valueForKey:@"CashFull"] floatValue]);
//        }
//        if([servicename isEqualToString:@"Self"] && [pPayMode.payName isEqualToString:@"Cash"])
//        {
//            
//            if([priceDict valueForKey:@"OldCashSelf"]){
//                
//                serviceTypeTemp.oldPrice = @([[priceDict valueForKey:@"OldCashSelf"]floatValue]);
//                
//            }
//            else{
//                if(!serviceTypeTemp.oldPrice){
//                    serviceTypeTemp.oldPrice = serviceTypeTemp.price;
//                }
//            }
//
//            
//            serviceTypeTemp.price = @([[priceDict valueForKey:@"CashSelf"] floatValue]);
//        }
//        if([servicename isEqualToString:@"Full"] && [pPayMode.payName isEqualToString:@"Credit"])
//        {
//            if([priceDict valueForKey:@"OldCreditFull"]){
//                
//                serviceTypeTemp.oldPrice = @([[priceDict valueForKey:@"OldCreditFull"]floatValue]);
//                
//            }
//            else{
//                if(!serviceTypeTemp.oldPrice){
//                    serviceTypeTemp.oldPrice = serviceTypeTemp.price;
//                }
//            }
//
//            
//            serviceTypeTemp.price = @([[priceDict valueForKey:@"CreditFull"] floatValue]);
//        }
//        if([servicename isEqualToString:@"Self"] && [pPayMode.payName isEqualToString:@"Credit"])
//        {
//            if([priceDict valueForKey:@"OldCreditSelf"]){
//                
//                serviceTypeTemp.oldPrice = @([[priceDict valueForKey:@"OldCreditSelf"]floatValue]);
//                
//            }
//            else{
//                if(!serviceTypeTemp.oldPrice){
//                    serviceTypeTemp.oldPrice = serviceTypeTemp.price;
//                }
//            }
//            serviceTypeTemp.price = @([[priceDict valueForKey:@"CreditSelf"] floatValue]);
//        }
//    
//        serviceTypeTemp.serviceName = servicename;
//        serviceTypeTemp.serviceIndex = @(i);
//        [pPayMode addServiceTypeObject:serviceTypeTemp];
//        serviceTypeTemp.spayMode = pPayMode;
//        i++;
//    }
//}

-(void)updateGasStationInLocalDatabase:(NSArray *)gasStation moc:(NsmoContext*)moc
{
    for (NSDictionary *gasStationdict in gasStation)
    {
//        GasStation *gasstation = (GasStation *)[self __fetchEntityWithName:@"GasStation" key:@"fuelTankIndex" value:@([[gasStationdict valueForKey:@"fuelTankIndex"] integerValue]) shouldCreate:YES moc:moc];
//        [gasstation updateGasStationDictionary:gasStationdict];
    }
    [UpdateManager saveContext:moc];
}


-(void)insertPumpCartInvoiceDetailInLocalDatabaseWithcartDetail:(NSMutableDictionary *)invoiceDictionary moc:(NsmoContext*)moc{
    
    PumpCartInvoiceData * pumpCartInvData = (PumpCartInvoiceData *)[self insertEntityWithName:@"PumpCartInvoiceData" moc:moc];
//    [pumpCartInvData updatePumpCartInvoiceDictDictionary:invoiceDictionary];
    [UpdateManager saveContext:moc];
}

-(PumpCartInvoiceData *)insertPumpCartInvoiceDetailInFromLive:(NSMutableDictionary *)invoiceDictionary moc:(NsmoContext*)moc{
    
    PumpCartInvoiceData * pumpCartInvData = (PumpCartInvoiceData *)[self insertEntityWithName:@"PumpCartInvoiceData" moc:moc];
//    [pumpCartInvData updatePumpCartInvoiceDictDictionaryFromLive:invoiceDictionary];
    [UpdateManager saveContext:moc];
    return pumpCartInvData;
}




#pragma mark Delete Failed PumpCart Service Code
-(void)deletePumpCartDataWebServiceCall:(PumpCart *)pumpCart{
    
    /*if (pumpCart) {
        NSMutableDictionary *dictParam = [[NSMutableDictionary alloc]init];
        dictParam[@"PumpId"] = pumpCart.pumpIndex.stringValue;
        dictParam[@"CartId"] = [NSString stringWithFormat:@"%@",pumpCart.cartId];
        dictParam[@"BranchId"] = [RmsDbController sharedRmsDbController].globalDict[@"BranchID"];
        
        AsyncCompletionHandler asyncCompletionHandler = ^(id response, NSError *error) {
            [self pumpCartDeleteResponse:response error:error];
        };
        
        RapidWebServiceConnection *deletePumpCartWC = [[RapidWebServiceConnection alloc]init];
        deletePumpCartWC = [deletePumpCartWC initWithAsyncRequest:KURL actionName:@"DeletePumpCart" params:dictParam asyncCompletionHandler:asyncCompletionHandler];
    }*/
}
-(void)pumpCartPostPayStatusLog:(NSMutableDictionary *)dictPumpCart{
    
    NSMutableDictionary * mDictLogInfo = [NSMutableDictionary dictionary];
    mDictLogInfo[@"command"] = @"";
    mDictLogInfo[@"cartID"] = @"";
    mDictLogInfo[@"direction"] = @(DirectionReceive);
    mDictLogInfo[@"cartStatus"] = @"none";
    mDictLogInfo[@"pumpIndex"] = @([dictPumpCart[@"PumpIndex"] integerValue]);
    mDictLogInfo[@"transactionType"] = dictPumpCart[@"TransactionType"];
    mDictLogInfo[@"isPad"] = @(0);
    mDictLogInfo[@"regInvNumber"] = @"";
    mDictLogInfo[@"invoiceNumber"] = @"";
    [UpdateLogManager logPetroPumpCartStatusWithDetail:mDictLogInfo];
}

- (void)pumpCartDeleteResponse:(id)response error:(NSError *)error
{
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            
            //    [_activityIndicator hideActivityIndicator];
        }
    }
}

- (NSArray*)fetchFuelDetails:(NSString *)entityName withPumpIndex:(int)fuelIndex withMoc:(NsmoContext *)moc
{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fuelTypeIndex = %d",fuelIndex];
    fetchRequest.predicate = predicate;
    
    NSArray *arryTemp = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    
    return arryTemp;
}

-(void)updateLiveGasInvoiceDetailInLocalDatabase:(NSArray *)gasInvoiceArray moc:(NsmoContext*)moc
{
    if(gasInvoiceArray.count>0){
        
        NSString *invoiceNo = [[gasInvoiceArray firstObject] valueForKey:@"RegisterInvNo"];
        PumpCartInvoiceData *invoiceData = (PumpCartInvoiceData *)[self __fetchEntityWithName:@"PumpCartInvoiceData" key:@"regInvNum" value:invoiceNo shouldCreate:NO moc:moc];
        
//        if(invoiceData.invoicePaymentPumpData == nil){
//            
//            PumpCartInvoiceData * pumpCartInvData = (PumpCartInvoiceData *)[self insertEntityWithName:@"PumpCartInvoiceData" moc:moc];
//            NSMutableArray *paymentDetail = [[NSMutableArray alloc]init];
//            [paymentDetail addObject:gasInvoiceArray];
//            pumpCartInvData.invoicePaymentPumpData = [self archivedDataWithInvoiceObject:paymentDetail];
//            pumpCartInvData.regInvNum = invoiceNo;
//            
//        }
//        else{
//            NSMutableArray *paymentDetail = [[NSMutableArray alloc]init];
//            [paymentDetail addObject:gasInvoiceArray];
//            invoiceData.invoicePaymentPumpData = [self archivedDataWithInvoiceObject:paymentDetail];
//        }
        [UpdateManager saveContext:moc];
    }

}

-(NSData *)archivedDataWithInvoiceObject:(NSMutableArray *)invoiceItemData
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:invoiceItemData];
    return data;
}
// Pump Cards from RegInvNo
- (NSArray*)fetcPumpCartWithName:(NSString*)entityName key:(NSString*)key value:(NSString *)value moc:(NsmoContext*)moc
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@",key,value];
    fetchRequest.predicate = predicate;
    NSArray *arryTemp = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    
    //NSManagedObject *anObject = nil;
    if (arryTemp.count == 0)
    {
    }
    else
    {
        //anObject = [arryTemp firstObject];
    }
    return arryTemp;
}

/*-(void)getInvoiceDetailForPumpCart:(NSString *)ReginvoiceNo{
    if([ReginvoiceNo isEqualToString:@""]){
        return;
    }
    RapidWebServiceConnection *invoiceDetail = [[RapidWebServiceConnection alloc]init];
    
    NSMutableDictionary *itemparam = [[NSMutableDictionary alloc]init];
    [itemparam setValue:ReginvoiceNo forKey:@"RegInvNo"];
    [itemparam setValue:([RmsDbController sharedRmsDbController].globalDict)[@"BranchID"] forKey:@"BranchId"];
    
    
    AsyncCompletionHandler asyncCompletionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self doGetInvoiceItemDetailResponse:response error:error];
        });
    };
    invoiceDetail = [invoiceDetail initWithRequest:KURL actionName:@"InvoiceDetailsByRegInvNo" params:itemparam completionHandler:asyncCompletionHandler];
    
}


- (void)doGetInvoiceItemDetailResponse:(id)response error:(NSError *)error
{
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                if (![RmsDbController sharedRmsDbController].pumpManager) {
                    [RmsDbController sharedRmsDbController].pumpManager = [[PumpManager alloc]init];
                    BOOL localUrlEnabled = [[[NSUserDefaults standardUserDefaults] valueForKey:@"GasPumpUrlEnabled"] boolValue];
                    if (localUrlEnabled) {
                        [RmsDbController sharedRmsDbController].pumpManager.bl.stopListing = YES;
                    }
                }
                 NSMutableDictionary *pumpInvoiceDictionary = [[RmsDbController sharedRmsDbController] objectFromJsonString:[response valueForKey:@"Data"]];
            
                  [self insertPumpCartInvoiceDetailInFromLive:pumpInvoiceDictionary moc:[RmsDbController sharedRmsDbController].rapidPetroPos.petroMOC];
            }
            else
            {
               
            }
        }
    }
}*/


-(void)deleteCartDetailInLocalDatabase:(NSDictionary *)cartDetail moc:(NsmoContext*)moc
{
    PumpCart *pumpCart = (PumpCart *)[self __fetchEntityWithName:@"PumpCart" key:@"pumpIndex" value:@([[cartDetail valueForKey:@"PumpIndex"] integerValue]) shouldCreate:YES moc:moc];
    [UpdateManager deleteFromContext:moc object:pumpCart];
    [UpdateManager saveContext:moc];
}

- (NSArray *)fetchCartDetail:(NSPredicate *)predicate intheEntity:(NSString *)entityName manageObjectContext:(NsmoContext *)context
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:entityName inManagedObjectContext:context];
    fetchRequest.entity = entity;
    fetchRequest.predicate = predicate;
    NSArray *resultSet = [UpdateManager executeForContext:context FetchRequest:fetchRequest];
    return resultSet;
}
- (NSArray *)fetchEntityDetail:(NSPredicate *)predicate intheEntity:(NSString *)entityName manageObjectContext:(NsmoContext *)context{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:entityName inManagedObjectContext:context];
    fetchRequest.entity = entity;
    if(predicate){
        fetchRequest.predicate = predicate;
    }
    NSArray *resultSet = [UpdateManager executeForContext:context FetchRequest:fetchRequest];
    return resultSet;
}
-(RestaurantItem *)insertGasItemInLocalDataBase:(NSDictionary *)restaurantOrderItemDictionary withContext:(NSManagedObjectContext *)context withItemRestaurantOrder:(RestaurantOrder *)restaurantOrder
{
    RestaurantItem *restaurantItem = nil;
    restaurantItem = (RestaurantItem *)[self insertEntityWithName:@"RestaurantItem" moc:context];
    [restaurantItem updateRestaurantItemDictionary:restaurantOrderItemDictionary];
    [restaurantOrder addRestaurantOrderItemObject:restaurantItem];
    restaurantItem.itemToOrderRestaurant = restaurantOrder;
    [UpdateManager saveContext:context];
    return restaurantItem;
}
-(void)deleteInitiatedCartForPumpIndex:(NSNumber *)pumpIndex withInvNo:(NSString *)reginvNo{
//    NSManagedObjectContext * privateManagedObjectContext = [RmsDbController sharedRmsDbController].rapidPetroPos.petroMOC;
//    
//    NSDictionary *dict = @{@"pumpIndex":pumpIndex,@"cartId":@"",@"regInvNum":reginvNo};
//    PumpCart  *pumpCart = (PumpCart *)[self __fetchEntityWithName:@"PumpCart" keysAndValue:dict shouldCreate:NO moc:privateManagedObjectContext];
//    
//    if (pumpCart) {
//        [UpdateManager deleteFromContext:privateManagedObjectContext object:pumpCart];
//        [UpdateManager saveContext:privateManagedObjectContext];
//    }
}

-(void)deleteInitiatedCartForPumpIndex:(NSNumber *)pumpIndex{
//    NSManagedObjectContext * privateManagedObjectContext = [RmsDbController sharedRmsDbController].rapidPetroPos.petroMOC;
//    
//    NSDictionary *dict = @{@"pumpIndex":pumpIndex,@"cartId":@"",@"transactionType":@"POST-PAY"};
//    PumpCart  *pumpCart = (PumpCart *)[self __fetchEntityWithName:@"PumpCart" keysAndValue:dict shouldCreate:NO moc:privateManagedObjectContext];
//    
//    if (pumpCart) {
//        [UpdateManager deleteFromContext:privateManagedObjectContext object:pumpCart];
//        [UpdateManager saveContext:privateManagedObjectContext];
//    }
}
@end
