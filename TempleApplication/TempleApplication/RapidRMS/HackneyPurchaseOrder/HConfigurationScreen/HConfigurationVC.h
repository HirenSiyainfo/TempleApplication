//
//  HConfigurationVC.h
//  RapidRMS
//
//  Created by Siya on 08/01/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HConfigurationVC : UIViewController<UITextFieldDelegate,UpdateDelegate>

@property (nonatomic, strong) NSMutableDictionary *dictBranchInfo;

@property (nonatomic, assign) BOOL alreadyActive;

@end
