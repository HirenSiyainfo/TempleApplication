//
//  HPurchaseOrderVC.h
//  RapidRMS
//
//  Created by Siya on 25/12/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HPurchaseOrderVC : UIViewController<UITextFieldDelegate,UpdateDelegate>

@property (nonatomic, strong) NSMutableDictionary *dictDept;

@property (nonatomic, strong) NSMutableArray *arrayBackorderArray;

@property (nonatomic, assign) BOOL fromHome;

@end
