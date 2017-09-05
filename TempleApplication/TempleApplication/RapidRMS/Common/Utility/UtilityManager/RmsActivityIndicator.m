//
//  RmsActivityIndicator.m
//  RapidRMS
//
//  Created by Siya Infotech on 04/03/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//
    
#import "RmsActivityIndicator.h"
#import "OLImageView.h"
#import "OLImage.h"

@interface RmsActivityIndicator()
{
    UILabel *loadingText;
    UIProgressView *progressBar;
    NSTimer *progressTimer;
}
@end

@implementation RmsActivityIndicator

- (void)hideActivityIndicator
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self removeFromSuperview];
    });
}

+ (RmsActivityIndicator *)showActivityIndicator:(UIView *)parentView
{
    for (UIView *subView in parentView.subviews) {
        if([subView isKindOfClass:[RmsActivityIndicator class]])
        {
            return (RmsActivityIndicator *)subView;
        }
    }
    
    RmsActivityIndicator *indicatorView;
    indicatorView = [[RmsActivityIndicator alloc] initWithFrame: CGRectMake(0, 0, parentView.bounds.size.width, parentView.bounds.size.height)];
    indicatorView.backgroundColor = [UIColor whiteColor];
    indicatorView.alpha = 0.8;
    indicatorView.center = CGPointMake(parentView.frame.size.width/2, parentView.frame.size.height/2);
    indicatorView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    OLImageView *imageView = [[OLImageView alloc] initWithImage:[OLImage imageNamed:@"RapidLoadingLogo.gif"]];
    imageView.backgroundColor = [UIColor clearColor];
    imageView.layer.shadowOffset = CGSizeMake(0, 2);
    imageView.frame = CGRectMake(parentView.bounds.size.width / 2 - 64, parentView.bounds.size.height / 2 - 64, 55, 55);
    imageView.layer.cornerRadius = 5;
    imageView.center = CGPointMake(parentView.frame.size.width/2, parentView.frame.size.height/2);
    imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [indicatorView insertSubview:imageView atIndex:0];
    
     indicatorView->loadingText = [[UILabel alloc] initWithFrame:CGRectMake(0, indicatorView.frame.size.height/2+35 , indicatorView.frame.size.width, 40)];
    indicatorView->loadingText.text = @"Loading...";
    indicatorView->loadingText.backgroundColor = [UIColor clearColor];
    indicatorView->loadingText.textAlignment = NSTextAlignmentCenter;
    indicatorView->loadingText.font = [UIFont fontWithName:@"Helvetica Neue" size:20];
    indicatorView->loadingText.textColor = [UIColor darkGrayColor];
    indicatorView->loadingText.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [indicatorView insertSubview:indicatorView->loadingText atIndex:1];
    
    indicatorView->progressBar = [[UIProgressView alloc] initWithFrame:CGRectMake(indicatorView.frame.size.width/2-100, indicatorView.frame.size.height/2+35+60 , 230, 2)];
    indicatorView->progressBar.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    indicatorView->progressBar.hidden = YES;
    [indicatorView insertSubview:indicatorView->progressBar atIndex:2];
    
    indicatorView.layer.cornerRadius = 5;
    [parentView addSubview: indicatorView];
//    [indicatorView addTimeToShowProgressBar];
    return indicatorView;
}
-(void)updateLoadingMessage:(NSString *)message
{
    loadingText.text = message;
}

-(void)updateProgressStatus:(float)progress
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self showProgressBar];
        [progressBar setProgress:progress animated:YES];
//        NSLog(@"progress = %f",progressBar.progress);
    });
}
-(void)addTimeToShowProgressBar
{
    progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(showProgressBar) userInfo:nil repeats:NO];
}

-(void)showProgressBar
{
    progressBar.hidden = NO;
//    for(int i = 0; i<100; i++)
//    {
//      float  intPercentage = i / 100.00;
//        NSLog(@"intPercentage = %f",intPercentage);
//
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [self updateProgressStatus:intPercentage];
//        });
//    }
}

-(void)dealloc
{
    [progressTimer invalidate];
}

@end
