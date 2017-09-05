//
//  PrinterVC.h
//  RapidRMS
//
//  Created by Siya on 06/04/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PrinterVC : UIViewController<UpdateDelegate>

@property (nonatomic, strong) NSMutableArray *selectedDeptArray;

@property (nonatomic, strong) NSString *strIPAddress;
@property (nonatomic, strong) NSString *strPrinterName;

@end
