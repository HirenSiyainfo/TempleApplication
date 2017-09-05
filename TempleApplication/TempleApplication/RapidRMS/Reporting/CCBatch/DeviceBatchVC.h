//
//  DeviceBatchVC.h
//  RapidRMS
//
//  Created by Siya-mac5 on 27/06/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCCommonHeaderVC.h"

@protocol DeviceBatchVCDelegate <NSObject>

- (void)didSearch:(NSString *)text;
- (void)didClearSearch;
- (void)didSelectRecordForTipAdjustmentAtIndexPath:(NSIndexPath *)indexpath;
- (void)setVoidTransactionProcess:(NSIndexPath *)indexpath;
- (void)setForceTransactionProcess:(NSIndexPath*)indexpath;

@end

@interface DeviceBatchVC : UIViewController

@property (nonatomic, strong) NSNumber *isTipsApplicable;
@property (nonatomic, weak) id <DeviceBatchVCDelegate> deviceBatchVCDelegate;

- (void)configureDeviceBatchHeader;
- (void)updateDeviceBatchUIWithCardDetail:(NSMutableArray *)cardDetails;
- (void)updateCommonHeaderWith:(CCBatchTrnxDetailStruct*)cCBatchTrnxDetail;
- (void)clearSearchTextFieldOfCommonHeader;
@end
