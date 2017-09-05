//
//  ItemInfoVC.h
//  RapidRMS
//
//  Created by Siya Infotech on 21/07/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ItemInfoEditVC.h"
#import "ItemInfoDataObject.h"
typedef NS_ENUM(NSUInteger, InfoSection) // itemInfoSectionArray
{
    ItemImageSection,
    ItemInfoSection,
    ItemPricingSection,
    ItemDepartmentTaxSection,
    SupplierSection,
    ProductInfoSection,
    DescriptionSection,
};
typedef NS_ENUM(NSInteger, PricingSectionItem)
{
    PricingSectionItemTitle,
    PricingSectionItemQty,
    PricingSectionItemCost,
    PricingSectionItemProfit,
    PricingSectionItemSales,
    PricingSectionItemNoOfQty,
    PricingSectionItemUnitQty_Unit,
};
typedef NS_ENUM(NSInteger, DepartmentSectionItem) // departmentSelection
{
    DepartmentSection,
    SubDepartmentSection,
    VariationSection,
    TaxSection,
    TaxListSection,
};
typedef NS_ENUM(NSInteger, ItemtextFieldsTag) // Department Info Selection
{
    ItemtextFieldsTagName=1000,
    ItemtextFieldsTagBarCode=1001,
    ItemtextFieldsTagItemH=1002,
    ItemtextFieldsTagItemTag=1003,
};
typedef NS_ENUM(NSInteger, ItemDescSectionTag) // Description Selection
{
    ItemDescSectionTagRemark=3000,
    ItemDescSectionTagCashierNote=3001,
};
@protocol PriceChangeAndCalculationDelegate <NSObject>
    -(void)didPriceChangeOf:(PricingSectionItem)PriceValueType inputValue:(NSNumber *)inputValue ValueIndex:(int)IndexNumber;
    -(void)didPriceChangeOfInputWeight:(NSNumber *)inputValue InputWeightUnit:(NSString *)weightUnit  ValueIndex:(int)IndexNumber;
    -(void)didPriceChangeOfMarkUPValue:(NSNumber *)inputValue ValueIndex:(int)IndexNumber;
//other
    -(void)selectImageCapture:(UIButton *)sender;
    -(void)setItemVariationsValue;
    -(void)getWeightScaleData;
    -(void)getPricingData;
    -(void)getItemVariationData;
@end
@interface ItemInfoVC : UIViewController


@property (nonatomic, weak) id<PriceChangeAndCalculationDelegate> priceChangeAndCalculationDelegate;
@property (nonatomic, weak) IBOutlet UITableView *tblItemInfo;

@property (nonatomic, strong) ItemInfoDataObject * itemInfoDataObject;

@property (nonatomic, strong) NSMutableArray *itemInfoSectionArray;
@property (nonatomic, strong) NSMutableArray *itemPricingSelection;
@property (nonatomic, strong) NSMutableArray *departmentSelection;

@property (nonatomic, strong) NSString *moduleCode;

- (void)didChangeSupplier:(NSMutableArray *)SupplierListArray;
@end
