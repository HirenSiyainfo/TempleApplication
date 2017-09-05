//
//  AgeVerificationVC.h
//  RapidRMS
//
//  Created by siya-IOS5 on 8/5/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol AgeVerificationDelegate<NSObject>

-(void)didVerifiedAge;
-(void)didDeclineAge;

@end

@interface AgeVerificationVC : UIViewController

@property (nonatomic, weak) id<AgeVerificationDelegate> ageVerificationDelegate;

@property (nonatomic, weak) NSString *age;

@end
