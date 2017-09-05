//
//  ItemImageSelectionVC.h
//  RapidRMS
//
//  Created by Siya Infotech on 16/12/15.
//  Copyright © 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ItemSelctionImageChangedVCDelegate <NSObject>
@required
-(void)itemImageChangeNewImage:(UIImage *)image withImageUrl:(NSString *)imageUrl;
@end
@interface ItemImageSelectionVC : UIViewController

@property (nonatomic, weak) id<ItemSelctionImageChangedVCDelegate> itemSelctionImageChangedVCDelegate;
@property (nonatomic, strong) NSString * strSearchText;


-(void)presentViewControllerForviewConteroller:(UIViewController *) objView sourceView:(UIView *)sourceView ArrowDirection:(UIPopoverArrowDirection)arrowDirection;
@end
