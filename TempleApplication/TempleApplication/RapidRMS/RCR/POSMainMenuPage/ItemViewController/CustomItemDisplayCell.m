//
//  CustomItemDisplayCell.m
//  RapidRMS
//
//  Created by siya-IOS5 on 4/17/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "CustomItemDisplayCell.h"
#import "Item+Dictionary.h"
#import "Item_Discount_MD2+Dictionary.h"
#import "Item_Discount_MD+Dictionary.h"
#import "Department+Dictionary.h"
@interface CustomItemDisplayCell ()
{
    
}
@property(nonatomic,weak)IBOutlet UILabel *lblItemName;
@property(nonatomic,weak)IBOutlet UILabel *lblBarcode;
@property(nonatomic,weak)IBOutlet UILabel *lblQty;
@property(nonatomic,weak)IBOutlet UILabel *lblPrice;
@property(nonatomic,weak)IBOutlet UILabel *lblDepartmentName;

@end
@implementation CustomItemDisplayCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

-(void)updateItemTable :(Item *)anItem
{
    NSDictionary *itemDictionary = anItem.itemDictionary;

    self.lblItemName=itemDictionary[@"ItemName"];
    self.lblBarcode=itemDictionary[@"Barcode"];

    NSMutableArray * itemDiscArray = [[NSMutableArray alloc]init];
    for (Item_Discount_MD *idiscMd in anItem.itemToDisMd )
    {
        [itemDiscArray addObjectsFromArray:idiscMd.mdTomd2.allObjects];
    }
    
    Item_Discount_MD2 *idiscMd2=nil;
    
    if(itemDiscArray.count>0)
    {
        for (int idisc=0; idisc<itemDiscArray.count; idisc++)
        {
            idiscMd2=itemDiscArray[idisc];
            
            NSInteger iDiscqty = idiscMd2.md2Tomd.dis_Qty.integerValue;
            
            
            if(idiscMd2.dayId.integerValue==-1 && iDiscqty==1)
            {
            }
        }
    }
    else
    {
        NSString *sCostPrice =[NSString stringWithFormat:@"%.2f", [itemDictionary[@"CostPrice"] floatValue]];
        NSString *slesPrice =[NSString stringWithFormat:@"%.2f", [itemDictionary[@"Price"] floatValue]];
        
        float CostPrice=sCostPrice.floatValue;
        
        float Price=slesPrice.floatValue;
        if (CostPrice>Price)
        {
           // price.textColor = [UIColor redColor];
            
        }
    }

    self.lblDepartmentName.text=anItem.itemDepartment.deptName;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
