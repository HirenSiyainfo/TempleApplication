//
//  popOverController.m
//  POSFrontEnd
//
//  Created by Minesh Purohit on 04/12/11.
//  Copyright 2011 Home. All rights reserved.
//

#import "packageQtyEditorVC.h"
#import "RmsDbController.h"

@interface packageQtyEditorVC ()

@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, weak) IBOutlet UITextField * topinPrice;

@end

@implementation packageQtyEditorVC

@synthesize topinPrice;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    UITextField *inputTextField = (UITextField *)self.inputControl;
    inputTextField.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:153.0/255.0 alpha:1.0];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
}

// tender keypad action
- (IBAction) tenderNumPadButtonAction:(id)sender
{
    [self.rmsDbController playButtonSound];
    
    if ([sender tag] >= 0 && [sender tag] < 10)
    {
        if (topinPrice.text==nil )
        {
            topinPrice.text=@"";
        }
        NSString * displyValue = [topinPrice.text stringByAppendingFormat:@"%ld",(long)[sender tag]];
        topinPrice.text = displyValue;
	}
    else if ([sender tag] == -98)
    {
		if (topinPrice.text.length > 0)
        {
            topinPrice.text = [topinPrice.text substringToIndex:topinPrice.text.length-1];
		}
	}
    else if ([sender tag] == -99)
    {
		if (topinPrice.text.length > 0)
        {
            topinPrice.text = @"";
		}
	}
    else if ([sender tag] == 101)
    {
        if ([topinPrice.text rangeOfString:@"."].location != NSNotFound)
        {
            // Found
        }
        else
        {
            // Not Found
            NSString * displyValue = [topinPrice.text stringByAppendingFormat:@"."];
            topinPrice.text = displyValue;
        }
	}
    else if ([sender tag] == 102)
    {
        topinPrice.text = [topinPrice.text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
      
        NSString * displyValue = [topinPrice.text stringByAppendingFormat:@"00"];
        topinPrice.text = displyValue;
    }

}

- (IBAction)enterClicked:(id)sender
{
//    if(([self.inputControl tag] == 1114) || ([self.inputControl tag] == 2514))
//    {
        NSArray *stringArray = [topinPrice.text componentsSeparatedByString:@"." ];
        if(stringArray.count == 2)
        {
            NSInteger y = [stringArray[1] integerValue ];
            if(y >= self.noOfItems )
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {};
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Please enter correct quantity." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                topinPrice.text = @"";
                return;
            }
        }
        else
        {
        }
        UITextField *inputTextField = (UITextField *)self.inputControl;
        inputTextField.backgroundColor = [UIColor clearColor];
        NSString *inputValue = [topinPrice.text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
        [self.packageQtyEditorVCDelegate didEnter:self.inputControl inputValue:inputValue.floatValue];
//    }
}

- (IBAction)cancelClicked:(id)sender
{
    UITextField *inputTextField = (UITextField *)self.inputControl;
    inputTextField.backgroundColor = [UIColor clearColor];
	[self.packageQtyEditorVCDelegate didCancel];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    UITextField *inputTextField = (UITextField *)self.inputControl;
    inputTextField.backgroundColor = [UIColor clearColor];
}

@end