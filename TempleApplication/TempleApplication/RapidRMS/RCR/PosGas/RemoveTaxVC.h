//
//  RemoveTaxVC.h
//  RapidRMS
//
//  Created by Siya on 27/05/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RemoveTaxDelegate<NSObject>
-(void)didremoveTax:(NSString *)strMessage;

-(void)didSelectAll;
-(void)selectedItems;

-(void)didCancelRemoveTax;

@end

@interface RemoveTaxVC : UIViewController


@property (nonatomic, weak) id<RemoveTaxDelegate> removeTaxDelegate;

@property (nonatomic, weak) IBOutlet UIImageView *imgChk1;
@property (nonatomic, weak) IBOutlet UIImageView *imgChk2;
@property (nonatomic, weak) IBOutlet UITextView *txtMessage;

-(IBAction)removeAllTax:(id)sender;

@end
