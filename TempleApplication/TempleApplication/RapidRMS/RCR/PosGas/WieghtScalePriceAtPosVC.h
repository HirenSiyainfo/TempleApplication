//
//  WieghtScalePriceAtPosVC.h
//  RapidRMS
//
//  Created by siya-IOS5 on 11/11/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol WeightScalePriceAtPosDelegate<NSObject>

-(void)didWeightScalePriceAtPosRingupItemWithItemUnitPrice :(NSString *)price withItemUnitQty:(CGFloat)qty withItemUnitType:(NSString *)itemUnitType;
-(void)didWeightScalePriceAtPosCancel;
@end

@interface WieghtScalePriceAtPosVC : UIViewController

@property (nonatomic,strong) Item *itemforWeightScale;
@property (nonatomic,strong) NSString *qty;

@property (nonatomic, weak) id<WeightScalePriceAtPosDelegate> weightScalePriceAtPosDelegate;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
