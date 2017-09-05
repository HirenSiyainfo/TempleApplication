//
//  TenderConfigurationSubViewController.h
//  RapidRMS
//
//  Created by Siya on 28/05/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TenderConfigurationSubEditVC : UIViewController <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) NSString *strIndex;
@property (nonatomic, strong) NSString *strPayID;

@property (nonatomic, strong) NSMutableArray *arrpaymentType;

@end
