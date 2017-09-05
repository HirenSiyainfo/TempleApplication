//
//  TopUpDiscountVC.m
//  RapidRMS
//
//  Created by siya-IOS5 on 8/5/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "TopUpDiscountVC.h"
#import "RmsDbController.h"
#import "DiscountMasterListVC.h"

@interface TopUpDiscountVC ()<DiscountMasterListDelegate,UpdateDelegate>
{
    NSString *sDiscount;
    NSString *sDiscType;
    IBOutlet   UITextField *txtDiscountAmt;
    IBOutlet UIButton *ItemDiscount;
    IBOutlet UIButton *BillDiscount;
    IBOutlet UIButton *PerDiscount;
    IBOutlet UIButton *AmtDiscount;
    NSNumberFormatter *discountCurrencyFormatter;
    IBOutlet  UIView *numpadDiscount;
    IBOutlet UIButton *salesDiscount;
    IBOutlet UIButton *manualDiscount;
    DiscountMasterListVC *discountMasterListVC;
    IBOutlet UIView *discountContainerView;
    NSDictionary *salesDiscountDictionary;
    
    IBOutlet UIView *salesButtonView;
    IBOutlet UIView *manualButtonView;
    
    IBOutlet UIView *viewDiscountOn;
    IBOutlet UIView *viewUnittype;

    IBOutlet UIView *discountNumpadView;
    
}
@property (nonatomic, strong) RcrController *crmController;
@property (strong, nonatomic) RmsDbController *rmsDbController;
@property (strong, nonatomic) UpdateManager *updateManager;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

@implementation TopUpDiscountVC

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
    [super viewDidLoad];
    self.crmController = [RcrController sharedCrmController];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    self.updateManager = [[UpdateManager alloc]initWithManagedObjectContext:self.managedObjectContext delegate:self];
    sDiscType=@"Per";
    sDiscount=@"Item";
    txtDiscountAmt.text= @"";
    ItemDiscount.selected = YES;
    BillDiscount.selected = NO;
    PerDiscount.selected = YES;

  
    [self showSalesDiscountView];
    discountNumpadView.hidden = YES;
    
    manualDiscount.titleLabel.numberOfLines = 0.0;
    salesDiscount.titleLabel.numberOfLines = 0.0;

    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if([self getDiscountMasterList] == 0)
    {
        [self salesManualDiscount:manualDiscount];
    }
}

-(NSInteger)getDiscountMasterList{
    
    NSUInteger count=0;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"DiscountMaster" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    NSPredicate *predicatesalesDiscount = [NSPredicate predicateWithFormat:@"salesDiscount = %@", @(TRUE)];
    fetchRequest.predicate = predicatesalesDiscount;
    
    count = [UpdateManager countForContext:self.managedObjectContext FetchRequest:fetchRequest];
    return count;


}

-(void)showSalesDiscountView
{
    salesDiscount.selected = YES;
    salesDiscount.userInteractionEnabled = NO;
    manualDiscount.selected = NO;
    
    [UIView animateWithDuration:0.3 animations:^{
        viewDiscountOn.frame = CGRectMake(117, 0, viewDiscountOn.frame.size.width, viewDiscountOn.frame.size.height);
        viewUnittype.alpha = 0.0;

    } completion:^(BOOL finished)
     {
         
     }];

    if (!discountMasterListVC) {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"RcrStoryboard" bundle:nil];
        discountMasterListVC = [storyBoard instantiateViewControllerWithIdentifier:@"DiscountMasterListVC"];
        discountMasterListVC.view.frame = discountContainerView.bounds;
        discountMasterListVC.discountMasterListDelegate = self;
        [discountContainerView addSubview:discountMasterListVC.view];
        [discountContainerView bringSubviewToFront:discountMasterListVC.view];
    }
}

-(IBAction)salesManualDiscount:(id)sender
{
    salesDiscount.selected = NO;
    manualDiscount.selected = NO;
    UIButton *selectedButton = (UIButton *)sender;
    selectedButton.selected = YES;
    
    CGFloat salesButtonWidth;
    CGFloat manualButtonWidth;

    if (salesButtonView.frame.size.width == 278)
    {
        salesButtonWidth = 104;
        manualButtonWidth = 278;
        discountNumpadView.hidden = NO;
        discountMasterListVC.view.hidden = YES;
        manualDiscount.userInteractionEnabled = NO;
        salesDiscount.userInteractionEnabled = YES;
        [UIView animateWithDuration:0.3 animations:^{
            viewDiscountOn.frame = CGRectMake(17, 0, viewDiscountOn.frame.size.width, viewDiscountOn.frame.size.height);
            viewUnittype.alpha = 1.0;

        } completion:^(BOOL finished)
         {
             
         }];
        [UIView transitionFromView:discountMasterListVC.view toView:discountNumpadView duration:0.5 options:UIViewAnimationOptionTransitionFlipFromBottom completion:^(BOOL finished) {
        }];
    }
    else
    {
        salesButtonWidth = 278;
        manualButtonWidth = 104;
        discountNumpadView.hidden = YES;
        discountMasterListVC.view.hidden = NO;
        manualDiscount.userInteractionEnabled = YES;
        salesDiscount.userInteractionEnabled = NO;
      
        [UIView animateWithDuration:0.3 animations:^{
            viewDiscountOn.frame = CGRectMake(117, 0, viewDiscountOn.frame.size.width, viewDiscountOn.frame.size.height);
            viewUnittype.alpha = 0.0;

        } completion:^(BOOL finished)
        {

        }];
        [UIView transitionFromView:discountNumpadView toView:discountMasterListVC.view duration:0.5 options:UIViewAnimationOptionTransitionFlipFromTop completion:^(BOOL finished) {
        }];
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        salesButtonView.frame = CGRectMake(salesButtonView.frame.origin.x, salesButtonView.frame.origin.y, salesButtonWidth, salesButtonView.frame.size.height);
        manualButtonView.frame = CGRectMake(salesButtonWidth + 6 , manualButtonView.frame.origin.y, manualButtonWidth, manualButtonView.frame.size.height);
    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)cancelButtonClicked:(id)sender
{
    [self.topUpDiscountDelegate didCancelTopupDiscount];
}

-(IBAction)removediscount:(id)sender
{
    [self.topUpDiscountDelegate didRemoveTopupDiscount];
}

-(IBAction)adddiscount:(id)sender
{
    NSString *discountType = @"";
    NSString *discountValue = @"";
    NSString *selectedDiscountType = @"";
    NSString *discountAmount = @"";

    NSNumber *discountId = @(0);
    if (salesDiscount.selected == YES)
    {
        discountValue = salesDiscountDictionary[@"DiscountValue"];
        discountType = salesDiscountDictionary[@"DiscountType"];
        discountId = salesDiscountDictionary[@"DiscountId"];
        selectedDiscountType = @"Sales";
    }
    else if (manualDiscount.selected == YES)
    {
        discountValue = txtDiscountAmt.text;
        discountType = sDiscType;
        selectedDiscountType = @"Manual";
        if ([discountType isEqualToString:@"Per"]) {
            discountAmount = [discountValue stringByReplacingOccurrencesOfString:@"%" withString:@""];
        }

    }
    else
    {
        
    }
    if(discountType!=nil){
        
        if(discountAmount.floatValue <= 100)
        {
        [self.topUpDiscountDelegate didAddTopupDiscountWithDiscountType:sDiscount withDiscountAmount:discountValue
                                                   withItemDiscountType:discountType selectedDiscountType:selectedDiscountType withItemDiscountID:discountId];
        }
    }
    
}

- (IBAction)btnItemDiscClick:(UIButton *)sender
{
  //  [self.rmsDbController playButtonSound];
   // [sender setBackgroundColor:[UIColor colorWithRed:13.0/255.0 green:130.0/255.0 blue:90.0/255.0 alpha:1.0]];
    //[BillDiscount setBackgroundColor:[UIColor clearColor]];
    ItemDiscount.selected = YES;
    BillDiscount.selected = NO;
    sDiscount=@"Item";
}

- (IBAction)btnBillDiscClick:(UIButton *)sender
{
   // [self.rmsDbController playButtonSound];
    //[sender setBackgroundColor:[UIColor colorWithRed:13.0/255.0 green:130.0/255.0 blue:90.0/255.0 alpha:1.0]];
   // [ItemDiscount setBackgroundColor:[UIColor clearColor]];
    
    ItemDiscount.selected = NO;
    BillDiscount.selected = YES;
    sDiscount=@"Bill";
}

- (IBAction)btnPerDiscClick:(UIButton *)sender
{
   // [self.rmsDbController playButtonSound];
    
    //[sender setBackgroundColor:[UIColor colorWithRed:13.0/255.0 green:130.0/255.0 blue:90.0/255.0 alpha:1.0]];
    //[AmtDiscount setBackgroundColor:[UIColor clearColor]];
    
    PerDiscount.selected = YES;
    AmtDiscount.selected = NO;

    sDiscType=@"Per";
    
    if(! [txtDiscountAmt.text isEqualToString:@""])
    {
        txtDiscountAmt.text = [txtDiscountAmt.text stringByReplacingOccurrencesOfString:self.crmController.currencyFormatter.currencySymbol withString:@"%"];
    }
}



- (IBAction)btnAmtDiscClick:(UIButton *)sender
{
 //   [self.rmsDbController playButtonSound];
    //[sender setBackgroundColor:[UIColor colorWithRed:13.0/255.0 green:130.0/255.0 blue:90.0/255.0 alpha:1.0]];
    //[PerDiscount setBackgroundColor:[UIColor clearColor]];
    
    PerDiscount.selected = NO;
    AmtDiscount.selected = YES;
    sDiscType=@"Amount";
    if(! [txtDiscountAmt.text isEqualToString:@""])
    {
        txtDiscountAmt.text = [txtDiscountAmt.text stringByReplacingOccurrencesOfString:@"%"  withString:self.rmsDbController.currencyFormatter.currencySymbol];
    }
}
- (IBAction) btnDiscpressKeyPadButton:(id)sender
{
  //  [self.rmsDbController playButtonSound];
    discountCurrencyFormatter = [[NSNumberFormatter alloc] init];
    discountCurrencyFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    discountCurrencyFormatter.maximumFractionDigits = 0;
    UIButton *btn;
    for(int i=0;i<numpadDiscount.subviews.count;i++){
        
        btn=(numpadDiscount.subviews)[i];
        
        if([btn isKindOfClass:[UIButton class]])
        {
            if(btn.tag==[sender tag])
            {
                if(btn.tag==0)
                {
                    [btn setImage:[UIImage imageNamed:@"btn_num0Active.png"] forState:UIControlStateNormal];
                }
                else if(btn.tag==-99)
                {
                    [btn setImage:[UIImage imageNamed:@"btn_num_c_Active.png"] forState:UIControlStateNormal];
                }
                else if(btn.tag==101)
                {
                    [btn setImage:[UIImage imageNamed:@"btn_num00Active.png"] forState:UIControlStateNormal];
                }
                else if (btn.tag > 0 && btn.tag < 10)
                {
                    NSString *strImg = [NSString stringWithFormat:@"btn_num%ldActive.png",(long)btn.tag];
                    [btn setImage:[UIImage imageNamed:strImg] forState:UIControlStateNormal];
                }
                else
                {
                    
                }
            }
            else{
                
                if(btn.tag==0)
                {
                    [btn setImage:[UIImage imageNamed:@"btn_num0Normal.png"] forState:UIControlStateNormal];
                }
                else if(btn.tag==-99)
                {
                    
                    [btn setImage:[UIImage imageNamed:@"btn_num_c_Normal.png"] forState:UIControlStateNormal];
                }
                else if(btn.tag==101)
                {
                    [btn setImage:[UIImage imageNamed:@"btn_num00Normal.png"] forState:UIControlStateNormal];
                }
                else if (btn.tag > 0 && btn.tag < 10)
                {
                    
                    NSString *strImg = [NSString stringWithFormat:@"btn_num%ldNormal.png",(long)btn.tag];
                    
                    [btn setImage:[UIImage imageNamed:strImg] forState:UIControlStateNormal];
                }
                else
                {
                    
                }
            }
        }
    }
    
    
    if ([sender tag] >= 0 && [sender tag] < 10) {
		if (txtDiscountAmt.text.length > 0) {
			NSString * displyValue = [txtDiscountAmt.text stringByAppendingFormat:@"%ld",(long)[sender tag]];
			txtDiscountAmt.text = displyValue;
		} else {
			NSString * displyValue = @"";
            if([sDiscType isEqualToString:@"Per"])
            {
				displyValue = [txtDiscountAmt.text stringByAppendingFormat:@"%@%ld",@"%",(long)[sender tag]];
                txtDiscountAmt.text = displyValue;
                
			} else
            {
                NSString * displyValue = [txtDiscountAmt.text stringByAppendingFormat:@"%ld",(long)[sender tag]];
                NSNumber *sPrice = @(displyValue.floatValue);
                NSString *iAmount = [discountCurrencyFormatter stringFromNumber:sPrice];
				txtDiscountAmt.text = iAmount;
			}
		}
	}
    else if ([sender tag] == -99) {
		if (txtDiscountAmt.text.length > 0) {
			txtDiscountAmt.text = @"";
		}
	} else if ([sender tag] == 101) {
		if (txtDiscountAmt.text.length > 0) {
			NSString * displyValue = [txtDiscountAmt.text stringByAppendingFormat:@"00"];
			txtDiscountAmt.text = displyValue;
		}
    }
    if([sDiscType isEqualToString:@"Per"])
    {
		if ([[txtDiscountAmt.text stringByReplacingOccurrencesOfString:@"%" withString:@""] stringByReplacingOccurrencesOfString:@"." withString:@""].length > 1) {
			txtDiscountAmt.text = [txtDiscountAmt.text stringByReplacingOccurrencesOfString:@"." withString:@""];
			txtDiscountAmt.text = [NSString stringWithFormat:@"%@.%@",[txtDiscountAmt.text substringToIndex:txtDiscountAmt.text.length-2],[txtDiscountAmt.text substringFromIndex:txtDiscountAmt.text.length-2]];
		} else if ([[txtDiscountAmt.text stringByReplacingOccurrencesOfString:@"%" withString:@""] stringByReplacingOccurrencesOfString:@"." withString:@""].length == 1) {
			txtDiscountAmt.text = [txtDiscountAmt.text stringByReplacingOccurrencesOfString:@"." withString:@""];
			txtDiscountAmt.text = [NSString stringWithFormat:@"%@.%@",[txtDiscountAmt.text substringToIndex:txtDiscountAmt.text.length-1],[txtDiscountAmt.text substringFromIndex:txtDiscountAmt.text.length-1]];
		}
	}else {
		if ([txtDiscountAmt.text stringByReplacingOccurrencesOfString:@"." withString:@""].length > 1)
        {
			txtDiscountAmt.text = [txtDiscountAmt.text stringByReplacingOccurrencesOfString:@"." withString:@""];
			txtDiscountAmt.text = [NSString stringWithFormat:@"%@.%@",[txtDiscountAmt.text substringToIndex:txtDiscountAmt.text.length-2],[txtDiscountAmt.text substringFromIndex:txtDiscountAmt.text.length-2]];
		} else if ([txtDiscountAmt.text stringByReplacingOccurrencesOfString:@"." withString:@""].length == 1)
        {
			txtDiscountAmt.text = [txtDiscountAmt.text stringByReplacingOccurrencesOfString:@"." withString:@""];
			txtDiscountAmt.text = [NSString stringWithFormat:@"%@.%@",[txtDiscountAmt.text substringToIndex:txtDiscountAmt.text.length-1],[txtDiscountAmt.text substringFromIndex:txtDiscountAmt.text.length-1]];
		}
	}
	if (txtDiscountAmt.text.length > 2) {
        if([sDiscType isEqualToString:@"Per"])
        {
			txtDiscountAmt.text = [txtDiscountAmt.text stringByReplacingOccurrencesOfString:self.rmsDbController.currencyFormatter.currencySymbol withString:@"%"];
		} else {
			txtDiscountAmt.text = [txtDiscountAmt.text stringByReplacingOccurrencesOfString:@"%" withString:self.rmsDbController.currencyFormatter.currencySymbol];
        }
	}
}
#pragma mark-
#pragma Discount master List Delgate Method
-(void)didSelectSalesDiscount :(NSDictionary *)discountInfo
{
    salesDiscountDictionary = discountInfo;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
