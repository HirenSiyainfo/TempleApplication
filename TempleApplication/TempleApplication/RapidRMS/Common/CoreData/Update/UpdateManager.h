//
//  UpdateManager.h
//  POSRetail
//
//  Created by Siya Infotech on 21/03/14.
//  Copyright (c) 2014 Nirav Patel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Configuration.h"
#import "InvoiceData_T+Dictionary.h"

#define OBJECT_COPY(O, C) [UpdateManager objectCopy:O fromContext:C]

@class Item;
@class InvoiceData_T;
@class ModuleInfo;
@class RegisterInfo;
@class BranchInfo;
@class CreditcardCredetnial;
@class ItemInventoryCountSession;
@class ItemInventoryCount;
@class ManualReceivedItem;
@class ManualPOSession;
@class ItemInfoEditVC;
@class VPurchaseOrder;
@class VPurchaseOrderItem;
@class Vendor_Item;
@class RestaurantOrder;
@class RestaurantItem;
@class Department;
@class BarCodeSearch;
@class PumpCart;
@class PumpCartInvoiceData;
@class UserInfo;


typedef NSManagedObjectContext NsmoContext;

@class NSManagedObject;

@protocol UpdateDelegate <NSObject>

@optional
- (void)insertDidFinish;
- (void)updateDidFinish;
- (void)masterUpdateDidFinish;
- (void)departmentUpdateDidFinish;
@end

@interface UpdateManager : NSObject

- (instancetype)initWithManagedObjectContext:(NsmoContext*)managedObjectContext delegate:(id<UpdateDelegate>)delegate NS_DESIGNATED_INITIALIZER;

+ (NsmoContext *)privateConextFromParentContext:(NsmoContext*)parentContext;

// This method is for first time insertion of item data
- (void)insertObjectsFromResponseDictionary:(NSDictionary*)responseDictionary;
// This method is for updating of item data when item db is not empty.
- (void)updateObjectsFromResponseDictionary:(NSDictionary*)updateResponseDictionary;
// This method is for update of Master Data.
- (void)insertObjectsFromMasterResponseDictionary:(NSDictionary*)masterResponseDictionary ;

- (void)UpdateObjectsFromMasterResponseDictionary:(NSDictionary*)masterResponseDictionary ;

- (void)linkItemToDepartmentFromResponseDictionary:(NSDictionary*)updateResponseDictionary ;

-(Configuration *)insertConfigurationMoc:(NsmoContext*)moc;
+(Configuration *)getConfigurationMoc:(NsmoContext*)moc;

// This method is for updating Department data
-(void)insertDepartmentFromDepartmentlist:(NSArray *)departmentList moc:(NsmoContext*)moc;
-(void)linkWithDepartmentFromItem:(Item*)item moc:(NsmoContext*)moc;
-(void)insertSizeMaster:(NSArray*)sizeMasterList moc:(NsmoContext*)moc;
-(void)deleteObjectsFromTable:(NSDictionary*)deleteDictionary;

-(void)insertSubDepartmentWithDictionary:(NSDictionary *)subDepartmentDictionary;
-(void)updateSubDepartmentWithDictionary:(NSDictionary *)subDepartmentDictionary;

-(void)insertDepartmentWithDictionary:(NSDictionary *)departmentDictionary;
-(void)updateDepartmentWithDictionary:(NSDictionary *)departmentDictionary;

-(void)insertSupplierCompanyWithDictionary:(NSDictionary *)departmentDictionary;
-(void)insertSupplierRepresentativelist:(NSArray *)supplierRepresentativeList moc:(NsmoContext*)moc;

- (Item*)fetchItemFromDBWithItemId:(NSString*)itemId shouldCreate:(BOOL)shouldCreate moc:(NsmoContext*)moc;
- (NSManagedObject*)insertEntityWithName:(NSString*)entityName moc:(NsmoContext*)moc;

+ (NSArray*)executeForContext:(NsmoContext*)theContext FetchRequest:(NSFetchRequest*)fetchRequest;
+ (void)saveContext:(NsmoContext*)theContext;
+ (void)deleteFromContext:(NsmoContext*)theContext object:(NSManagedObject*)anObject;
+ (NSUInteger)countForContext:(NsmoContext*)theContext FetchRequest:(NSFetchRequest*)fetchRequest;
+ (void)deleteFromContext:(NsmoContext*)theContext objectId:(NSManagedObjectID*)anObjectId;

+ (NSManagedObject*)objectCopy:(NSManagedObject*)object fromContext:(NsmoContext *)context;


- (NSArray*)fetcObjectsWithItemCodeName:(NSString*)entityName key:(NSString*)key value:(id)value moc:(NsmoContext*)moc;
- (NSArray*)fetcDiscountMD2ObjectsWithItemCodeName:(NSString*)entityName key:(NSString*)key value:(id)value moc:(NsmoContext*)moc;

- (void)insertGroupMaster:(NSArray*)paymentMasterList moc:(NsmoContext*)moc;

-(void)updateSupplierListFromItemTable :(NSArray *)supplierlist with:(NSString *)itemCode;
-(void)updateTaxListFromItemTable :(NSArray *)taxArray with:(NSString *)itemCode;
-(void)updateSizeListFromItemTable :(NSArray *)sizeArray with:(NSString *)itemCode;
-(void)deleteItemWithItemCode:(NSNumber*)itemCode;
-(void)deleteSubDepartmentWithSubDepartmentId:(NSNumber*)subDepartmentId;
-(void)deleteDepartmentWithSubDepartmentId:(NSNumber*)subDepartmentId;
- (NSDate *)ludFromString:(NSString *)configDateString;
-(void)insertMasterDate;
-(void)insertMasterDate:(NSString *)strDate;
-(void)insertItemUpdateDate:(NSString *)strDate;
- (InvoiceData_T *)insertTenderPaymentDataFromDictionary:(NSDictionary*)responseDictionary withContext:(NsmoContext*)privateManagedObjectContext;
- (InvoiceData_T *)updateDataToDataTableWithObject :(NSManagedObjectID *)invoiceDataId withInvoiceDetail:(NSDictionary*)responseDictionary;

- (BOOL)doesBarcodeExist:(NSString *)barCode forItemCode:(NSString *)itemCode;

-(void)insertGasPumpDataFromXmlList:(NSData *)gasPumpData moc:(NsmoContext*)moc;


/// Lastinvoice data insert
-(void)insertLastinvoiceDataFromDictionary :(NSDictionary *)invoiceDictionary withSubDictionary:(NSDictionary *)subDictionary;
-(ModuleInfo *)updateModuleInfoMoc:(NsmoContext*)moc;

-(RegisterInfo *)updateRegisterInfoMoc:(NsmoContext*)moc;
-(BranchInfo *)updateBranchInfoMoc:(NsmoContext*)moc;
-(BarCodeSearch *)updateBarcodeSearchInfo:(NsmoContext*)moc;

-(void)deleteModuleInfoFromDatabaseWithContext:(NsmoContext *)moc;
-(ModuleInfo *)fetchModuleInfoMoc:(NsmoContext*)moc withDiviceId:(NSString *)deviceId;
-(void)updateCreditcardCredentialWithDetail :(NSMutableArray *)credentialDetail withContext:(NsmoContext*)context;
-(CreditcardCredetnial *)fetchCreditcardCredetnialMoc:(NsmoContext*)moc;
-(NSArray *)moduleInfoMoc:(NsmoContext*)moc;

-(void)updateZidWithRegisrterInfo :(NSString *)zid withContext:(NsmoContext *)manageObjectContext;
-(NSArray *)fetchEntityFromDatabase:(NsmoContext *)moc withEntityName:(NSString *)entityname;

-(void)insertCustomVariationMasterToCoreData:(NSMutableArray *)customVariationList;
-(void)updateSizeMasterToCoreData:(NSMutableArray *)sizeList;

- (void)liveUpdateFromResponseDictionary:(NSDictionary*)updateResponseDictionary;


-(void)updateItemForInventoryCountListwithDetail:(NSDictionary *)inventoryCountDictionary withItem:(Item *)item withitemInventoryCount:(ItemInventoryCount *)itemInventoryCount withItemInventorySession:(ItemInventoryCountSession *)itemInventoryCountSession withManageObjectContext:(NsmoContext *)context;

-(void)updateItemForInventoryCountListwithServerDetail:(NSDictionary *)inventoryCountDictionary withItem:(Item *)item withitemInventoryCount:(ItemInventoryCount *)itemInventoryCount withItemInventorySession:(ItemInventoryCountSession *)itemInventoryCountSession withManageObjectContext:(NsmoContext *)context;

-(void)modifidedServerUpdateItemForInventoryCountHistoryListwithDetail:(NSDictionary *)inventoryCountDictionary withItem:(Item *)item withitemInventoryCount:(ItemInventoryCount *)itemInventoryCount withItemInventorySession:(ItemInventoryCountSession *)itemInventoryCountSession withInventoryCountSessionDetail:(NSDictionary *)inventoryCountSessionDictionary withManageObjectContext:(NsmoContext *)context;

-(void)modifidedUpdateItemForInventoryCountListwithDetail:(NSDictionary *)inventoryCountDictionary withItem:(Item *)item withitemInventoryCount:(ItemInventoryCount *)itemInventoryCount withItemInventorySession:(ItemInventoryCountSession *)itemInventoryCountSession withInventoryCountSessionDetail:(NSDictionary *)inventoryCountSessionDictionary withManageObjectContext:(NsmoContext *)context;

-(void)modifidedServerUpdateItemForInventoryCountListwithDetail:(NSDictionary *)inventoryCountDictionary withItem:(Item *)item withitemInventoryCount:(ItemInventoryCount *)itemInventoryCount withItemInventorySession:(ItemInventoryCountSession *)itemInventoryCountSession withInventoryCountSessionDetail:(NSDictionary *)inventoryCountSessionDictionary withManageObjectContext:(NsmoContext *)context;

-(void)insertReconcileCountForItem:(Item *)item withDetail:(NSMutableDictionary *)reconcileSessionlistDictionary withReconcileSession:(ItemInventoryCountSession *)itemInventoryCountSession withContext:(NsmoContext *)moc;


-(void)updateItemReceiveListwithDetail:(NSDictionary *)receiveItemDictionary withItem:(Item *)item withitemReceive:(ManualReceivedItem *)itemreceive withManualPoSession:(ManualPOSession *)posession withManageObjectContext:(NsmoContext *)context;



-(ItemInventoryCountSession*)insertInventoryCountSessionInLocalDataBaseWithDetail :(NSDictionary *)inventoryCountSessionDetail withContext:(NsmoContext *)context;

- (ItemInventoryCountSession*)fetchItemInventoryCountSession:(NSString *)sessionId moc:(NsmoContext*)moc;
-(void)removeItemInventoryCount:(ItemInventoryCount *)itemInventoryCount withManageObjectContext:(NsmoContext *)context;

-(void)updateDepartmentTaxForList :(NSArray *)departmentTaxList;

-(ManualPOSession *)insertManualPOWithDictionary:(NSDictionary *)PoDictionary;

-(void)addPrinterDictionary:(NSDictionary *)printerDictionary withDepartment:(NSMutableArray *)deptArray;

-(void)updatePrinterDictionary:(NSDictionary *)printerDictionary withDepartment:(NSMutableArray *)deptArray withMoc:(NsmoContext *)moc;

-(void)insertManualPOItemWithDictionary:(NSDictionary *)PoitemDictionary;

//// tax
-(void)insertTaxMasterWithDictionary:(NSDictionary *)taxMasterDictionary;
-(void)updateTaxMasterWithDictionary:(NSDictionary *)taxMasterDictionary;

//// Payment
-(void)insertPayMasterWithDictionary:(NSDictionary *)payMasterDictionary;
-(void)updatePayMasterWithDictionary:(NSDictionary *)payMasterDictionary;

-(void)updatePaymentMaster:(NSArray*)paymentMasterList moc:(NsmoContext*)moc;
-(void)insertPaymentMaster:(NSArray*)paymentMasterList moc:(NsmoContext*)moc;

// Customer
-(void)insertCustomerWithDictionary:(NSDictionary *)customerDictionary;
-(void)updateCustomerWithDictionary:(NSDictionary *)customerDictionary;

-(void)updateCustomerInfo:(NSArray *)customerInfoList moc:(NsmoContext*)moc;


-(NSMutableArray *)updateGasAmountLimitandDeleteOjbect:(NSMutableArray *)paymentMasterList moc:(NsmoContext*)moc;



-(ManualReceivedItem *)updateItemReceiveListwithDetailReturn:(NSDictionary *)receiveItemDictionary withItem:(Item *)item withitemReceive:(ManualReceivedItem *)itemreceive withManualPoSession:(ManualPOSession *)posession withManageObjectContext:(NsmoContext *)context;


-(void)cleanUptheManaulPoTables:(NsmoContext *)moc;
-(ManualPOSession *)fetchManualPOWithDictionary:(NSInteger)poid withManageObjectContext:(NsmoContext *)moc;

- (NSArray*)fetchAllPoitemDetailsFromID:(NsmoContext *)moc withItemID:(NSString *)strID;

-(VPurchaseOrder *)insertVendorPoDictionary:(NSDictionary *)vendorPoDictionary;
-(VPurchaseOrder *)fetchVendorPurchaseOrder:(NSInteger)poid withManageObjectContext:(NsmoContext *)moc;

-(void)updatePurchaseOrderItemListwithDetail:(NSDictionary *)receivePOItemDictionary withVendorItem:(Vendor_Item *)vitem withpurchaseOrderItem:(VPurchaseOrderItem *)vPoitemreceive withPurchaseOrder:(VPurchaseOrder *)vPurchaseOrder withManageObjectContext:(NsmoContext *)context;

-(VPurchaseOrderItem *)updatePurchaseOrderItemListwithDetailReturn:(NSDictionary *)receivePOItemDictionary withVendorItem:(Vendor_Item *)vitem withpurchaseOrderItem:(VPurchaseOrderItem *)vPoitemreceive withPurchaseOrder:(VPurchaseOrder *)vPurchaseOrder withManageObjectContext:(NsmoContext *)context;

- (NSArray*)getPurchaseOrderItem:(NsmoContext *)moc withItemID:(NSString *)stritemID andPoID:(NSString *)strpoId;

-(void)deleteAllPurchaseOrders:(NsmoContext *)moc;
-(void)deleteAllPurchaseOrdersItems:(NsmoContext *)moc;
- (Vendor_Item *)fetchVendorItem :(NSInteger)itemId manageObjectContext:(NsmoContext *)context;
- (NSManagedObject*)__fetchEntityWithName:(NSString*)entityName key:(NSString*)key value:(id)value shouldCreate:(BOOL)shouldCreate moc:(NsmoContext*)moc;
- (NSManagedObject*)__fetchEntityWithName:(NSString*)entityName key:(NSString*)key value:(id)value  key2:(NSString*)key2 value2:(id)value2 shouldCreate:(BOOL)shouldCreate moc:(NsmoContext*)moc;
+ (NSArray <NSManagedObject*> *)fetchEntityWithName:(NSString*)entityName withPredicate:(NSPredicate *)predicate moc:(NsmoContext*)moc;
- (Vendor_Item *)insertVendorItemWithItemDictionary:(NSDictionary *)itemDictionary moc:(NsmoContext *)moc;
-(void)insertVendorItemWithItem:(NSDictionary *)itemDictionary moc:(NsmoContext *)moc;
-(void)updateDetailWithUserInfo:(NSDictionary *)userInfoDictionary withmoc:(NsmoContext *)context;
- (void)deleteDetailOfUserInfo:(NsmoContext *)privateContextObject;
- (void)deleteDetailOfUserInfoWithUserId:(NSNumber *)userId withContext:(NsmoContext *)privateContextObject;
-(NSUInteger )fetchEntityObjectsCounts :(NSString *)entityName withManageObjectContext:(NsmoContext *)moc;
-(void)insertHoldTransctionInLocalDataBase:(NSDictionary *)holdDictionary withContext:(NsmoContext *)context;
-(void)updateHoldTransctionInLocalDataBase:(NSDictionary *)holdDictionary withContext:(NsmoContext *)context;
-(NSInteger)deleteHoldInvoiceForRecallInvoiceID:(NSString *)recallInvoiceId;
-(void)insertNoSaleToLocalDatabase:(NSDictionary *)noSaleDictionary withContext:(NsmoContext *)context;
-(void)insertShiftDetailToLocalDatabase:(NSDictionary *)shiftDictionary withContext:(NsmoContext *)context;
-(RestaurantOrder *)insertRestaurantOrderListInLocalDataBase:(NSDictionary *)restaurantOrderListDictionary withContext:(NsmoContext *)context;
-(RestaurantItem *)insertRestaurantItemInLocalDataBase:(NSDictionary *)restaurantOrderItemDictionary withContext:(NsmoContext *)context withItemRestaurantOrder:(RestaurantOrder *)restaurantOrder withItem:(Item *)anitem;

-(RestaurantItem *)insertGasItemInLocalDataBase:(NSDictionary *)restaurantOrderItemDictionary withContext:(NSManagedObjectContext *)context withItemRestaurantOrder:(RestaurantOrder *)restaurantOrder;

-(RestaurantOrder *)fetchRestaurantOrderForInvoiceNo:(NSString *)invoiceNo withContext:(NSManagedObjectContext *)moc;


-(void)storeCurrentStep:(NSInteger)currentStep;
-(void)insertPhase1:(NSDictionary *)responseDictionary;
-(void)insertPhase2:(NSDictionary *)responseDictionary;
-(void)insertPhase3:(NSDictionary *)responseDictionary;
-(void)insertPhase4:(NSMutableArray *)vendorItem;

- (Department*)fetchDepartmentWithDepartmentId:(NSNumber*)departmentId moc:(NsmoContext*)moc;

-(void)deletePaymentMaster:(NSString*)paymentId moc:(NsmoContext*)moc;
-(void)updateTaxMaster:(NSArray *)taxMasterList moc:(NsmoContext*)moc;
-(void)deleteTaxMaster:(NSString*)taxId moc:(NsmoContext*)moc;

-(void)deleteCustomerInfo:(NSString*)custId moc:(NsmoContext*)moc;

- (void)deleteTaxMaster:(NSDictionary *)deleteDictionary;
-(void)updateFuelPumpInLocalDatabase:(NSArray *)fuelpump moc:(NsmoContext*)moc;
-(void)fuelPumpinReserveMode:(int)pumpIndex moc:(NsmoContext*)moc;
-(void)fuelPumpinunReserveMode:(int)pumpIndex moc:(NsmoContext*)moc;
-(void)updateFuelPumpMasterInLocalDatabase:(NSArray *)fuelpumpArray moc:(NsmoContext*)moc;
-(void)updateFuelTankInLocalDatabase:(NSArray *)fueltank moc:(NsmoContext*)moc;
-(void)updateFuelTypeInLocalDatabase:(NSArray *)fueltype moc:(NsmoContext*)moc;
-(void)updateMasterFuelTypeInLocalDatabase:(NSArray *)fueltype moc:(NsmoContext*)moc;
-(void)updateGasStationInLocalDatabase:(NSArray *)gasStation moc:(NsmoContext*)moc;
-(PumpCart *)insertCartDetailInLocalDatabaseWithcartDetail:(NSDictionary *)cartDetail moc:(NsmoContext*)moc;
-(void)insertPumpCartInvoiceDetailInLocalDatabaseWithcartDetail:(NSMutableDictionary *)invoiceDictionary moc:(NsmoContext*)moc;
-(PumpCartInvoiceData *)insertPumpCartInvoiceDetailInFromLive:(NSMutableDictionary *)invoiceDictionary moc:(NsmoContext*)moc;
-(PumpCart *)insertCartDetailInLocalDatabaseWithcartDetail:(NSDictionary *)cartDetail withInvoiceDetail:(NSMutableDictionary *)invoiceDictionary moc:(NsmoContext*)moc;

-(BOOL)checkCartIsOutSidePay:(NSDictionary *)cartDetail moc:(NsmoContext*)moc;
-(PumpCart *)updateBlankCartDetailInLocalDatabase:(NSDictionary *)cartDetail moc:(NsmoContext*)moc;
-(PumpCart *)updatePostPayBlankCartDetailInLocalDatabase:(NSDictionary *)cartDetail moc:(NsmoContext*)moc;
-(PumpCart *)getPumpCard:(NSDictionary *)pumpCardDetail withMoc:(NsmoContext*)moc;
-(void)updateLiveCartDetailInLocalDatabase:(NSArray *)pumpCartArray;
-(void)deleteCartDetailInLocalDatabase:(NSDictionary *)cartDetail moc:(NsmoContext*)moc;
- (NSArray *)fetchCartDetail:(NSPredicate *)predicate intheEntity:(NSString *)entityName manageObjectContext:(NsmoContext *)context;
- (NSArray *)fetchEntityDetail:(NSPredicate *)predicate intheEntity:(NSString *)entityName manageObjectContext:(NsmoContext *)context;
/*!
 *  @author Siya Infotech, 16-02-08 10:02:18
 *
 *  Used for MMD item insert OR update but sub class items are delete and inser new
 *
 *  @param privateManagedObjectContext private contax
 *  @param updateResponseDictionary    disctiona with MMD data
 */
-(BOOL)checkCartIsPostPay:(NSDictionary *)cartDetail moc:(NsmoContext*)moc;
-(void)configureMMDDataWithContex:(NsmoContext *)privateManagedObjectContext andChangedData:(NSDictionary*)updateResponseDictionary;
- (NSArray*)fetchFuelDetails:(NSString *)entityName withPumpIndex:(int)fuelIndex withMoc:(NsmoContext *)moc;
- (UserInfo *)fetchUserInfo:(NSNumber *)userId usingMOC:(NsmoContext *)context usingPredicate:(NSPredicate *)predicate;
- (void)deleteUserRights:(NsmoContext *)privateContextObject usingPredicate:(NSPredicate *)predicate;
-(void)updateRightInfoWithDetail:(NSArray *)allUserRightInfo forUser:(UserInfo *)userInfo withContext:(NsmoContext *)context;
- (NSArray*)fetcPumpCartWithName:(NSString*)entityName key:(NSString*)key value:(NSString *)value moc:(NsmoContext*)moc;
-(PumpCart *)movePumpCarttoDoneState:(NSDictionary *)cartDetail moc:(NsmoContext*)moc;
- (NSArray *)fetchAllEntityWithName:(NSString*)entityName key:(NSString*)key value:(NSArray *)value moc:(NsmoContext*)moc;
-(void)deleteInitiatedCartForPumpIndex:(NSNumber *)pumpIndex withInvNo:(NSString *)reginvNo;
-(void)deleteInitiatedCartForPumpIndex:(NSNumber *)pumpIndex;
-(void)insertOrUpdatePumpCartChangedData:(NSDictionary*)updateResponseDictionary;
@end
