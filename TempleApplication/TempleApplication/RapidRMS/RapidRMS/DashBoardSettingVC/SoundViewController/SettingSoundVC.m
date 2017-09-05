//
//  SoundViewController.m
//  RapidRMS
//
//  Created by Siya Infotech on 07/05/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "SettingSoundVC.h"
#import <AVFoundation/AVFoundation.h>
#import "SoundSettingPopover.h"
#import "RmsDbController.h"

@interface SettingSoundVC ()
{
    UIPopoverController *settingPopOver;
}

@property (nonatomic, weak) IBOutlet UISwitch *switch_SoundSetting;
@property (nonatomic, weak) IBOutlet UITableView *settingSoundTable;

@property (nonatomic, weak) UIButton *btnSoundSelect;

@property (nonatomic, strong) UIImageView *SoundImage;

@property (nonatomic, strong) NSMutableArray *soundArray;

@property (nonatomic, strong) RmsDbController *rmsDbController;

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

@property (atomic) NSInteger IndexSound;


@end

@implementation SettingSoundVC

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
    
    self.IndexSound = [[[NSUserDefaults standardUserDefaults] valueForKey:@"SelectedSound"] integerValue];
    
   // self.settingSoundTable.layer.borderWidth = 0.5;
    //self.settingSoundTable.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    if (self.rmsDbController.globalSoundSetting != nil && self.rmsDbController.globalSoundSetting.length > 0)
    {
        _switch_SoundSetting.on=TRUE;
    }
    else
    {
        _switch_SoundSetting.on=FALSE;
        self.IndexSound = -1;
    }
    
    self.soundArray = [[NSMutableArray alloc]initWithObjects:@"beep-8",@"button-16",@"beep-21",@"beep-22",@"beep-23",@"beep-28",@"button-33",@"button-38",@"button-50",nil];
    [self.settingSoundTable reloadData];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(IBAction)btnBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == self.settingSoundTable)
    {
        return self.soundArray.count;
    }
    return 1 ;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == self.settingSoundTable)
    {
        return 44;
    }
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    static NSString *cellIndentifier = @"BaseCell";
    //    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    //    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UITableViewCellStyle style =  UITableViewCellStyleDefault;
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"BaseCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor whiteColor];
    if(tableView == self.settingSoundTable)
    {
        
        if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        {
            self.SoundImage = [[UIImageView alloc] initWithFrame:CGRectMake(250, 12, 21,21)];
        }
        else
        {
            self.SoundImage = [[UIImageView alloc] initWithFrame:CGRectMake(367, 12, 21,21)];
        }
        
        self.SoundImage.contentMode = UIViewContentModeScaleToFill;
        self.SoundImage.image = [UIImage imageNamed:@"btn_soungListUnactiveicon.png"];
        [cell addSubview:self.SoundImage];
        
        self.btnSoundSelect =[UIButton buttonWithType:UIButtonTypeCustom];
        [self.btnSoundSelect setImage:nil forState:UIControlStateNormal];
        if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        {
            self.btnSoundSelect.frame = CGRectMake(260, 11, 27, 27);
        }
        else
        {
            self.btnSoundSelect.frame = CGRectMake(640, 11, 27, 27);
        }
        
        self.btnSoundSelect.tag = indexPath.row;
        [self.btnSoundSelect addTarget:
         
         self action:@selector(setSound:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:self.btnSoundSelect];
        
        UILabel * taxTypeName = nil;
        if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        {
            taxTypeName = [[UILabel alloc] initWithFrame:CGRectMake(20, 12, 300, 20)];
        }
        else
        {
            taxTypeName = [[UILabel alloc] initWithFrame:CGRectMake(20, 12, 300, 20)];
        }
        taxTypeName.text = [NSString stringWithFormat:@"%@",(self.soundArray)[indexPath.row]];
        taxTypeName.numberOfLines = 0;
        taxTypeName.textAlignment = NSTextAlignmentLeft;
        taxTypeName.font = [UIFont fontWithName:@"Helvetica Neue" size:17];
        taxTypeName.backgroundColor = [UIColor clearColor];
        taxTypeName.textColor = [UIColor blackColor];
        [cell.contentView addSubview:taxTypeName];
        
        if (self.IndexSound == indexPath.row) {
            [self.btnSoundSelect setImage:[UIImage imageNamed:@"soundCheckMark.png"] forState:UIControlStateNormal];
            self.SoundImage.image = [UIImage imageNamed:@"btn_soungListActiveicon.png"];
            taxTypeName.textColor = [UIColor colorWithRed:0.0/255.0 green:115.0/255.0 blue:170.0/255.0 alpha:1.0];
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_switch_SoundSetting.on)
    {
        if(tableView == self.settingSoundTable)
        {
            NSString *path = [[NSBundle mainBundle] pathForResource:(self.soundArray)[indexPath.row] ofType:@"wav"];
            self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:NULL];
            [self.audioPlayer play];
            
            //[self.rmsDbController playButtonSound];
            self.IndexSound = indexPath.row;
            self.rmsDbController.globalSoundString = (self.soundArray)[indexPath.row];
            
            NSString *strSound=[NSString stringWithFormat:@"%ld",(long)indexPath.row];
            [[NSUserDefaults standardUserDefaults] setObject:self.rmsDbController.globalSoundString forKey:@"Sound"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            self.rmsDbController.globalSoundSetting = [[NSString alloc] init];
            self.rmsDbController.globalSoundSetting = self.rmsDbController.globalSoundString;
            [self.rmsDbController setupAudio];
            [[NSUserDefaults standardUserDefaults] setObject:strSound forKey:@"SelectedSound"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            
            [self.settingSoundTable reloadData];
        }
    }
}

-(void)setSound:(id)sender
{
    if(_switch_SoundSetting.on)
    {
        //[self.rmsDbController playButtonSound];
        self.rmsDbController.globalSoundString = nil;
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.settingSoundTable];
        NSIndexPath *indexPath = [self.settingSoundTable indexPathForRowAtPoint:buttonPosition];
        
        NSString *path = [[NSBundle mainBundle] pathForResource:(self.soundArray)[indexPath.row] ofType:@"wav"];
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:NULL];
        [self.audioPlayer play];
        
        //[self.rmsDbController playButtonSound];
        self.IndexSound = indexPath.row;
        self.rmsDbController.globalSoundString = (self.soundArray)[indexPath.row];
        NSString *strSound=[NSString stringWithFormat:@"%ld",(long)indexPath.row];
        [[NSUserDefaults standardUserDefaults] setObject:self.rmsDbController.globalSoundString forKey:@"Sound"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        self.rmsDbController.globalSoundSetting = [[NSString alloc] init];
        self.rmsDbController.globalSoundSetting = self.rmsDbController.globalSoundString;
        [self.rmsDbController setupAudio];
        [[NSUserDefaults standardUserDefaults] setObject:strSound forKey:@"SelectedSound"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        [self.settingSoundTable reloadData];
    }
    else
    {
        
    }
}

- (IBAction)switch_SoundSetting:(id)sender
{
    [self.rmsDbController playButtonSound];
    if(_switch_SoundSetting.on)
    {
        self.settingSoundTable.hidden=NO;
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"Sound"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        self.rmsDbController.globalSoundSetting = nil;
        [self.rmsDbController removeAudio];
        [[NSUserDefaults standardUserDefaults] setObject:@"-1" forKey:@"SelectedSound"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        self.IndexSound=-1;
        [self.settingSoundTable reloadData];
    }
}

-(void)SaveData
{
    [self.rmsDbController playButtonSound];
    NSString *strSound=[NSString stringWithFormat:@"%ld",(long)self.IndexSound];
    [[NSUserDefaults standardUserDefaults] setObject:self.rmsDbController.globalSoundString forKey:@"Sound"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    self.rmsDbController.globalSoundSetting = [[NSString alloc] init];
    self.rmsDbController.globalSoundSetting = self.rmsDbController.globalSoundString;
    [self.rmsDbController setupAudio];
    [[NSUserDefaults standardUserDefaults] setObject:strSound forKey:@"SelectedSound"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    [settingPopOver dismissPopoverAnimated:YES];
    settingPopOver = nil;
}

-(void)HidePopover
{
    [settingPopOver dismissPopoverAnimated:YES];
    settingPopOver = nil;
    self.IndexSound=[[[NSUserDefaults standardUserDefaults]valueForKey:@"SelectedSound"] integerValue];
    [self.settingSoundTable reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
