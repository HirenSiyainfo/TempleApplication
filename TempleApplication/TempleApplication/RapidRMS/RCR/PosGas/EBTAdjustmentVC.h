//
//  EBTAdjustmentVC.h
//  RapidRMS
//
//  Created by Siya-ios5 on 7/7/17.
//  Copyright © 2017 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol EBTAdjustmentVCDelegate <NSObject>
-(void)didRemoveEbtForItems:(NSMutableArray *)removeEbtItems;
@end



@interface EBTAdjustmentVC : UIViewController
@property (nonatomic, strong) NSMutableArray *reciptDataAry;
@property (nonatomic, weak) id<EBTAdjustmentVCDelegate> ebtAdjustmentVCDelegate;

@end
