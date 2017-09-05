//
//  SettingPopover.m
//  POSRetail
//
//  Created by Siya Infotech on 25/09/13.
//  Copyright (c) 2013 Nirav Patel. All rights reserved.
//

#import "SoundSettingPopover.h"
#import "RmsDbController.h"

@interface SoundSettingPopover ()

@property (nonatomic, weak) IBOutlet UILabel *lblSoundText;

@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) SettingSoundVC *settingSoundVC;

@end


@implementation SoundSettingPopover

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    self.rmsDbController = [RmsDbController sharedRmsDbController];

    _lblSoundText.text = self.rmsDbController.globalSoundString;
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btn_Done:(id)sender
{
    [_settingSoundVC SaveData];
}

- (IBAction)btn_Cancel:(id)sender
{
    [_settingSoundVC HidePopover];
}
@end
