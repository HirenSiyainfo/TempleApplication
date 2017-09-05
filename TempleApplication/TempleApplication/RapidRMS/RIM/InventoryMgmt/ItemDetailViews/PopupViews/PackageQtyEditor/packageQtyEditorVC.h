//
//  popOverController.h
//  POSFrontEnd
//
//  Created by Minesh Purohit on 04/12/11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ItemInfoEditVC.h"

@protocol PackageQtyEditorVCDelegate <NSObject>

-(void)didEnter:(id)inputControl inputValue:(CGFloat)inputValue;
-(void)didCancel;

@end

@interface packageQtyEditorVC : UIViewController

@property (nonatomic, weak) id<PackageQtyEditorVCDelegate> packageQtyEditorVCDelegate;

@property (nonatomic, weak) id inputControl;
@property (nonatomic) NSInteger noOfItems;


@end