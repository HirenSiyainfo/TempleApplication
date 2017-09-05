//
//  ItemTag+Dictionary.m
//  POSRetail
//
//  Created by Siya Infotech on 13/03/14.
//  Copyright (c) 2014 Nirav Patel. All rights reserved.
//

#import "ItemTag+Dictionary.h"

@implementation ItemTag (Dictionary)
-(NSDictionary *)itemTagDictionary
{
    return nil;

}
-(void)updateItemTagFromDictionary :(NSDictionary *)itemTagDictionary
{
    self.itemId= @([[itemTagDictionary valueForKey:@"ItemId"] integerValue]);
    self.sizeId = @([[itemTagDictionary valueForKey:@"SizeId"] integerValue]);
    self.isDelete=@([[itemTagDictionary valueForKey:@"isDeleted"] integerValue]);
}
-(void)updateItemTagFromItemTable :(NSDictionary *)itemTagDictionary withItemCode:(NSString *)itemCode
{
    self.itemId= @(itemCode.integerValue);
    self.sizeId = @([[itemTagDictionary valueForKey:@"SizeId"] integerValue]);
    self.isDelete=@([[itemTagDictionary valueForKey:@"isDeleted"] integerValue]);
}

@end
