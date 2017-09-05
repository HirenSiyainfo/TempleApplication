#import "PrintViewController.h"


@implementation PrintViewController

-(void)displayAlert:(NSString *)title message:(NSString *)message
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
	[alert show];
}

-(void)paperStatus:(BOOL)present
{
    [paperStatusLabel setText:present?@"":@"Out of paper!"];
}

#define COMMAND(operation,x) if(!x){[self displayAlert:@"Error" message:[NSString stringWithFormat:@"%@ failed with error: %@",operation,err.localizedDescription]]; return; }


-(IBAction)onFontsDemo:(id)sender;
{
    NSError *err;
    
	COMMAND(@"Print text",[dtdev prnPrintText:@"{=C}FONT SIZES" usingEncoding:NSWindowsCP1252StringEncoding error:&err]);
    COMMAND(@"Print text",[dtdev prnPrintText:@"{=F0}Font 9x16\n{+DW}Double width\n{-DW}{+DH}Double height\n{+DW}{+DH}DW & DH" usingEncoding:NSWindowsCP1252StringEncoding error:&err]);
	COMMAND(@"Print text",[dtdev prnPrintText:@"{=F1}Font 12x24\n{+DW}Double width\n{-DW}{+DH}Double height\n{+DW}{+DH}DW & DH" usingEncoding:NSWindowsCP1252StringEncoding error:&err]);
	
	COMMAND(@"Print text",[dtdev prnPrintText:@"{=C}FONT STYLES\n{=L}Normal\n{+B}Bold\n{+I}Bold Italic{-I}{-B}\n{+U}Underlined{-U}\n{+V}Inversed{-V}\n" usingEncoding:NSWindowsCP1252StringEncoding error:&err]);
	COMMAND(@"Print text",[dtdev prnPrintText:@"{=C}FONT ROTATION\n{=L}{=R1}Rotated 90 degrees\n{=R2}Rotated 180 degrees\n" usingEncoding:NSWindowsCP1252StringEncoding error:&err]);
	
	COMMAND(@"Print text",[dtdev prnPrintText:@"{+W}{=F0}This function demonstrates the use of the built-in word-wrapping capability" usingEncoding:NSWindowsCP1252StringEncoding error:&err]);
	COMMAND(@"Print text",[dtdev prnPrintText:@"{+W}{=F1}This function demonstrates the use of the built-in word-wrapping capability" usingEncoding:NSWindowsCP1252StringEncoding error:&err]);
	COMMAND(@"Print text",[dtdev prnPrintText:@"{+W}{=F0}{=J}This function demonstrates the use of the built-in word-wrapping capability and the use of justify" usingEncoding:NSWindowsCP1252StringEncoding error:&err]);
	COMMAND(@"Print text",[dtdev prnPrintText:@"{+W}{=F1}{=J}This function demonstrates the use of the built-in word-wrapping capability and the use of justify" usingEncoding:NSWindowsCP1252StringEncoding error:&err]);
    
	COMMAND(@"Print text",[dtdev prnPrintText:@"{+W}{=L}Left {=R}and right aligned" usingEncoding:NSWindowsCP1252StringEncoding error:&err]);
    
	COMMAND(@"Feed paper",[dtdev prnFeedPaper:0 error:&err]);
    COMMAND(@"Wait for job",[dtdev prnWaitPrintJob:30 error:&err]);
}

-(IBAction)onSelfTest:(id)sender;
{
    NSError *err;
    
	COMMAND(@"Print logo",[dtdev prnPrintLogo:LOGO_NORMAL error:&err]);
	COMMAND(@"Print self test",[dtdev prnSelfTest:FALSE error:&err]);
	
    COMMAND(@"Wait for job",[dtdev prnWaitPrintJob:30 error:&err]);
}

-(IBAction)onCalibrate:(id)sender;
{
    NSError *err;
    
    int calib=0;
    //    COMMAND("Calibrate",[dtdev prnCalibrateBlackMark:&calib error:&err]);
    if(![dtdev prnCalibrateBlackMark:&calib error:&err])
    {
        [self displayAlert:@"Error" message:[NSString stringWithFormat:@"%@ failed with error: %@",@"Calibrate",err.localizedDescription]];
        return;
    }
}

-(IBAction)onBarcodesDemo:(id)sender;
{
    NSError *err;
    
	COMMAND(@"Barcode settings",[dtdev prnSetBarcodeSettings:2 height:77 hriPosition:BAR_TEXT_BELOW align:ALIGN_LEFT error:&err]);
	
	COMMAND(@"Print text",[dtdev prnPrintText:@"UPC-A" usingEncoding:NSWindowsCP1252StringEncoding error:&err]);
	COMMAND(@"Print barcode",[dtdev prnPrintBarcode:BAR_PRN_UPCA barcode:[@"12345678901" dataUsingEncoding:NSASCIIStringEncoding] error:&err]);
	COMMAND(@"Print text",[dtdev prnPrintText:@"\nUPC-E" usingEncoding:NSWindowsCP1252StringEncoding error:&err]);
	COMMAND(@"Print barcode",[dtdev prnPrintBarcode:BAR_PRN_UPCE barcode:[@"012340000040" dataUsingEncoding:NSASCIIStringEncoding] error:&err]);
	COMMAND(@"Print text",[dtdev prnPrintText:@"\nJAN13(EAN)" usingEncoding:NSWindowsCP1252StringEncoding error:&err]);
	COMMAND(@"Print barcode",[dtdev prnPrintBarcode:BAR_PRN_EAN13 barcode:[@"123456789012" dataUsingEncoding:NSASCIIStringEncoding] error:&err]);
	COMMAND(@"Print text",[dtdev prnPrintText:@"\nJAN8(EAN)" usingEncoding:NSWindowsCP1252StringEncoding error:&err]);
	COMMAND(@"Print barcode",[dtdev prnPrintBarcode:BAR_PRN_EAN8 barcode:[@"96385074" dataUsingEncoding:NSASCIIStringEncoding] error:&err]);
	COMMAND(@"Print text",[dtdev prnPrintText:@"\nCODE 39" usingEncoding:NSWindowsCP1252StringEncoding error:&err]);
	COMMAND(@"Print barcode",[dtdev prnPrintBarcode:BAR_PRN_CODE39 barcode:[@"1A1234567" dataUsingEncoding:NSASCIIStringEncoding] error:&err]);
	COMMAND(@"Print text",[dtdev prnPrintText:@"\nITF" usingEncoding:NSWindowsCP1252StringEncoding error:&err]);
	COMMAND(@"Print barcode",[dtdev prnPrintBarcode:BAR_PRN_ITF barcode:[@"123456789012" dataUsingEncoding:NSASCIIStringEncoding] error:&err]);
	COMMAND(@"Print text",[dtdev prnPrintText:@"\nCODABAR (NW-7)" usingEncoding:NSWindowsCP1252StringEncoding error:&err]);
	COMMAND(@"Print barcode",[dtdev prnPrintBarcode:BAR_PRN_CODABAR barcode:[@"A12356789A" dataUsingEncoding:NSASCIIStringEncoding] error:&err]);
	COMMAND(@"Print text",[dtdev prnPrintText:@"\nCODE 93" usingEncoding:NSWindowsCP1252StringEncoding error:&err]);
	COMMAND(@"Print barcode",[dtdev prnPrintBarcode:BAR_PRN_CODE93 barcode:[@"AABCD12345" dataUsingEncoding:NSASCIIStringEncoding] error:&err]);
	COMMAND(@"Print text",[dtdev prnPrintText:@"\nCODE 128" usingEncoding:NSWindowsCP1252StringEncoding error:&err]);
	COMMAND(@"Print barcode",[dtdev prnPrintBarcode:BAR_PRN_CODE128 barcode:[@"BABCD12345" dataUsingEncoding:NSASCIIStringEncoding] error:&err]);
	COMMAND(@"Print text",[dtdev prnPrintText:@"\nPDF-417" usingEncoding:NSWindowsCP1252StringEncoding error:&err]);
	COMMAND(@"Print barcode",[dtdev prnPrintBarcode:BAR_PRN_PDF417 barcode:[@"Hey try to read this :)" dataUsingEncoding:NSASCIIStringEncoding] error:&err]);
	
	COMMAND(@"Feed paper",[dtdev prnFeedPaper:0 error:&err]);
    COMMAND(@"Wait for job",[dtdev prnWaitPrintJob:30 error:&err]);
}

-(IBAction)onGraphicsDemo:(id)sender;
{
    NSError *err;

    NSDate *d=[NSDate date];
    
	COMMAND(@"Print image",[dtdev prnPrintImage:[UIImage imageNamed:@"taz.png"] align:ALIGN_CENTER error:&err]);
	
	COMMAND(@"Feed paper",[dtdev prnFeedPaper:0 error:&err]);
    [self displayAlert:@"Print done" message:[NSString stringWithFormat:@"Time taken: %.02f",-[d timeIntervalSinceNow]]];
    COMMAND(@"Wait for job",[dtdev prnWaitPrintJob:30 error:&err]);
}

-(IBAction)onLoadLogo:(id)sender;
{
    NSError *err;
    
    COMMAND(@"Load logo",[dtdev prnLoadLogo:[UIImage imageNamed:@"Icon-72.png"] align:ALIGN_CENTER error:&err]);
    COMMAND(@"Print logo",[dtdev prnPrintLogo:LOGO_NORMAL error:&err]);
    
	COMMAND(@"Feed paper",[dtdev prnFeedPaper:0 error:&err]);
    COMMAND(@"Wait for job",[dtdev prnWaitPrintJob:30 error:&err]);
}

-(void)viewWillAppear:(BOOL)animated
{
}

-(void)viewWillDisappear:(BOOL)animated
{
}

-(void)viewDidLoad
{
	dtdev=[DTDevices sharedDevice];
    [dtdev addDelegate:self];
    [super viewDidLoad];
    [self paperStatus:true];
}


@end
