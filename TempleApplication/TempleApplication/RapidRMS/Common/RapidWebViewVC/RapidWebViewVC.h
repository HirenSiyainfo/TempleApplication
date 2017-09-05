//
//  RapidWebViewVC.h
//  RapidRMS
//
//  Created by Siya Infotech on 14/05/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RapidBackOfficeMenuVC.h"
@interface RapidWebViewVC : UIViewController<UIWebViewDelegate,RapidWebManuSelecteItemDelegate>

@property (nonatomic) PageId pageId;

@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *password;

@property (nonatomic) BOOL isMenuEnable;

@end
