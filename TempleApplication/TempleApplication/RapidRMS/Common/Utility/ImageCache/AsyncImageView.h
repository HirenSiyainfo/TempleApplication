//
//  AsyncImageView.h
//  YellowJacket
//
//  Created by Wayne Cochran on 7/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AsyncImageView : UIView

@property (assign) CGFloat imageCornerRadius;

-(void)loadImageFromURL:(NSURL*)url;
-(void)cancelDownloadTask;
@property (NS_NONATOMIC_IOSONLY, strong) UIImage *image;
@end
