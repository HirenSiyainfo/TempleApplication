//
//  SizeMaster+Dictionary.m
//  POSRetail
//
//  Created by Siya Infotech on 15/03/14.
//  Copyright (c) 2014 Nirav Patel. All rights reserved.
//

#import "SizeMaster+Dictionary.h"

@implementation SizeMaster (Dictionary)
-(NSDictionary *)sizeMasterDictionary
{
    return nil;
}
-(void)updateSizeMasterFromDictionary :(NSDictionary *)sizeMasterDictionary
{
    self.sizeId =  @([[sizeMasterDictionary valueForKey:@"SizeId"] integerValue]);;
    self.sizeName =[sizeMasterDictionary valueForKey:@"SizeName"] ;
}
@end
