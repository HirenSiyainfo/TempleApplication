//
//  TipsVC.h
//  RapidRMS
//
//  Created by Siya Infotech on 10/12/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol tipsSelectionDeletage <NSObject>
-(void)didRemoveTip;
-(void)didSelectTip:(CGFloat)tipAmount;
-(void)didCancelTip;

@end

@interface TipsVC : UIViewController <UITableViewDataSource,UITableViewDelegate,UIPopoverControllerDelegate>
{
    IBOutlet UILabel *grandTotal;
}

@property (nonatomic, weak) id <tipsSelectionDeletage> tipsSelectionDeletage;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic) CGFloat billAmountForTipCalculation;
@property (nonatomic) CGFloat tipAmount;




@end
