//
//  HScanBarcodeVC.h
//  RapidRMS
//
//  Created by Siya on 17/02/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "HPOItemListVC.h"
#import "HReceiveOrderItemListVC.h"
#import "HItemProductVC.h"

@interface HScanBarcodeVC : UIViewController<AVCaptureMetadataOutputObjectsDelegate,UpdateDelegate>

@property (nonatomic, strong) HItemProductVC *itemProductVC;
@property (nonatomic, strong) HReceiveOrderItemListVC *itemReceiveListVC;
@property (nonatomic, strong) HPOItemListVC *itemLitVC;

@end
