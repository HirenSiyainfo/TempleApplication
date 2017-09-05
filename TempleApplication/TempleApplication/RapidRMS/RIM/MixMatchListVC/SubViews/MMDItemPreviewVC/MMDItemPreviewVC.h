//
//  MMDItemPreviewVC.h
//  RapidRMS
//
//  Created by Siya Infotech on 28/01/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol MMDItemPreviewVCDelegate <NSObject>
-(void)didSelectItemListEditWithNewXItems:(NSMutableArray *) arrSelectedXItems WithNewYItems:(NSMutableArray *) arrSelectedYItems;
@end
@interface MMDItemPreviewVC : UIViewController

@property (nonatomic,strong) NSMutableArray * arrXitems;
@property (nonatomic,strong) NSMutableArray * arrYitems;
@property (nonatomic, weak) id<MMDItemPreviewVCDelegate> Delegate;
@end
