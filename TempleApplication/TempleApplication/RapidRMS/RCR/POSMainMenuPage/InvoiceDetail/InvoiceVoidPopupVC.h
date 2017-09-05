//
//  InvoiceVoidPopupVC.h
//  RapidRMS
//
//  Created by Siya on 15/05/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol InvoiceVoidePopUpDelegate<NSObject>

-(void)didsendVoidMessage :(NSString *)message;
-(void)didCancelInvoicePopup;

@end

@interface InvoiceVoidPopupVC : UIViewController


@property (nonatomic, weak) id<InvoiceVoidePopUpDelegate> invoiceVoidePopUpDelegate;
@end
