//
//  PriceAtPosVC.h
//  RapidRMS
//
//  Created by siya-IOS5 on 8/5/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol PriceAtPosDelegate<NSObject>

-(void)didAddItemWithPosPrice:(NSString *)priceAtPos;
-(void)didCancelPriceAtPos;

@end

@interface PriceAtPosVC : UIViewController

@property (nonatomic, weak) id<PriceAtPosDelegate> priceAtPosDelegate;

@property (nonatomic, strong) NSMutableDictionary  *priceAtPosDictionary;

@end
