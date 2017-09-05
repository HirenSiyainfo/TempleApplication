//
//  RmsActivityIndicator.h
//  RapidRMS
//
//  Created by Siya Infotech on 04/03/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RmsActivityIndicator : UIView

- (void)hideActivityIndicator;
+ (RmsActivityIndicator *)showActivityIndicator:(UIView *)parentView;
-(void)updateLoadingMessage:(NSString *)message;
-(void)updateProgressStatus:(float)progress;

@end
