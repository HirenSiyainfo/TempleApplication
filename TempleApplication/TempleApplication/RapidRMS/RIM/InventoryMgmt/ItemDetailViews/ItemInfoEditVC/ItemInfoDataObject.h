//
//  ItemInfoDataObject.h
//  RapidRMS
//
//  Created by Siya Infotech on 06/08/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ItemInfoDataObject : NSObject


//ItemMain Info
@property (nonatomic) BOOL Active;
@property (nonatomic) BOOL oldActive;
@property (nonatomic) BOOL BlockActive;
@property (nonatomic) BOOL isCopy;

@property (nonatomic) BOOL DisplayInPOS;
@property (nonatomic) BOOL oldDisplayInPOS;

@property (nonatomic) BOOL IsFavourite;
@property (nonatomic) BOOL oldIsFavourite;

@property (nonatomic) BOOL IsPriceAtPOS;
@property (nonatomic) BOOL oldIsPriceAtPOS;

@property (nonatomic) BOOL IsduplicateUPC;
@property (nonatomic) BOOL oldIsduplicateUPC;

@property (nonatomic) BOOL Memo;
@property (nonatomic) BOOL oldMemo;

@property (nonatomic) BOOL isItemPayout;
@property (nonatomic) BOOL oldisItemPayout;

@property (nonatomic) BOOL isQtyDiscount;
@property (nonatomic) BOOL oldisQtyDiscount;

@property (nonatomic) BOOL isTax;
@property (nonatomic) BOOL oldisTax;

@property (nonatomic) BOOL quantityManagementEnabled;
@property (nonatomic) BOOL oldquantityManagementEnabled;

@property (nonatomic) BOOL POSDISCOUNT;
@property (nonatomic) BOOL oldPOSDISCOUNT;

@property (nonatomic, strong) NSDate * LastReceivedDate;
@property (nonatomic, strong) NSDate * oldLastReceivedDate;

@property (nonatomic, strong) NSNumber * AverageCost;
@property (nonatomic, strong) NSNumber * oldAverageCost;

@property (nonatomic, strong) NSString * Barcode;
@property (nonatomic, strong) NSString * oldBarcode;

@property (nonatomic, strong) NSNumber * CITM_Code;
@property (nonatomic, strong) NSNumber * oldCITM_Code;

@property (nonatomic, strong) NSString * CashierNote;
@property (nonatomic, strong) NSString * oldCashierNote;

@property (nonatomic, strong) NSNumber * CateId;
@property (nonatomic, strong) NSNumber * oldCateId;

@property (nonatomic, strong) NSNumber * ChildQty;
@property (nonatomic, strong) NSNumber * oldChildQty;

@property (nonatomic, strong) NSNumber * CostPrice;
@property (nonatomic, strong) NSNumber * oldCostPrice;

@property (nonatomic, strong) NSNumber * DepartId;
@property (nonatomic, strong) NSNumber * oldDepartId;

@property (nonatomic, strong) NSString * DepartmentName;
@property (nonatomic, strong) NSString * oldDepartmentName;

@property (nonatomic, strong) NSString * Description;
@property (nonatomic, strong) NSString * oldDescription;

@property (nonatomic, strong) NSNumber * EBT;
@property (nonatomic, strong) NSNumber * oldEBT;

@property (nonatomic, strong) NSString * GroupName;
@property (nonatomic, strong) NSString * oldGroupName;

@property (nonatomic, strong) NSNumber * ITM_Type;
@property (nonatomic, strong) NSNumber * oldITM_Type;

@property (nonatomic, strong) NSNumber * ItemId;
@property (nonatomic, strong) NSNumber * oldItemId;

@property (nonatomic, strong) NSString * ItemImage;
@property (nonatomic, strong) NSString * oldItemImage;

@property (nonatomic, strong) NSString * ItemName;
@property (nonatomic, strong) NSString * oldItemName;

@property (nonatomic, strong) NSString * ItemNo;
@property (nonatomic, strong) NSString * oldItemNo;

@property (nonatomic, strong) NSNumber * LastInvoice;
@property (nonatomic, strong) NSNumber * oldLastInvoice;

@property (nonatomic, strong) NSNumber * MaxStockLevel;
@property (nonatomic, strong) NSNumber * oldMaxStockLevel;

@property (nonatomic, strong) NSNumber * MinStockLevel;
@property (nonatomic, strong) NSNumber * oldMinStockLevel;

@property (nonatomic, strong) NSNumber * NoDiscountFlg;
@property (nonatomic, strong) NSNumber * oldNoDiscountFlg;

@property (nonatomic, strong) NSString * PriceScale;
@property (nonatomic, strong) NSString * oldPriceScale;

@property (nonatomic, strong) NSNumber * ProfitAmt;
@property (nonatomic, strong) NSNumber * oldProfitAmt;

@property (nonatomic, strong) NSString * ProfitType;
@property (nonatomic, strong) NSString * oldProfitType;

@property (nonatomic, strong) NSString * Remark;
@property (nonatomic, strong) NSString * oldRemark;

@property (nonatomic, strong) NSNumber * SalesPrice;
@property (nonatomic, strong) NSNumber * oldSalesPrice;

@property (nonatomic, strong) NSNumber * SubDepartId;
@property (nonatomic, strong) NSNumber * oldSubDepartId;

@property (nonatomic, strong) NSString * SubDepartmentName;
@property (nonatomic, strong) NSString * oldSubDepartmentName;

@property (nonatomic, strong) NSString * TaxType;
@property (nonatomic, strong) NSString * oldTaxType;

@property (nonatomic, strong) NSNumber * WeightQty;
@property (nonatomic, strong) NSNumber * oldWeightQty;

@property (nonatomic, strong) NSString * WeightType;
@property (nonatomic, strong) NSString * oldWeightType;

@property (nonatomic, strong) NSNumber * avaibleQty;
@property (nonatomic, strong) NSNumber * oldavaibleQty;

@property (nonatomic, strong) NSString * cate_MixMatchDiscription;
@property (nonatomic, strong) NSString * oldcate_MixMatchDiscription;

@property (nonatomic, strong) NSNumber * cate_MixMatchFlg;
@property (nonatomic, strong) NSNumber * oldcate_MixMatchFlg;

@property (nonatomic, strong) NSNumber * cate_MixMatchId;
@property (nonatomic, strong) NSNumber * oldcate_MixMatchId;

@property (nonatomic, strong) NSString * mixMatchDiscription;
@property (nonatomic, strong) NSString * oldmixMatchDiscription;

@property (nonatomic, strong) NSNumber * mixMatchFlg;
@property (nonatomic, strong) NSNumber * oldmixMatchFlg;

@property (nonatomic, strong) NSNumber * mixMatchId;
@property (nonatomic, strong) NSNumber * oldmixMatchId;

@property (nonatomic, strong) NSNumber * selected;
@property (nonatomic, strong) NSNumber * oldselected;



//item ticket info

@property (nonatomic) BOOL isPass;
@property (nonatomic) BOOL oldisPass;

@property (nonatomic) BOOL IsExpiration;
@property (nonatomic) BOOL oldIsExpiration;

@property (nonatomic) BOOL SelectedOption;
@property (nonatomic) BOOL oldSelectedOption;

@property (nonatomic) BOOL Sunday;
@property (nonatomic) BOOL oldSunday;

@property (nonatomic) BOOL Monday;
@property (nonatomic) BOOL oldMonday;

@property (nonatomic) BOOL Tuesday;
@property (nonatomic) BOOL oldTuesday;

@property (nonatomic) BOOL Wednesday;
@property (nonatomic) BOOL oldWednesday;

@property (nonatomic) BOOL Thursday;
@property (nonatomic) BOOL oldThursday;

@property (nonatomic) BOOL Friday;
@property (nonatomic) BOOL oldFriday;

@property (nonatomic) BOOL Saturday;
@property (nonatomic) BOOL oldSaturday;

@property (nonatomic, strong) NSNumber * NoOfPerson;
@property (nonatomic, strong) NSNumber * oldNoOfPerson;

@property (nonatomic, strong) NSNumber * ExpirationDays;
@property (nonatomic, strong) NSNumber * oldExpirationDays;

@property (nonatomic, strong) NSNumber * NoOfdays;
@property (nonatomic, strong) NSNumber * oldNoOfdays;


//info
@property (nonatomic) BOOL isPricingLevelSelected;
@property (nonatomic) BOOL rowSwitch;

@property (nonatomic, strong) UIImage *selectedImage;

@property (nonatomic, strong) NSString * imageNameURL;
@property (nonatomic, strong) NSString *duplicateUPCItemCodes;


@property (nonatomic, strong) NSMutableArray *itemPricingArray;
@property (nonatomic, strong) NSMutableArray *olditemPricingArray;

@property (nonatomic, strong) NSMutableArray *itemWeightScaleArray;
@property (nonatomic, strong) NSMutableArray *olditemWeightScaleArray;

@property (nonatomic, strong) NSMutableArray *itemtaxarray;
@property (nonatomic, strong) NSMutableArray *olditemtaxarray;

@property (nonatomic, strong) NSMutableArray *itemsupplierarray;//ItemSupplierData
@property (nonatomic, strong) NSMutableArray *olditemsupplierarray;

@property (nonatomic, strong) NSMutableArray *responseTagArray;
@property (nonatomic, strong) NSMutableArray *oldresponseTagArray;

@property (nonatomic, strong) NSMutableArray *discountDetailsArray;
@property (nonatomic, strong) NSMutableArray *olddiscountDetailsArray;


@property (nonatomic, strong) NSMutableArray * arrItemAllBarcode;
@property (nonatomic, strong) NSMutableArray * oldarrItemAllBarcode;

@property (nonatomic, strong) NSMutableArray *arrayDeletedVariation;
@property (nonatomic, strong) NSMutableArray *arrayDisplayVariation;
@property (nonatomic, strong) NSMutableArray *itemInfoSectionArray;
@property (nonatomic, strong) NSMutableArray *arrayVariation;


@property (nonatomic, strong) NSMutableArray *selectedPricingType;

@property (nonatomic, strong) NSMutableArray *itemVariationTypes;
@property (nonatomic, strong) NSMutableArray *olditemVariationTypes;

@property (nonatomic, strong) NSMutableArray *itemVariationData1;
@property (nonatomic, strong) NSMutableArray *itemVariationData2;
@property (nonatomic, strong) NSMutableArray *itemVariationData3;

@property (nonatomic, strong) NSMutableArray *olditemVariationData1;
@property (nonatomic, strong) NSMutableArray *olditemVariationData2;
@property (nonatomic, strong) NSMutableArray *olditemVariationData3;

@property (nonatomic, strong) NSMutableArray *pricingOption;


-(void)setItemMainDataFrom:(NSDictionary *)dictItemMain;

@property (NS_NONATOMIC_IOSONLY, getter=getItemMainUpdateData, readonly, copy) NSMutableDictionary *itemMainUpdateData;
@property (NS_NONATOMIC_IOSONLY, getter=getItemMainInsertData, readonly, copy) NSMutableDictionary *itemMainInsertData;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSMutableDictionary *itemInfoDataForManual;

-(void)createDuplicateItemPricingArray;
@property (NS_NONATOMIC_IOSONLY, getter=getChangedItemPricingSingle, readonly, copy) NSMutableArray *changedItemPricingSingle;
@property (NS_NONATOMIC_IOSONLY, getter=getChangedItemPricingCase, readonly, copy) NSMutableArray *changedItemPricingCase;
@property (NS_NONATOMIC_IOSONLY, getter=getChangedItemPricingPack, readonly, copy) NSMutableArray *changedItemPricingPack;

#pragma mark - Price -
-(NSMutableArray *)getChangedItemWeightScalePricingSingle;
-(NSMutableArray *)getChangedItemWeightScalePricingCase;
-(NSMutableArray *)getChangedItemWeightScalePricingPack;
-(NSMutableArray *)getManualPricingDataAt:(int)index;
@property (NS_NONATOMIC_IOSONLY, getter=isChangeInfoInManualItem, readonly) BOOL changeInfoInManualItem;

-(void)createDuplicateItemWeightScaleArray;
@property (NS_NONATOMIC_IOSONLY, getter=getChangedItemWeightScaleArray, readonly, copy) NSMutableArray *changedItemWeightScaleArray;
#pragma mark - master -
-(void)createDuplicateItemTaxArray;
@property (NS_NONATOMIC_IOSONLY, getter=getChangedItemAddedTaxArray, readonly, copy) NSMutableArray *changedItemAddedTaxArray;
@property (NS_NONATOMIC_IOSONLY, getter=getChangedItemDeletedTaxArray, readonly, copy) NSString *changedItemDeletedTaxArray;

-(void)createDuplicateItemSupplierarray;
@property (NS_NONATOMIC_IOSONLY, getter=getChangedItemAddedSupplierarray, readonly, copy) NSMutableArray *changedItemAddedSupplierarray;
@property (NS_NONATOMIC_IOSONLY, getter=getChangedItemDeletedSupplierarray, readonly, copy) NSMutableArray *changedItemDeletedSupplierarray;


-(void)createDuplicateItemresponseTagArray;
@property (NS_NONATOMIC_IOSONLY, getter=getChangedItemAddedTagArray, readonly, copy) NSMutableArray *changedItemAddedTagArray;
@property (NS_NONATOMIC_IOSONLY, getter=getChangedItemDeletedTagArray, readonly, copy) NSString *changedItemDeletedTagArray;

-(void)createDuplicateItemDiscountDetailsArray;
@property (NS_NONATOMIC_IOSONLY, getter=getChangedItemAddedDiscountDetailsArray, readonly, copy) NSMutableArray *changedItemAddedDiscountDetailsArray;
@property (NS_NONATOMIC_IOSONLY, getter=getChangedItemDeletedDiscountDetailsArray, readonly, copy) NSString *changedItemDeletedDiscountDetailsArray;

-(void)setItemTicketDataFrom:(NSDictionary *)dictItemTicket;
@property (NS_NONATOMIC_IOSONLY, getter=getItemTicketInfo, readonly, copy) NSMutableDictionary *itemTicketInfo;
@property (NS_NONATOMIC_IOSONLY, getter=isChangeItemTicketInfo, readonly) BOOL changeItemTicketInfo;

-(NSMutableArray *)createDuplicateArrayFrom:(NSMutableArray *)arrChenged;

#pragma mark - barcode -

-(void)createDuplicateItemBarcodeArray;
-(NSString *)getDuplicateBarcodenumber;
@property (readonly, copy) NSArray *arrAddedBarcodeList;
@property (readonly, copy) NSArray *arrDeletedBarcodeList;

@end
