//
//  Item+CoreDataProperties.m
//  RapidRMS
//
//  Created by Siya9 on 24/08/17.
//  Copyright © 2017 Siya Infotech. All rights reserved.
//

#import "Item+CoreDataProperties.h"

@implementation Item (CoreDataProperties)

+ (NSFetchRequest<Item *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Item"];
}

@dynamic active;
@dynamic averageCost;
@dynamic barcode;
@dynamic branchId;
@dynamic cashierNote;
@dynamic cate_MixMatchFlg;
@dynamic cate_MixMatchId;
@dynamic catId;
@dynamic child_Qty;
@dynamic citm_Code;
@dynamic costPrice;
@dynamic departmentName;
@dynamic deptId;
@dynamic descriptionText;
@dynamic dis_CalcItm;
@dynamic eBT;
@dynamic is_Selected;
@dynamic isDelete;
@dynamic isDisplayInPos;
@dynamic isDuplicateBarcodeAllowed;
@dynamic isFavourite;
@dynamic isItemPayout;
@dynamic isNotDisplayInventory;
@dynamic isPriceAtPOS;
@dynamic isTicket;
@dynamic item_Desc;
@dynamic item_Discount;
@dynamic item_ImagePath;
@dynamic item_InStock;
@dynamic item_MaxStockLevel;
@dynamic item_MinStockLevel;
@dynamic item_No;
@dynamic item_Remarks;
@dynamic itemCode;
@dynamic itm_Type;
@dynamic lastInvoice;
@dynamic lastReceivedDate;
@dynamic lastSoldDate;
@dynamic memo;
@dynamic mixMatchFlg;
@dynamic mixMatchId;
@dynamic noDiscountFlg;
@dynamic orderStatus;
@dynamic perbox_Qty;
@dynamic pos_DISCOUNT;
@dynamic pricescale;
@dynamic profit_Amt;
@dynamic profit_Type;
@dynamic qty_Discount;
@dynamic quantityManagementEnabled;
@dynamic salesPrice;
@dynamic salesVelocity;
@dynamic sectionLabel;
@dynamic subDeptId;
@dynamic supplierdata;
@dynamic taxApply;
@dynamic taxType;
@dynamic weightqty;
@dynamic weightype;
@dynamic isDisplayInSubDept;
@dynamic itemBarcodes;
@dynamic itemDepartment;
@dynamic itemGroupMaster;
@dynamic itemItemCount;
@dynamic itemMixMatchDisc;
@dynamic itemModifierPrices;
@dynamic itemSubDepartment;
@dynamic itemTags;
@dynamic itemTicket;
@dynamic itemToDisMd;
@dynamic itemToItemList;
@dynamic itemToPriceMd;
@dynamic itemToRestaurantItem;
@dynamic itemVariations;
@dynamic manualEntries;
@dynamic primaryItemDetail;
@dynamic secondaryItemDetail;
@dynamic suppliers;

@end
