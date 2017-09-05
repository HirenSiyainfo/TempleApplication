//
//  GenerateOrderTypePopUpVC.h
//  RapidRMS
//
//  Created by Siya on 23/07/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GenerateOrderTypePopUpVCDelegate <NSObject>

- (void)didSelectGenerateOrderTypeFromArray:(NSArray *)arrGenerateOrderType withIndexPath:(NSIndexPath *)indexPath;

@end

@interface GenerateOrderTypePopUpVC : UIViewController
@property (nonatomic, weak) id<GenerateOrderTypePopUpVCDelegate> delegate;
@end
