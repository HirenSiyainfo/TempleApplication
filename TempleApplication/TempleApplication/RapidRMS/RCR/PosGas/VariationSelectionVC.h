//
//  VariationSelectionVC.h
//  RapidRMS
//
//  Created by siya-IOS5 on 12/1/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol VariationSelectionDelegate <NSObject>
-(void)didSelectItemWithVariationDetail :(NSArray *)variationDetail withItem:(Item *)item;
-(void)didCancelVariationSelectionProcess;

@end

@interface VariationSelectionVC : UIViewController

@property (nonatomic,strong) Item *itemforVariation;

@property (nonatomic, weak) id<VariationSelectionDelegate> variationSelectionDelegate;

@property (nonatomic,strong) NSMutableArray *selectedVariance;

@end
