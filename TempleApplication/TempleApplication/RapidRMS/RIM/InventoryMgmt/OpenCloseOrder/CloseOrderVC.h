//
//  OutRecallViewController.h
//  I-RMS
//
//  Created by Siya Infotech on 27/09/13.
//  Copyright (c) 2013 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITableViewCell+NIB.h"
#import "NDHTMLtoPDF.h"
#import "SideMenuVCDelegate.h"

@interface CloseOrderVC : UIViewController <UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,UIPopoverControllerDelegate,NDHTMLtoPDFDelegate,UIDocumentInteractionControllerDelegate>


@property (nonatomic, weak) id<SideMenuVCDelegate> sideMenuVCDelegate;

@end
