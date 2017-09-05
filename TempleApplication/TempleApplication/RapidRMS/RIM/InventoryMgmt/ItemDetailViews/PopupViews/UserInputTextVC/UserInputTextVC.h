//
//  UserInputTextVC.h
//  RapidRMS
//
//  Created by Siya9 on 10/05/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopupSuperVC.h"

typedef void (^InputSaved)(NSString * strInput);
typedef void (^InputClosed)(UIViewController * popUpVC);


@interface UserInputTextVC : PopupSuperVC<UIPopoverPresentationControllerDelegate>
@property (nonatomic, strong) NSString * strInputValue;
@property (nonatomic, strong) NSString * strTitle;
@property (nonatomic, strong) NSString * strSubTitle;

@property (nonatomic, strong) NSString * strImputPlaceHolder;
@property (nonatomic, strong) NSString * strImputErrorMessage;

@property (nonatomic, strong) InputSaved inputSaved;
@property (nonatomic, strong) InputClosed inputClosed;

@property (nonatomic) BOOL isBlankInputSaved;

+(instancetype)setInputTextFieldViewitem:(NSString *)InputValue InputTitle:(NSString *)strTitle InputSubTitle:(NSString *)strSubTitle InputSaved:(InputSaved)inputSaved InputClosed:(InputClosed)inputClosed;

+(instancetype)setInputTextViewViewitem:(NSString *)InputValue InputTitle:(NSString *)strTitle InputSaved:(InputSaved)inputClosed InputClosed:(InputClosed)inputClosed;
@end
