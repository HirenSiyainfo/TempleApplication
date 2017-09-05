//
//  TenderItemTableCustomCell.m
//  RapidRMS
//
//  Created by Siya Infotech on 01/07/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "TenderItemTableCustomCell.h"
#import "BillItem.h"
#import "RmsDbController.h"

@interface TenderItemTableCustomCell ()

@property (nonatomic, strong) BillItem *billItem;

@end

@implementation TenderItemTableCustomCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setUpCell];

    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    [self setUpCell];
}


-(void)setUpCell
{
    self.backgroundView = [[UIView alloc]initWithFrame:self.bounds];
    self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    self. selectedBackgroundView = [[UIView alloc]initWithFrame:self.bounds];
    self.selectedBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    self.backgroundView.backgroundColor = [UIColor clearColor];
    self.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:(196/255.f) green:(237/255.f) blue:(224/255.f) alpha:1.0];

}
- (void)resizeLabel:(UILabel *)label
{
    CGSize constraintSize = label.frame.size;
    constraintSize.height = 200;
    CGRect textRect = [label.text boundingRectWithSize:constraintSize
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{NSFontAttributeName:label.font}
                                               context:nil];
    CGSize size = textRect.size;
    CGRect lblNameFrame = label.frame;
    lblNameFrame.size.height = size.height;
    label.frame = lblNameFrame;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        //[self resizeLabel:self.itemName];
    }
}

- (void)setItemImageFromURL:(NSString *)itemImageURL
{
    self.itemImage.imageCornerRadius = 8.0;
    if ([[itemImageURL stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""])
    {
        NSString *imgString = @"RCR_NoImageForRingUp.png";

        self.itemImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@", imgString]];
    }
    else if ([[itemImageURL stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@"<null>"])
    {
        NSString *imgString = @"RCR_NoImageForRingUp.png";
        self.itemImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@", imgString]];
    }
    else
    {
        [self.itemImage loadImageFromURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",itemImageURL]]];
    }
}

- (float)variationCostForbillEntryDictionary:(NSDictionary *)billEntryDictionary
{
    float variationCost=0.0;
    if(billEntryDictionary[@"InvoiceVariationdetail"])
    {
        variationCost = [[(NSArray *)billEntryDictionary[@"InvoiceVariationdetail"] valueForKeyPath:@"@sum.Price"] floatValue];
    }
    return variationCost;
}

-(void)updateCellWithBillItem:(NSDictionary *)billEntryDictionary withItem:(Item *)item
{
    self.itemName.text = [billEntryDictionary valueForKey:@"itemName"];
    
    NSString * barcode = @"";
    barcode = [billEntryDictionary valueForKey:@"Barcode"];
    if([barcode isKindOfClass:[NSNull class]])
    {
        barcode=@"";
    }
    self.itemBarcode.text = barcode;
    
    if([[billEntryDictionary valueForKey:@"itemName"] isEqualToString:@"GAS"]){
        self.itemName.text = [billEntryDictionary valueForKey:@"Pump"];
        self.itemBarcode.text = [billEntryDictionary valueForKey:@"Discription"];
    }
    
    NSString *itemImageURL = [billEntryDictionary valueForKey:@"itemImage"];
    [self setItemImageFromURL:itemImageURL];
    
    NSNumber *qty;
    if ([billEntryDictionary objectForKey:@"PackageQty"]) {
        qty = @([[billEntryDictionary valueForKey:@"itemQty"] integerValue]/ [[billEntryDictionary valueForKey:@"PackageQty"] integerValue]);
    }
    else{
        qty = @([[billEntryDictionary valueForKey:@"itemQty"] integerValue]);
    }
    
    self.itemQty.text = [NSString stringWithFormat:@"%@",qty];
    
    
    
    float itemCost = [billEntryDictionary[@"itemPrice"] floatValue] * [billEntryDictionary[@"PackageQty"] floatValue];
    
    //float variationCost = [billEntryDictionary[@"TotalVarionCost"] floatValue];
    
    float discountOnItem = [[billEntryDictionary valueForKey:@"ItemDiscount"] floatValue];
    
    NSNumber *numeritemCost=@(itemCost);
    NSString *sitemPrice =[NSString stringWithFormat:@"%@",[self.currencyFormatter stringFromNumber:numeritemCost]];
    
    self.itemSalesPrice.text = [NSString stringWithFormat:@"%@",sitemPrice];
    
    if( [billEntryDictionary objectForKey:@"PackageType"]){
        self.lblPackageType.text = [NSString stringWithFormat:@"%@",[billEntryDictionary valueForKey:@"PackageType"]];
        if ([[billEntryDictionary valueForKey:@"PackageType"] isEqualToString:@"Single Item"]) {
            self.lblPackageType.text = [NSString stringWithFormat:@"%@",@"Single"];

        }
    }
    else{
        self.lblPackageType.text = @"";
    }
    
    if (([billEntryDictionary[@"itemPrice"] floatValue] < [billEntryDictionary[@"ItemCost"] floatValue]) && [billEntryDictionary[@"ItemCost"] floatValue] > 0 )
    {
        self.itemSalesPrice.textColor = [UIColor redColor];
    }
    else
    {
        self.itemSalesPrice.textColor = [UIColor colorWithRed:(33/255.f) green:(33/255.f) blue:(33/255.f) alpha:1.0];

    }
    float totalItemCostValue = [billEntryDictionary [@"TotalItemPrice"] floatValue];
    
    NSNumber *numerTotalItemCost=@(totalItemCostValue);
    NSString *sTotalItemCost =[NSString stringWithFormat:@"%@",[self.currencyFormatter stringFromNumber:numerTotalItemCost]];
    self.itemTotalPrice.text = [NSString stringWithFormat:@"%@",sTotalItemCost];
    
    if(discountOnItem>0)
    {
        self.itemTotalPrice.textColor = [UIColor blueColor];
    }
    else
    {
        self.itemTotalPrice.textColor = [UIColor colorWithRed:(33/255.f) green:(33/255.f) blue:(33/255.f) alpha:1.0];
    }
    
    self.noPosDiscount.text = @"";
    
    if (item.pos_DISCOUNT.boolValue == TRUE)
    {
        self.noPosDiscount.text = @"No Discount Apply";
    }
    
    NSMutableArray *taxArray= [billEntryDictionary valueForKey:@"ItemTaxDetail"];
    self.itemTax.text = @"";
    if([taxArray isKindOfClass:[NSMutableArray class]])
    {
        if (taxArray.count>0)
        {
            self.itemTax.text = [NSString stringWithFormat:@"Tax"];
        }
    }
    else if ([[billEntryDictionary valueForKey:@"EBTApplied"] boolValue] == TRUE)
    {
        self.itemTax.text = [NSString stringWithFormat:@"EBT"];
    }
    
    
    
    [self.qtyDownArrow addTarget:self action:@selector(subtractionQtyAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.qtyUpArrow addTarget:self action:@selector(addQtyAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    //
    self.fee.text = @"";
    self.feeAmount.text = @"";
    if ([[[billEntryDictionary valueForKey:@"item"] valueForKey:@"isCheckCash"]boolValue]==YES)
    {
        self.fee.text = @"Fee";
        NSNumber *numerCheckCashCharge=@([[[billEntryDictionary valueForKey:@"item"] valueForKey:@"CheckCashCharge"] floatValue]);
        NSString *sCheckCashCharge =[NSString stringWithFormat:@"%@",[self.currencyFormatter stringFromNumber:numerCheckCashCharge]];
        self.feeAmount.text = [NSString stringWithFormat:@"%@",sCheckCashCharge];
        
    }
    if ([[[billEntryDictionary valueForKey:@"item"] valueForKey:@"isExtraCharge"]boolValue] == YES)
    {
        self.fee.text = @"Fee";
        
        float extChargeAmount=[[[billEntryDictionary valueForKey:@"item"] valueForKey:@"ExtraCharge"] floatValue];
        float extAmount=extChargeAmount * [[billEntryDictionary valueForKey:@"itemQty"] intValue];
        NSNumber *numerExtAmount=@(extAmount);
        NSString *sExtAmount =[NSString stringWithFormat:@"%@",[self.currencyFormatter stringFromNumber:numerExtAmount]];
        self.feeAmount.text=[NSString stringWithFormat:@"%@",sExtAmount];
    }
    
    self.qtyDownArrow.tag = self.indexPathForCell.row;
    self.qtyUpArrow.tag = self.indexPathForCell.row;
    
    self.itemUnitQtyType.text = @"";
    
    if(billEntryDictionary[@"UnitType"])
    {
        NSString * unitType = billEntryDictionary[@"UnitType"];
        NSString * unitQty = billEntryDictionary[@"UnitQty"];
        
        if (unitType.length > 0)
        {
            self.itemUnitQtyType.text = [NSString stringWithFormat:@"%.2f %@",unitQty.floatValue,unitType];
        }
    }
    
       UILabel *label;
    for(label in self.contentView.subviews){
        if([label isKindOfClass:[UILabel class]]  && label.tag!=0)
            [label removeFromSuperview];
    }
    
    if(billEntryDictionary[@"InvoiceVariationdetail"])
    {
        float priceY = self.feeAmount.frame.origin.y ;
        if ( self.feeAmount.text.length > 0) {
            priceY = self.feeAmount.frame.origin.y + self.feeAmount.frame.size.height +10 ;
        }
        float Y = 64;
        NSArray * variationArray = billEntryDictionary[@"InvoiceVariationdetail"];
        for (int i =0; i < variationArray.count; i++) {
            UILabel * variationName = [[UILabel alloc] init];
            variationName.frame = CGRectMake(self.itemName.frame.origin.x,priceY, 100, 25);
            variationName.text = [NSString stringWithFormat:@" %@",[variationArray[i] valueForKey:@"VariationItemName"]];
            variationName.tag = [NSString stringWithFormat:@"1%d",i].integerValue;
            variationName.font = [UIFont fontWithName:@"Lato" size:12.0];
            [self.contentView addSubview:variationName];
            
            
            UILabel * variationPrice = [[UILabel alloc] init];
            variationPrice.frame = CGRectMake(self.itemSalesPrice.frame.origin.x,priceY, self.itemSalesPrice.frame.size.width, 25);
            
            NSNumber *variationPriceFloat=@([[variationArray[i] valueForKey:@"Price"] floatValue]);
            NSString *svariationPrice =[NSString stringWithFormat:@"%@",[self.currencyFormatter stringFromNumber:variationPriceFloat]];
            variationPrice.text = svariationPrice;
            variationPrice.textAlignment = NSTextAlignmentCenter;
            variationPrice.tag = [NSString stringWithFormat:@"1%d",i].integerValue;
            variationPrice.font = [UIFont fontWithName:@"Lato" size:12.0];
            [self.contentView addSubview:variationPrice];
            Y +=15;
            priceY+=15;
        }
    }
    
    
    self.sepratorView.frame=CGRectMake(self.sepratorView.frame.origin.x, self.frame.size.height-1, self.sepratorView.frame.size.width, 1);
    
}

-(void)updateCellWithInvoiceItem:(NSDictionary *)invoiceItemDictionary indexpath:(NSIndexPath *)index
{
    if(invoiceItemDictionary)
    {
        NSInteger ino = index.row+1;
        self.itemNo.text = [NSString stringWithFormat:@"%ld",(long)ino];
        
        self.itemName.text = [invoiceItemDictionary valueForKey:@"itemName"];
        
        NSString * barcode = @"";
        barcode = [invoiceItemDictionary valueForKey:@"Barcode"];
        if([barcode isKindOfClass:[NSNull class]])
        {
            barcode=@"";
        }
        self.itemBarcode.text = barcode;
        
        NSString *itemImageURL = [invoiceItemDictionary valueForKey:@"itemImage"];
        [self setItemImageFromURL:itemImageURL];
      
        NSNumber *qty;
        if ([invoiceItemDictionary objectForKey:@"PackageQty"]) {
            qty = @([[invoiceItemDictionary valueForKey:@"itemQty"] integerValue]/ [[invoiceItemDictionary valueForKey:@"PackageQty"] integerValue]);
        }
        else{
            qty = @([[invoiceItemDictionary valueForKey:@"itemQty"] integerValue]);
        }
        self.itemQty.text = [NSString stringWithFormat:@"%@",qty];

        
        float itemCost = [invoiceItemDictionary[@"itemPrice"] floatValue] * [invoiceItemDictionary[@"PackageQty"] floatValue];
        
        //float variationCost = [billEntryDictionary[@"TotalVarionCost"] floatValue];
        
        float discountOnItem = [[invoiceItemDictionary valueForKey:@"ItemDiscount"] floatValue];
        
        NSNumber *numeritemCost=@(itemCost);
        NSString *sitemPrice =[NSString stringWithFormat:@"%@",[self.currencyFormatter stringFromNumber:numeritemCost]];
        
        self.itemSalesPrice.text = [NSString stringWithFormat:@"%@",sitemPrice];
        
        if ([invoiceItemDictionary[@"itemPrice"] floatValue] < -([invoiceItemDictionary[@"ItemCost"] floatValue]))
        {
            self.itemSalesPrice.textColor = [UIColor redColor];
        }

        CGFloat totalVariationCost = [self variationCostForbillEntryDictionary:invoiceItemDictionary];
        float totalCostWithVariation = totalVariationCost + itemCost;
        float totalItemCostValue = totalCostWithVariation * qty.floatValue;
        
        NSNumber *numerTotalItemCost=@(totalItemCostValue);
        NSString *sTotalItemCost =[NSString stringWithFormat:@"%@",[self.currencyFormatter stringFromNumber:numerTotalItemCost]];
        self.itemTotalPrice.text = [NSString stringWithFormat:@"%@",sTotalItemCost];
        
        if(discountOnItem>0)
        {
            self.itemTotalPrice.textColor = [UIColor blueColor];
        }
        else
        {
            self.itemTotalPrice.textColor = [UIColor colorWithRed:(33/255.f) green:(33/255.f) blue:(33/255.f) alpha:1.0];
        }
        
        self.noPosDiscount.text = @"";
        
        
        NSMutableArray *taxArray= [invoiceItemDictionary valueForKey:@"ItemTaxDetail"];
        self.itemTax.text = @"";
        if([taxArray isKindOfClass:[NSMutableArray class]])
        {
            if (taxArray.count>0)
            {
                self.itemTax.text = [NSString stringWithFormat:@"Tax"];
            }
        }
        else if ([[invoiceItemDictionary valueForKey:@"EBTApplied"] boolValue] == TRUE)
        {
            self.itemTax.text = [NSString stringWithFormat:@"EBT"];
        }
        
        
        //
        
        if( [invoiceItemDictionary objectForKey:@"PackageType"]){
            self.lblPackageType.text = [NSString stringWithFormat:@"%@",[invoiceItemDictionary valueForKey:@"PackageType"]];
            if ([[invoiceItemDictionary valueForKey:@"PackageType"] isEqualToString:@"Single Item"]) {
                self.lblPackageType.text = [NSString stringWithFormat:@"%@",@"Single"];
            }
        }
        else{
            self.lblPackageType.text = @"";
        }
        self.fee.text = @"";
        self.feeAmount.text = @"";
        if ([[[invoiceItemDictionary valueForKey:@"item"] valueForKey:@"isCheckCash"]boolValue]==YES)
        {
            self.fee.text = @"Fee";
            NSNumber *numerCheckCashCharge=@([[[invoiceItemDictionary valueForKey:@"item"] valueForKey:@"CheckCashCharge"] floatValue]);
            NSString *sCheckCashCharge =[NSString stringWithFormat:@"%@",[self.currencyFormatter stringFromNumber:numerCheckCashCharge]];
            self.feeAmount.text = [NSString stringWithFormat:@"%@",sCheckCashCharge];
            
        }
        if ([[[invoiceItemDictionary valueForKey:@"item"] valueForKey:@"isExtraCharge"]boolValue] == YES)
        {
            self.fee.text = @"Fee";
            
            float extChargeAmount=[[[invoiceItemDictionary valueForKey:@"item"] valueForKey:@"ExtraCharge"] floatValue];
            float extAmount=extChargeAmount * [[invoiceItemDictionary valueForKey:@"itemQty"] intValue];
            NSNumber *numerExtAmount=@(extAmount);
            NSString *sExtAmount =[NSString stringWithFormat:@"%@",[self.currencyFormatter stringFromNumber:numerExtAmount]];
            self.feeAmount.text=[NSString stringWithFormat:@"%@",sExtAmount];
        }
        
        self.qtyDownArrow.tag = self.indexPathForCell.row;
        self.qtyUpArrow.tag = self.indexPathForCell.row;
        
        self.itemUnitQtyType.text = @"";
        
        if(invoiceItemDictionary[@"UnitType"])
        {
            NSString * unitType = invoiceItemDictionary[@"UnitType"];
            NSString * unitQty = invoiceItemDictionary[@"UnitQty"];
            
            if (unitType.length > 0)
            {
                self.itemUnitQtyType.text = [NSString stringWithFormat:@"%.2f %@",unitQty.floatValue,unitType];
            }
        }
        
        UILabel *label;
        for(label in self.contentView.subviews){
            if([label isKindOfClass:[UILabel class]]  && label.tag!=0)
                [label removeFromSuperview];
        }
        
        if(invoiceItemDictionary[@"InvoiceVariationdetail"])
        {
            float priceY = self.feeAmount.frame.origin.y ;
            if ( self.feeAmount.text.length > 0) {
                priceY = self.feeAmount.frame.origin.y + self.feeAmount.frame.size.height +10 ;
            }
            float Y = 64;
            NSArray * variationArray = invoiceItemDictionary[@"InvoiceVariationdetail"];
            for (int i =0; i < variationArray.count; i++) {
                UILabel * variationName = [[UILabel alloc] init];
                variationName.frame = CGRectMake(140,priceY, 100, 25);
                variationName.text = [NSString stringWithFormat:@" %@",[variationArray[i] valueForKey:@"VariationItemName"]];
                variationName.tag = [NSString stringWithFormat:@"1%d",i].integerValue;
                variationName.font = [UIFont fontWithName:@"Lato" size:13.0];
                [self.contentView addSubview:variationName];
                
                
                UILabel * variationPrice = [[UILabel alloc] init];
                variationPrice.frame = CGRectMake(self.itemSalesPrice.frame.origin.x,priceY, self.itemSalesPrice.frame.size.width, 25);
                
                NSNumber *variationPriceFloat=@([[variationArray[i] valueForKey:@"Price"] floatValue]);
                NSString *svariationPrice =[NSString stringWithFormat:@"%@",[self.currencyFormatter stringFromNumber:variationPriceFloat]];
                variationPrice.text = svariationPrice;
                variationPrice.textAlignment = NSTextAlignmentLeft;
                variationPrice.tag = [NSString stringWithFormat:@"1%d",i].integerValue;
                variationPrice.font = [UIFont fontWithName:@"Lato" size:13.0];
                [self.contentView addSubview:variationPrice];
                Y +=15;
                priceY+=15;
            }
        }
        
        self.sepratorView.frame=CGRectMake(self.sepratorView.frame.origin.x, self.frame.size.height-1, self.sepratorView.frame.size.width, 1);
    }
    
}

-(IBAction)addQtyAction:(id)sender
{
    [self.tenderItemTableCellDelegate didAddQtyAtIndxPath:self.indexPathForCell];
}

-(IBAction)subtractionQtyAction:(id)sender
{
    [self.tenderItemTableCellDelegate didSubtractQtyAtIndxPath:self.indexPathForCell];
}

-(void)removeModiFier :(id)sender
{
   // [self.tenderItemTableCellDelegate didRemoveModiFier:[sender tag] atIndexPath:self.indexPathForCell];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
