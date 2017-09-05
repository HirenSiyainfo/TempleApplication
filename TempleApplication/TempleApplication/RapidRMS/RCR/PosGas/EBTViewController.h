//
//  EBTViewController.h
//  RapidRMS
//
//  Created by Siya on 27/05/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EBTDelegate<NSObject>
-(void)didEbtAppliedWithMessage:(NSString *)strMessage;
-(void)didSelectEBTItemsWithIsThisChangeForAllItems:(BOOL)isThisChangeForAllItems;
-(void)didCancelEBT;
-(void)didRemoveEBT;

@end

@interface EBTViewController : UIViewController

@property (nonatomic, weak) id<EBTDelegate> eBTDelegate;

@property (nonatomic, weak) IBOutlet UIImageView *imgChk1;
@property (nonatomic, weak) IBOutlet UIImageView *imgChk2;
@property (nonatomic, weak) IBOutlet UITextView *txtMessage;


@end
