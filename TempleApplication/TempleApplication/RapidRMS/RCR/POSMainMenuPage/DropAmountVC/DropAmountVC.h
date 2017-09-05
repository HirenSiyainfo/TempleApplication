//
//  DropAmountVC.h
//  RapidRMS
//
//  Created by Siya Infotech on 13/06/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, DAAlignment) {
    DAAlignmentLeft,
    DAAlignmentCenter,
    DAAlignmentRight,
};

@protocol DropAmountDelegate<NSObject>
-(void)dropAmountProcessSuccessfullyDone;
-(void)dropAmountProcessFailed;
-(void)dismissDropAmountViewController;
@end

@interface DropAmountVC : UIViewController
@property (nonatomic, weak) id<DropAmountDelegate> dropAmountDelegate;
@property (nonatomic,strong) NSString *strPrintBarcode;
@property (nonatomic,assign) BOOL isDrawerOpened;

@end
