//
//  InRecallViewController.h
//  I-RMS
//
//  Created by Siya Infotech on 27/09/13.
//  Copyright (c) 2013 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITableViewCell+NIB.h"
//#import "menuViewController.h"
#import "NDHTMLtoPDF.h"
#import "SideMenuVCDelegate.h"

@interface OpenOrderVC : UIViewController <UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate,NDHTMLtoPDFDelegate,UIDocumentInteractionControllerDelegate>


@property (nonatomic, weak) id<SideMenuVCDelegate> sideMenuVCDelegate;

@end
