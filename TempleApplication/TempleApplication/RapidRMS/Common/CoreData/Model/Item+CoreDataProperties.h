//
//  Item+CoreDataProperties.h
//  RapidRMS
//
//  Created by Siya9 on 24/08/17.
//  Copyright © 2017 Siya Infotech. All rights reserved.
//

#import "Item.h"


NS_ASSUME_NONNULL_BEGIN

@interface Item (CoreDataProperties)

+ (NSFetchRequest<Item *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSNumber *active;
@property (nullable, nonatomic, copy) NSNumber *averageCost;
@property (nullable, nonatomic, copy) NSString *barcode;
@property (nullable, nonatomic, copy) NSNumber *branchId;
@property (nullable, nonatomic, copy) NSString *cashierNote;
@property (nullable, nonatomic, copy) NSNumber *cate_MixMatchFlg;
@property (nullable, nonatomic, copy) NSNumber *cate_MixMatchId;
@property (nullable, nonatomic, copy) NSNumber *catId;
@property (nullable, nonatomic, copy) NSNumber *child_Qty;
@property (nullable, nonatomic, copy) NSNumber *citm_Code;
@property (nullable, nonatomic, copy) NSNumber *costPrice;
@property (nullable, nonatomic, copy) NSString *departmentName;
@property (nullable, nonatomic, copy) NSNumber *deptId;
@property (nullable, nonatomic, copy) NSString *descriptionText;
@property (nullable, nonatomic, copy) NSNumber *dis_CalcItm;
@property (nullable, nonatomic, copy) NSNumber *eBT;
@property (nullable, nonatomic, copy) NSNumber *is_Selected;
@property (nullable, nonatomic, copy) NSNumber *isDelete;
@property (nullable, nonatomic, copy) NSNumber *isDisplayInPos;
@property (nullable, nonatomic, copy) NSNumber *isDuplicateBarcodeAllowed;
@property (nullable, nonatomic, copy) NSNumber *isFavourite;
@property (nullable, nonatomic, copy) NSNumber *isItemPayout;
@property (nullable, nonatomic, copy) NSNumber *isNotDisplayInventory;
@property (nullable, nonatomic, copy) NSNumber *isPriceAtPOS;
@property (nullable, nonatomic, copy) NSNumber *isTicket;
@property (nullable, nonatomic, copy) NSString *item_Desc;
@property (nullable, nonatomic, copy) NSNumber *item_Discount;
@property (nullable, nonatomic, copy) NSString *item_ImagePath;
@property (nullable, nonatomic, copy) NSNumber *item_InStock;
@property (nullable, nonatomic, copy) NSNumber *item_MaxStockLevel;
@property (nullable, nonatomic, copy) NSNumber *item_MinStockLevel;
@property (nullable, nonatomic, copy) NSString *item_No;
@property (nullable, nonatomic, copy) NSString *item_Remarks;
@property (nullable, nonatomic, copy) NSNumber *itemCode;
@property (nullable, nonatomic, copy) NSString *itm_Type;
@property (nullable, nonatomic, copy) NSString *lastInvoice;
@property (nullable, nonatomic, copy) NSDate *lastReceivedDate;
@property (nullable, nonatomic, copy) NSDate *lastSoldDate;
@property (nullable, nonatomic, copy) NSNumber *memo;
@property (nullable, nonatomic, copy) NSNumber *mixMatchFlg;
@property (nullable, nonatomic, copy) NSNumber *mixMatchId;
@property (nullable, nonatomic, copy) NSNumber *noDiscountFlg;
@property (nullable, nonatomic, copy) NSString *orderStatus;
@property (nullable, nonatomic, copy) NSNumber *perbox_Qty;
@property (nullable, nonatomic, copy) NSNumber *pos_DISCOUNT;
@property (nullable, nonatomic, copy) NSString *pricescale;
@property (nullable, nonatomic, copy) NSNumber *profit_Amt;
@property (nullable, nonatomic, copy) NSString *profit_Type;
@property (nullable, nonatomic, copy) NSNumber *qty_Discount;
@property (nullable, nonatomic, copy) NSNumber *quantityManagementEnabled;
@property (nullable, nonatomic, copy) NSNumber *salesPrice;
@property (nullable, nonatomic, copy) NSString *salesVelocity;
@property (nullable, nonatomic, copy) NSString *sectionLabel;
@property (nullable, nonatomic, copy) NSNumber *subDeptId;
@property (nullable, nonatomic, retain) NSObject *supplierdata;
@property (nullable, nonatomic, copy) NSNumber *taxApply;
@property (nullable, nonatomic, copy) NSString *taxType;
@property (nullable, nonatomic, copy) NSNumber *weightqty;
@property (nullable, nonatomic, copy) NSString *weightype;
@property (nullable, nonatomic, copy) NSNumber *isDisplayInSubDept;
@property (nullable, nonatomic, retain) NSSet<ItemBarCode_Md *> *itemBarcodes;
@property (nullable, nonatomic, retain) Department *itemDepartment;
@property (nullable, nonatomic, retain) GroupMaster *itemGroupMaster;
@property (nullable, nonatomic, retain) NSSet<ItemInventoryCount *> *itemItemCount;
@property (nullable, nonatomic, retain) Mix_MatchDetail *itemMixMatchDisc;
@property (nullable, nonatomic, retain) NSSet<ModifierPrice *> *itemModifierPrices;
@property (nullable, nonatomic, retain) SubDepartment *itemSubDepartment;
@property (nullable, nonatomic, retain) NSSet<ItemTag *> *itemTags;
@property (nullable, nonatomic, retain) ItemTicket_MD *itemTicket;
@property (nullable, nonatomic, retain) NSSet<Item_Discount_MD *> *itemToDisMd;
@property (nullable, nonatomic, retain) NSSet<ItemList *> *itemToItemList;
@property (nullable, nonatomic, retain) NSSet<Item_Price_MD *> *itemToPriceMd;
@property (nullable, nonatomic, retain) NSSet<RestaurantItem *> *itemToRestaurantItem;
@property (nullable, nonatomic, retain) NSSet<ItemVariation_M *> *itemVariations;
@property (nullable, nonatomic, retain) NSSet<ManualReceivedItem *> *manualEntries;
@property (nullable, nonatomic, retain) NSSet<Discount_Primary_MD *> *primaryItemDetail;
@property (nullable, nonatomic, retain) NSSet<Discount_Secondary_MD *> *secondaryItemDetail;
@property (nullable, nonatomic, retain) NSSet<SupplierCompany *> *suppliers;

@end

@interface Item (CoreDataGeneratedAccessors)

- (void)addItemBarcodesObject:(ItemBarCode_Md *)value;
- (void)removeItemBarcodesObject:(ItemBarCode_Md *)value;
- (void)addItemBarcodes:(NSSet<ItemBarCode_Md *> *)values;
- (void)removeItemBarcodes:(NSSet<ItemBarCode_Md *> *)values;

- (void)addItemItemCountObject:(ItemInventoryCount *)value;
- (void)removeItemItemCountObject:(ItemInventoryCount *)value;
- (void)addItemItemCount:(NSSet<ItemInventoryCount *> *)values;
- (void)removeItemItemCount:(NSSet<ItemInventoryCount *> *)values;

- (void)addItemModifierPricesObject:(ModifierPrice *)value;
- (void)removeItemModifierPricesObject:(ModifierPrice *)value;
- (void)addItemModifierPrices:(NSSet<ModifierPrice *> *)values;
- (void)removeItemModifierPrices:(NSSet<ModifierPrice *> *)values;

- (void)addItemTagsObject:(ItemTag *)value;
- (void)removeItemTagsObject:(ItemTag *)value;
- (void)addItemTags:(NSSet<ItemTag *> *)values;
- (void)removeItemTags:(NSSet<ItemTag *> *)values;

- (void)addItemToDisMdObject:(Item_Discount_MD *)value;
- (void)removeItemToDisMdObject:(Item_Discount_MD *)value;
- (void)addItemToDisMd:(NSSet<Item_Discount_MD *> *)values;
- (void)removeItemToDisMd:(NSSet<Item_Discount_MD *> *)values;

- (void)addItemToItemListObject:(ItemList *)value;
- (void)removeItemToItemListObject:(ItemList *)value;
- (void)addItemToItemList:(NSSet<ItemList *> *)values;
- (void)removeItemToItemList:(NSSet<ItemList *> *)values;

- (void)addItemToPriceMdObject:(Item_Price_MD *)value;
- (void)removeItemToPriceMdObject:(Item_Price_MD *)value;
- (void)addItemToPriceMd:(NSSet<Item_Price_MD *> *)values;
- (void)removeItemToPriceMd:(NSSet<Item_Price_MD *> *)values;

- (void)addItemToRestaurantItemObject:(RestaurantItem *)value;
- (void)removeItemToRestaurantItemObject:(RestaurantItem *)value;
- (void)addItemToRestaurantItem:(NSSet<RestaurantItem *> *)values;
- (void)removeItemToRestaurantItem:(NSSet<RestaurantItem *> *)values;

- (void)addItemVariationsObject:(ItemVariation_M *)value;
- (void)removeItemVariationsObject:(ItemVariation_M *)value;
- (void)addItemVariations:(NSSet<ItemVariation_M *> *)values;
- (void)removeItemVariations:(NSSet<ItemVariation_M *> *)values;

- (void)addManualEntriesObject:(ManualReceivedItem *)value;
- (void)removeManualEntriesObject:(ManualReceivedItem *)value;
- (void)addManualEntries:(NSSet<ManualReceivedItem *> *)values;
- (void)removeManualEntries:(NSSet<ManualReceivedItem *> *)values;

- (void)addPrimaryItemDetailObject:(Discount_Primary_MD *)value;
- (void)removePrimaryItemDetailObject:(Discount_Primary_MD *)value;
- (void)addPrimaryItemDetail:(NSSet<Discount_Primary_MD *> *)values;
- (void)removePrimaryItemDetail:(NSSet<Discount_Primary_MD *> *)values;

- (void)addSecondaryItemDetailObject:(Discount_Secondary_MD *)value;
- (void)removeSecondaryItemDetailObject:(Discount_Secondary_MD *)value;
- (void)addSecondaryItemDetail:(NSSet<Discount_Secondary_MD *> *)values;
- (void)removeSecondaryItemDetail:(NSSet<Discount_Secondary_MD *> *)values;

- (void)addSuppliersObject:(SupplierCompany *)value;
- (void)removeSuppliersObject:(SupplierCompany *)value;
- (void)addSuppliers:(NSSet<SupplierCompany *> *)values;
- (void)removeSuppliers:(NSSet<SupplierCompany *> *)values;

@end

NS_ASSUME_NONNULL_END
