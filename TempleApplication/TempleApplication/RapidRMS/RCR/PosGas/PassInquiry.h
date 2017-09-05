//
//  PassInquiry.h
//  RapidRMS
//
//  Created by Siya Infotech on 26/06/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol PassInquiryDelegate <NSObject>
-(void)cancelPassInquiry;
@end

@interface PassInquiry : UIViewController
@property (nonatomic,weak) id<PassInquiryDelegate> passInquiryDelegate;

@end
