//
//  Mix_MatchDetail+Dictionary.m
//  RapidRMS
//
//  Created by Siya Infotech on 23/06/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "Mix_MatchDetail+Dictionary.h"

@implementation Mix_MatchDetail (Dictionary)

-(NSDictionary *)mixMatchDetailDictionary
{
    return nil;
}

-(NSDictionary *)mixMatchLoadDictionary
{
    NSMutableDictionary *mixMatchDetailDictionary=[[NSMutableDictionary alloc]init];
    mixMatchDetailDictionary[@"Amount"] = self.amount;
    mixMatchDetailDictionary[@"MixMatchId"] = self.mixMatchId;
    mixMatchDetailDictionary[@"Code"] = self.code;
    mixMatchDetailDictionary[@"DiscountType"] = self.discountType;
    mixMatchDetailDictionary[@"Description"] = self.item_Description;
    mixMatchDetailDictionary[@"ItemType"] = self.itemType;
    mixMatchDetailDictionary[@"Mix_Match_Amt"] = self.mix_Match_Amt;
    mixMatchDetailDictionary[@"Mix_Match_Qty"] = self.mix_Match_Qty;
    mixMatchDetailDictionary[@"QuantityX"] = self.quantityX;
    mixMatchDetailDictionary[@"QuantityY"] = self.quantityY;
    mixMatchDetailDictionary[@"DiscCode"] = self.discCode;

    return  mixMatchDetailDictionary;
}

-(void)updateMixMatchDetailFromDictionary :(NSDictionary *)mixMatchDetailDictionary
{
    /*
     Amount = 0;
     --BrnId = 1;
     Code = "";
     --CreatedBy = 1;
     --CreatedDate = "/Date(1399984347270)/";
     Description = "item Buy X Get Y";
     DiscountType = "Mix and Match: Percentage Off";
     ItemType = Item;
     "Mix_Match_Amt" = 150;
     "Mix_Match_Qty" = 15;
     QuantityX = 0;
     QuantityY = 0;
     */
    
    self.amount = @([[mixMatchDetailDictionary valueForKey:@"Amount"] integerValue]);
    self.mixMatchId = @([[mixMatchDetailDictionary valueForKey:@"MixMatchId"] integerValue]);
    self.code = @([[mixMatchDetailDictionary valueForKey:@"Code"] integerValue]);
    self.discountType = [mixMatchDetailDictionary valueForKey:@"DiscountType"];
    self.item_Description = [mixMatchDetailDictionary valueForKey:@"Description"];
    self.itemType = [mixMatchDetailDictionary valueForKey:@"ItemType"];
    self.mix_Match_Amt = @([[mixMatchDetailDictionary valueForKey:@"Mix_Match_Amt"] integerValue]);
    self.mix_Match_Qty = @([[mixMatchDetailDictionary valueForKey:@"Mix_Match_Qty"] integerValue]);
    self.quantityX = @([[mixMatchDetailDictionary valueForKey:@"QuantityX"] integerValue]);
    self.quantityY = @([[mixMatchDetailDictionary valueForKey:@"QuantityY"] integerValue]);
    self.discCode = @([[mixMatchDetailDictionary valueForKey:@"DiscCode"] integerValue]);

    
}

@end
