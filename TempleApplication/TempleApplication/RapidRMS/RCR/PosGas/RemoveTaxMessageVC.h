//
//  RemoveTaxMessageVC.h
//  RapidRMS
//
//  Created by Siya on 27/05/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RemoveTaxPopUpMessageDelegate<NSObject>

-(void)didsendRemoveTaxMessage :(NSString *)message;
-(void)didCancelRemoveTaxPopup;

@end

@interface RemoveTaxMessageVC : UIViewController

@property (nonatomic, weak) id<RemoveTaxPopUpMessageDelegate> removeTaxPopUpMessageDelegate;

@end
