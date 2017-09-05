//
//  WeightScaleVC.h
//  RapidRMS
//
//  Created by siya-IOS5 on 8/29/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Item;
@protocol WeightScaleDelegate<NSObject>
-(void)didAddItemWithWeightQty:(NSNumber *)weightQty withCostPrice:(NSNumber *)costPrice withItemStatus:(BOOL)isInserted WithItem:(Item *)item;
-(void)didCancelWeightScale;
@end
@interface WeightScaleVC : UIViewController
@property (nonatomic, strong) NSMutableDictionary  *weightScaleDictionary;
@property (nonatomic, weak) id<WeightScaleDelegate> weightScaleDelegate;
@property (nonatomic, strong) Item  *weightScaleItem;
@property (assign) BOOL  isInserted;
@end
