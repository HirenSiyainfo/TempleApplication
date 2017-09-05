//
//  BillAmountCalculator.m
//  RapidRMS
//
//  Created by Siya Infotech on 16/07/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "BillAmountCalculator.h"
#import "Item+Discount.h"
#import "Item_Discount_MD+Dictionary.h"
#import "Item_Discount_MD2+Dictionary.h"
#import "Mix_MatchDetail+Dictionary.h"
#import "RcrController.h"
#import "ItemTax+Dictionary.h"
#import "DepartmentTax+Dictionary.h"
#import "Department+Dictionary.h"
#import "RmsDbController.h"
#import "TaxMaster+Dictionary.h"
#import "GroupMaster+Dictionary.h"
#import "ItemDiscountCalculator.h"
#import "ItemMixMatchDiscountCalculator.h"

#import "Item_Price_MD+Dictionary.h"
#import "ItemTicket_MD+Dictionary.h"
#import "Configuration+Dictionary.h"

//#define USE_DISCOUNT_CALCULATOR_CLASS


#define ITEM @"Item"


//#define USE_DISCOUNT_CALCULATOR_CLASS

//#define MERGE_MIXMATCH_DISCOUNT

@interface BillAmountCalculator ()<NSCoding>
@property (nonatomic, strong) NSMutableArray *billReceiptArray;
@property (nonatomic, strong) UpdateManager *updateManager;
@property (nonatomic, strong) NSManagedObjectContext *moc;
@property (nonatomic, strong) RcrController *crmController;
@property (nonatomic, strong) NSMutableDictionary *carryForwardBillEntry;
@property (nonatomic) int carryForwardQuantity;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) NSNumberFormatter *currencyFormatter;

@end

@implementation BillAmountCalculator
@synthesize managedObjectContext = __managedObjectContext;

- (instancetype)initWithManageObjectcontext:(NSManagedObjectContext*)moc
{
    self = [super init];
    if (self) {
        _moc = moc;
        _updateManager = [[UpdateManager alloc] initWithManagedObjectContext:_moc delegate:nil];
        self.crmController = [RcrController sharedCrmController];
        self.rmsDbController = [RmsDbController sharedRmsDbController];
        self.managedObjectContext = self.rmsDbController.managedObjectContext;
        self.currencyFormatter = [[NSNumberFormatter alloc] init];
        self.currencyFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
        self.currencyFormatter.maximumFractionDigits = 2;
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.billWiseDiscount forKey:@"billWiseDiscount"];
    [aCoder encodeObject:self.packageQty forKey:@"packageQty"];
    
    [aCoder encodeFloat:self.fCheckCashCharge forKey:@"fCheckCashCharge"];
    [aCoder encodeFloat:self.fExtraChargeAmt forKey:@"fExtraChargeAmt"];

    
    [aCoder encodeObject:self.variationDetail forKey:@"variationDetail"];
    
    [aCoder encodeObject:self.memoMessage forKey:@"memoMessage"];
    [aCoder encodeObject:self.packageType forKey:@"packageType"];
    
    [aCoder encodeBool:self.isEbtApplied forKey:@"isEbtApplied"];
    [aCoder encodeBool:self.isEBTApplicaleForBill forKey:@"isEBTApplicaleForBill"];
    [aCoder encodeBool:self.itemRefund forKey:@"itemRefund"];
    [aCoder encodeBool:self.isCheckCash forKey:@"isCheckCash"];
}

- ( instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [self initWithManageObjectcontext:_moc];
    if (self) {
        
        self.fExtraChargeAmt = [aDecoder decodeFloatForKey:@"fExtraChargeAmt"];
        self.fCheckCashCharge = [aDecoder decodeFloatForKey:@"fCheckCashCharge"];

        self.billWiseDiscount = [aDecoder decodeObjectForKey:@"billWiseDiscount"];
        self.packageQty = [aDecoder decodeObjectForKey:@"packageQty"];
        
        self.variationDetail = [aDecoder decodeObjectForKey:@"variationDetail"];
        
        self.memoMessage = [aDecoder decodeObjectForKey:@"memoMessage"];
        self.packageType = [aDecoder decodeObjectForKey:@"packageType"];
        
        self.isEbtApplied = [aDecoder decodeBoolForKey:@"isEbtApplied"];
        self.isEBTApplicaleForBill = [aDecoder decodeBoolForKey:@"isEBTApplicaleForBill"];
        self.itemRefund = [aDecoder decodeBoolForKey:@"itemRefund"];
        self.isCheckCash = [aDecoder decodeBoolForKey:@"isCheckCash"];
    }
    
    return self;
    
}


-(NSMutableArray *)fetchTaxDetailForItem:(Item *)anItem
{
    NSMutableArray *taxdetail = [[NSMutableArray alloc]init];
    if (anItem.taxApply.boolValue ==TRUE)
    {
        NSString *strTaxType = anItem.taxType;
        
        if([strTaxType isEqualToString:@"Tax wise"])
        {
            taxdetail = [self getitemTaxDetailFromTaxTable:anItem.itemCode.stringValue withSalesPrice:@"" In:taxdetail];
        }
        else if([strTaxType isEqualToString:@"Department wise"])
        {
            taxdetail = [self getItemDepartmentTaxFromTaxTable:anItem.deptId.stringValue withSalesPrice:@"" In:taxdetail];
        }
        else
        {
            taxdetail = nil;
        }
    }
    else
    {
        taxdetail = nil;
    }
    return taxdetail;
}


-(NSMutableDictionary *)setItemDetailWithBillEntry :(NSMutableDictionary *)billentryDictionary withItem:(Item *)anItem WithItemPrice:(NSString *)price WithItemQty:(NSString *)qty WithItemImage:(NSString *)itemImage withItemBarcode:(NSString *)itemBarcode withItemUnitType:(NSString *)itemUnitType  withItemUnitQty:(NSString *)itemUnitQty
{
    NSMutableArray *taxdetail = [[NSMutableArray alloc]init];
    if (anItem.taxApply.boolValue ==TRUE)
    {
        NSString *strTaxType = anItem.taxType;
        
        if([strTaxType isEqualToString:@"Tax wise"])
        {
        taxdetail = [self getitemTaxDetailFromTaxTable:anItem.itemCode.stringValue withSalesPrice:price In:taxdetail];
        }
        else if([strTaxType isEqualToString:@"Department wise"])
        {
            Department *department=[self fetchDepartment:[NSString stringWithFormat:@"%ld",(long)anItem.deptId.integerValue]];
            
            if(department.chkExtra.boolValue)
            {
                //fExtraChargeAmt = [self getDepartmentExtraChargeAmount:department withSalesPrice:price];
            }
           taxdetail = [self getItemDepartmentTaxFromTaxTable:anItem.deptId.stringValue withSalesPrice:price In:taxdetail];
        }
        else
        {
            taxdetail = nil;
        }
    }
    else
    {
        taxdetail = nil;
    }
      NSMutableDictionary * tempDict = [self setUpDictionaty:billentryDictionary withDetails:@"" withPrice:price withTax:0.0 withQuantity:qty  withItemId:[billentryDictionary valueForKey:@"itemId"] withType:ITEM  withTaxDetails:taxdetail withItemName:anItem.item_Desc withimagePath:itemImage withDepartId:anItem.deptId.stringValue withBarcode:itemBarcode withItemCost:anItem.costPrice.stringValue withItemUnitType:itemUnitType withItemUnitQty:itemUnitQty withItemPayOut:anItem.isItemPayout];
    
    return tempDict;
    
}
-(NSMutableArray *)getitemTaxDetailFromTaxTable :(NSString *)itemId withSalesPrice:(NSString *)salesPrice In:(NSMutableArray *)taxDetail
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ItemTax" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemId==%d",itemId.integerValue];
    fetchRequest.predicate = predicate;
    NSArray *taxListArray = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    for (int i=0; i<taxListArray.count; i++)
    {
        ItemTax *tax=taxListArray[i];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"TaxMaster" inManagedObjectContext:self.managedObjectContext];
        fetchRequest.entity = entity;
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"taxId==%d",tax.taxId.integerValue];
        fetchRequest.predicate = predicate;
        NSArray *itemTaxName = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
        if (itemTaxName.count>0)
        {
            TaxMaster *taxmaster=itemTaxName.firstObject;
            NSMutableDictionary *taxDict=[[NSMutableDictionary alloc]init];
            taxDict[@"ItemTaxAmount"] = @"0";
            taxDict[@"TaxPercentage"] = taxmaster.percentage;
            taxDict[@"TaxAmount"] = taxmaster.amount;
            taxDict[@"TaxId"] = taxmaster.taxId;
            [taxDetail addObject:taxDict];
        }
    }
    return taxDetail;
}

-(NSMutableArray *)getItemDepartmentTaxFromTaxTable :(NSString *)departMentTaxId withSalesPrice:(NSString *)salesPrice In:(NSMutableArray *)taxDetail
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DepartmentTax" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"deptId==%d",departMentTaxId.integerValue];
    fetchRequest.predicate = predicate;
    NSArray *departmentTaxListArray = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    for (int i=0; i<departmentTaxListArray.count; i++)
    {
        DepartmentTax *departmentTax=departmentTaxListArray[i];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"TaxMaster" inManagedObjectContext:self.managedObjectContext];
        fetchRequest.entity = entity;
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"taxId==%d",departmentTax.taxId.integerValue];
        fetchRequest.predicate = predicate;
        NSArray *itemTaxName = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
        if (itemTaxName.count>0)
        {
            TaxMaster *taxmaster=itemTaxName.firstObject;
            NSMutableDictionary *departmentTaxDictionary=[[NSMutableDictionary alloc]init];
            departmentTaxDictionary[@"ItemTaxAmount"] = @"0";
            departmentTaxDictionary[@"TaxPercentage"] = taxmaster.percentage;
            departmentTaxDictionary[@"TaxAmount"] = taxmaster.amount;
            departmentTaxDictionary[@"TaxId"] = taxmaster.taxId;
//            departmentTaxDictionary[@"TaxType"] = taxmaster.taxId;

            [taxDetail addObject:departmentTaxDictionary];
        }
    }
    
    return taxDetail;
}


- (NSMutableDictionary *) setUpDictionaty:(id) item withDetails:(id) details withPrice:(NSString *) itemPrice withTax:(CGFloat)itemTaxValue withQuantity:(NSString *) qty withItemId:(NSString *) itemId withType:(NSString *)itemType  withTaxDetails:(id)taxDetailData withItemName:(NSString *)itemName withimagePath:(NSString *)itemImagePath withDepartId:(NSString *)departId withBarcode:(NSString *)Barcode withItemCost:(NSString *)ItemCost  withItemUnitType:(NSString *)itemUnitType  withItemUnitQty:(NSString *)itemUnitQty withItemPayOut:(NSNumber *)itempayout
{
    
	NSMutableDictionary * tempDict = [[NSMutableDictionary alloc] init];
    if (self.itemRefund || itempayout.boolValue == TRUE)
    {
        NSString *strItemId=[NSString stringWithFormat:@"%ld",(long)itemId.integerValue];
        Item *anitem=[self fetchItem:strItemId];

        item[@"isDeduct"] = itempayout;

        tempDict[@"itemId"] = itemId;
        tempDict[@"itemName"] = itemName;
        tempDict[@"itemImage"] = itemImagePath;
        tempDict[@"departId"] = departId;
        tempDict[@"itemType"] = itemType;
        tempDict[@"Barcode"] = Barcode;
        
        if ([anitem.itm_Type isEqualToString:@"1"]) {
            CGFloat itemCost = 0 ;
            if (anitem.itemDepartment) {
                itemCost = itemPrice.floatValue - itemPrice.floatValue * (anitem.itemDepartment.profitMargin.floatValue / 100) ;
                itemCost = -itemCost;
            }
            tempDict[@"ItemCost"] = [NSString stringWithFormat:@"%f",itemCost];
        }
        else
        {
            tempDict[@"ItemCost"] = [NSString stringWithFormat:@"-%@",ItemCost];
        }
        
        tempDict[@"isBasicDiscounted"] = @"0";
        tempDict[@"IsPriceEdited"] = [NSString stringWithFormat:@"0"];
        tempDict[@"UnitType"] = [NSString stringWithFormat:@"%@",itemUnitType];
        tempDict[@"UnitQty"] = [NSString stringWithFormat:@"%@",itemUnitQty];

        if(anitem.itemGroupMaster.groupId)
        {
            tempDict[@"categoryId"] = anitem.itemGroupMaster.groupId;
            
        }
        else
        {
            tempDict[@"categoryId"] = @"0";
            
        }
        if(anitem.itemMixMatchDisc.mixMatchId)
        {
            tempDict[@"mixMatchId"] = anitem.itemMixMatchDisc.mixMatchId;
        }
        else
        {
            tempDict[@"mixMatchId"] = @"0";
            
        }
        if(anitem.subDeptId)
        {
            tempDict[@"SubDeptId"] = anitem.subDeptId;
        }
        else
        {
            tempDict[@"SubDeptId"] = @"0";
        }

		//[tempDict setObject:@"" forKey:@"itemMessage"];
     //   [tempDict setObject:anitem.pos_DISCOUNT forKey:@"pos_DISCOUNT"];
		if(item != nil) {
			if(_isCheckCash == TRUE && _fCheckCashCharge > 0)
            {
                item[@"CheckCashCharge"] = [NSString stringWithFormat:@"-%f", _fCheckCashCharge];
                item[@"isCheckCash"] = @"1";
            } else if(_fExtraChargeAmt>0)
            {
                item[@"ExtraCharge"] = [NSString stringWithFormat:@"%f", _fExtraChargeAmt];
                item[@"isExtraCharge"] = @"1";
            }
            
			tempDict[@"item"] = item;
		}
        tempDict[@"itemPrice"] = @(-itemPrice.floatValue);
        tempDict[@"itemTax"] = @(-itemTaxValue);
        tempDict[@"itemQty"] = [NSString stringWithFormat:@"%d",qty.intValue];
        tempDict[@"ItemDiscount"] = [NSString stringWithFormat:@"0"];
        
		if (taxDetailData != nil)
        {
            for (int i=0; i<[taxDetailData count]; i++)
            {
                NSMutableDictionary *Dict=taxDetailData[i];
                NSString *strItemTaxAmount=Dict[@"ItemTaxAmount"];
                NSString *strSetAmount=[NSString stringWithFormat:@"-%@",strItemTaxAmount];
                Dict[@"ItemTaxAmount"] = strSetAmount;
                taxDetailData[i] = Dict;
                
            }
			tempDict[@"ItemTaxDetail"] = taxDetailData;
		} else
        {
			tempDict[@"ItemTaxDetail"] = @"";
		}
        tempDict[@"ItemBasicPrice"] = [NSString stringWithFormat:@"-%@",itemPrice];
        tempDict[@"ItemDiscountPercentage"] = @(0);
        tempDict[@"ItemExternalDiscount"] = @(0);
        tempDict[@"ItemInternalDiscount"] = @(0);

        if (self.variationDetail) {
            tempDict[@"InvoiceVariationdetail"] = self.variationDetail;
        }
        if (self.memoMessage.length > 0) {
            tempDict[@"Memo"] = [NSString stringWithFormat:@"%@",self.memoMessage];
        }
        else
        {
            tempDict[@"Memo"] = @"";
        }
      
        if (anitem.item_No) {
            tempDict[@"ItemNo"] = [NSString stringWithFormat:@"%@",anitem.item_No];
        }
        else
        {
            tempDict[@"ItemNo"] = @"";
        }

        
       Configuration *configuration = [UpdateManager getConfigurationMoc:self.managedObjectContext];
        if (configuration.ticket.boolValue == TRUE) {
            tempDict[@"IsTicket"] = @(anitem.isTicket.boolValue);
            if (anitem.itemTicket) {
                tempDict[@"ExpirationDay"] = anitem.itemTicket.expirationDays;
                tempDict[@"NoOfDay"] = anitem.itemTicket.noOfdays;
            }
            else
            {
                tempDict[@"ExpirationDay"] = @(0);
                tempDict[@"NoOfDay"] = @(0);
            }
            
        }
        else
        {
            tempDict[@"IsTicket"] = @(0);
            tempDict[@"ExpirationDay"] = @(0);
            tempDict[@"NoOfDay"] = @(0);
        }
        
      
        
        if (anitem.eBT.boolValue) {
            self.isEbtApplied = true;
            tempDict[@"EBTApplicable"] = anitem.eBT;
            tempDict[@"EBTApplied"] = @(0);
        }
        else
        {
            self.isEbtApplied = false;
            tempDict[@"EBTApplicable"] = @(0);
            tempDict[@"EBTApplied"] = @(0);
        }
        
        if (anitem.eBT.boolValue == TRUE && self.isEBTApplicaleForBill == TRUE)
        {
            tempDict[@"EBTApplied"] = @(1);
            tempDict[@"ItemTaxDetail"] = @"";

        }
        tempDict[@"EBTApplicableForDisplay"] = @(0);
        tempDict[@"IsRefundFromInvoice"] = @(0);
       
        if (self.packageQty == nil) {
            tempDict[@"PackageType"] = @"Single Item";
            tempDict[@"PackageQty"] = @(1);
        }
        else
        {
            tempDict[@"PackageType"] = self.packageType;
            tempDict[@"PackageQty"] = self.packageQty;
        }
        tempDict[@"DeptTypeId"] = anitem.itemDepartment.deptTypeId;



    }
    else
    {
        NSString *strItemId=[NSString stringWithFormat:@"%ld",(long)itemId.integerValue];
        Item *anitem=[self fetchItem:strItemId];

		tempDict[@"itemId"] = itemId;
        tempDict[@"itemName"] = itemName;
        tempDict[@"itemImage"] = itemImagePath;
        tempDict[@"departId"] = departId;
        tempDict[@"itemType"] = itemType;
        tempDict[@"Barcode"] = Barcode;
        
        if ([anitem.itm_Type isEqualToString:@"1"]) {
         CGFloat itemCost = 0 ;
         if (anitem.itemDepartment)
         {
             itemCost = itemPrice.floatValue - itemPrice.floatValue * (anitem.itemDepartment.profitMargin.floatValue / 100) ;
         }
         tempDict[@"ItemCost"] = [NSString stringWithFormat:@"%f",itemCost];
         }
        else
        {
            tempDict[@"ItemCost"] = ItemCost;
        }
        
        
        tempDict[@"isBasicDiscounted"] = @"0";
        tempDict[@"IsPriceEdited"] = [NSString stringWithFormat:@"0"];
        tempDict[@"UnitType"] = [NSString stringWithFormat:@"%@",itemUnitType];
        tempDict[@"UnitQty"] = [NSString stringWithFormat:@"%@",itemUnitQty];

        if(anitem.itemGroupMaster.groupId)
        {
            tempDict[@"categoryId"] = anitem.itemGroupMaster.groupId;
        }
        else
        {
            tempDict[@"categoryId"] = @"0";
        }
        
        if(anitem.itemMixMatchDisc.mixMatchId)
        {
            tempDict[@"mixMatchId"] = anitem.itemMixMatchDisc.mixMatchId;
        }
        else
        {
            tempDict[@"mixMatchId"] = @"0";
            
        }
        
       // [tempDict setObject:anitem.pos_DISCOUNT forKey:@"pos_DISCOUNT"];
        if(anitem.subDeptId)
        {
            tempDict[@"SubDeptId"] = anitem.subDeptId;
        }
        else
        {
            tempDict[@"SubDeptId"] = @"0";
        }

		//[tempDict setObject:@"" forKey:@"itemMessage"];
		if(item != nil) {
            
            
			if(_isCheckCash == TRUE && _fCheckCashCharge > 0)
            {
                item[@"CheckCashCharge"] = [NSString stringWithFormat:@"%f", _fCheckCashCharge];
                item[@"isCheckCash"] = @"1";
                
            } else if(_fExtraChargeAmt>0)
            {
                item[@"ExtraCharge"] = [NSString stringWithFormat:@"%f", _fExtraChargeAmt];
                item[@"isExtraCharge"] = @"1";
            }
            
			tempDict[@"item"] = item;
		}
        if([[[tempDict valueForKey:@"item"] valueForKey:@"isDeduct"]boolValue] == YES)
        {
            tempDict[@"itemPrice"] = @(-itemPrice.floatValue);
            tempDict[@"itemTax"] = @(-itemTaxValue);
            tempDict[@"itemQty"] = [NSString stringWithFormat:@"%d",qty.intValue];
            tempDict[@"ItemDiscount"] = [NSString stringWithFormat:@"0"];
            
            
            if (taxDetailData != nil)
            {
                for (int i=0; i<[taxDetailData count]; i++)
                {
                    NSMutableDictionary *Dict=taxDetailData[i];
                    NSString *strItemTaxAmount=Dict[@"ItemTaxAmount"];
                    NSString *strSetAmount=[NSString stringWithFormat:@"-%@",strItemTaxAmount];
                    Dict[@"ItemTaxAmount"] = strSetAmount;
                    taxDetailData[i] = Dict;
                }
                
                tempDict[@"ItemTaxDetail"] = taxDetailData;
            }
            else
            {
                tempDict[@"ItemTaxDetail"] = @"";
            }
            tempDict[@"ItemBasicPrice"] = [NSString stringWithFormat:@"-%@",itemPrice];
        }
        else
        {
            tempDict[@"itemPrice"] = @(itemPrice.floatValue);
            tempDict[@"itemTax"] = @(itemTaxValue);
            tempDict[@"itemQty"] = [NSString stringWithFormat:@"%d",qty.intValue];
            tempDict[@"ItemDiscount"] = [NSString stringWithFormat:@"0"];
            
            if (taxDetailData != nil) {
                tempDict[@"ItemTaxDetail"] = taxDetailData;
            } else {
                tempDict[@"ItemTaxDetail"] = @"";
            }
            tempDict[@"ItemBasicPrice"] = itemPrice;
            
        }
        
        tempDict[@"ItemDiscountPercentage"] = @(0);
        tempDict[@"ItemExternalDiscount"] = @(0);
        tempDict[@"ItemInternalDiscount"] = @(0);
        if (anitem.item_No) {
            tempDict[@"ItemNo"] = [NSString stringWithFormat:@"%@",anitem.item_No];
        }
        else
        {
            tempDict[@"ItemNo"] = @"";
        }
        if (self.variationDetail) {
            tempDict[@"InvoiceVariationdetail"] = self.variationDetail;
        }
        if (self.memoMessage.length > 0) {
            tempDict[@"Memo"] = [NSString stringWithFormat:@"%@",self.memoMessage];
        }
        else
        {
            tempDict[@"Memo"] = @"";
        }
        
        Configuration *configuration = [UpdateManager getConfigurationMoc:self.managedObjectContext];
        if (configuration.ticket.boolValue == TRUE) {
            tempDict[@"IsTicket"] = @(anitem.isTicket.boolValue);
            if (anitem.itemTicket) {
                tempDict[@"ExpirationDay"] = anitem.itemTicket.expirationDays;
                tempDict[@"NoOfDay"] = anitem.itemTicket.noOfdays;
            }
            else
            {
                tempDict[@"ExpirationDay"] = @(0);
                tempDict[@"NoOfDay"] = @(0);
            }
            
        }
        else
        {
            tempDict[@"IsTicket"] = @(0);
            tempDict[@"ExpirationDay"] = @(0);
            tempDict[@"NoOfDay"] = @(0);
        }
        
        if (anitem.eBT.boolValue) {
            tempDict[@"EBTApplicable"] = anitem.eBT;
            tempDict[@"EBTApplied"] = @(0);
        }
        else
        {
            tempDict[@"EBTApplicable"] = @(0);
            tempDict[@"EBTApplied"] = @(0);
        }
        
        if (anitem.eBT.boolValue == TRUE && self.isEBTApplicaleForBill == TRUE)
        {
            tempDict[@"EBTApplied"] = @(1);
            tempDict[@"ItemTaxDetail"] = @"";

        }
        tempDict[@"EBTApplicableForDisplay"] = @(0);
        tempDict[@"IsRefundFromInvoice"] = @(0);
        
        if (self.packageQty == nil) {
            tempDict[@"PackageType"] = @"Single Item";
            tempDict[@"PackageQty"] = @(1);
        }
        else
        {
            tempDict[@"PackageType"] = self.packageType;
            tempDict[@"PackageQty"] = self.packageQty;
        }
        tempDict[@"DeptTypeId"] = anitem.itemDepartment.deptTypeId;



    }
    self.packageType = @"";
    self.packageQty = nil;

    self.variationDetail = nil;
    tempDict[@"IsQtyEdited"] = @"1";
    self.memoMessage = @"";
    _fCheckCashCharge = 0;
    _fExtraChargeAmt = 0;
    _isCheckCash = FALSE;
	return tempDict;
}

-(NSString *)getDepartmentTypeid:(NSNumber *)deptId{
    
    Department *dept = (Department *)[self.updateManager __fetchEntityWithName:@"Department" key:@"deptId" value:deptId shouldCreate:NO moc:self.managedObjectContext];
    
    return dept.deptTypeId.stringValue;
}
-(NSInteger)itemQtyForItemId :(NSString *)itemId
{
    NSInteger itemQty = 0;
    NSArray *itemArrayBunch = [self filterArray:_billReceiptArray forkey:@"itemId" withValue:itemId];
    itemQty = [[itemArrayBunch valueForKeyPath:@"@sum.itemQty"] integerValue];

    return itemQty;
}
-(CGFloat)itemPriceForItemQty :(NSInteger)itemQty forItem:(Item *)item
{
    CGFloat itemPrice = 0.0;
    NSArray * priceMD_Array = item.itemToPriceMd.allObjects;
    for (NSDictionary *price_MD_Dictionary in priceMD_Array)
    {
        if ([[price_MD_Dictionary valueForKey:@"itemQty"] integerValue] == itemQty)
        {
            itemPrice = [[price_MD_Dictionary valueForKey:@"cost"] floatValue];
        }
    }
    return itemPrice;
}

-(CGFloat)setItemWscalePriceForItem :(Item *)item
{
    NSInteger ItemQty = [self itemQtyForItemId:item.itemCode .stringValue];
    
    CGFloat itemPrice = [self itemPriceForItemQty:ItemQty forItem:item];
    return itemPrice;
}
-(CGFloat)setItemApproriatePriceForItem :(Item *)item
{
    NSInteger ItemQty = [self itemQtyForItemId:item.itemCode .stringValue];
    
    CGFloat itemPrice = [self itemPriceForItemQty:ItemQty forItem:item];
    return itemPrice;
}

- (Department*)fetchDepartment :(NSString *)strdeptId
{
    Department *department=nil;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Department" inManagedObjectContext:__managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"deptId==%d", strdeptId.integerValue];
    fetchRequest.predicate = predicate;
    
    // NSError *error;
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if (resultSet.count>0)
    {
        department=resultSet.firstObject;
    }
    return department;
}

- (Item*)fetchItem :(NSString *)itemId
{
    Item *item=nil;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Item" inManagedObjectContext:__managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemCode==%d", itemId.integerValue];
    fetchRequest.predicate = predicate;
    
    // NSError *error;
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if (resultSet.count>0)
    {
        item=resultSet.firstObject;
    }
    return item;
}
- (void)setupItemSwipeDiscountDictionary
{
    for (NSMutableDictionary *billDictionary in _billReceiptArray)
    {
        NSMutableArray *discountArray = [billDictionary valueForKey:@"Discount"];
        if (billDictionary[@"PriceAtPos"])
        {
            CGFloat priceAtPosDiscount = [billDictionary[@"ItemBasicPrice"] floatValue] - [billDictionary[@"PriceAtPos"] floatValue];
            
            if (priceAtPosDiscount < 0) {
                continue;
            }
            NSMutableDictionary *itemwisePecentageDiscountDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                                 @"Swipe", @"DiscountType",
                                                                 @(priceAtPosDiscount * [billDictionary[@"itemQty"] integerValue]),@"Amount",
                                                                  @"Swipe",@"AppliedOn",
                                                                        @(0),@"DiscountId"
                                                                        ,nil];
            [discountArray addObject:itemwisePecentageDiscountDictionary];
        }
    }
}

-(void)calculateBillAmountsWithBillReceiptArray:(NSMutableArray*)billReceiptArray;
{
    _billReceiptArray = [[NSMutableArray alloc]init];
    _billReceiptArray = billReceiptArray;
    [self resetItemPrice];
   
#ifdef USE_DISCOUNT_CALCULATOR_CLASS

    for (NSMutableDictionary *billEntry in billReceiptArray) {
        billEntry[@"UnProcessedQuantity"] = @([billEntry[@"itemQty"] integerValue]);
    }
    ItemMixMatchDiscountCalculator *calculator = [[ItemMixMatchDiscountCalculator alloc] init];
    [calculator calculateDiscountForBillEntries:billReceiptArray];
#else
    NSMutableArray *itemIdList = [self getNumberOfItems:_billReceiptArray withKey:@"itemId"];
    
    [self setupItemSwipeDiscountDictionary];
    
    
    for (NSString *itemId in itemIdList)
    {
        [self recalculateBillAmounts:itemId.integerValue isPriceEdited:NO];
    }
#endif
  
    [self calCulateItemWiseDiscount];
    
    
    switch (self.billWiseDiscountType) {
        case BillWiseDiscountTypeNone:
            
            break;
        case BillWiseDiscountTypeAmount:
            [self calCulateBillWiseDiscountWithPercentage:[self calculateBillParcentageForBill]];

            break;
            
        case BillWiseDiscountTypePercentage:
            [self calCulateBillWiseDiscountWithPercentage:self.billWiseDiscount.floatValue];

            break;
        default:
            break;
    }
    
  /*  if(self.billWiseDiscountApplied)
    {
        [self calCulateBillWiseDiscountWithPercentage:self.billWiseDiscount.floatValue];
    }*/

    [self calculateTotalItemCost];

}

-(CGFloat )calculateBillParcentageForBill
{
    CGFloat totalBillAmountForBill = 0.00;
    CGFloat billDiscountPercentage = 0.00;
    for(int i=0;i<_billReceiptArray.count;i++)
    {
        NSMutableDictionary *billEntryDict = _billReceiptArray[i];
        
        if (billEntryDict[@"ItemWiseDiscountType"])
        {
            if ([billEntryDict[@"ItemWiseDiscountType"] isEqualToString:@"Amount"]) {
                NSString *discountValue=[billEntryDict[@"ItemWiseDiscountValue"] stringByReplacingOccurrencesOfString:self.crmController.currencyFormatter.internationalCurrencySymbol withString:@""];
                float discPrice=[NSString stringWithFormat:@"%f",[self.crmController.currencyFormatter numberFromString:discountValue].floatValue].floatValue;
                if (discPrice == 0) {
                    continue;
                }
            }
            else
            {
                if ([billEntryDict[@"ItemWiseDiscountType"] floatValue] == 0) {
                    continue;
                }
            }
        }
        
        float itemCost = [billEntryDict[@"itemPrice"] floatValue];
        if (itemCost < 0) {
            continue ;
        }
        float variationCost = [billEntryDict[@"TotalVarionCost"] floatValue];
        float totalItemCostValue = (itemCost*[[billEntryDict valueForKey:@"itemQty"] intValue]);
        totalItemCostValue += variationCost;
        totalBillAmountForBill += totalItemCostValue;
    }
   
    if (totalBillAmountForBill != 0.00) {
        billDiscountPercentage = (self.billWiseDiscount.floatValue * 100) / totalBillAmountForBill;
        if (billDiscountPercentage > 100) {
            billDiscountPercentage = 100;
        }
    }
    return billDiscountPercentage;
}
-(void)calculateTotalItemCost
{

    for(int i=0;i<_billReceiptArray.count;i++)
    {
        NSMutableDictionary *billEntryDict = _billReceiptArray[i];

        float itemCost = [billEntryDict[@"itemPrice"] floatValue];
        float variationCost = [billEntryDict[@"TotalVarionCost"] floatValue];
        float totalItemCostValue = (itemCost*[[billEntryDict valueForKey:@"itemQty"] intValue]);
        totalItemCostValue += variationCost;

        billEntryDict[@"TotalItemPrice"] = @(totalItemCostValue);
    }
}

-(void)calculateItemAsPosSeprateCalculationWithBillDetail :(NSMutableArray*)billReceiptArray
{
    _billReceiptArray = [[NSMutableArray alloc]init];
    _billReceiptArray = billReceiptArray;
  //  [self setItemPrice];
    [self setupItemSwipeDiscountDictionary];
    [self calCulateItemWiseDiscount];
  /*  if(self.billWiseDiscountApplied)
    {
        [self calCulateBillWiseDiscountWithPercentage:self.billWiseDiscount.floatValue];
    }*/
}

- (void)calculateBillAmounts_Restructured {
    // Calculate Quantity Discount
    NSMutableArray *uniqueItemCodes = [self getNumberOfItems:_billReceiptArray withKey:@"itemId"];
    NSString *itemCode;
    for (itemCode in uniqueItemCodes) {
       
    }

    // Calculate Mix-Match Discount
    [self itemCategoryMixMatchDiscountCalculation];
    // Calculate Mix-Match Category (/Group) Discount
    [self itemMixMatchDiscountCalculation];

    // Calculate Item Wise Discount

    // Calculate Bill Wise Discount
    // Calculate Tax

    // Calculate Subtotal
}



- (void)setIntialDiscountValue:(NSMutableDictionary *)dict
{
    dict[@"ItemDiscount"] = @(0);
    dict[@"TotalDiscount"] = @(0);
    dict[@"ItemExternalDiscount"] = @(0);
    dict[@"ItemInternalDiscount"] = @(0);
    dict[@"ItemDiscountPercentage"] = @(0);
}

-(void)resetItemPrice
{
    for(int i=0;i<_billReceiptArray.count;i++)
    {
        NSMutableDictionary *dict = _billReceiptArray[i];
        
            dict[@"itemPrice"] = @([dict[@"ItemBasicPrice"] floatValue]);
            dict[@"ItemDiscount"] = @(0);
            dict[@"TotalDiscount"] = @(0);
            dict[@"ItemExternalDiscount"] = @(0);
            dict[@"ItemInternalDiscount"] = @(0);
            dict[@"ItemDiscountPercentage"] = @(0);
            dict[@"Discount"] = [[NSMutableArray alloc]init];

        [self resetVariationForDictionary:dict];
        
        float totalVarionCost = 0.0;
        if (dict[@"InvoiceVariationdetail"])
        {
            totalVarionCost = [[(NSArray *)dict[@"InvoiceVariationdetail"] valueForKeyPath:@"@sum.VariationBasicPrice"] floatValue] * [[dict valueForKey:@"itemQty"] floatValue];
        }
        dict[@"TotalVarionCost"] = @(totalVarionCost);

          /*  if ([[[_billReceiptArray objectAtIndex:i] objectForKey:@"PriceAtPos"] floatValue] > 0)
            {
                dict[@"itemPrice"] = @([dict[@"ItemBasicPrice"] floatValue]);
                [self setIntialDiscountValue:dict];
            }
            else
            {
                dict[@"itemPrice"] = @([dict[@"PriceAtPos"] floatValue]);
                [self setIntialDiscountValue:dict];
                dict[@"ItemDiscountPercentage"] = @(0);
            }
        }
        else
        {
            dict[@"itemPrice"] = @([dict[@"ItemBasicPrice"] floatValue]);
            [self setIntialDiscountValue:dict];
        }*/
    }
}

-(void)resetVariationForDictionary :(NSMutableDictionary *)variationDictionary
{
    if (variationDictionary[@"InvoiceVariationdetail"])
    {
        NSMutableArray *variation = variationDictionary[@"InvoiceVariationdetail"];
        for (NSMutableDictionary *variationDictionary in variation)
        {
            [variationDictionary setValue:variationDictionary[@"VariationBasicPrice"] forKey:@"Price"];
        }
    }
}


- (void)recalculateBillAmounts:(NSInteger)itemCodeId isPriceEdited:(BOOL)isPriceEdited {

    if(_billReceiptArray.count > 0)
    {
        NSString *strItemId = [NSString stringWithFormat:@"%ld", (long)itemCodeId];
        Item *item = [_updateManager fetchItemFromDBWithItemId:strItemId shouldCreate:NO moc:_moc];
 
        if (item.qty_Discount.boolValue  || ![item.pricescale isEqualToString:@""] || ![item.pricescale isEqual:[NSNull null]] /* == TRUE && !isPriceEdited Do not check this flag here */)
        {
           // Item *item = [_updateManager fetchItemFromDBWithItemId:itemCode shouldCreate:NO moc:_moc];
            if (!item.isPriceAtPOS.boolValue)
            {
                [self calculateQDForItem:item];
            }
           // [self calculateSimpleDiscount:itemCodeId];
        }
#ifndef MERGE_MIXMATCH_DISCOUNT
        else  if (item.cate_MixMatchFlg.boolValue == TRUE)
        {
            [self itemCategoryMixMatchDiscountCalculation];
        }
        else if (item.mixMatchFlg.boolValue == TRUE)
        {
            [self itemMixMatchDiscountCalculation];
        }
#endif
        
        
    }

}
-(void)setBasicPriceAtItemPriceForItem :(Item*)item
{
    NSArray *itemArrayBunch = [self filterArray:_billReceiptArray forkey:@"itemId" withValue:item.itemCode];
    NSMutableArray *itemArray = [itemArrayBunch copy];
    for (NSMutableDictionary *itemDictionary in itemArray)
    {
        itemDictionary[@"itemPrice"] = @([itemDictionary[@"ItemBasicPrice"] floatValue]);
    }
}
-(void)calulateQtyDiscountPerItem
{
    for(int i=0;i<_billReceiptArray.count;i++)
    {
        
    }
}
-(NSString *)discountTypeForBill
{
    NSString *discountType = @"";
    switch (self.billWiseDiscountType) {
        case BillWiseDiscountTypeNone:
            discountType = @"";
            break;
        case BillWiseDiscountTypeAmount:
            discountType = @"Amount";
            
            break;
            
        case BillWiseDiscountTypePercentage:
            discountType = @"Percentage";
            
            break;
        default:
            break;
    }
    return discountType;

}
-(void)calCulateBillWiseDiscountWithPercentage :(CGFloat )percentage
{
    for(int i=0;i<_billReceiptArray.count;i++)
    {
        NSMutableDictionary *dict = _billReceiptArray[i];
        if (![dict[@"item"][@"isCheckCash"] boolValue]==YES)
        {
            if (!dict[@"ItemWiseDiscountType"])
            {
                Item *item = [_updateManager fetchItemFromDBWithItemId:[NSString stringWithFormat:@"%@",[dict  valueForKey:@"itemId"]] shouldCreate:NO moc:_moc];
                
                if (item.pos_DISCOUNT.integerValue == 0)
                {
                    NSNumber *itemPrice = nil;
                    

                    if (dict[@"PriceAtPos"])
                    {
                        itemPrice = @([dict[@"PriceAtPos"] floatValue]);
                    }
                    else
                    {
                        itemPrice = dict[@"itemPrice"];
                    }
                    
                //    if ([itemPrice floatValue] > 0)
                    {
                        CGFloat totalVariationForItem = [self calculateTotalForVariationDictionary:dict];
                        
                        CGFloat totalVariationDiscountForItem = [self calculateBillDiscountForVariationDictionary:dict withPercentage:percentage];

                        float desForItemprice = (itemPrice.floatValue* percentage * 0.01);
                        
                        dict[@"ItemExternalDiscount"] = @(desForItemprice + totalVariationDiscountForItem);
                        
                        
                        NSNumber *discountId = @(0);
                        
                        if (dict[@"SalesManualDiscountId"]) {
                            discountId = dict[@"SalesManualDiscountId"];
                        }
                        
                        if ([self discountTypeForBill].length > 0) {
                            NSMutableDictionary *billDiscountDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                                    [self discountTypeForBill], @"DiscountType",
                                                                    @((desForItemprice + totalVariationDiscountForItem) * [dict[@"itemQty"] integerValue]),@"Amount",
                                                                    @"Bill",@"AppliedOn",
                                                                    discountId,@"DiscountId",nil];
                            NSMutableArray *discountArray = [dict valueForKey:@"Discount"];
                            [discountArray addObject:billDiscountDictionary];
                        }
                        
                        dict[@"itemPrice"] = @(itemPrice.floatValue - desForItemprice);
                        
                        float ItemOrignalDiscount = [dict[@"ItemDiscount"] floatValue] + desForItemprice + totalVariationDiscountForItem;
                        
                        [dict setValue:[NSString stringWithFormat:@"%f",ItemOrignalDiscount] forKey:@"ItemDiscount"];
                        
                        float totalItemPrice = [dict[@"ItemBasicPrice"] floatValue] + totalVariationForItem;
                        float  totalItemPercenatge  = 0.0;
                        if (totalItemPrice != 0) {
                            totalItemPercenatge = ItemOrignalDiscount / totalItemPrice * 100;
                        }
                        dict[@"ItemDiscountPercentage"] = @(totalItemPercenatge);
                        
                        CGFloat totalDiscountedVariationForItem = totalVariationForItem - totalVariationDiscountForItem;
                        
                        dict[@"TotalVarionCost"] = @(totalDiscountedVariationForItem * [[dict valueForKey:@"itemQty"] floatValue]) ;

                    }
                }
            }
        }
    }
}

-(CGFloat )calculateTotalForVariationDictionary :(NSDictionary *)dictionary
{
    CGFloat totalVarionCost = 0.0;
    
    if (dictionary[@"InvoiceVariationdetail"])
    {
        totalVarionCost = [[(NSArray *)dictionary[@"InvoiceVariationdetail"] valueForKeyPath:@"@sum.VariationBasicPrice"] floatValue] ;
    }
    return totalVarionCost;
}

-(CGFloat )calculateBillDiscountForVariationDictionary :(NSDictionary *)dictionary withPercentage:(CGFloat )percentage
{
    CGFloat totalVarionDiscount = 0.0;
    
    if (dictionary[@"InvoiceVariationdetail"])
    {
        NSMutableArray *variationDetailForItem = dictionary[@"InvoiceVariationdetail"];
        for (NSMutableDictionary *variationDictionary in variationDetailForItem)
        {
            CGFloat variationPrice = [variationDictionary[@"VariationBasicPrice"] floatValue];
        
             float despriceForVariation = (variationPrice * percentage * 0.01);
            
            totalVarionDiscount += despriceForVariation;
            
             variationPrice = variationPrice - despriceForVariation;
            
             [variationDictionary setValue:[NSString stringWithFormat:@"%f",variationPrice] forKey:@"Price"];
        }
    }
    return totalVarionDiscount;
}

-(void)calCulateItemWiseDiscount
{
    for(int i=0;i<_billReceiptArray.count;i++)
    {
        NSMutableDictionary *_billReceiptDict = _billReceiptArray[i];
        if (![[_billReceiptDict valueForKey:@"item"][@"isCheckCash"] boolValue]==YES)
        {
            if (_billReceiptDict[@"ItemWiseDiscountType"])
            {
                Item *item = [_updateManager fetchItemFromDBWithItemId:[NSString stringWithFormat:@"%@",[_billReceiptDict  valueForKey:@"itemId"]] shouldCreate:NO moc:_moc];
                
                if (item.pos_DISCOUNT.integerValue == 0)
                {
                    if ([_billReceiptDict[@"ItemWiseDiscountType"] isEqualToString:@"Percentage"])
                    {
                        [self itemPercentageWiseDiscountCalculation:_billReceiptDict];
                    }
                    else if ([_billReceiptDict[@"ItemWiseDiscountType"] isEqualToString:@"Amount"])
                    {
                        [self itemAmountWiseDiscountCalculation:_billReceiptDict];
                    }
                }
            }
            else if (_billReceiptDict[@"PriceAtPos"])
            {
                [self calculatePriceAtPosDiscount:_billReceiptDict];
            }
            else
            {
                
            }
        }
    }
    
}

-(void)calculatePriceAtPosDiscount :(NSMutableDictionary *)priceAtPosDiscountDict
{
  //  if ([[priceAtPosDiscountDict objectForKey:@"PriceAtPos"] floatValue] >= 0)
    {
        float discPrice = 0.0;
        //if ([[priceAtPosDiscountDict objectForKey:@"ItemBasicPrice"] floatValue] > [[priceAtPosDiscountDict objectForKey:@"PriceAtPos"] floatValue])
        {
            discPrice = [priceAtPosDiscountDict[@"ItemBasicPrice"] floatValue] - [priceAtPosDiscountDict[@"PriceAtPos"] floatValue];
        }
        if ((discPrice * [priceAtPosDiscountDict[@"ItemBasicPrice"] floatValue]) < 0)
        {
            discPrice = 0;
        }
        
        priceAtPosDiscountDict[@"itemPrice"] = @([priceAtPosDiscountDict[@"PriceAtPos"] floatValue]);
        priceAtPosDiscountDict[@"ItemExternalDiscount"] = @(0);
        priceAtPosDiscountDict[@"ItemDiscount"] = [NSString stringWithFormat:@"%f",discPrice];
        float  totalItemPercenatge  = 0.0;
        if ([priceAtPosDiscountDict[@"ItemBasicPrice"] floatValue] != 0) {
            totalItemPercenatge = discPrice / [priceAtPosDiscountDict[@"ItemBasicPrice"] floatValue] * 100;
        }
        
       // float  totalItemPercenatge = discPrice / [[priceAtPosDiscountDict objectForKey:@"ItemBasicPrice"] floatValue] * 100;
        priceAtPosDiscountDict[@"ItemDiscountPercentage"] = @(totalItemPercenatge);

    }
}

-(void)itemAmountWiseDiscountCalculation :(NSMutableDictionary *)amountDiscountDict
{
    if (amountDiscountDict[@"PriceAtPos"])
    {
        NSString *itemPrice = amountDiscountDict[@"PriceAtPos"];
      //  if ([itemPrice floatValue] > 0)
        {
            NSString *discountValue=[amountDiscountDict[@"ItemWiseDiscountValue"] stringByReplacingOccurrencesOfString:self.crmController.currencyFormatter.internationalCurrencySymbol withString:@""];
            
            float mainPrice=itemPrice.floatValue;
            float discPrice=[NSString stringWithFormat:@"%f",[self.crmController.currencyFormatter numberFromString:discountValue].floatValue].floatValue;
            float discountToCompare = discPrice;
           // if (mainPrice>=discPrice)
            {
                if (mainPrice < 0)
                {
                    discPrice = -discPrice;
                }
                
                float itemPrice = mainPrice-discPrice ;
                amountDiscountDict[@"ItemExternalDiscount"] = @(discPrice);
          ///      if ([[amuntDiscountDict objectForKey:@"ItemBasicPrice"] floatValue] > [[amuntDiscountDict objectForKey:@"PriceAtPos"] floatValue])
                {
                    discPrice = [amountDiscountDict[@"ItemBasicPrice"] floatValue] - itemPrice;
                }
                if ((discPrice * [amountDiscountDict[@"ItemBasicPrice"] floatValue]) < 0)
                {
                    discPrice = -[NSString stringWithFormat:@"%f",[self.crmController.currencyFormatter numberFromString:discountValue].floatValue].floatValue;
                }
                NSNumber *discountId = @(0);
                
                if (amountDiscountDict[@"SalesManualDiscountId"]) {
                    discountId = amountDiscountDict[@"SalesManualDiscountId"];
                }
                
                if (discountToCompare != 0.00) {
                    NSMutableDictionary *amountPecentageDiscountDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                                       @"Amount", @"DiscountType",
                                                                       @(discountToCompare  *  [amountDiscountDict[@"itemQty"] integerValue]),@"Amount",
                                                                        @"Item",@"AppliedOn",
                                                                        discountId,@"DiscountId",nil];
                    
                    NSMutableArray *discountArray = [amountDiscountDict valueForKey:@"Discount"];
                    [discountArray addObject:amountPecentageDiscountDictionary];
                }
                
                CGFloat totalVariationForItem = [self calculateTotalForVariationDictionary:amountDiscountDict];
                
                float totalItemPrice = [amountDiscountDict[@"ItemBasicPrice"] floatValue] + totalVariationForItem;
                float  totalItemPercenatge  = 0.0;
                if (totalItemPrice != 0) {
                    totalItemPercenatge = discPrice / totalItemPrice * 100;
                }
                amountDiscountDict[@"ItemDiscountPercentage"] = @(totalItemPercenatge);
                amountDiscountDict[@"itemPrice"] = @(itemPrice);
                amountDiscountDict[@"ItemDiscount"] = [NSString stringWithFormat:@"%f",discPrice];
            }
        }
    }
    else
    {
        NSNumber *itemPrice = amountDiscountDict[@"itemPrice"];
     //   if ([itemPrice floatValue] > 0)
        {
            // Item.
            NSString *discountValue=[amountDiscountDict[@"ItemWiseDiscountValue"] stringByReplacingOccurrencesOfString:self.crmController.currencyFormatter.internationalCurrencySymbol withString:@""];
            
            float mainPrice=itemPrice.floatValue;
            float discPrice=[NSString stringWithFormat:@"%f",[self.crmController.currencyFormatter numberFromString:discountValue].floatValue].floatValue;
            
         //   if (mainPrice>=discPrice)
            {
            if (mainPrice < 0)
            {
                discPrice = -discPrice;
                
            }
                NSNumber *discountId = @(0);
                if (amountDiscountDict[@"SalesManualDiscountId"]) {
                    discountId = amountDiscountDict[@"SalesManualDiscountId"];
                }
                
                NSMutableDictionary *amountPecentageDiscountDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                                     @"Amount", @"DiscountType",
                                                                     @(discPrice *  [amountDiscountDict[@"itemQty"] integerValue]),@"Amount",
                                                                    @"Item",@"AppliedOn",
                                                                    discountId,@"DiscountId",nil];
                
                NSMutableArray *discountArray = [amountDiscountDict valueForKey:@"Discount"];
                [discountArray addObject:amountPecentageDiscountDictionary];
                
                float itemPrice=mainPrice-discPrice ;
                amountDiscountDict[@"itemPrice"] = @(itemPrice);
                
                float ItemOrignalDiscount = [amountDiscountDict[@"ItemDiscount"] floatValue] + discPrice;
                
                CGFloat totalVariationForItem = [self calculateTotalForVariationDictionary:amountDiscountDict];
                
                float totalItemPrice = [amountDiscountDict[@"ItemBasicPrice"] floatValue] + totalVariationForItem;
               
                float  totalItemPercenatge  = 0.0;
               
                if (totalItemPrice != 0) {
                    totalItemPercenatge = ItemOrignalDiscount / totalItemPrice * 100;
                }
                
                amountDiscountDict[@"ItemDiscountPercentage"] = @(totalItemPercenatge);
                amountDiscountDict[@"ItemExternalDiscount"] = @(discPrice);

                amountDiscountDict[@"ItemDiscount"] = [NSString stringWithFormat:@"%f",[self.crmController.currencyFormatter numberFromString:discountValue].floatValue];
                amountDiscountDict[@"ItemDiscount"] = [NSString stringWithFormat:@"%f",ItemOrignalDiscount];
            }
        }
    }
}




-(void)itemPercentageWiseDiscountCalculation :(NSMutableDictionary *)percentageDiscountDict
{
    if (percentageDiscountDict[@"PriceAtPos"])
    {
        NSString *itemPrice = percentageDiscountDict[@"PriceAtPos"];
      

        CGFloat totalVariationForItem = [self calculateTotalForVariationDictionary:percentageDiscountDict];
        
        CGFloat totalVariationDiscountForItem = [self calculateItemWisePercentageDiscountForVariationDictionary:percentageDiscountDict];
        
     //   if ([itemPrice floatValue] > 0)
        {
            float desprice = (itemPrice.floatValue * [[percentageDiscountDict valueForKey:@"ItemWiseDiscountValue"] floatValue] * 0.01);
            
            percentageDiscountDict[@"itemPrice"] = @(itemPrice.floatValue - desprice);

            percentageDiscountDict[@"ItemExternalDiscount"] = @(desprice + totalVariationDiscountForItem);

            CGFloat totalDiscountForItem = desprice + totalVariationDiscountForItem;
            
            NSNumber *discountId = @(0);
            
            if (percentageDiscountDict[@"SalesManualDiscountId"]) {
                discountId = percentageDiscountDict[@"SalesManualDiscountId"];
            }
            
            NSMutableDictionary *itemwisePecentageDiscountDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                                 @"Percentage", @"DiscountType",
                                                                 @(totalDiscountForItem * [percentageDiscountDict[@"itemQty"] integerValue]),@"Amount",
                                                                  @"Item",@"AppliedOn",
                                                                    discountId,@"DiscountId",nil];
            
            NSMutableArray *discountArray = [percentageDiscountDict valueForKey:@"Discount"];
            [discountArray addObject:itemwisePecentageDiscountDictionary];

            
            
            {
                desprice += [percentageDiscountDict[@"ItemBasicPrice"] floatValue] - itemPrice.floatValue;
            }
            if ((desprice * [percentageDiscountDict[@"ItemBasicPrice"] floatValue]) < 0)
            {
                desprice = -(itemPrice.floatValue * [[percentageDiscountDict valueForKey:@"ItemWiseDiscountValue"] floatValue] * 0.01);
            }

            [percentageDiscountDict setValue:[NSString stringWithFormat:@"%f",totalDiscountForItem] forKey:@"ItemDiscount"];
            
            float totalItemPrice = [percentageDiscountDict[@"ItemBasicPrice"] floatValue] + totalVariationForItem;

            float  totalItemPercenatge  = 0.0;
            if (totalItemPrice != 0) {
                totalItemPercenatge = desprice / totalItemPrice * 100;
            }

            percentageDiscountDict[@"ItemDiscountPercentage"] = @(totalItemPercenatge);
            
            
            CGFloat totalDiscountedVariationForItem = totalVariationForItem - totalVariationDiscountForItem;
            
            percentageDiscountDict[@"TotalVarionCost"] = @(totalDiscountedVariationForItem * [[percentageDiscountDict valueForKey:@"itemQty"] floatValue]) ;
            
        }
    }
    else
    {
        NSNumber *itemPrice = percentageDiscountDict[@"itemPrice"];
      //  if ([itemPrice floatValue] > 0)
        {
            CGFloat totalVariationForItem = [self calculateTotalForVariationDictionary:percentageDiscountDict];
            
            CGFloat totalVariationDiscountForItem = [self calculateItemWisePercentageDiscountForVariationDictionary:percentageDiscountDict];

            float desprice = (itemPrice.floatValue*[[percentageDiscountDict valueForKey:@"ItemWiseDiscountValue"] floatValue]*0.01);
            
            if (itemPrice < 0)
            {
                desprice = -desprice;
            }
            
            percentageDiscountDict[@"itemPrice"] = @(itemPrice.floatValue - desprice);

            percentageDiscountDict[@"ItemExternalDiscount"] = @(desprice + totalVariationDiscountForItem);
            
            
            NSNumber *discountId = @(0);
            
            if (percentageDiscountDict[@"SalesManualDiscountId"]) {
                discountId = percentageDiscountDict[@"SalesManualDiscountId"];
            }
            
            NSMutableDictionary *itemwisePecentageDiscountDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                 @"Percentage", @"DiscountType",
                                                  @((desprice + totalVariationDiscountForItem) * [percentageDiscountDict[@"itemQty"] integerValue]),@"Amount",
                                                  @"Item",@"AppliedOn",
                                                   discountId,@"DiscountId",nil];
            
            NSMutableArray *discountArray = [percentageDiscountDict valueForKey:@"Discount"];
            [discountArray addObject:itemwisePecentageDiscountDictionary];

            float ItemOrignalDiscount = [percentageDiscountDict[@"ItemDiscount"] floatValue] + desprice + totalVariationDiscountForItem;
            
            float totalItemPrice = [percentageDiscountDict[@"ItemBasicPrice"] floatValue] + totalVariationForItem;

            float  totalItemPercenatge  = 0.0;
            if (totalItemPrice != 0) {
                totalItemPercenatge = ItemOrignalDiscount / totalItemPrice * 100;
            }
            
            [percentageDiscountDict setValue:[NSString stringWithFormat:@"%f",ItemOrignalDiscount] forKey:@"ItemDiscount"];
            
            percentageDiscountDict[@"ItemDiscountPercentage"] = @(totalItemPercenatge);
            
            CGFloat totalDiscountedVariationForItem = totalVariationForItem - totalVariationDiscountForItem;
            
            percentageDiscountDict[@"TotalVarionCost"] = @(totalDiscountedVariationForItem * [[percentageDiscountDict valueForKey:@"itemQty"] floatValue]) ;

        }
        
    }
}



-(CGFloat )calculateItemWisePercentageDiscountForVariationDictionary :(NSDictionary *)dictionary
{
    CGFloat totalVarionDiscount = 0.0;
    
    if (dictionary[@"InvoiceVariationdetail"])
    {
        NSMutableArray *variationDetailForItem = dictionary[@"InvoiceVariationdetail"];
        for (NSMutableDictionary *variationDictionary in variationDetailForItem)
        {
            CGFloat variationPrice = [variationDictionary[@"VariationBasicPrice"] floatValue];
            
            float despriceForVariation = (variationPrice * [[dictionary valueForKey:@"ItemWiseDiscountValue"] floatValue] * 0.01);
            
            totalVarionDiscount += despriceForVariation;
            
            variationPrice = variationPrice - despriceForVariation;
            
            [variationDictionary setValue:[NSString stringWithFormat:@"%f",variationPrice] forKey:@"Price"];
        }
    }
    return totalVarionDiscount;
}

- (void)prepareDataForCalculations
{
    if(_billReceiptArray.count>0)
    {
        for (int idata=0; idata<_billReceiptArray.count; idata++) {
            
            NSMutableDictionary *replaceDict=_billReceiptArray[idata];
            replaceDict[@"discFlg"] = @"0";
            replaceDict[@"itemRowId"] = @(idata);
        }
    }
}

- (int)totalQuantityForItemCode:(NSInteger)itemCode
{
    int totalQuantity=0;
    if(_billReceiptArray.count>0)
    {
        for (NSDictionary *billEntryDictionary in _billReceiptArray) {
            int ircptItemId=[[billEntryDictionary valueForKey:@"itemId"]intValue];
            
            if(ircptItemId==itemCode)
            {
                totalQuantity+=[[billEntryDictionary valueForKey:@"itemQty"]intValue];
            }
        }
    }
    return totalQuantity;
}

- (void)resetDiscountAndPriceFor:(NSInteger)itemCode
{
    for (NSMutableDictionary *itemRcptDisc in _billReceiptArray) {
        int ircptItemId=[[itemRcptDisc valueForKey:@"itemId"]intValue];
        if (ircptItemId==itemCode)
        {
            if ([itemRcptDisc[@"isBasicDiscounted"]isEqualToString:@"1"])
            {
                itemRcptDisc[@"discFlg"] = @"0";
                [self resetDiscountAndPrice:itemRcptDisc];
            }
        }
    }
}

- (BOOL)isDiscountMD2Applicable:(Item_Discount_MD2 *)idiscMd2 onDate:(NSDate *)date {
    NSComparisonResult result,result2;

    NSDate *strStartDate=[self getDate:idiscMd2.itemDiscount_MD2Dictionary[@"StartDate"]];
    NSDate *strEndDate=[self getDate:idiscMd2.itemDiscount_MD2Dictionary[@"EndDate"]];

    result = [date compare:strStartDate]; // comparing two dates
    result2 = [date compare:strEndDate]; // comparing two dates

    return (result==NSOrderedDescending && result2==NSOrderedAscending);
}

#ifdef MERGE_MIXMATCH_DISCOUNT
- (NSMutableArray *)applicableMMDiscountDataForItemCode:(int)itemCode {
    NSMutableArray *mmDiscountData = [NSMutableArray array];

    NSString *strItemId = [NSString stringWithFormat:@"%d", itemCode];
    Item *item = [_updateManager fetchItemFromDBWithItemId:strItemId shouldCreate:NO moc:_moc];

    if ([item.cate_MixMatchFlg boolValue] == TRUE)
    {

    }
    else if ([item.mixMatchFlg boolValue] == TRUE)
    {

    }

    return mmDiscountData;
}
#endif

- (NSMutableArray *)applicableDiscountData:(NSInteger)itemCode {
    NSString *strItemId=[NSString stringWithFormat:@"%ld", (long)itemCode];
    Item *item = [_updateManager fetchItemFromDBWithItemId:strItemId shouldCreate:NO moc:_moc];

    int iqty = [self totalQuantityForItemCode:itemCode];

    Item_Discount_MD2 *idiscMd2;
    NSMutableArray * itemDiscArray = [[NSMutableArray alloc]init];
    for (Item_Discount_MD *idiscMd in item.itemToDisMd )
    {
        [itemDiscArray addObjectsFromArray:idiscMd.mdTomd2.allObjects];
    }
    NSMutableArray *itmDiscountData=[[NSMutableArray alloc]init];
    
    for (int idisc=0; idisc<itemDiscArray.count; idisc++) {
        
        //  NSMutableDictionary *dict=[itemDiscArray objectAtIndex:idisc];
        idiscMd2=itemDiscArray[idisc];
        
        //  int iDiscqty=[[dict valueForKey:@"DIS_Qty"]integerValue];
        NSInteger iDiscqty = idiscMd2.md2Tomd.dis_Qty.integerValue;
        
        if(iqty >= iDiscqty)
        {
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSDateComponents *comps = [gregorian components:NSCalendarUnitWeekday fromDate:[NSDate date]];
            NSInteger weekday = comps.weekday;
            
            if(idiscMd2.dayId.integerValue == 0)
            {
                if ([self isDiscountMD2Applicable:idiscMd2 onDate:[self setFormatter:[NSDate date]]])
                {
                    [itmDiscountData addObject:idiscMd2.itemDiscount_MD2Dictionary];
                }
            }
            else if (idiscMd2.dayId.integerValue==weekday|| idiscMd2.dayId.integerValue==-1)
            {
                if (idiscMd2.dayId.integerValue==weekday)
                {
                    if ([self isDiscountMD2Applicable:idiscMd2 onDate:[self setFormatter:[NSDate date]]])
                    {
                        [itmDiscountData addObject:idiscMd2.itemDiscount_MD2Dictionary];
                    }
                }
                else
                {
                    [itmDiscountData addObject:idiscMd2.itemDiscount_MD2Dictionary];
                }
            }
            else
            {
                
            }
        }
        else
        {
           // [self resetDiscountAndPriceFor:itemCode];
        }
    }
    [self setItemPriceFromItem_Price_MdforItem:item withQtyDiscountArray:itmDiscountData];
    return itmDiscountData;
}

-(void)setItemPriceFromItem_Price_MdforItem :(Item *)item withQtyDiscountArray:(NSMutableArray *)discountArray
{
    if ([item.pricescale isEqualToString:@"APPPRICE"])
    {
        for (Item_Price_MD *price_md in item.itemToPriceMd)
        {
            NSMutableDictionary *price_Md_dictionary = [[NSMutableDictionary alloc]init];
            price_Md_dictionary[@"Qty"] = [NSString stringWithFormat:@"%ld",(long)price_md.qty.integerValue];
            price_Md_dictionary[@"applyPrice"] = price_md.applyPrice;
            
            NSString *priceType = [NSString stringWithFormat:@"%@",price_md.applyPrice];
            NSNumber *priceValue = 0;
            
            if ([priceType isEqualToString:@"PriceA"])
            {
                priceValue = price_md.priceA;
            }
            else if ([priceType isEqualToString:@"PriceB"])
            {
                priceValue = price_md.priceB;
                
            }
            else if ([priceType isEqualToString:@"PriceC"])
            {
                priceValue = price_md.priceC;
            }
            else
            {
                priceValue = price_md.unitPrice;
            }
            
            NSPredicate *itemCodePredicate = [NSPredicate predicateWithFormat:@"DIS_Qty = %@", price_md.qty];
            NSArray *filteredArray = [discountArray filteredArrayUsingPredicate:itemCodePredicate];
            if (filteredArray.count > 0)
            {
                NSMutableDictionary *filterdDictionary = [filteredArray firstObject];
                if ([filterdDictionary[@"DIS_UnitPrice"] floatValue]  > priceValue.floatValue && !(priceValue.floatValue == 0)  && price_md.qty.floatValue > 0)
                {
                    filterdDictionary[@"DIS_UnitPrice"] = priceValue;
                    filterdDictionary[@"DIS_Qty"] = price_md.qty;
                    filterdDictionary[@"DiscountAddedKey"] = @"DiscountAddedFromPriceMD";
                    
                }
            }
            else
            {
                if(!(priceValue.floatValue == 0) && price_md.qty.floatValue > 0)
                {
                    NSMutableDictionary *discountAddDictionary = [[NSMutableDictionary alloc]init];
                    [discountAddDictionary setObject:price_md.qty forKey:@"DIS_Qty"];
                    [discountAddDictionary setObject:priceValue forKey:@"DIS_UnitPrice"];
                    [discountAddDictionary setObject:@"DiscountAddedFromPriceMD" forKey:@"DiscountAddedKey"];
                    [discountArray addObject:discountAddDictionary];
                }
            }
        }
    }
   else if ([item.pricescale isEqualToString:@"WSCALE"] && item.isPriceAtPOS.boolValue == FALSE)
    {
        for (Item_Price_MD *price_md in item.itemToPriceMd)
        {
            NSMutableDictionary *price_Md_dictionary = [[NSMutableDictionary alloc]init];
            price_Md_dictionary[@"Qty"] = [NSString stringWithFormat:@"%ld",(long)price_md.qty.integerValue];
            price_Md_dictionary[@"applyPrice"] = price_md.applyPrice;
            
            NSString *priceType = [NSString stringWithFormat:@"%@",price_md.applyPrice];
            NSNumber *priceValue = 0;
            if ([priceType isEqualToString:@"PriceA"])
            {
                priceValue = price_md.priceA;
            }
            else if ([priceType isEqualToString:@"PriceB"])
            {
                priceValue = price_md.priceB;
                
            }
            else if ([priceType isEqualToString:@"PriceC"])
            {
                priceValue = price_md.priceC;
            }
            else
            {
                priceValue = price_md.unitPrice;
            }
            
            NSPredicate *itemCodePredicate = [NSPredicate predicateWithFormat:@"DIS_Qty = %@", price_md.qty];
            NSArray *filteredArray = [discountArray filteredArrayUsingPredicate:itemCodePredicate];
            if (filteredArray.count > 0)
            {
                NSMutableDictionary *filterdDictionary = filteredArray.firstObject;
                if ([filterdDictionary[@"DIS_UnitPrice"] floatValue]  > priceValue.floatValue && !(priceValue.floatValue == 0)  && price_md.qty.floatValue > 0)
                {
                    filterdDictionary[@"DIS_UnitPrice"] = priceValue;
                    filterdDictionary[@"DIS_Qty"] = price_md.qty;
                    filterdDictionary[@"DiscountAddedKey"] = @"DiscountAddedFromPriceMD";
                }
            }
            else
            {
                if(!(priceValue.floatValue == 0) && price_md.qty.floatValue > 0)
                {
                    NSMutableDictionary *discountAddDictionary = [[NSMutableDictionary alloc]init];
                    discountAddDictionary[@"DIS_Qty"] = price_md.qty;
                    discountAddDictionary[@"DIS_UnitPrice"] = priceValue;
                    discountAddDictionary[@"DiscountAddedKey"] = @"DiscountAddedFromPriceMD";
                    [discountArray addObject:discountAddDictionary];
                }
            }
        }
    }

    
}

- (NSMutableArray*)sortDiscountArrayOnDiscountQuantity:(NSArray*)itmDiscountArray
{
    // first array order by discount array in desc (max Qty wise)
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"DIS_Qty"
                                                 ascending:NO ];
    NSArray *sortDescriptors = [@[sortDescriptor]mutableCopy];
    NSArray *sortedArray = [itmDiscountArray sortedArrayUsingDescriptors:sortDescriptors];
    
    return [sortedArray mutableCopy];
}

- (NSMutableArray*)sortBillReceiptArrayOnItemQuantity:(NSArray*)billReceiptArray key:(NSString*)key
{
    // reminder process
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:key
                                                 ascending:NO ];
    NSArray *sortDescriptors = [@[sortDescriptor]mutableCopy];
    NSArray *sortedArray = [billReceiptArray sortedArrayUsingDescriptors:sortDescriptors];
    return [sortedArray mutableCopy];
}

- (void)calculateSimpleDiscount:(int)itemCodeId
{
    NSString *strItemId=[NSString stringWithFormat:@"%d", itemCodeId];
    Item *item = [_updateManager fetchItemFromDBWithItemId:strItemId shouldCreate:NO moc:_moc];

    NSInteger itemCode = item.itemCode.integerValue;

    [self prepareDataForCalculations];

    int iqty = [self totalQuantityForItemCode:itemCode];

    NSMutableArray *itmDiscountData;
    itmDiscountData = [self applicableDiscountData:itemCode];

    if(itmDiscountData.count>0)
    {

        int TotalQty=iqty;
        int avaibleQty=iqty;
        int usedQty=0;
        int idescQty=0;
        int reminder=0;
        itmDiscountData = [self sortDiscountArrayOnDiscountQuantity:itmDiscountData];

        for (int iMaxQty=0; iMaxQty<itmDiscountData.count; iMaxQty++)
        {
            idescQty=[[itmDiscountData[iMaxQty] valueForKey:@"DIS_Qty"] intValue];
            if (!(idescQty==0))
            {

                if(avaibleQty >= idescQty)
                {
                    float price=[[itmDiscountData[iMaxQty]valueForKey:@"DIS_UnitPrice"]floatValue];

                    reminder=avaibleQty/idescQty;
                  

                    int applyQty=idescQty *reminder;
                    _billReceiptArray = [self sortBillReceiptArrayOnItemQuantity:_billReceiptArray key:@"itemQty"];


                    for (int iRcptData=0; iRcptData<_billReceiptArray.count; iRcptData++)
                    {
                        NSMutableDictionary *itemRcptDisc=_billReceiptArray[iRcptData];

//                          price = price * reminder * idescQty + ((avaibleQty - reminder*idescQty)*[[itemRcptDisc objectForKey:@"ItemBasicPrice"] floatValue]);
                        
                        if ([[itemRcptDisc valueForKey:@"IsPriceEdited"] isEqualToString:@"1"]) {
                            // For this entry price was edited.
                            // Ignore this entry
                            continue;
                        }


                        // if condition required... (before receipt array apply in discount)
                        int iflg=[itemRcptDisc[@"discFlg"]intValue];
                        if(iflg==0)
                        {
                            int ircptItemId = [itemRcptDisc[@"itemId"]intValue];

                            Item *ircptitem = [_updateManager fetchItemFromDBWithItemId:[NSString stringWithFormat:@"%d", ircptItemId] shouldCreate:NO moc:_moc];
                            if (ircptitem.pos_DISCOUNT.integerValue == 0)
                            {
                                if(ircptItemId==itemCode)
                                {
                                    if(applyQty>0)
                                    {
                                        int iItemQty=[itemRcptDisc[@"itemQty"]intValue];

                                        if(applyQty>=iItemQty)
                                        {
                                            usedQty+=iItemQty;
                                            applyQty = applyQty-iItemQty;
                                            itemRcptDisc[@"discFlg"] = @"1";
                                            float itemBasicPrice = [itemRcptDisc[@"ItemBasicPrice"] floatValue];

                                            float avgPrice = price/idescQty;
                                            //NSString *sPrice = [NSString stringWithFormat:@"%.3f",avgPrice];
                                            itemRcptDisc[@"itemPrice"] = @(avgPrice);
                                            float itemDiscountPrice = itemBasicPrice-avgPrice;
                                            NSString *sDiscountPrice = [NSString stringWithFormat:@"%f",itemDiscountPrice];

                                            itemRcptDisc[@"ItemDiscount"] = sDiscountPrice;
                                            itemRcptDisc[@"isBasicDiscounted"] = @"1";

                                            float  totalItemPercenatge = itemDiscountPrice / itemBasicPrice * 100;
//                                            totalItemPercenatge = totalItemPercenatge / [[itemRcptDisc objectForKey:@"itemQty"]intValue];
                                            itemRcptDisc[@"ItemDiscountPercentage"] = @(totalItemPercenatge);
                                            [itemRcptDisc removeObjectForKey:@"PriceAtPos"];

                                            avaibleQty = TotalQty-usedQty;
                                        }
                                    }
                                    else
                                    {
                                        itemRcptDisc[@"discFlg"] = @"0";
                                        [self resetDiscountAndPrice:itemRcptDisc];
                                    }

                                }
                            }

                        }




                    }

                }
            }
        }
        NSSortDescriptor *sortrcptArray;
        sortrcptArray = [[NSSortDescriptor alloc] initWithKey:@"itemRowId"
                                                    ascending:YES ];
        NSArray *sortarray = [@[sortrcptArray]mutableCopy];
        NSArray *sortedrcptArray;
        sortedrcptArray = [[_billReceiptArray sortedArrayUsingDescriptors:sortarray]mutableCopy];
        
        [_billReceiptArray removeAllObjects];
        _billReceiptArray =[sortedrcptArray mutableCopy];
    }
}

#pragma mark - Mixmatch Discount methods
-(NSMutableArray *)getNumberOfItems :(NSMutableArray*)responseArray withKey:(NSString *)keyName
{
    NSMutableArray  *totalItemArray = [[NSMutableArray alloc]init];

    for (int i=0; i<responseArray.count; i++)
    {
        NSString *itemId = [responseArray[i] valueForKey:keyName];
        if (![totalItemArray containsObject:itemId])
        {
            [totalItemArray addObject:itemId];
        }
    }
    return totalItemArray;
}

- (void)calculateMixMatchXYDiscountForBillEntries:(NSMutableArray *)billEntries forItemX:(Item *)itemX withItemY:(Item *)itemY isApplicable:(BOOL)isApplicable xQuantity:(NSInteger)xQuntity
{
    NSInteger quantity = [[billEntries valueForKeyPath:@"@sum.itemQty"] integerValue];
    NSNumber *totalQty = [billEntries valueForKeyPath:@"@sum.itemQty"];

    //    if (itemX.itemMixMatchDisc.quantityY.floatValue > quantity) {
    //        // Discount not applicable
    //        return;
    //    }


    NSInteger applicationFactor =  quantity / itemX.itemMixMatchDisc.quantityY.integerValue;
    NSInteger maxapplicationFactor =  xQuntity / itemX.itemMixMatchDisc.quantityX.integerValue;

    applicationFactor = MIN(maxapplicationFactor, applicationFactor);

    CGFloat totalDiscount=0.00;



    switch (itemX.itemMixMatchDisc.discCode.integerValue)
    {
        case MIX_MATCH_DISCOUNT_BUY_X_GET_Y_FOR_X_SALES_PRICE:
        {
            totalDiscount = itemX.itemMixMatchDisc.amount.floatValue * applicationFactor ;
        }
            break;
        case MIX_MATCH_DISCOUNT_BUY_X_GET_Y_FOR_X_PERCENTAGE_OFF:
        {
            totalDiscount = itemY.salesPrice.floatValue * applicationFactor * itemX.itemMixMatchDisc.quantityY.integerValue * itemX.itemMixMatchDisc.amount.floatValue  * 0.01;
        }
            break;
    }

    CGFloat itemPrice = (itemY.salesPrice.floatValue * quantity) - totalDiscount;

    for (int j = 0; j < billEntries.count; j++)
    {
        NSMutableDictionary *uniqueDict = billEntries[j];
        CGFloat perItemPrice = itemPrice  / totalQty.integerValue;
        CGFloat perItemDiscount = totalDiscount * [[uniqueDict valueForKey:@"itemQty"] integerValue] / totalQty.integerValue;
        uniqueDict[@"itemPrice"] = @(perItemPrice);
        uniqueDict[@"ItemDiscount"] = [NSString stringWithFormat:@"%f",perItemDiscount];

        float  totalItemPercenatge = perItemDiscount / [[uniqueDict valueForKey:@"ItemBasicPrice"] floatValue]*100;
        totalItemPercenatge = totalItemPercenatge / [[uniqueDict valueForKey:@"itemQty"] integerValue];
        uniqueDict[@"ItemDiscountPercentage"] = @(totalItemPercenatge);
        [uniqueDict removeObjectForKey:@"PriceAtPos"];

    }
}

- (void)resetDiscountAndPrice:(NSMutableDictionary *)billEntryDictionary
{
    billEntryDictionary[@"ItemDiscount"] = @"0";
    billEntryDictionary[@"isBasicDiscounted"] = @"0";
    billEntryDictionary[@"itemPrice"] = @([billEntryDictionary[@"ItemBasicPrice"] floatValue]);
    billEntryDictionary[@"ItemDiscountPercentage"] = @(0);

    billEntryDictionary[@"UnProcessedQuantity"] = @([billEntryDictionary[@"itemQty"] integerValue]);
    billEntryDictionary[@"TotalDiscount"] = @(0);
}


- (void)calculateMixMatchDiscountForBillEntries:(NSMutableArray *)billEntries forItem:(Item *)item
{
    NSInteger totalQty = [[billEntries valueForKeyPath:@"@sum.itemQty"] integerValue];
    
    NSInteger applicationFactor =  totalQty / item.itemMixMatchDisc.mix_Match_Qty.integerValue;
    NSInteger applyDiscountQty = item.itemMixMatchDisc.mix_Match_Qty.integerValue * applicationFactor;
    
    
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"itemQty"
                                                 ascending:NO ];
    NSArray *sortDescriptors = [@[sortDescriptor]mutableCopy];
    NSArray *sortedArray;
    sortedArray = [[billEntries sortedArrayUsingDescriptors:sortDescriptors]mutableCopy];
    [billEntries removeAllObjects];
    billEntries =[sortedArray mutableCopy];
    
    
    NSInteger mix_MatchQty = item.itemMixMatchDisc.mix_Match_Qty.integerValue * applicationFactor;
    NSInteger uniqueTotalQty = totalQty;
    
    
    for (int j=0; j<billEntries.count; j++)
    {
        NSMutableDictionary *uniqueDict = billEntries[j];
        
        CGFloat totalDiscount = 0.00;
        CGFloat discountForThisBillEntry = 0.00;
        CGFloat itemPriceForThisBillEntry = 0.00;

        switch (item.itemMixMatchDisc.discCode.integerValue)
        {
            case MIX_MATCH_DISCOUNT_SALES_PRICE:
                
                totalDiscount = item.itemMixMatchDisc.mix_Match_Amt.floatValue * applicationFactor ;
                discountForThisBillEntry = totalDiscount * [billEntries[j][@"itemQty"]intValue] / applyDiscountQty;
                
                itemPriceForThisBillEntry = ([[uniqueDict valueForKey:@"ItemBasicPrice"] floatValue] * [billEntries[j][@"itemQty"]intValue]) - discountForThisBillEntry;
                break;
                
            case MIX_MATCH_DISCOUNT_PERCENTAGE_OFF:
                
                totalDiscount = [[uniqueDict valueForKey:@"ItemBasicPrice"]floatValue] *applicationFactor * item.itemMixMatchDisc.mix_Match_Amt.floatValue  * 0.01 ;

                
                discountForThisBillEntry =  totalDiscount * [billEntries[j][@"itemQty"]intValue]  ;
                
                itemPriceForThisBillEntry = ([[uniqueDict valueForKey:@"ItemBasicPrice"] floatValue]*applicationFactor * [billEntries[j][@"itemQty"]intValue]) - totalDiscount * [billEntries[j][@"itemQty"]intValue] ;
                
                discountForThisBillEntry = discountForThisBillEntry / applicationFactor ;
                
                itemPriceForThisBillEntry = itemPriceForThisBillEntry / applicationFactor;
                break;
        }
        
       
        
        if(mix_MatchQty>0)
        {
            int iItemQty=[billEntries[j][@"itemQty"]intValue];
            if (mix_MatchQty >=  iItemQty)
            {
                if(uniqueTotalQty>=mix_MatchQty)
                {
                    uniqueTotalQty = uniqueTotalQty -iItemQty;
                    mix_MatchQty = mix_MatchQty - iItemQty;
                    CGFloat perItemPrice = itemPriceForThisBillEntry  / [billEntries[j][@"itemQty"]intValue];
                    CGFloat perItemDiscount = discountForThisBillEntry / [[uniqueDict valueForKey:@"itemQty"] integerValue] ;
                    
                    uniqueDict[@"itemPrice"] = @(perItemPrice);
                    uniqueDict[@"ItemDiscount"] = [NSString stringWithFormat:@"%f",perItemDiscount];
                    
                    float  totalItemPercenatge = perItemDiscount / [[uniqueDict valueForKey:@"ItemBasicPrice"] floatValue]*100;
                //    totalItemPercenatge = totalItemPercenatge / [[uniqueDict valueForKey:@"itemQty"] integerValue];
                    uniqueDict[@"ItemDiscountPercentage"] = @(totalItemPercenatge);
                    [uniqueDict removeObjectForKey:@"PriceAtPos"];

                }
            }
            else
            {
                if (mix_MatchQty > 0)
                {
                    if (j+1 == billEntries.count)
                    {
                        uniqueTotalQty = uniqueTotalQty -iItemQty;
                        mix_MatchQty = mix_MatchQty - iItemQty;
                        CGFloat perItemPrice = itemPriceForThisBillEntry  / [billEntries[j][@"itemQty"]intValue];
                        CGFloat perItemDiscount = discountForThisBillEntry / [[uniqueDict valueForKey:@"itemQty"] integerValue] ;
                        
                        uniqueDict[@"itemPrice"] = @(perItemPrice);
                        uniqueDict[@"ItemDiscount"] = [NSString stringWithFormat:@"%f",perItemDiscount];
                        
                        float  totalItemPercenatge = perItemDiscount / [[uniqueDict valueForKey:@"ItemBasicPrice"] floatValue]*100;
                     //   totalItemPercenatge = totalItemPercenatge / [[uniqueDict valueForKey:@"itemQty"] integerValue];
                        uniqueDict[@"ItemDiscountPercentage"] = @(totalItemPercenatge);
                        [uniqueDict removeObjectForKey:@"PriceAtPos"];

                    }
                    else
                    {
                        [self resetDiscountAndPrice:uniqueDict];
                    }
                }
                else
                {
                    [self resetDiscountAndPrice:uniqueDict];
                }
            }
            
        }
        else
        {
            [self resetDiscountAndPrice:uniqueDict];
        }
    }
    
    
}


- (void)calculateMixMatchDiscountForBillEntries_old:(NSMutableArray *)billEntries forItem:(Item *)item
{
    NSInteger totalQty = [[billEntries valueForKeyPath:@"@sum.itemQty"] integerValue];
    NSInteger applicationFactor =  totalQty / item.itemMixMatchDisc.mix_Match_Qty.integerValue;
    NSInteger applyDiscountQty = item.itemMixMatchDisc.mix_Match_Qty.integerValue * applicationFactor;
    CGFloat itemPrice = [item discountedTotalPriceForQuantity:applyDiscountQty];
    CGFloat totalDiscount = [item totalDiscountForQuantity:applyDiscountQty];

    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"itemQty"
                                                 ascending:NO ];
    NSArray *sortDescriptors = [@[sortDescriptor]mutableCopy];
    NSArray *sortedArray;
    sortedArray = [[billEntries sortedArrayUsingDescriptors:sortDescriptors]mutableCopy];
    [billEntries removeAllObjects];
    billEntries =[sortedArray mutableCopy];

    NSInteger mix_MatchQty = item.itemMixMatchDisc.mix_Match_Qty.integerValue * applicationFactor;
    NSInteger uniqueTotalQty = totalQty;

    for (int j=0; j<billEntries.count; j++)
    {
        NSMutableDictionary *uniqueDict = billEntries[j];

        if(mix_MatchQty>0)
        {
            int iItemQty=[billEntries[j][@"itemQty"]intValue];
            if (mix_MatchQty >=  iItemQty)
            {
                if(uniqueTotalQty>=mix_MatchQty)
                {
                    uniqueTotalQty = uniqueTotalQty -iItemQty;
                    mix_MatchQty = mix_MatchQty - iItemQty;
                    CGFloat perItemPrice = itemPrice  / applyDiscountQty;
                    CGFloat perItemDiscount = totalDiscount * [[uniqueDict valueForKey:@"itemQty"] integerValue] / applyDiscountQty;

                    uniqueDict[@"itemPrice"] = @(perItemPrice);
                    uniqueDict[@"ItemDiscount"] = [NSString stringWithFormat:@"%f",perItemDiscount];

                    float  totalItemPercenatge = perItemDiscount / [[uniqueDict valueForKey:@"ItemBasicPrice"] floatValue]*100;
                    totalItemPercenatge = totalItemPercenatge / [[uniqueDict valueForKey:@"itemQty"] integerValue];
                    uniqueDict[@"ItemDiscountPercentage"] = @(totalItemPercenatge);
                    [uniqueDict removeObjectForKey:@"PriceAtPos"];

                }
            }
            else
            {
                if (mix_MatchQty > 0)
                {
                    if (j+1 == billEntries.count)
                    {
                        uniqueTotalQty = uniqueTotalQty -iItemQty;
                        mix_MatchQty = mix_MatchQty - iItemQty;
                        CGFloat perItemPrice = itemPrice  / applyDiscountQty;
                        CGFloat perItemDiscount = totalDiscount * [[uniqueDict valueForKey:@"itemQty"] integerValue] / applyDiscountQty;

                        uniqueDict[@"itemPrice"] = @(perItemPrice);
                        uniqueDict[@"ItemDiscount"] = [NSString stringWithFormat:@"%f",perItemDiscount];

                        float  totalItemPercenatge = perItemDiscount / [[uniqueDict valueForKey:@"ItemBasicPrice"] floatValue]*100;
                        totalItemPercenatge = totalItemPercenatge / [[uniqueDict valueForKey:@"itemQty"] integerValue];
                        uniqueDict[@"ItemDiscountPercentage"] = @(totalItemPercenatge);
                        [uniqueDict removeObjectForKey:@"PriceAtPos"];

                    }
                    else
                    {
                        [self resetDiscountAndPrice:uniqueDict];
                    }
                }
                else
                {
                    [self resetDiscountAndPrice:uniqueDict];
                }
            }

        }
        else
        {
            [self resetDiscountAndPrice:uniqueDict];
        }
    }


}

-(void)itemMixMatchDiscountCalculation
{
    if(_billReceiptArray.count>0)
    {
        NSMutableArray *totalItemArray = [self getNumberOfItems:_billReceiptArray withKey:@"mixMatchId"];

        for (int i=0; i<totalItemArray.count; i++)
        {
            NSPredicate *itemPredicate = [NSPredicate predicateWithFormat:@"mixMatchId == %@", totalItemArray[i]];
            NSMutableArray *uniqueItemArray = [[_billReceiptArray filteredArrayUsingPredicate:itemPredicate] mutableCopy ];

            NSInteger ircptItemId=[[uniqueItemArray.firstObject valueForKey:@"itemId"] integerValue];

            Item *item = [_updateManager fetchItemFromDBWithItemId:[NSString stringWithFormat:@"%ld",(long)ircptItemId] shouldCreate:NO moc:_moc];
            if (item.itemMixMatchDisc)
            {
                switch (item.itemMixMatchDisc.discCode.integerValue)
                {
                    case MIX_MATCH_DISCOUNT_SALES_PRICE:
                    case MIX_MATCH_DISCOUNT_PERCENTAGE_OFF:
                        
                        [self calculateMixMatchDiscountForBillEntries:uniqueItemArray forItem:item];
                        break;
                    case MIX_MATCH_DISCOUNT_BUY_X_GET_Y_FOR_X_SALES_PRICE:
                    case MIX_MATCH_DISCOUNT_BUY_X_GET_Y_FOR_X_PERCENTAGE_OFF:
                    {
                        NSNumber *totalQty = [uniqueItemArray valueForKeyPath:@"@sum.itemQty"];

                        //                        if (totalQty.integerValue > item.itemMixMatchDisc.mix_Match_Qty.integerValue)
                        {
                            itemPredicate = [NSPredicate predicateWithFormat:@"itemId == %@", [NSString stringWithFormat:@"%ld",(long)item.itemMixMatchDisc.code.integerValue]];
                            uniqueItemArray = [[_billReceiptArray filteredArrayUsingPredicate:itemPredicate] mutableCopy];
                            NSInteger code = item.itemMixMatchDisc.code.integerValue;

                            Item *itemY = [_updateManager fetchItemFromDBWithItemId:[NSString stringWithFormat:@"%ld",(long)code] shouldCreate:NO moc:_moc];

                            [self calculateMixMatchXYDiscountForBillEntries:uniqueItemArray forItemX:item withItemY:itemY isApplicable:(totalQty.integerValue >= item.itemMixMatchDisc.quantityX.integerValue) xQuantity:totalQty.integerValue ];
                        }
                    }
                        break;
                    default:
                        break;
                }


            }
        }

    }

}

-(void)itemCategoryMixMatchDiscountCalculation
{
    if(_billReceiptArray.count>0)
    {
        NSMutableArray *totalItemArray = [self getNumberOfItems:_billReceiptArray withKey:@"categoryId"];

        for (int i=0; i<totalItemArray.count; i++)
        {
            NSPredicate *itemPredicate = [NSPredicate predicateWithFormat:@"categoryId == %@", totalItemArray[i]];
            NSMutableArray *uniqueItemArray = [[_billReceiptArray filteredArrayUsingPredicate:itemPredicate] mutableCopy ];

            NSInteger ircptItemId=[[uniqueItemArray.firstObject valueForKey:@"itemId"] integerValue];

            Item *item = [_updateManager fetchItemFromDBWithItemId:[NSString stringWithFormat:@"%ld", (long)ircptItemId] shouldCreate:NO moc:_moc];
            if (item.itemMixMatchDisc)
            {
                switch (item.itemMixMatchDisc.discCode.integerValue)
                {
                    case MIX_MATCH_DISCOUNT_SALES_PRICE:
                    case MIX_MATCH_DISCOUNT_PERCENTAGE_OFF:
                        [self calculateMixMatchDiscountForBillEntries:uniqueItemArray forItem:item];
                        break;
                    case MIX_MATCH_DISCOUNT_BUY_X_GET_Y_FOR_X_SALES_PRICE:
                    case MIX_MATCH_DISCOUNT_BUY_X_GET_Y_FOR_X_PERCENTAGE_OFF:
                    {
                        NSNumber *totalQty = [uniqueItemArray valueForKeyPath:@"@sum.itemQty"];

                        //                        if (totalQty.integerValue > item.itemMixMatchDisc.mix_Match_Qty.integerValue)
                        {
                            itemPredicate = [NSPredicate predicateWithFormat:@"categoryId == %@",item.itemMixMatchDisc.code];
                            uniqueItemArray = [[_billReceiptArray filteredArrayUsingPredicate:itemPredicate] mutableCopy];
                            NSInteger code = [[uniqueItemArray.firstObject valueForKey:@"itemId"] integerValue];

                            Item *itemY = [_updateManager fetchItemFromDBWithItemId:[NSString stringWithFormat:@"%ld",(long)code] shouldCreate:NO moc:_moc];

                            [self calculateCategoryMixMatchXYDiscountForBillEntries:uniqueItemArray forItemX:item withItemY:itemY isApplicable:(totalQty.integerValue >= item.itemMixMatchDisc.quantityX.integerValue) xQuantity:totalQty.integerValue ];
                        }
                    }
                        break;
                    default:
                        break;
                }


            }
        }

    }

}
- (void)calculateCategoryMixMatchXYDiscountForBillEntries:(NSMutableArray *)billEntries forItemX:(Item *)itemX withItemY:(Item *)itemY isApplicable:(BOOL)isApplicable xQuantity:(NSInteger)xQuntity
{
    NSInteger quantity = [[billEntries valueForKeyPath:@"@sum.itemQty"] integerValue];
    NSNumber *totalQty = [billEntries valueForKeyPath:@"@sum.itemQty"];

    //    if (itemX.itemMixMatchDisc.quantityY.floatValue > quantity) {
    //        // Discount not applicable
    //        return;
    //    }


    NSInteger applicationFactor =  quantity / itemX.itemMixMatchDisc.quantityY.integerValue;
    NSInteger maxapplicationFactor =  xQuntity / itemX.itemMixMatchDisc.quantityX.integerValue;

    applicationFactor = MIN(maxapplicationFactor, applicationFactor);

    CGFloat totalDiscount=0.00;

    for (int j = 0; j < billEntries.count; j++)
    {
        NSMutableDictionary *uniqueDict = billEntries[j];

        switch (itemX.itemMixMatchDisc.discCode.integerValue)
        {
            case MIX_MATCH_DISCOUNT_BUY_X_GET_Y_FOR_X_SALES_PRICE:
            {
                totalDiscount = itemX.itemMixMatchDisc.amount.floatValue * applicationFactor ;
            }
                break;
            case MIX_MATCH_DISCOUNT_BUY_X_GET_Y_FOR_X_PERCENTAGE_OFF:
            {
                totalDiscount = [[uniqueDict valueForKey:@"ItemBasicPrice"]floatValue] * applicationFactor * itemX.itemMixMatchDisc.quantityY.integerValue * itemX.itemMixMatchDisc.amount.floatValue  * 0.01;
            }
                break;
        }


        CGFloat itemPrice = ([[uniqueDict valueForKey:@"ItemBasicPrice"] floatValue] * quantity) - totalDiscount;

        CGFloat perItemPrice = itemPrice  / totalQty.integerValue;
        CGFloat perItemDiscount = totalDiscount * [[uniqueDict valueForKey:@"itemQty"] integerValue] / totalQty.integerValue;
        uniqueDict[@"itemPrice"] = @(perItemPrice);
        uniqueDict[@"ItemDiscount"] = [NSString stringWithFormat:@"%f",perItemDiscount];

        float  totalItemPercenatge = perItemDiscount / [[uniqueDict valueForKey:@"ItemBasicPrice"] floatValue]*100;
        totalItemPercenatge = totalItemPercenatge / [[uniqueDict valueForKey:@"itemQty"] integerValue];
        uniqueDict[@"ItemDiscountPercentage"] = @(totalItemPercenatge);
        [uniqueDict removeObjectForKey:@"PriceAtPos"];

    }
}

#pragma mark - Date methods
-(NSDate*)getDate :(NSString *)dateString
{
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    dateFormater.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
    dateFormater.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    NSDate *currentDate = [dateFormater dateFromString:dateString];
    return currentDate;
}

-(NSDate *)setFormatter :(NSDate *)date
{
    NSDate *currDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *dateString = [dateFormatter stringFromDate:currDate];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    NSDate *currentDate = [dateFormatter dateFromString:dateString];
    return currentDate;
}

- (BOOL)isDate:(NSDate *)date inRangeFirstDate:(NSDate *)firstDate lastDate:(NSDate *)lastDate
{
    return [date compare:firstDate] == NSOrderedDescending &&
    [date compare:lastDate]  == NSOrderedAscending;
}

-(NSDate*)getTime :(NSString *)dateString
{
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    dateFormater.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
    // [dateFormater setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    NSDate *currentDate = [dateFormater dateFromString:dateString];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"HH:mm:ss";
    NSString *ChangedateString = [dateFormatter stringFromDate:currentDate];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    NSDate *Date = [dateFormatter dateFromString:ChangedateString];

    return Date;
}

-(NSDate *)setTimeFormatter :(NSDate *)date
{
    NSDate *currDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"HH:mm:ss";

    NSString *dateString = [dateFormatter stringFromDate:currDate];

    NSDateFormatter *dateFormatterSecond = [[NSDateFormatter alloc]init];
    dateFormatterSecond.dateFormat = @"HH:mm:ss";
    dateFormatterSecond.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    NSDate *currentDate = [dateFormatterSecond dateFromString:dateString];
    return currentDate;
}


#pragma mark - Grouping and Other restructuring
- (NSInteger)quantityFromBunch:(NSArray*)anArray forSelectionArray:(NSArray*)selectionArray {
    NSInteger quantity = 0;

    for (int index = 0; index < anArray.count; index++) {
        NSDictionary *billEntryDictionary = anArray[index];
        NSInteger currentQuantity = [billEntryDictionary[@"UnProcessedQuantity"] integerValue];
        NSInteger currentSelection = [selectionArray[index] integerValue];
        quantity += (currentQuantity * currentSelection);
    }
    return quantity;
}

- (NSInteger)quantityFromBunch:(NSArray*)anArray {
    NSInteger quantity = 0;

    for (int index = 0; index < anArray.count; index++) {
        NSDictionary *billEntryDictionary = anArray[index];
        NSInteger currentQuantity = [billEntryDictionary[@"UnProcessedQuantity"] integerValue];
        quantity += currentQuantity;
    }
    return quantity;
}

- (NSArray*)groupBunch:(NSArray*)anArray selectionArray:(NSArray*)selectionArray groupingQuantity:(NSInteger)groupingQuantity index:(NSInteger)index {

    if (index >= anArray.count) {
        return selectionArray;
    }
    NSArray *selectionArray_0 = [self groupBunch:anArray selectionArray:selectionArray groupingQuantity:groupingQuantity index:(index + 1)];
    NSMutableArray *selectionArray_1 = [selectionArray mutableCopy];
    selectionArray_1[index] = @(1);

    selectionArray_1 = [[self groupBunch:anArray selectionArray:selectionArray_1 groupingQuantity:groupingQuantity index:(index + 1)] mutableCopy];

    //    NSInteger quantity1 = [self quantityFromBunch:anArray forSelectionArray:selectionArray_0];
    NSInteger quantity2 = [self quantityFromBunch:anArray forSelectionArray:selectionArray_1];

    NSArray *updatedSelectionArray;
    if ((quantity2 != 0) && ((quantity2 % groupingQuantity) == 0)) {
        updatedSelectionArray = selectionArray_1;
    } else {
        updatedSelectionArray = selectionArray_0;
    }

    return updatedSelectionArray;
}

- (NSArray*)bunchFromArray:(NSArray*)anArray selectionArray:(NSArray*)selectionArray selected:(BOOL)selected {
    NSMutableArray *requestedBunch = [NSMutableArray array];

    for (int index = 0; index < anArray.count; index++) {
        if (selected && ([selectionArray[index] integerValue] == 1)) {
            [requestedBunch addObject:anArray[index]];
        } else if (!selected && ([selectionArray[index] integerValue] == 0)) {
            [requestedBunch addObject:anArray[index]];
        }
    }

    return requestedBunch;
}

- (NSArray*)filterArray:(NSArray*)array forkey:(NSString *)key withValue:(id)value {
    NSPredicate *itemCodePredicate = [NSPredicate predicateWithFormat:@"itemId = %@", value];
    NSArray *filteredArray = [array filteredArrayUsingPredicate:itemCodePredicate];

    return filteredArray;
}

- (void)calculateQDForItem:(Item*)item {
    // Clear the carry forward if any
    _carryForwardBillEntry = nil;
    _carryForwardQuantity = 0;

    // Get bunch with Item Code
    NSString *key = @"itemId";
    NSString *value = [NSString stringWithFormat:@"%@", item.itemCode];

    // Get Bunch for this item
    NSArray *bunchToProcess = [self filterArray:_billReceiptArray forkey:key withValue:value];

    for (NSMutableDictionary *billEntryDictionary in bunchToProcess) {
        [self resetDiscountAndPrice:billEntryDictionary];
    }
    // Calculate QD on entire bunch
    [self calculateQDForBunch:bunchToProcess forItem:item];
}

- (void)calculateQDForBunch:(NSArray*)bunchToProcess forItem:(Item*)item {

    NSMutableArray *tempArray = [self sortBillReceiptArrayOnItemQuantity:bunchToProcess key:@"UnProcessedQuantity"];
    bunchToProcess = [NSArray arrayWithArray:tempArray];
    // Get QD Entries for this item
    NSMutableArray *qdDiscountEntries = [self applicableDiscountData:item.itemCode.integerValue];
    qdDiscountEntries = [self sortDiscountArrayOnDiscountQuantity:qdDiscountEntries];

    if (qdDiscountEntries.count == 0) {
        // There are no discount entries
        return;
    }

    // Total quantity of this bunch
    NSInteger totalBunchQuantity = [self quantityFromBunch:bunchToProcess];
    NSDictionary *applicableDiscountDictionary;

    for (NSDictionary *qdDiscountDictionary in qdDiscountEntries) {
        NSInteger groupingQuantity = [qdDiscountDictionary[@"DIS_Qty"] integerValue];

        // Need to consider _carryForwardQuantity
        if ((totalBunchQuantity + _carryForwardQuantity) >= groupingQuantity) {
            // This is QD entry that is applicable
            applicableDiscountDictionary = qdDiscountDictionary;
            break;
        }
    }

    if (applicableDiscountDictionary == nil) {
        // There is QD applicable on this bunch
        return;
    }

    BOOL originalBunch = YES;
#define IS_QUANTITY_EDITED_KEY @"IsQtyEdited"
    NSMutableArray *billEntriesExcludingSwipedEntries = [NSMutableArray array];
    // Need to check if quantity was edited
    for (NSMutableDictionary *billEntry in bunchToProcess) {
        BOOL includeInCalculation = YES;
        // if there is Price At POS
        if (billEntry[@"PriceAtPos"]) {
            // This entry has Price Set at POS
            // Now check if quantity was edited
            if ([billEntry[IS_QUANTITY_EDITED_KEY] boolValue] == YES) {
                // Quantity was edited
                // Remove PriceAtPOS Key
                [billEntry removeObjectForKey:@"PriceAtPos"];
                [billEntry removeObjectForKey:IS_QUANTITY_EDITED_KEY];
            } else {
                // Quantity was not edited
                includeInCalculation = NO;
            }
        }

        if (includeInCalculation) {
            [billEntriesExcludingSwipedEntries addObject:billEntry];
        } else {
//            originalBunch = NO;
        }
    }

//    originalBunch = YES;

    if (!originalBunch) {
        // Should process bunch excludeing Swiped (Price At POS) entries
        [self calculateQDForBunch:billEntriesExcludingSwipedEntries forItem:item];
        return;
    }

    // Get the quantity for grouping
    NSInteger groupingQuantity = [applicableDiscountDictionary[@"DIS_Qty"] integerValue];

//    if ((totalBunchQuantity % groupingQuantity) == 0) {
//        // This is a perfect
//    } else if (totalBunchQuantity < groupingQuantity) {
//    } else {
//    }

    NSArray *selectionArray = [NSArray array];
    NSDictionary *unusedVariable;
    for (unusedVariable in bunchToProcess)
    {
        selectionArray = [selectionArray arrayByAddingObject:@(0)];
    }

    selectionArray = [self groupBunch:bunchToProcess selectionArray:selectionArray groupingQuantity:groupingQuantity index:0];

    NSArray *selectedBunch = [self bunchFromArray:bunchToProcess selectionArray:selectionArray selected:YES];

    if (selectedBunch.count > 0) {
        [self calculateQDForBunch:selectedBunch forItem:item forDiscountDictionary:applicableDiscountDictionary];

        [self calculateQDForBunch:bunchToProcess forItem:item];
        return;
    }


    NSArray *remainingBunch = [self bunchFromArray:bunchToProcess selectionArray:selectionArray selected:NO];

    if (remainingBunch.count <= 0) {
        return;
    }

    NSInteger remainingQuantity = [self quantityFromBunch:remainingBunch];

    if (remainingQuantity + _carryForwardQuantity >= groupingQuantity) {
        // Now what ???

        // Need to break down remaining bunch in parts

        NSInteger applicationFactor = (remainingQuantity + _carryForwardQuantity) / groupingQuantity;

        NSInteger nextBunchQuantity = applicationFactor * groupingQuantity;

        NSInteger quantitySum = 0;

        NSMutableArray *nextBunch = [NSMutableArray array];
        NSMutableArray *leftOverBunch = [NSMutableArray array];

        for (NSMutableDictionary *billEntryDictionary in remainingBunch) {
            if (quantitySum < nextBunchQuantity) {
                [nextBunch addObject:billEntryDictionary];
            } else {
                [leftOverBunch addObject:billEntryDictionary];
            }

            quantitySum += [billEntryDictionary[@"UnProcessedQuantity"] integerValue];
        }

        // Next bunch for same QD scheme
        [self calculateQDForBunch:nextBunch forItem:item forDiscountDictionary:applicableDiscountDictionary];

//        // Check if there is any other QD scheme applicable for
//        // leftOverBunch
//        if ([leftOverBunch count] > 0) {
//            [self calculateQDForBunch:leftOverBunch forItem:item];
//        } else if (_carryForwardBillEntry) {
//            // Still there is something left
//            _carryForwardBillEntry = nil;
//            _carryForwardQuantity = 0;
//
//            // Total quantity of this bunch
//            int totalBunchQuantity = [self quantityFromBunch:@[[nextBunch lastObject]]];
//            NSDictionary *applicableDiscountDictionary;
//
//            for (NSDictionary *qdDiscountDictionary in qdDiscountEntries) {
//                int groupingQuantity = [qdDiscountDictionary[@"DIS_Qty"] integerValue];
//
//                // Need to consider _carryForwardQuantity
//                if ((totalBunchQuantity + _carryForwardQuantity) >= groupingQuantity) {
//                    // This is QD entry that is applicable
//                    applicableDiscountDictionary = qdDiscountDictionary;
//                    break;
//                }
//            }
//
//            if (applicableDiscountDictionary == nil) {
//                // There is QD applicable on this bunch
//                return;
//            }
//
//            [self calculateQDForLast:[nextBunch lastObject] forItem:item forDiscountDictionary:applicableDiscountDictionary];
//        }
    }
//    else {
//        // Check if there is any other QD scheme applicable for
//        // remainingBunch
//        [self calculateQDForBunch:remainingBunch forItem:item];
//    }

    [self calculateQDForBunch:bunchToProcess forItem:item];
}

- (void)calculateQDForLast:(NSMutableDictionary*) billEntryDictionary forItem:(Item*)item forDiscountDictionary:(NSDictionary*)qdDiscountDictionary {
    {
        return;
        CGFloat unitSalesPrice = [billEntryDictionary[@"ItemBasicPrice"] floatValue];
        int billEntryQuantity = [billEntryDictionary[@"itemQty"] integerValue];
        int groupingQuantity = [qdDiscountDictionary[@"DIS_Qty"] integerValue];

        int excludeQuantity = billEntryQuantity % groupingQuantity;

        // Discount calculation is here
        CGFloat singleQuantityDiscount = [self singleQuantityQDPriceForDiscountDictionary:qdDiscountDictionary];
        if (unitSalesPrice < 0) {
            singleQuantityDiscount = -singleQuantityDiscount;
        }
        CGFloat qdOnSingleQuantity = unitSalesPrice - singleQuantityDiscount;

        CGFloat additionalDiscount = qdOnSingleQuantity * (billEntryQuantity - excludeQuantity);
        CGFloat qdOnThisEntry = ([billEntryDictionary[@"TotalDiscount"] floatValue]) + additionalDiscount;


        CGFloat totalSalesPrice = [billEntryDictionary[@"TotalPrice"] floatValue];

        CGFloat averageSalesPrice = (totalSalesPrice - additionalDiscount) / billEntryQuantity;

        billEntryDictionary[@"TotalPrice"] = @(totalSalesPrice - additionalDiscount);
        billEntryDictionary[@"TotalDiscount"] = @(qdOnThisEntry);
        billEntryDictionary[@"itemPrice"] = @(averageSalesPrice);
        billEntryDictionary[@"ItemDiscountPercentage"] = @(qdOnThisEntry / unitSalesPrice);

    }
}

- (void)calculateQDForBunch:(NSArray*)bunchToProcess forItem:(Item*)item forDiscountDictionary:(NSDictionary*)qdDiscountDictionary {

   /* NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"itemQty"
                                                                   ascending:NO ];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    bunchToProcess = [bunchToProcess sortedArrayUsingDescriptors:sortDescriptors];*/

    NSInteger billEntryIndex = 0;
    NSInteger billEntryCount = bunchToProcess.count;
    
    
    NSInteger groupingQuantity = [qdDiscountDictionary[@"DIS_Qty"] integerValue];
    NSInteger pendingBunchQuantity = [self quantityFromBunch:bunchToProcess];


    NSInteger leftOverQuantity = 0;

    if (_carryForwardBillEntry) {
        leftOverQuantity = _carryForwardQuantity;
    }
    pendingBunchQuantity += leftOverQuantity;

    // Start the loop now
    for (NSMutableDictionary *billEntryDictionary in bunchToProcess) {

        billEntryIndex++;

        NSInteger unProcessedQuantity = [billEntryDictionary[@"UnProcessedQuantity"] integerValue];

        CGFloat unitSalesPrice = [billEntryDictionary[@"ItemBasicPrice"] floatValue];
        NSInteger billEntryQuantity = [billEntryDictionary[@"itemQty"] integerValue];
        NSInteger totalQuantity = unProcessedQuantity + leftOverQuantity;

        if (pendingBunchQuantity >= groupingQuantity) {
            // Process full discount on billEntryQuantity

            // adjust values now
            pendingBunchQuantity -= ((totalQuantity / groupingQuantity) * groupingQuantity);
            leftOverQuantity = totalQuantity % groupingQuantity;

            NSInteger excludeQuantity = 0;

            if (billEntryIndex == billEntryCount) {
                excludeQuantity = totalQuantity % groupingQuantity;
            }

            // Discount calculation is here
            
            CGFloat singleQuantityDiscount = [self singleQuantityQDPriceForDiscountDictionary:qdDiscountDictionary];
            if (unitSalesPrice < 0) {
                singleQuantityDiscount = -singleQuantityDiscount;
            }
            CGFloat qdOnSingleQuantity = unitSalesPrice - singleQuantityDiscount;
            CGFloat qdOnThisEntry = qdOnSingleQuantity * (unProcessedQuantity - excludeQuantity);

            if (billEntryDictionary[@"PriceAtPos"]) {
                qdOnThisEntry = 0;
            }
            
            if (qdOnThisEntry != 0) {
                NSString *discountKeyValue = @"";
                NSString *discountTypeKeyValue = @"";
                NSNumber *discountId;
                if (qdDiscountDictionary[@"DiscountAddedKey"])
                {
                    discountKeyValue = @"Price_Md";
                    discountTypeKeyValue = @"Price_Md";
                    discountId = @(0);
                }
                else
                {
                    discountKeyValue = @"Quantity";
                    discountTypeKeyValue = @"Quantity";
                    discountId = qdDiscountDictionary[@"RowId"];
                }

                NSMutableArray *discountArray = [billEntryDictionary valueForKey:@"Discount"];
                
                NSMutableDictionary *qtyPriceMdDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                                     discountKeyValue, @"DiscountType",
                                                                     @(qdOnThisEntry ),@"Amount",
                                                                     discountTypeKeyValue,@"AppliedOn",
                                                                    discountId ,@"DiscountId",nil];
                [discountArray addObject:qtyPriceMdDictionary];
            }
            

            
            qdOnThisEntry += [billEntryDictionary[@"TotalDiscount"] floatValue];

            CGFloat totalSalesPrice = unitSalesPrice * billEntryQuantity;

            CGFloat averageSalesPrice = (totalSalesPrice - qdOnThisEntry) / billEntryQuantity;

            billEntryDictionary[@"TotalPrice"] = @(totalSalesPrice - qdOnThisEntry);

            billEntryDictionary[@"TotalDiscount"] = @(qdOnThisEntry);
            billEntryDictionary[@"itemPrice"] = @(averageSalesPrice);
            billEntryDictionary[@"ItemDiscount"] = @(qdOnThisEntry / [billEntryDictionary[@"itemQty"] integerValue]);


//            unProcessedQuantity -= excludeQuantity;
            billEntryDictionary[@"UnProcessedQuantity"] = @(excludeQuantity);
//            billEntryDictionary[@"TotalDiscount"] = @(0);


            NSString *itemDiscountPercentage = [NSString stringWithFormat:@"%f", qdOnThisEntry / unitSalesPrice*100];
            float Percentage = itemDiscountPercentage.floatValue  / [billEntryDictionary[@"itemQty"] integerValue];
            billEntryDictionary[@"ItemDiscountPercentage"] = @(Percentage);



            // Process Carry Forward Dictionary
//            if (_carryForwardBillEntry) {
//                CGFloat averageSalesPriceForCarryForwardEntry = [_carryForwardBillEntry[@"itemPrice"] floatValue];
//                CGFloat itemDiscountPercentageForCarryForwardEntry = [_carryForwardBillEntry[@"ItemDiscountPercentage"] floatValue];
//                int quantityForCarryForwardEntry = [_carryForwardBillEntry[@"itemQty"] integerValue];
//
//                averageSalesPriceForCarryForwardEntry = ((averageSalesPriceForCarryForwardEntry * quantityForCarryForwardEntry) - (qdOnSingleQuantity * _carryForwardQuantity)) / quantityForCarryForwardEntry;
//                _carryForwardBillEntry[@"itemPrice"] = @(averageSalesPriceForCarryForwardEntry);
//
//                itemDiscountPercentageForCarryForwardEntry += (qdOnSingleQuantity / (unitSalesPrice * quantityForCarryForwardEntry));
//                _carryForwardBillEntry[@"ItemDiscountPercentage"] = @(itemDiscountPercentageForCarryForwardEntry);
//
//
//                CGFloat totalSalesPrice_cf = [_carryForwardBillEntry[@"TotalPrice"] floatValue];
//                CGFloat totalDiscount_cf = [_carryForwardBillEntry[@"TotalDiscount"] floatValue];
//
//                totalSalesPrice_cf -= (qdOnSingleQuantity * _carryForwardQuantity);
//                totalDiscount_cf += (qdOnSingleQuantity * _carryForwardQuantity);
//
//                _carryForwardBillEntry[@"TotalPrice"] = @(totalSalesPrice_cf);
//                _carryForwardBillEntry[@"TotalDiscount"] = @(totalDiscount_cf);
//
//
//                _carryForwardBillEntry = nil;
//                _carryForwardQuantity = 0;
//            }


            ///////
            // DISCOUNT
            ///////
            // DISCOUNT
            ///////
            // DISCOUNT
            ///////
            // DISCOUNT
            ///////
            // DISCOUNT
            ///////
            // DISCOUNT

            // Check for left over for last entry
//            if ((billEntryIndex == billEntryCount) && leftOverQuantity > 0) {
//                _carryForwardBillEntry = billEntryDictionary;
//                _carryForwardQuantity = leftOverQuantity;
//            }


        } else {
            // Leave remaining entries
            // Can't process further
            // NEED TO ADDRESS THIS

            return;
        }


    }
}

- (CGFloat)singleQuantityQDPriceForDiscountDictionary:(NSDictionary*)qdDiscountDictionary {
    CGFloat discountedPrice = [qdDiscountDictionary[@"DIS_UnitPrice"] floatValue] / [qdDiscountDictionary[@"DIS_Qty"] floatValue];
    return discountedPrice;
}
@end
