//
//  CameraScanVC.h
//  RapidRMS
//
//  Created by Siya Infotech on 28/04/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol CameraScanVCDelegate <NSObject>
-(void)barcodeScanned:(NSString *)strBarcode;

@end

@interface CameraScanVC : UIViewController

@property (nonatomic, weak) IBOutlet UIButton *backButton;

@property (nonatomic, weak) id<CameraScanVCDelegate> delegate;

@property (NS_NONATOMIC_IOSONLY, readonly) BOOL startReading;
-(void)stopReading;

@end
