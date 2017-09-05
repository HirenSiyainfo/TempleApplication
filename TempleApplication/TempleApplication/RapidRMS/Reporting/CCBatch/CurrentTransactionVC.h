//
//  CurrentTransactionVC.h
//  RapidRMS
//
//  Created by Siya-mac5 on 18/06/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCCommonHeaderVC.h"

@protocol CurrentTransactionVCDelegate <NSObject>
- (void)didSelectRecordForTipAdjustmentAtIndexPath:(NSIndexPath *)indexpath;
@end

@interface CurrentTransactionVC : UIViewController
@property (nonatomic, strong) NSNumber *isTipsApplicable;

@property (nonatomic, weak) id <CurrentTransactionVCDelegate> currentTransactionVCDelegate;

- (void)updateCommonHeaderWith:(CCBatchTrnxDetailStruct*)cCBatchTrnxDetail;
- (void)updateCurrentTrnxUIWithCardDetail:(NSMutableArray *)cardDetails;
- (void)configureCurrentTransactionHeader;

@end
