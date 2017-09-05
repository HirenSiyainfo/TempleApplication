//
//  RCRTaxCalculation.m
//  RapidRMS
//
//  Created by siya-IOS5 on 1/22/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "RCRTaxCalculation.h"
#import "Item+Dictionary.h"
#import "Department+Dictionary.h"
#import "DepartmentTax+Dictionary.h"
#import "TaxMaster+Dictionary.h"
#import "RmsDbController.h"
#import "ItemTax+Dictionary.h"

@interface RCRTaxCalculation ()
@property (nonatomic, strong) NSManagedObjectContext *moc;
@property (nonatomic, strong) RmsDbController *rmsDbController;

@end

@implementation RCRTaxCalculation

- (instancetype)initWithManageObjectContext:(NSManagedObjectContext *)manageObjectContext
{
    self = [super init];
    
    if (self) {
        self.moc = manageObjectContext;
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


-(NSMutableArray *)getitemTaxDetailFromTaxTable :(NSString *)itemId withSalesPrice:(NSString *)salesPrice In:(NSMutableArray *)taxDetail
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ItemTax" inManagedObjectContext:self.moc];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemId==%d",itemId.integerValue];
    fetchRequest.predicate = predicate;
    NSArray *taxListArray = [UpdateManager executeForContext:self.moc FetchRequest:fetchRequest];
    for (int i=0; i<taxListArray.count; i++)
    {
        ItemTax *tax=taxListArray[i];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"TaxMaster" inManagedObjectContext:self.moc];
        fetchRequest.entity = entity;
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"taxId==%d",tax.taxId.integerValue];
        fetchRequest.predicate = predicate;
        NSArray *itemTaxName = [UpdateManager executeForContext:self.moc FetchRequest:fetchRequest];
        if (itemTaxName.count>0)
        {
            TaxMaster *taxmaster=itemTaxName.firstObject;
            NSMutableDictionary *taxDict=[[NSMutableDictionary alloc]init];
            taxDict[@"ItemTaxAmount"] = @(0);
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
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DepartmentTax" inManagedObjectContext:self.moc];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"deptId==%d",departMentTaxId.integerValue];
    fetchRequest.predicate = predicate;
    NSArray *departmentTaxListArray = [UpdateManager executeForContext:self.moc FetchRequest:fetchRequest];
    for (int i=0; i<departmentTaxListArray.count; i++)
    {
        DepartmentTax *departmentTax=departmentTaxListArray[i];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"TaxMaster" inManagedObjectContext:self.moc];
        fetchRequest.entity = entity;
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"taxId==%d",departmentTax.taxId.integerValue];
        fetchRequest.predicate = predicate;
        NSArray *itemTaxName = [UpdateManager executeForContext:self.moc FetchRequest:fetchRequest];
        if (itemTaxName.count>0)
        {
            TaxMaster *taxmaster=itemTaxName.firstObject;
            NSMutableDictionary *departmentTaxDictionary=[[NSMutableDictionary alloc]init];
            departmentTaxDictionary[@"ItemTaxAmount"] = @(0);
            departmentTaxDictionary[@"TaxPercentage"] = taxmaster.percentage;
            departmentTaxDictionary[@"TaxAmount"] = taxmaster.amount;
            departmentTaxDictionary[@"TaxId"] = taxmaster.taxId;
            [taxDetail addObject:departmentTaxDictionary];
        }
    }
    
    return taxDetail;
}

@end
