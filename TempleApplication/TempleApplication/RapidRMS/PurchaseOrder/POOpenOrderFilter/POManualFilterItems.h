//
//  POManualFilterItems.h
//  RapidRMS
//
//  Created by Siya10 on 20/10/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol POManualFilterItemsDelegate <NSObject>

-(void)didsaveWithSelectedItems:(NSMutableArray *)selecteditems;

@end

@interface POManualFilterItems : UIViewController

@property(nonatomic,strong)NSMutableArray *manualFilterItems;
@property(nonatomic,weak) id <POManualFilterItemsDelegate> poManualFilterItemsDelegate;
@end
