//
//  RmsAppSeeEvents.h
//  RapidRMS
//
//  Created by Siya Infotech on 18/03/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#ifndef RapidRMS_RmsAppSeeEvents_h
#define RapidRMS_RmsAppSeeEvents_h

#pragma mark - Events

//*************************** Events Name ****************************//

//************** RcrPOSVC *************//

//MaterUpdate Event

#define kMasterUpdateEvent @"RapidAppStarted"
#define kMasterUpdateView @"MasterUpdateView"
#define kMasterUpdateService @"MasterUpdateService"
#define kModuelActivation @"ModuleActivation"

// Menu Events
#define kPosMenuItem @"PosMenuItem"
#define kPosMenuHold @"PosMenuHold"
#define kPosMenuRecall @"PosMenuRecall"
#define kPosMenuVoid @"PosMenuVoid"
#define kPosMenuDiscount @"PosMenuDiscount"
#define kPosMenuCancel @"PosMenuCancel"
#define kPosMenuRefund @"PosMenuRefund"
#define kPosMenuInvoice @"PosMenuInvoice"
#define kPosMenuNoSale @"PosMenuNoSale"
#define kPosMenuDrop @"PosMenuDrop"

// Menu Hold
#define kPosMenuHoldMessage @"PosMenuHoldMessage"
#define kPosMenuHoldCancel @"PosMenuHoldCancel"

#define kPosMenuHoldWebserviceCall @"PosMenuHoldWebserviceCall"
#define kPosMenuHoldWebserviceResponse @"PosMenuHoldWebserviceResponse"

// Menu Recall
#define kPosMenuRecallCancel @"PosMenuRecallCancel"
#define kPosMenuRecallOrder @"PosMenuRecallOrder"

#define kPosMenuRecallWebServiceCall @"PosMenuRecallWebServiceCall"
#define kPosMenuRecallWebServiceResponse @"PosMenuRecallWebServiceResponse"

// Menu Void Transaction
#define kPosMenuVoidTransactionWebServiceCall @"PosMenuVoidTransactionWebServiceCall"
#define kPosMenuVoidTransactionWebServiceResponse @"PosMenuVoidTransactionWebServiceResponse"

// Menu Discount
#define kPosMenuDiscountAdd @"PosMenuDiscountAdd"
#define kPosMenuDiscountRemove @"PosMenuDiscountRemove"
#define kPosMenuDiscountCancel @"PosMenuDiscountCancel"

// Menu Invoice
#define kPosMenuInvoiceAddItem @"PosMenuInvoiceAddItem"
#define kPosMenuInvoiceCancel @"PosMenuInvoiceCancel"

// Menu No Sale
#define kPosMenuNoSaleWebServiceCall @"PosMenuNoSaleWebServiceCall"
#define kPosMenuNoSaleWebServiceResponse @"PosMenuNoSaleWebServiceResponse"

// Menu Drop Amount
#define kPosMenuDropAmountProcessDone @"PosMenuDropAmountProcessDone"
#define kPosMenuDropAmountProcessFailed @"PosMenuDropAmountProcessFailed"


// Ring up - Adding Item / Department / Favorite Item
#define kPosItemSelectedForRingUp @"ItemSelectedForRingUp"
#define kPosDepartmentSelectedForRingUp @"PosDepartmentSelectedForRingUp"
#define kFavoriteItemSelectedForRingUp @"FavoriteItemSelectedForRingUp"

// Age Verification
#define kPosLaunchAgeVerification @"PosLaunchAgeVerification"
#define kPosVerifiedAge @"PosVerifiedAge"
#define kPosDeclineAge @"PosDeclineAge"

// Price At Pos
#define kPosLaunchPriceAtPos @"PosLaunchPriceAtPos"
#define kPosAddPriceAtPos @"PosAddPriceAtPos"
#define kPosCancelPriceAtPos @"PosCancelPriceAtPos"

// Item Swipe
#define kPosItemSwipe @"PosItemSwipe"
#define kPosItemSwipeCancel @"PosItemSwipeCancel"
#define kPosItemSwipeRemove @"PosItemSwipeRemove"
#define kPosItemSwipeQtyEdit @"PosItemSwipeQtyEdit"
#define kPosItemSwipePriceEdit @"PosItemSwipePriceEdit"
#define kPosItemSwipeRemoveDiscount @"PosItemSwipeRemoveDiscount"
#define kPosItemSwipeRemoveTaxes @"PosItemSwipeRemoveTaxes"
#define kPosItemSwipeAddTaxes @"PosItemSwipeAddTaxes"

// Tender
#define kPosTender @"PosTender"
#define kPosDoneTender @"PosDoneTender"

//************** CardProcessingVC *************//

// Card Processing
#define kPosCardSwipe @"PosCardSwipe"
#define kPosCardSwipeNotProper @"PosCardSwipeNotProper"
#define kPosPaymentProcessDone @"PosPaymentProcessDone"
#define kPosCardProcessFailed @"PosCardProcessFailed"
#define kPosCardProcessingCancel @"PosCardProcessingCancel"

#define kPosCardProcessingWebServiceCall @"PosCardProcessingWebServiceCall"
#define kPosCardProcessingWebServiceResponse @"PosCardProcessingWebServiceResponse"

// Manual CardProcessing
#define kPosManualCardProcessing @"PosManualCardProcessing"

#define kPosManualCardProcessingWebServiceCall @"PosManualCardProcessWebServiceCall"
#define kPosManualCardProcessingWebServiceResponse @"PosManualCardProcessWebServiceResponse"

//************** Rapid Inventory Management *************//

// Menu Events
#define kRIMMenuHome @"RIMMenuHome"
#define kRIMMenuItemList @"RIMMenuItemList"
#define kRIMMenuItemIn @"RIMMenuItemIn"
#define kRIMMenuItemOut @"RIMMenuItemOut"
#define kRIMMenuItemOpenOrder @"RIMMenuItemOpenOrder"
#define kRIMMenuItemCloseOrder @"RIMMenuItemCloseOrder"
#define kRIMMenuItemInventoryCount @"RIMMenuItemInventoryCount"
#define kRIMMenuItemSupplierInventory @"RIMMenuItemSupplierInventory"
#define kRIMMenuDepartmentMaster @"RIMMenuDepartmentMaster"
#define kRIMMenuMixMatchMaster @"RIMMenuMixMatchMaster"
#define kRIMMenuSupplierMaster @"RIMMenuSupplierMaster"
#define kRIMMenuGroupMaster @"RIMMenuGroupMaster"
#define kRIMMenuSubDepartment @"RIMMenuSubDepartment"
#define kRIMMenuModifierGroup @"RIMMenuModifierGroup"
#define kRIMMenuItemModifier @"RIMMenuItemModifier"
#define kRIMMenuLogout @"RIMMenuLogout"
#define kRIMMenuHide @"RIMMenuHide"
#define kRIMMenuDashboard @"RIMMenuDashboard"
#define kRIMMenuTaxMaster @"RIMMenuTaxMaster"
#define kRIMMenuPaymentMaster @"RIMMenuPaymentMaster"
#define kRIMMenuChangeGroupPrice @"RIMMenuChangeGroupPrice"



// Item Swipe Events
#define kRIMItemSwipe @"RIMItemItemSwipe"
#define kRIMItemSwipeCopy @"RIMItemItemSwipeCopy"
#define kRIMItemSwipeDelete @"RIMItemSwipeDelete"
#define kRIMItemSwipeSingle @"RIMItemSwipeSingleItem"
#define kRIMItemSwipeCase @"RIMItemSwipeCase"
#define kRIMItemSwipePack @"RIMItemSwipePack"

#define kRIMItemSwipeDeleteWebServiceCall @"RIMItemSwipeDeleteWebServiceCall"
#define kRIMItemSwipeDeleteWebServiceResponse @"RIMItemSwipeDeleteWebServiceResponse"

#define kRIMItemSwipeBarcodeWebServiceCall @"RIMItemSwipeBarcodeWebServiceCall"
#define kRIMItemSwipeBarcodeWebServiceResponse @"RIMItemSwipeBarcodeWebServiceResponse"

#define kRIMItemListWebServiceCall @"RIMItemListWebServiceCall"
#define kRIMItemListWebServiceResponse @"RIMItemListWebServiceResponse"

//************** Inventory Management *************//

// Footer Button Events
#define kRIMFooterNewItem @"RIMFooterNewItem"
#define kRIMFooterLogout @"RIMFooterLogout"
#define kRIMFooterItemInfo @"RIMFooterItemInfo"
#define kRIMFooterDone @"RIMFooterDone"
#define kRIMFooterItemSelect @"RIMFooterItemSelect"
#define kRIMFooterLablePrint @"RIMFooterLablePrint"

#define kRIMFooterLablePrintWebServiceCall @"RIMFooterLablePrintWebServiceCall"
#define kRIMFooterLablePrintWebServiceResponse @"RIMFooterLablePrintWebServiceResponse"

// Search Button Events
#define kRIMUniversalItemSearch @"RIMUniversalItemSearch"
#define kRIMUpcSearch @"RIMUpcSearch"
#define kRIMClearUniversalItemSearch @"RIMClearUniversalItemSearch"
#define kRIMClearUpcSearch @"RIMClearUpcSearch"
#define kRIMItemSearchRecordFound @"RIMItemSearchRecordFound"

#define kRIMItemFilterTypeSelection @"RIMItemFilterTypeSelection"

// Sorting Button Events
#define kRIMItemDescriptionSorting @"RIMItemDescriptionSorting"
#define kRIMItemQtySorting @"RIMItemQtySorting"
#define kRIMItemSalesPriceSorting @"RIMItemSalesPriceSorting"

//************** ItemInfoEditVC *************//

// Image Events
#define kRIMItemImage @"RIMItemImage"
#define kRIMItemTakeAPhoto @"RIMItemTakeAPhoto"
#define kRIMItemChooseExisting @"RIMItemChooseExisting"
#define kRIMItemInternet @"RIMItemInternet"
#define kRIMItemImageSearchWebServiceCall @"RIMItemImageSearchWebServiceCall"
#define kRIMItemImageSearchWebServiceResponse @"RIMItemImageSearchWebServiceResponse"
#define kRIMItemRemoveImage @"RIMItemRemoveImage"
#define kRIMItemRemoveImageCancel @"RIMItemRemoveImageCancel"
#define kRIMItemRemoveImageDone @"RIMItemRemoveImageDone"

//Display Views Events
#define kRIMDisplayViewInfo @"RIMDisplayViewInfo"
#define kRIMDisplayViewDiscount @"RIMDisplayViewDiscount"
#define kRIMDisplayViewHistory @"RIMDisplayViewHistory"
#define kRIMDisplayViewOption @"RIMDisplayViewOption"
#define kRIMDisplayViewPricing @"RIMDisplayViewPricing"

// Footer Button Events
#define kRIMFooterSaveItem @"RIMFooterSaveItem"
#define kRIMFooterDeleteItem @"RIMFooterDeleteItem"

#define kRIMItemInsertWebServiceCall @"RIMItemInsertWebServiceCall"
#define kRIMItemUpdateWebServiceCall @"RIMItemUpdateWebServiceCall"
#define kRIMItemDeleteWebServiceCall @"RIMItemDeleteWebServiceCall"

#define kRIMItemInsertWebServiceResponse @"RIMItemInsertWebServiceResponse"
#define kRIMItemUpdateWebServiceResponse @"RIMItemUpdateWebServiceResponse"
#define kRIMItemDeleteWebServiceResponse @"RIMItemDeleteWebServiceResponse"

// Info View
#define kRIMItemNameChange @"RIMItemNameChange"
#define kRIMItemNumberChange @"RIMItemNumberChange"
#define kRIMItemAllowDuplicateBarcode @"RIMItemAllowDuplicateBarcode"

#define kRIMItemQtyOHChangeOfSingle @"RIMItemQtyOHChangeOfSingle"
#define kRIMItemQtyOHChangeOfCase @"RIMItemQtyOHChangeOfCase"
#define kRIMItemQtyOHChangeOfPack @"RIMItemQtyOHChangeOfPack"

#define kRIMItemCostChangeOfSingle @"RIMItemCostChangeOfSingle"
#define kRIMItemCostChangeOfCase @"RIMItemCostChangeOfCase"
#define kRIMItemCostChangeOfPack @"RIMItemCostChangeOfPack"

#define kRIMItemProfitChangeOfSingle @"RIMItemProfitChangeOfSingle"
#define kRIMItemProfitChangeOfCase @"RIMItemProfitChangeOfCase"
#define kRIMItemProfitChangeOfPack @"RIMItemProfitChangeOfPack"

#define kRIMItemProfitMargin @"RIMItemProfitMargin"
#define kRIMItemProfitMarkUp @"RIMItemProfitMarkUp"

#define kRIMItemSalesPriceChangeOfSingle @"RIMItemSalesPriceChangeOfSingle"
#define kRIMItemSalesPriceChangeOfCase @"RIMItemSalesPriceChangeOfCase"
#define kRIMItemSalesPriceChangeOfPack @"RIMItemSalesPriceChangeOfPack"

#define kRIMItemNumberOfQtyChangeOfCase @"RIMItemNumberOfQtyChangeOfCase"
#define kRIMItemNumberOfQtyChangeOfPack @"RIMItemNumberOfQtyChangeOfPack"

#define kRIMItemDepartment @"RIMItemDepartment"
#define kRIMItemDepartmentSelected @"RIMItemDepartmentSelected"

#define kRIMItemSubDepartment @"RIMItemSubDepartment"

#define kRIMItemTaxType @"RIMItemTaxType"
#define kRIMItemTaxTypeSelected @"RIMItemTaxTypeSelected"
#define kRIMItemTaxTypeCancel @"RIMItemTaxTypeCancel"
#define kRIMItemTaxSelected @"RIMItemTaxSelected"

#define kRIMItemSupplier @"RIMItemSupplier"
#define kRIMItemSupplierSelected @"RIMItemSupplierSelected"

#define kRIMItemGroup @"RIMItemGroup"
#define kRIMItemGroupSelected @"RIMItemGroupSelected"

#define kRIMItemTag @"RIMItemTag"

#define kRIMItemRemarkChange @"RIMItemRemarkChange"
#define kRIMItemCashierNoteChange @"RIMItemCashierNoteChange"

// Pricing View
#define kRIMItemPriceAtPos @"RIMItemPriceAtPos"

#define kRIMItemUnitPriceChangeOfSingle @"RIMItemUnitPriceChangeOfSingle"
#define kRIMItemUnitPriceChangeOfCase @"RIMItemUnitPriceChangeOfCase"
#define kRIMItemUnitPriceChangeOfPack @"RIMItemUnitPriceChangeOfPack"

#define kRIMItemPriceOfLevelAChangeOfSingle @"RIMItemPriceOfLevelAChangeOfSingle"
#define kRIMItemPriceOfLevelAChangeOfCase @"RIMItemPriceOfLevelAChangeOfCase"
#define kRIMItemPriceOfLevelAChangeOfPack @"RIMItemPriceOfLevelAChangeOfPack"

#define kRIMItemPriceOfLevelBChangeOfSingle @"RIMItemPriceOfLevelBChangeOfSingle"
#define kRIMItemPriceOfLevelBChangeOfCase @"RIMItemPriceOfLevelBChangeOfCase"
#define kRIMItemPriceOfLevelBChangeOfPack @"RIMItemPriceOfLevelBChangeOfPack"

#define kRIMItemPriceOfLevelCChangeOfSingle @"RIMItemPriceOfLevelCChangeOfSingle"
#define kRIMItemPriceOfLevelCChangeOfCase @"RIMItemPriceOfLevelCChangeOfCase"
#define kRIMItemPriceOfLevelCChangeOfPack @"RIMItemPriceOfLevelCChangeOfPack"

#define kRIMItemUnitPriceForSingle @"RIMItemUnitPriceForSingle"
#define kRIMItemUnitPriceForCase @"RIMItemUnitPriceForCase"
#define kRIMItemUnitPriceForPack @"RIMItemUnitPricePack"

#define kRIMItemPriceLevelAForSingle @"RIMItemPriceLevelAForSingle"
#define kRIMItemPriceLevelAForCase @"RIMItemPriceLevelAForCase"
#define kRIMItemPriceLevelAForPack @"RIMItemPriceLevelAForPack"

#define kRIMItemPriceLevelBForSingle @"RIMItemPriceLevelBForSingle"
#define kRIMItemPriceLevelBForCase @"RIMItemPriceLevelBForCase"
#define kRIMItemPriceLevelBForPack @"RIMItemPriceLevelBForPack"

#define kRIMItemPriceLevelCForSingle @"RIMItemPriceLevelCForSingle"
#define kRIMItemPriceLevelCForCase @"RIMItemPriceLevelCForCase"
#define kRIMItemPriceLevelCForPack @"RIMItemPriceLevelCForPack"

#define kRIMItemIsCaseAllow @"RIMItemIsCashAllow"
#define kRIMItemIsPackAllow @"RIMItemIsPackAllow"

// Weight Scale View
#define kRIMWSNumberOfQtyChangeOfCase @"RIMWSNumberOfQtyChangeOfCase"
#define kRIMWSNumberOfQtyChangeOfPack @"RIMWSNumberOfQtyChangeOfPack"

#define kRIMWSCostChangeOfSingle @"RIMWSCostChangeOfSingle"
#define kRIMWSCostChangeOfCase @"RIMWSCostChangeOfCase"
#define kRIMWSCostChangeOfPack @"RIMWSCostChangeOfPack"

#define kRIMWSProfitChangeOfSingle @"RIMWSProfitChangeOfSingle"
#define kRIMWSProfitChangeOfCase @"RIMWSProfitChangeOfCase"
#define kRIMWSProfitChangeOfPack @"RIMWSProfitChangeOfPack"

#define kRIMWSUnitPriceChangeOfSingle @"RIMWSUnitPriceChangeOfSingle"
#define kRIMWSUnitPriceChangeOfCase @"RIMWSUnitPriceChangeOfCase"
#define kRIMWSUnitPriceChangeOfPack @"RIMWSUnitPriceChangeOfPack"

#define kRIMWSPriceOfLevelAChangeOfSingle @"RIMWSPriceOfLevelAChangeOfSingle"
#define kRIMWSPriceOfLevelAChangeOfCase @"RIMWSPriceOfLevelAChangeOfCase"
#define kRIMWSPriceOfLevelAChangeOfPack @"RIMWSPriceOfLevelAChangeOfPack"

#define kRIMWSPriceOfLevelBChangeOfSingle @"RIMWSPriceOfLevelBChangeOfSingle"
#define kRIMWSPriceOfLevelBChangeOfCase @"RIMWSPriceOfLevelBChangeOfCase"
#define kRIMWSPriceOfLevelBChangeOfPack @"RIMWSPriceOfLevelBChangeOfPack"

#define kRIMWSPriceOfLevelCChangeOfSingle @"RIMWSPriceOfLevelCChangeOfSingle"
#define kRIMWSPriceOfLevelCChangeOfCase @"RIMWSPriceOfLevelCChangeOfCase"
#define kRIMWSPriceOfLevelCChangeOfPack @"RIMWSPriceOfLevelCChangeOfPack"

#define kRIMWSUnitPriceForSingle @"RIMWSUnitPriceForSingle"
#define kRIMWSUnitPriceForCase @"RIMWSUnitPriceForCase"
#define kRIMWSUnitPriceForPack @"RIMWSUnitPriceForPack"

#define kRIMWSPriceLevelAForSingle @"RIMWSPriceLevelAForSingle"
#define kRIMWSPriceLevelAForCase @"RIMWSPriceLevelAForCase"
#define kRIMWSPriceLevelAForPack @"RIMWSPriceLevelAForPack"

#define kRIMWSPriceLevelBForSingle @"RIMWSPriceLevelBForSingle"
#define kRIMWSPriceLevelBForCase @"RIMWSPriceLevelBForCase"
#define kRIMWSPriceLevelBForPack @"RIMWSPriceLevelBForPack"

#define kRIMWSPriceLevelCForSingle @"RIMWSPriceLevelCForSingle"
#define kRIMWSPriceLevelCForCase @"RIMWSPriceLevelCForCase"
#define kRIMWSPriceLevelCForPack @"RIMWSPriceLevelCForPack"

#define kRIMWSUnitQtyChangeOfSingle @"RIMWSUnitQtyChangeOfSingle"
#define kRIMWSUnitQtyChangeOfCase @"RIMWSUnitQtyChangeOfCase"
#define kRIMWSUnitQtyChangeOfPack @"RIMWSUnitQtyChangeOfPack"


// Discount View
#define kRIMItemNoPosDiscount @"RIMItemNoPosDiscount"
#define kRIMItemNoDiscountScheme @"RIMItemNoDiscountScheme"
#define kRIMItemQtyDiscount @"RIMItemQtyDiscount"
#define kRIMItemDiscountQtyEdit @"RIMItemDiscountQtyEdit"
#define kRIMItemDiscountPriceEdit @"RIMItemDiscountPriceEdit"
#define kRIMItemDiscountPriceWithTaxEdit @"RIMItemDiscountPriceWithTaxEdit"
#define kRIMItemDiscountRemove @"RIMItemDiscountRemove"
#define kRIMItemApplyTaxToDiscount @"RIMItemApplyTaxToDiscount"
#define kRIMItemAddNewDiscountSection @"RIMItemAddNewDiscountSection"

// Option View
#define kRIMItemFavorite @"RIMItemFavorite"
#define kRIMItemDisplayInPos @"RIMItemDisplayInPos"
#define kRIMItemRemoveICForQtyOH @"RIMItemRemoveICForQtyOH"
#define kRIMItemPayout @"RIMItemPayout"
#define kRIMItemMemo @"RIMItemMemo"
#define kRIMItemMinInventoryLevel @"RIMItemMinInventoryLevel"
#define kRIMItemMaxInventoryLevel @"RIMItemMaxInventoryLevel"
#define kRIMParentItem @"RIMParentItem"
#define kRIMParentItemSelected @"RIMParentItemSelected"
#define kRIMClearParentItem @"RIMClearParentItem"
#define kRIMItemChildQty @"RIMItemChildQty"

//************** Item In *************//

// Footer Button Events
#define kRIMItemInFooterAddNew @"RIMItemInFooterAddNew"
#define kRIMItemInFooterSearch @"RIMItemInFooterSearch"
#define kRIMItemInFooterHold @"RIMItemInFooterHold"
#define kRIMItemInFooterSave @"RIMItemInFooterSave"
#define kRIMItemInFooterItemInfo @"RIMItemInFooterItemInfo"
#define kRIMItemInFooterExport @"RIMItemInFooterExport"

// Email & Preview Events
#define kRIMItemInEmail @"RIMItemInEmail"
#define kRIMItemInPreview @"RIMItemInPreview"

// Item Selected Event
#define kRIMItemInItemSelected @"RIMItemInItemSelected"

// Hold Events
#define kRIMItemInHoldSave @"RIMItemInHoldSave"
#define kRIMItemInHoldCancel @"RIMItemInHoldCancel"
#define kRIMItemInAddInventoryWebServiceCall @"RIMItemInAddInventoryWebServiceCall"
#define kRIMItemInAddInventoryWebServiceResponse @"RIMItemInAddInventoryWebServiceResponse"

// Barcode Search Events
#define kRIMItemInBarcodeSearch @"RIMItemInBarcodeSearch"
#define kRIMItemInBarcodeSearchWebServiceCall @"RIMItemInBarcodeSearchWebServiceCall"
#define kRIMItemInBarcodeSearchWebServiceResponse @"RIMItemInBarcodeSearchWebServiceResponse"

// Item Swipe Events
#define kRIMItemInSwipe @"RIMItemInSwipe"
#define kRIMItemInSwipeEdit @"RIMItemInSwipeEdit"
#define kRIMItemInSwipeCopy @"RIMItemInSwipeCopy"
#define kRIMItemInSwipeDelete @"RIMItemInSwipeDelete"
#define kRIMItemInSwipeDeleteCancel @"RIMItemInSwipeDeleteCancel"
#define kRIMItemInSwipeDeleteDone @"RIMItemInSwipeDeleteDone"

//************** Item Out *************//

// Footer Button Events
#define kRIMItemOutFooterClearAll @"RIMItemOutFooterClearAll"
#define kRIMItemOutFooterSearch @"RIMItemOutFooterSearch"
#define kRIMItemOutFooterHold @"RIMItemOutFooterHold"
#define kRIMItemOutFooterSave @"RIMItemOutFooterSave"
#define kRIMItemOutFooterItemInfo @"RIMItemOutFooterItemInfo"
#define kRIMItemOutFooterExport @"RIMItemOutFooterExport"

#define kRIMItemOutFooterClearAllCancel @"RIMItemOutFooterClearAllCancel"
#define kRIMItemOutFooterClearAllDone @"RIMItemOutFooterClearAllDone"

// Email & Preview Events
#define kRIMItemOutEmail @"RIMItemOutEmail"
#define kRIMItemOutPreview @"RIMItemOutPreview"

// Item Selected Event
#define kRIMItemOutItemSelected @"RIMItemOutItemSelected"

// Hold Events
#define kRIMItemOutHoldSave @"RIMItemOutHoldSave"
#define kRIMItemOutHoldCancel @"RIMItemOutHoldCancel"
#define kRIMItemOutAddInventoryWebServiceCall @"RIMItemOutAddInventoryWebServiceCall"
#define kRIMItemOutAddInventoryWebServiceResponse @"RIMItemOutAddInventoryWebServiceResponse"

// Barcode Search Events
#define kRIMItemOutBarcodeSearch @"RIMItemOutBarcodeSearch"
#define kRIMItemOutBarcodeSearchWebServiceCall @"RIMItemOutBarcodeSearchWebServiceCall"
#define kRIMItemOutBarcodeSearchWebServiceResponse @"RIMItemOutBarcodeSearchWebServiceResponse"

// Item Swipe Events
#define kRIMItemOutSwipeDelete @"RIMItemOutSwipeDelete"
#define kRIMItemOutSwipeDeleteCancel @"RIMItemOutSwipeDeleteCancel"
#define kRIMItemOutSwipeDeleteDone @"RIMItemOutSwipeDeleteDone"

//************** Item Open Order *************//

// Item Open Order List Events
#define kRIMItemOpenOrderListWebServiceCall @"RIMItemOpenOrderListWebServiceCall"
#define kRIMItemOpenOrderListWebServiceResponse @"RIMItemOpenOrderListWebServiceResponse"

#define kRIMItemOpenOrderSelectWebServiceCall @"RIMItemOpenOrderSelectWebServiceCall"
#define kRIMItemOpenOrderSelectWebServiceResponse @"RIMItemOpenOrderSelectWebServiceResponse"

// Export Options Events
#define kRIMItemOpenOrderListExportOption @"RIMItemOpenOrderListExportOption"
#define kRIMItemOpenOrderListExportOptionEmail @"RIMItemOpenOrderListExportOptionEmail"
#define kRIMItemOpenOrderListExportOptionPreview @"RIMItemOpenOrderListExportOptionPreview"

// Item Open Order Swipe Key
#define kRIMItemOpenOrderSwipeDelete @"RIMItemOpenOrderSwipeDelete"
#define kRIMItemOpenOrderSwipeDeleteCancel @"RIMItemOutSwipeDeleteCancel"

#define kRIMOOItemInDeleteWebServiceCall @"RIMOOItemInDeleteWebServiceCall"
#define kRIMOOItemOutDeleteWebServiceCall @"RIMOOItemOutDeleteWebServiceCall"

#define kRIMOOItemInDeleteWebServiceResponse @"RIMOOItemInDeleteWebServiceResponse"
#define kRIMOOItemOutDeleteWebServiceResponse @"RIMOOItemOutDeleteWebServiceResponse"

//************** Item Close Order *************//

// Export Options Events
#define kRIMItemCloseOrderListExportOption @"RIMItemCloseOrderListExportOption"
#define kRIMItemCloseOrderListExportOptionEmail @"RIMItemCloseOrderListExportOptionEmail"
#define kRIMItemCloseOrderListExportOptionPreview @"RIMItemCloseOrderListExportOptionPreview"

#define kRIMItemCloseOrderListDropDown @"RIMItemCloseOrderListDropDown"
#define kRIMItemCloseOrderListDropDownWeekly @"RIMItemCloseOrderListDropDownWeekly"
#define kRIMItemCloseOrderListDropDownCustomDate @"RIMItemCloseOrderListDropDownCustomDate"

#define kRIMItemCloseOrderListDropDownStartDate @"RIMItemCloseOrderListDropDownStartDate"
#define kRIMItemCloseOrderListDropDownEndDate @"RIMItemCloseOrderListDropDownEndDate"

#define kRIMItemCloseOrderListDatePickerDone @"RIMItemCloseOrderListDatePickerDone"
#define kRIMItemCloseOrderListDatePickerCancel @"RIMItemCloseOrderListDatePickerCancel"

#define kRIMItemCloseOrderListSearchDateWiseRecord @"RIMItemCloseOrderListSearchDateWiseRecord"

#define kRIMItemCloseOrderListWebServiceCall @"RIMItemCloseOrderListWebServiceCall"
#define kRIMItemCloseOrderListWebServiceResponse @"RIMItemCloseOrderListWebServiceResponse"

#define kRIMItemCloseOrderListItemInfo @"RIMItemCloseOrderListItemInfo"

#define kRIMCloseOrderItemInOutWebServiceCall @"RIMCloseOrderItemInOutWebServiceCall"
#define kRIMCloseOrderItemInOutWebServiceResponse @"RIMCloseOrderItemInOutWebServiceResponse"

//************** Item Supplier Inventory *************//

#define kRIMItemSupplierInventory @"RIMItemSupplierInventory"
#define kRIMItemSupplierInventoryMinimum @"RIMItemSupplierInventoryMinimum"
#define kRIMItemSupplierInventoryMaximum @"RIMItemSupplierInventoryMaximum"
#define kRIMItemSISearchBySupplierWebServiceCall @"RIMItemSISearchBySupplierWebServiceCall"
#define kRIMItemSISearchBySupplierWebServiceResponse @"RIMItemSISearchBySupplierWebServiceResponse"

//************** Department *************//

// Department List Events
#define kRIMDepartmentAdd @"RIMDepartmentAdd"
#define kRIMDepartmentSearch @"RIMDepartmentSearch"
#define kRIMDepartmentSearchRecordFound @"RIMDepartmentSearchRecordFound"
#define kRIMDepartmentClearSearchText @"RIMDepartmentClearSearchText"
#define kRIMDepartmentSelected @"RIMDepartmentSelected"

// Department Add & Edit Events
#define kRIMDepartmentImage @"RIMDepartmentImage"
#define kRIMDepartmentTakeAPhoto @"RIMDepartmentTakeAPhoto"
#define kRIMDepartmentChooseExisting @"RIMDepartmentChooseExisting"
#define kRIMDepartmentInternet @"RIMDepartmentInternet"
#define kRIMDepartmentImageSearchWebServiceCall @"RIMDepartmentImageSearchWebServiceCall"
#define kRIMDepartmentImageSearchWebServiceResponse @"RIMDepartmentImageSearchWebServiceResponse"
#define kRIMDepartmentRemoveImage @"RIMDepartmentRemoveImage"
#define kRIMDepartmentRemoveImageCancel @"RIMDepartmentRemoveImageCancel"
#define kRIMDepartmentRemoveImageDone @"RIMDepartmentRemoveImageDone"

#define kRIMDepartmentName @"RIMDepartmentName"
#define kRIMDepartmentCode @"RIMDepartmentCode"
#define kRIMDepartmentProfitMargin @"RIMDepartmentProfitMargin"
#define kRIMDepartmentCheckCashAmount @"RIMDepartmentCheckCashAmount"
#define kRIMDepartmentChargeTypeAmount @"RIMDepartmentChargeTypeAmount"

#define kRIMDepartmentNameClear @"RIMDepartmentNameClear"
#define kRIMDepartmentCodeClear @"RIMDepartmentCodeClear"
#define kRIMDepartmentProfitMarginClear @"RIMDepartmentProfitMarginClear"
#define kRIMDepartmentCheckCashAmountClear @"RIMDepartmentCheckCashAmountClear"
#define kRIMDepartmentChargeTypeAmountClear @"RIMDepartmentChargeTypeAmountClear"

#define kRIMDepartmentAgeRestriction @"RIMDepartmentAgeRestriction"
#define kRIMDepartmentCheckCash @"RIMDepartmentCheckCash"
#define kRIMDepartmentChargeType @"RIMDepartmentChargeType"
#define kRIMDepartmentTaxApplyIn @"RIMDepartmentTaxApplyIn"
#define kRIMDepartmentTax @"RIMDepartmentTax"

#define kRIMDepartmentAgeSelected @"RIMDepartmentAgeSelected"
#define kRIMDepartmentCheckCashSelected @"RIMDepartmentCheckCashSelected"
#define kRIMDepartmentChargeTypeSelected @"RIMDepartmentChargeTypeSelected"
#define kRIMDepartmentTaxApplyInSelected @"RIMDepartmentTaxApplyInSelected"

#define kRIMDepartmentTaxSelected @"RIMDepartmentTaxSelected"

#define kRIMDepartmentInfo @"RIMDepartmentInfo"
#define kRIMDepartmentSetting @"RIMDepartmentSetting"

#define kRIMDepartmentClose @"RIMDepartmentClose"
#define kRIMDepartmentSave @"RIMDepartmentSave"

#define kRIMTaxMasterClose @"RIMTaxMasterClose"
#define kRIMTaxMasterSave @"RIMTaxMasterSave"

#define kRIMPaymentMasterClose @"RIMPaymentMasterClose"
#define kRIMPaymentMasterSave @"RIMPaymentMasterSave"

#define kRIMDepartmentInsertWebServiceCall @"RIMDepartmentInsertWebServiceCall"
#define kRIMDepartmentUpdateWebServiceCall @"RIMDepartmentUpdateWebServiceCall"

#define kRIMDepartmentInsertWebServiceResponse @"RIMDepartmentInsertWebServiceResponse"
#define kRIMDepartmentUpdateWebServiceResponse @"RIMDepartmentUpdateWebServiceResponse"

//************** SubDepartment *************//

// SubDepartment List Events
#define kRIMSubDepartmentAdd @"RIMSubDepartmentAdd"
#define kRIMSubDepartmentSearch @"RIMSubDepartmentSearch"
#define kRIMSubDepartmentSearchRecordFound @"RIMSubDepartmentSearchRecordFound"
#define kRIMSubDepartmentClearSearchText @"RIMSubDepartmentClearSearchText"
#define kRIMSubDepartmentSelected @"RIMSubDepartmentSelected"

// SubDepartment Add , Edit & Delete Events
#define kRIMSubDepartmentImage @"RIMSubDepartmentImage"
#define kRIMSubDepartmentTakeAPhoto @"RIMSubDepartmentTakeAPhoto"
#define kRIMSubDepartmentChooseExisting @"RIMSubDepartmentChooseExisting"
#define kRIMSubDepartmentInternet @"RIMSubDepartmentInternet"
#define kRIMSubDepartmentImageSearchWebServiceCall @"RIMSubDepartmentImageSearchWebServiceCall"
#define kRIMSubDepartmentImageSearchWebServiceResponse @"RIMSubDepartmentImageSearchWebServiceResponse"
#define kRIMSubDepartmentRemoveImage @"RIMSubDepartmentRemoveImage"
#define kRIMSubDepartmentRemoveImageCancel @"RIMSubDepartmentRemoveImageCancel"
#define kRIMSubDepartmentRemoveImageDone @"RIMSubDepartmentRemoveImageDone"

#define kRIMSubDepartmentName @"RIMSubDepartmentName"
#define kRIMSubDepartmentCode @"RIMSubDepartmentCode"
#define kRIMSubDepartmentRemarks @"RIMSubDepartmentRemarks"

#define kRIMSubDepartmentNameClear @"RIMSubDepartmentNameClear"
#define kRIMSubDepartmentCodeClear @"RIMSubDepartmentCodeClear"
#define kRIMSubDepartmentRemarksClear @"RIMSubDepartmentRemarksClear"

#define kRIMSubDepartmentClose @"RIMSubDepartmentClose"
#define kRIMSubDepartmentSave @"RIMSubDepartmentSave"
#define kRIMSubDepartmentDelete @"RIMSubDepartmentDelete"

#define kRIMSubDepartmentInsertWebServiceCall @"RIMSubDepartmentInsertWebServiceCall"
#define kRIMSubDepartmentUpdateWebServiceCall @"RIMSubDepartmentUpdateWebServiceCall"
#define kRIMSubDepartmentDeleteWebServiceCall @"RIMSubDepartmentDeleteWebServiceCall"

#define kRIMSubDepartmentInsertWebServiceResponse @"RIMSubDepartmentInsertWebServiceResponse"
#define kRIMSubDepartmentUpdateWebServiceResponse @"RIMSubDepartmentUpdateWebServiceResponse"
#define kRIMSubDepartmentDeleteWebServiceResponse @"RIMSubDepartmentDeleteWebServiceResponse"

//************** Email Send *************//

#define kRIMEmailSend @"RIMEmailSend"
#define kRIMEmailCancel @"RIMEmailCancel"

//************************* Purchase Order *************************//

// Menu Events
#define kPOMenuGenerateOrder @"POMenuGenerateOrder"
#define kPOMenuPurchaseOrderList @"POMenuPurchaseOrderList"
#define kPOMenuOpenOrder @"POMenuOpenOrder"
#define kPOMenuDeliveryPending @"POMenuDeliveryPending"
#define kPOMenuCloseOrder @"POMenuCloseOrder"
#define kPOMenuDashboard @"POMenuDashboard"
#define kPOMenuLogout @"POMenuLogout"

//************** Generate Order *************//
#define kPOGenerateOrderSelectDate @"POGenerateOrderSelectDate"
#define kPOGenerateOrderSelectedType @"POGenerateOrderSelectedType"

#define kPOGenerateOrderFromDateSelected @"POGenerateOrderFromDateSelected"
#define kPOGenerateOrderToDateSelected @"POGenerateOrderToDateSelected"

#define kPOGenerateOrderDepartmentSelection @"POGenerateOrderDepartmentSelection"
#define kPOGenerateOrderSupplierSelection @"POGenerateOrderSupplierSelection"
#define kPOGenerateOrderGroupSelection @"POGenerateOrderGroupSelection"

#define kPOGenerateOrderDepartmentsSelected @"POGenerateOrderDepartmentsSelected"
#define kPOGenerateOrderSuppliersSelected @"POGenerateOrderSuppliersSelected"
#define kPOGenerateOrderGroupsSelected @"POGenerateOrderGroupsSelected"
#define kPOGenerateOrderTagSelected @"POGenerateOrderTagSelected"
#define kPOGenerateOrderMinimumStoke @"POGenerateOrderMinimumStoke"

#define kPOGenerateOrderOpenBackListData @"POGenerateOrderOpenBackListData"
#define kPOGOOpenBackListDataWebServiceCall @"POGOOpenBackListDataWebServiceCall"
#define kPOGOOpenBackListDataWebServiceResponse @"POGOOpenBackListDataWebServiceResponse"

#define kPOGenerateOrderWebServiceCall @"POGenerateOrderWebServiceCall"
#define kPOGenerateOrderWebServiceResponse @"POGenerateOrderWebServiceResponse"

//Manual Filter
#define kPOGenerateOrderBackListDataCancel @"POGenerateOrderBackListDataCancel"
#define kPOGenerateOrderBackListDataDone @"POGenerateOrderBackListDataDone"

//************** Purchase Order Filter List Detail*************//

//Footer
#define kPOFilterListDetailFooterSearch @"POFilterListDetailFooterSearch"
#define kPOFilterListDetailFooterSave @"POFilterListDetailFooterSave"
#define kPOFilterListDetailFooterCreateOpenOrder @"POFilterListDetailFooterCreateOpenOrder"
#define kPOFilterListDetailFooterItemInfo @"POFilterListDetailFooterItemInfo"
#define kPOFilterListDetailFooterOrderInfo @"POFilterListDetailFooterOrderInfo"
#define kPOFilterListDetailFooterExport @"POFilterListDetailFooterExport"

#define kPOFilterListDetailSearchBarcode @"POFilterListDetailSearchBarcode"
#define kPOFilterListDetailSearchBarcodeResult @"POFilterListDetailSearchBarcodeResult"

#define kPOUpdatePODetailWebServiceCall @"POUpdatePODetailWebServiceCall"
#define kPOUpdatePODetailWebServiceResponse @"POUpdatePODetailWebServiceResponse"

#define kPOInsertOpenPODetailWebServiceCall @"POInsertOpenPODetailWebServiceCall"
#define kPOInsertOpenPODetailWebServiceResponse @"POInsertOpenPODetailWebServiceResponse"

#define kPOFilterListDetailFilter @"POFilterListDetailFilter"

// Export Options Events
#define kPOFilterListDetailExportOptionEmail @"POFilterListDetailExportOptionEmail"
#define kPOFilterListDetailExportOptionPreview @"POFilterListDetailExportOptionPreview"

//Multiple Item Selection
#define kPOMultipleItemSelectionCancel @"POMultipleItemSelectionCancel"
#define kPOMultipleItemSelectionDone @"POMultipleItemSelectionDone"
#define kPOMultipleItemSelectionSearchType @"POMultipleItemSelectionSearchType"
#define kPOMultipleItemSelectionSearch @"POMultipleItemSelectionSearch"
#define kPOMultipleItemSelectionSearchClear @"POMultipleItemSelectionSearchClear"

//************** Purchase Order Filter View Controller *************//

//Menu
#define kPOFilterMenuDepartment @"POFilterMenuDepartment"
#define kPOFilterMenuSupplier @"POFilterMenuSupplier"
#define kPOFilterMenuManualOption @"POFilterMenuManualOption"

//Footer
#define kPOFilterFooterDone @"POFilterDone"
#define kPOFilterFooterCancel @"POFilterCancel"

//Selection
#define kPOFilterDepartmentSelected @"POFilterDepartmentSelected"
#define kPOFilterSupplierSelected @"POFilterSupplierSelected"
#define kPOFilterManualSelected @"POFilterManualSelected"


#pragma mark - Keys

//*************************** Keys Name ********************************//

//************** RcrPOSVC *************//

// Menu Hold Keys
#define kPosHoldMessageKey @"HoldMessage"

#define kPosMenuHoldWebserviceCallKey @"HoldInvoiceParameter"
#define kPosMenuHoldWebserviceResponseKey @"HoldWebserviceResponse"

// Menu Recall Keys
#define kPosMenuRecallOrderKey @"RecallOrderInvoiceId"

#define kPosMenuRecallWebServiceCallKey @"RecallOrderParameter"
#define kPosMenuRecallWebServiceResponseKey @"RecallOrderResponse"

// Menu Void Transaction Keys
#define kPosMenuVoidTransactionWebServiceCallKey @"VoidTransactionParameter"
#define kPosMenuVoidTransactionWebServiceResponseKey @"VoidTransactionResponse"

// Menu Discount Key
#define kPosMenuDiscountAddKey @"DiscountDetail"

// Menu No Sale Keys
#define kPosMenuNoSaleWebServiceCallKey @"NoSaleParameter"
#define kPosMenuNoSaleWebServiceResponseKey @"NoSaleResponse"

// Ring up - Adding Item / Department  / Favorite Item Keys
#define kPosItemRingUpKey @"ItemRingUp"
#define kPosDepartmentRingUpKey @"DepartmentRingUpItemCode"
#define kPosFavoriteItemRingUpKey @"FavoriteItemRingUpId"

// Price At Pos Key
#define kPosPriceAtPosKey @"PriceAtPos"

// Item Swipe Keys
#define kPosItemSwipeKey @"ItemId"
#define kPosItemSwipeRemoveKey @"ItemId"
#define kPosItemSwipeQtyEditKey @"ItemQty"
#define kPosItemSwipePriceEditKey @"ItemPrice"

// Tender Key
#define kPosTenderKey @"Tender"

//************** CardProcessingVC *************//

// Card Processing Keys
#define kPosCardSwipeKey @"CardInfo"
#define kPosPaymentProcessDoneKey @"CardPayment"
#define kPosCardProcessFailedKey @"PosCardProcessFailedMessage"

#define kPosCardProcessingWebServiceCallKey @"CardProcessingParameter"
#define kPosCardProcessingWebServiceResponseKey @"PosCardProcessingResponse"


// Manual Card Processing Keys
#define kPosManualCardProcessingWebServiceCallKey @"ManualCardParameter"
#define kPosManualCardProcessingWebServiceResponseKey @"ManualCardProcessResponse"

//************** Rapid Inventory Management *************//

// Item Swipe Event Keys
#define kRIMItemSwipeCopyKey @"ItemId"
#define kRIMItemSwipeDeleteKey @"ItemId"
#define kRIMItemSwipeSingleKey @"ItemId"
#define kRIMItemSwipeCaseKey @"ItemId"
#define kRIMItemSwipePackKey @"ItemId"

#define kRIMItemSwipeDeleteWebServiceCallKey @"ItemId"
#define kRIMItemSwipeDeleteWebServiceResponseKey @"DeleteItemWebServiceResponse"

#define kRIMItemSwipeBarcodeWebServiceResponseKey @"BarcodeWebServiceResponse"

#define kRIMItemListWebServiceCallKey @"ItemId"
#define kRIMItemListWebServiceResponseKey @"ItemListResponse"

//************** Inventory Management *************//

// Footer Button Keys
#define kRIMFooterLablePrintWebServiceCallKey @"ItemCount"
#define kRIMFooterLablePrintWebServiceResponseKey @"LablePrintWebServiceResponse"

// Search Button Keys
#define kRIMUniversalItemSearchKey @"UniversalSearchText"
#define kRIMUpcSearchKey @"UpcSearchText"
#define kRIMItemSearchRecordFoundKey @"ItemCount"

#define kRIMItemFilterTypeSelectionKey @"FilterType"

//************** ItemInfoEditVC *************//
// Image Keys
#define kRIMItemImageSearchWebServiceCallKey @"ImageSearchText"
#define kRIMItemImageSearchWebServiceResponseKey @"ImageFoundCount"

// Footer Button Keys
#define kRIMItemUpdateWebServiceCallKey @"ItemId"
#define kRIMItemDeleteWebServiceCallKey @"ItemId"

#define kRIMItemInsertWebServiceResponseKey @"WebServiceResponse"
#define kRIMItemUpdateWebServiceResponseKey @"WebServiceResponse"
#define kRIMItemDeleteWebServiceResponseKey @"WebServiceResponse"

// Info View Keys
#define kRIMItemNameChangeKey @"ItemName"
#define kRIMItemNumberChangeKey @"ItemNumber"
#define kRIMItemAllowDuplicateBarcodeKey @"IsAllowDuplicateBarcode"

#define kRIMItemTaxTypeSelectedKey @"TaxType"
#define kRIMItemTaxSelectedKey @"SelectedTaxCount"

#define kRIMItemSupplierSelectedKey @"SelectedSupplierCount"

#define kRIMItemTagKey @"TagCount"

#define kRIMItemRemarkChangeKey @"Remark"
#define kRIMItemCashierNoteChangeKey @"CashierNote"

// Pricing View Keys
#define kRIMItemPriceAtPosKey @"IsPriceAtPos"

#define kRIMItemNumberOfQtyChangeOfCaseKey @"NumberOfItemForCase"
#define kRIMItemNumberOfQtyChangeOfPackKey @"NumberOfItemForPack"

#define kRIMItemCostChangeOfSingleKey @"CostOfSingle"
#define kRIMItemCostChangeOfCaseKey @"CostOfCase"
#define kRIMItemCostChangeOfPackKey @"CostOfPack"

#define kRIMItemProfitChangeOfSingleKey @"ProfitOfSingle"
#define kRIMItemProfitChangeOfCaseKey @"ProfitOfCase"
#define kRIMItemProfitChangeOfPackKey @"ProfitOfPack"

#define kRIMItemUnitPriceChangeOfSingleKey @"UnitPriceOfSingle"
#define kRIMItemUnitPriceChangeOfCaseKey @"UnitPriceOfCase"
#define kRIMItemUnitPriceChangeOfPackKey @"UnitPriceOfPack"

#define kRIMItemPriceOfLevelAChangeOfSingleKey @"PriceOfLevelAOfSingle"
#define kRIMItemPriceOfLevelAChangeOfCaseKey @"PriceOfLevelAOfCase"
#define kRIMItemPriceOfLevelAChangeOfPackKey @"PriceOfLevelAOfPack"

#define kRIMItemPriceOfLevelBChangeOfSingleKey @"PriceOfLevelBOfSingle"
#define kRIMItemPriceOfLevelBChangeOfCaseKey @"PriceOfLevelBChangeOfCase"
#define kRIMItemPriceOfLevelBChangeOfPackKey @"PriceOfLevelBChangeOfPack"

#define kRIMItemPriceOfLevelCChangeOfSingleKey @"PriceOfLevelCOfSingle"
#define kRIMItemPriceOfLevelCChangeOfCaseKey @"PriceOfLevelCOfCase"
#define kRIMItemPriceOfLevelCChangeOfPackKey @"PriceOfLevelCOfPack"

#define kRIMItemIsCaseAllowKey @"IsCashAllow"
#define kRIMItemIsPackAllowKey @"IsPackAllow"

// Weight Scale View Keys
#define kRIMWSNumberOfQtyChangeOfCaseKey @"NumberOfQtyOfCaseForWS"
#define kRIMWSNumberOfQtyChangeOfPackKey @"NumberOfQtyOfPackForWS"

#define kRIMWSCostChangeOfSingleKey @"CostOfSingleForWS"
#define kRIMWSCostChangeOfCaseKey @"CostOfCaseForWS"
#define kRIMWSCostChangeOfPackKey @"CostOfPackForWS"

#define kRIMWSProfitChangeOfSingleKey @"ProfitOfSingleForWS"
#define kRIMWSProfitChangeOfCaseKey @"ProfitOfCaseForWS"
#define kRIMWSProfitChangeOfPackKey @"ProfitOfPackForWS"

#define kRIMWSUnitPriceChangeOfSingleKey @"UnitPriceOfSingleForWS"
#define kRIMWSUnitPriceChangeOfCaseKey @"UnitPriceOfCaseForWS"
#define kRIMWSUnitPriceChangeOfPackKey @"UnitPriceOfPackForWS"

#define kRIMWSPriceOfLevelAChangeOfSingleKey @"PriceOfLevelAOfSingleForWS"
#define kRIMWSPriceOfLevelAChangeOfCaseKey @"PriceOfLevelAOfCaseForWS"
#define kRIMWSPriceOfLevelAChangeOfPackKey @"PriceOfLevelAOfPackForWS"

#define kRIMWSPriceOfLevelBChangeOfSingleKey @"PriceOfLevelBOfSingleForWS"
#define kRIMWSPriceOfLevelBChangeOfCaseKey @"PriceOfLevelBChangeOfCaseForWS"
#define kRIMWSPriceOfLevelBChangeOfPackKey @"PriceOfLevelBChangeOfPackForWS"

#define kRIMWSPriceOfLevelCChangeOfSingleKey @"PriceOfLevelCOfSingleForWS"
#define kRIMWSPriceOfLevelCChangeOfCaseKey @"PriceOfLevelCOfCaseForWS"
#define kRIMWSPriceOfLevelCChangeOfPackKey @"PriceOfLevelCOfPackForWS"

// Discount View Keys
#define kRIMItemNoPosDiscountKey @"NoPosDiscount"
#define kRIMItemDiscountRemoveKey @"DiscountRowIndex"

// Option View keys
#define kRIMItemFavoriteKey @"IsItemFavorite"
#define kRIMItemDisplayInPosKey @"IsItemDisplayInPos"
#define kRIMItemRemoveICForQtyOHKey @"IsRemoveICForQtyOH"
#define kRIMItemPayoutKey @"IsItemPayout"
#define kRIMItemMemoKey @"IsItemMemo"
#define kRIMItemMinInventoryLevelKey @"MinInventoryLevel"
#define kRIMItemMaxInventoryLevelKey @"MaxInventoryLevel"
#define kRIMItemChildQtyKey @"ChildQty"
#define kRIMParentItemSelectedKey @"ParentItemCode"

//************** Item In *************//

// Item Selected Key
#define kRIMItemInItemSelectedKey @"SelectedItemCount"

// Hold Keys
#define kRIMItemInAddInventoryWebServiceCallKey @"ItemCount"
#define kRIMItemInAddInventoryWebServiceResponseKey @"WebServiceResponse"

// Barcode Search Keys
#define kRIMItemInBarcodeSearchKey @"Barcode"
#define kRIMItemInBarcodeSearchWebServiceCallKey @"Barcode"
#define kRIMItemInBarcodeSearchWebServiceResponseKey @"WebServiceResponse"

// Item Swipe Keys
#define kRIMItemInSwipeEditKey @"EditItemIndex"
#define kRIMItemInSwipeCopyKey @"CopyItemIndex"
#define kRIMItemInSwipeDeleteKey @"DeleteItemIndex"

//************** Item Out *************//

// Item Selected Key
#define kRIMItemOutItemSelectedKey @"SelectedItemCount"

// Hold Keys
#define kRIMItemOutAddInventoryWebServiceCallKey @"ItemCount"
#define kRIMItemOutAddInventoryWebServiceResponseKey @"WebServiceResponse"

// Barcode Search Keys
#define kRIMItemOutBarcodeSearchKey @"Barcode"
#define kRIMItemOutBarcodeSearchWebServiceCallKey @"Barcode"
#define kRIMItemOutBarcodeSearchWebServiceResponseKey @"WebServiceResponse"

// Item Swipe Key
#define kRIMItemOutSwipeDeleteKey @"DeleteItemIndex"

//************** Item Open Order *************//

// Item Open Order List Keys
#define kRIMItemOpenOrderListWebServiceResponseKey @"WebServiceResponse"

#define kRIMItemOpenOrderSelectWebServiceCallKey @"OpenOrderId"
#define kRIMItemOpenOrderSelectWebServiceResponseKey @"WebServiceResponse"

// Item Open Order Swipe Keys
#define kRIMItemOpenOrderSwipeDeleteKey @"OpenOrderId"

#define kRIMOOItemInDeleteWebServiceCallKey @"ItemInId"
#define kRIMOOItemOutDeleteWebServiceCallKey @"ItemOutId"

#define kRIMOOItemInDeleteWebServiceResponseKey @"WebServiceResponse"
#define kRIMOOItemOutDeleteWebServiceResponseKey @"WebServiceResponse"

//************** Item Close Order *************//

#define kRIMCloseOrderItemInOutWebServiceCallKey @"CloseOrderId"
#define kRIMCloseOrderItemInOutWebServiceResponseKey @"WebServiceResponse"

#define kRIMItemCloseOrderListWebServiceResponseKey @"WebServiceResponse"

//************** Item Supplier Inventory *************//

#define kRIMItemSISearchBySupplierWebServiceCallKey @"SupplierId"
#define kRIMItemSISearchBySupplierWebServiceResponseKey @"WebServiceResponse"

//************** Department *************//

// Department List Keys
#define kRIMDepartmentSearchKey @"SearchText"
#define kRIMDepartmentSearchRecordFoundKey @"RecordFoundCount"
#define kRIMDepartmentSelectedKey @"DeptId"

// Department Add & Edit Keys
#define kRIMDepartmentImageSearchWebServiceCallKey @"ImageSearchText"
#define kRIMDepartmentImageSearchWebServiceResponseKey @"ImageFoundCount"

#define kRIMDepartmentNameKey @"DepartmentName"
#define kRIMDepartmentCodeKey @"DepartmentCode"
#define kRIMDepartmentProfitMarginKey @"ProfitMargin"
#define kRIMDepartmentCheckCashAmountKey @"CheckCashAmount"
#define kRIMDepartmentChargeTypeAmountKey @"ChargeTypeAmount"

#define kRIMDepartmentAgeRestrictionKey @"IsAgeRestriction"
#define kRIMDepartmentCheckCashKey @"IsCheckCash"
#define kRIMDepartmentChargeTypeKey @"IsChargeType"
#define kRIMDepartmentTaxApplyInKey @"IsTaxApplyIn"
#define kRIMDepartmentTaxKey @"IsDepartmentTax"

#define kRIMDepartmentAgeSelectedKey @"Age"
#define kRIMDepartmentCheckCashSelectedKey @"CheckCash"
#define kRIMDepartmentChargeTypeSelectedKey @"ChargeType"
#define kRIMDepartmentTaxApplyInSelectedKey @"TaxApplyIn"

#define kRIMDepartmentTaxSelectedKey @"TaxCount"

#define kRIMDepartmentUpdateWebServiceCallKey @"DeptId"

#define kRIMDepartmentInsertWebServiceResponseKey @"WebServiceResponse"
#define kRIMDepartmentUpdateWebServiceResponseKey @"WebServiceResponse"

//************** SubDepartment *************//

// SubDepartment List Keys
#define kRIMSubDepartmentSearchKey @"SearchText"
#define kRIMSubDepartmentSearchRecordFoundKey @"RecordFoundCount"
#define kRIMSubDepartmentSelectedKey @"SubDeptId"

// SubDepartment Add , Edit & Delete Keys
#define kRIMSubDepartmentImageSearchWebServiceCallKey @"ImageSearchText"
#define kRIMSubDepartmentImageSearchWebServiceResponseKey @"ImageFoundCount"

#define kRIMSubDepartmentNameKey @"SubDepartmentName"
#define kRIMSubDepartmentCodeKey @"SubDepartmentCode"
#define kRIMSubDepartmentRemarksKey @"SubDepartmentRemarks"

#define kRIMSubDepartmentUpdateWebServiceCallKey @"SubDeptId"
#define kRIMSubDepartmentDeleteWebServiceCallKey @"SubDeptId"

#define kRIMSubDepartmentInsertWebServiceResponseKey @"WebServiceResponse"
#define kRIMSubDepartmentUpdateWebServiceResponseKey @"WebServiceResponse"
#define kRIMSubDepartmentDeleteWebServiceResponseKey @"WebServiceResponse"

//************************* Purchase Order *************************//

//************** Generate Order *************//

//Generate Order Keys
#define kPOGenerateOrderSelectedTypeKey @"SelectedOrderType"

#define kPOGenerateOrderFromDateSelectedKey @"FromDate"
#define kPOGenerateOrderToDateSelectedKey @"ToDate"

#define kPOGenerateOrderDepartmentsSelectedKey @"SelectedDepartmentsCount"
#define kPOGenerateOrderSuppliersSelectedKey @"SelectedSuppliersCount"
#define kPOGenerateOrderGroupsSelectedKey @"SelectedGroupsCount"
#define kPOGenerateOrderTagSelectedKey @"SelectedTagCount"

#define kPOGenerateOrderMinimumStokeKey @"IsMinimumStoke"

#define kPOGOOpenBackListDataWebServiceResponseKey @"WebServiceResponse"

#define kPOGenerateOrderWebServiceResponseKey @"WebServiceResponse"

//Manual Filter Key
#define kPOGenerateOrderBackListDataDoneKey @"BackListDataCount"

//Multiple Item SelectionKey
#define kPOMultipleItemSelectionDoneKey @"SelectedItemCount"
#define kPOMultipleItemSelectionSearchTypeKey @"SearchType"
#define kPOMultipleItemSelectionSearchKey @"SearchText"

//************** Purchase Order Filter List Detail*************//

//Footer Keys
#define kPOUpdatePODetailWebServiceResponseKey @"WebServiceResponse"
#define kPOInsertOpenPODetailWebServiceResponseKey @"WebServiceResponse"

#define kPOFilterListDetailSearchBarcodeKey @"SearchText"
#define kPOFilterListDetailSearchBarcodeResultKey @"ItemCount"

//************** Purchase Order Filter View Controller *************//

//Footer Key
#define kPOFilterFooterDoneKey @"Selected"

//Selection Keys
#define kPOFilterDepartmentSelectedKey @"SelectedDepartmentCount"
#define kPOFilterSupplierSelectedKey @"SelectedSupplierCount"
#define kPOFilterManualSelectedKey @"SelectedManualCount"

//************** Printer & Drawer *************//
#define kPrinterStatusKey @"PrinterStatus"
#define kDrawerDidNotOpenKey @"DrawerDidNotOpen"
#define kPrinterFailedKey @"PrinterFailed"
#define kDrawerFailedKey @"DrawerFailed"

#endif
