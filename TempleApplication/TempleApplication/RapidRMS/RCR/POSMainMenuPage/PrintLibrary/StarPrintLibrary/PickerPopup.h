//
//  PickerPopup.h
//  IOS_SDK
//
//  Created by Tzvi on 8/3/11.
//  Copyright 2011 STAR MICRONICS CO., LTD. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PickerPopup : NSObject <UITableViewDelegate, UITableViewDataSource, UIPickerViewDataSource, UIPickerViewDelegate> {
    SEL listener;
    NSObject *listenerObject;
    NSMutableArray *my_DataSource;
    UIPickerView *dataPicker;
    UIActionSheet *actionSheet;
    NSInteger selectedIndex;
    UITableViewCell *cell;
}

-(void)setListener:(SEL)selector :(NSObject*)object;
-(instancetype)init;
-(void)setDataSource:(NSMutableArray *)dataSource;
-(void)showPicker;
-(void)dismissActionSheet:(id)sender;
@property (NS_NONATOMIC_IOSONLY, getter=getSelectedIndex, readonly) NSInteger selectedIndex;


@end
