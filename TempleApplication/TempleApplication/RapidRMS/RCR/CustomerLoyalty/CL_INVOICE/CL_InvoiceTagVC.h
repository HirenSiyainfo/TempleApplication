//
//  CL_InvoiceTagVC.h
//  RapidRMS
//
//  Created by Siya Infotech on 16/12/15.
//  Copyright © 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol CL_InvoiceTagVCDelegate <NSObject>
@end

@interface CL_InvoiceTagVC : UIViewController

@property(nonatomic , strong) NSMutableArray *arrInvoicetagList;

@property(nonatomic,weak)id <CL_InvoiceTagVCDelegate> cl_InvoiceTagVCDelegate;

@end
