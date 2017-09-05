//
//  GroupSelectionVC.h
//  RapidRMS
//
//  Created by Siya Infotech on 04/04/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GroupSelectionVCDelegate <NSObject>
    -(void)didselectGroupSelection :(NSMutableArray *)selectedGroupSelection;

@end

@interface GroupSelectionVC : UIViewController
@property (nonatomic, weak) id<GroupSelectionVCDelegate> groupSelectionVCDelegate;

@property (nonatomic, strong) NSString *callingFunction;
@property (nonatomic, strong) NSMutableArray *checkedGroup;

@end
