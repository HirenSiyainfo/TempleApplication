//
//  MMDAddDiscountTypeVC.h
//  RapidRMS
//
//  Created by Siya Infotech on 19/01/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Discount_M.h"

typedef NS_ENUM (NSInteger , MMDDiscountType){
    MMDDiscountTypeQuantity = 1,
    MMDDiscountTypeMandM = 2,
    MMDDiscountTypeSD = 3,
};

@interface MMDAddDiscountTypeVC : UIViewController
@property (nonatomic, strong) NSManagedObjectContext * moc;
@property (nonatomic, strong) Discount_M * objMixMatch;
@end
