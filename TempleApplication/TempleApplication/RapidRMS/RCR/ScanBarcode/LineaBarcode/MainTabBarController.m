#import "MainTabBarController.h"
#import "NSDataCrypto.h"

@implementation MainTabBarController

-(void)enableCharging {
    [dtdev setCharging:[[NSUserDefaults standardUserDefaults] boolForKey:@"AutoCharging"] error:nil];
}

-(void)addController:(id)viewController
{
    NSMutableArray *controllers=[self.viewControllers mutableCopy];
    for(int i=0;i<controllers.count;i++)
        if([controllers objectAtIndex:i]==viewController)
            return;
    [controllers addObject:viewController];
    self.viewControllers=controllers;
}

-(void)removeController:(id)viewController
{
    NSMutableArray *controllers=[self.viewControllers mutableCopy];
    for(int i=0;i<controllers.count;i++)
        if([controllers objectAtIndex:i]==viewController)
        {
            [controllers removeObjectAtIndex:i];
            self.viewControllers=controllers;
            return;
        }
}

-(void)deviceFeatureSupported:(int)feature value:(int)value
{
#if !TARGET_IPHONE_SIMULATOR
    if(feature==FEAT_RF_READER)
    {
        if(value==FEAT_SUPPORTED)
        {
            [self addController:rfViewController];
        }else
        {
            [self removeController:rfViewController];
        }
    }
    if(feature==FEAT_MSR)
    {
        if(value&MSR_ENCRYPTED)
            [self addController:emsrCryptoViewController];
        else
            [self removeController:emsrCryptoViewController];
        
        if(value&MSR_PLAIN_WITH_ENCRYPTION)
            [self addController:cryptoViewController];
        else
            [self removeController:cryptoViewController];
    }
    if(feature==FEAT_PRINTING)
    {
        if(value==FEAT_SUPPORTED)
        {
            [self addController:printViewController];
            [dtdev prnPrintText:@"{=C}{+B}PRINTER CONNECTED" error:nil];
            //[dtdev prnFeedPaper:0 error:nil];
        }else
        {
            [self removeController:printViewController];
        }
    }
    if(feature==FEAT_EMVL2_KERNEL)
    {
        if(value==FEAT_SUPPORTED)
        {
            [self addController:emvViewController];
        }else
        {
            [self removeController:emvViewController];
        }
    }
#endif
}

/*-(void)testExtSerial
{
    bool r;
    NSError *error;
    r=[dtdev extOpenSerialPort:1 baudRate:9600 parity:PARITY_NONE dataBits:DATABITS_8 stopBits:STOPBITS_1 flowControl:FLOW_NONE error:&error];
    if(r)
    {
        r=[dtdev extWriteSerialPort:1 data:[@"Blah\n" dataUsingEncoding:NSASCIIStringEncoding] error:&error];
        {
            NSData *rcv=[dtdev extReadSerialPort:1 length:20000 timeout:0.2 error:&error];
            if(rcv)
            {
                NSLog(@"R(%d): %@",rcv.length,rcv);
                [dtdev extWriteSerialPort:1 data:rcv error:&error];
            }
        }
        [dtdev extCloseSerialPort:1 error:&error];
    }
}*/

-(void)displayAlert:(NSString *)title message:(NSString *)message
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
	[alert show];
}

-(void)connectionState:(int)state {
    NSError *error=nil;
    
    if(state==CONN_CONNECTED && UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone && [dtdev.deviceName hasPrefix:@"LINEAPad"])
    {
        self.tabBar.frame = CGRectMake(tabRect.origin.x, mainRect.size.height-80, tabRect.size.width, 65);
    }else
    {
        self.tabBar.frame = tabRect;
    }
    
	switch (state) {
		case CONN_DISCONNECTED:
		case CONN_CONNECTING:
#if TARGET_IPHONE_SIMULATOR
			[self setViewControllers:[NSArray arrayWithObjects:scannerViewController,
                                      settingsViewController,
                                      cryptoViewController,
                                      rfViewController,
                                      emsrCryptoViewController,
                                      printViewController,
                                      nil] animated:TRUE];
#else
			[self setViewControllers:[NSArray arrayWithObjects:scannerViewController,settingsViewController,nil] animated:FALSE];
#endif
			break;
		case CONN_CONNECTED:
            SHOWERR([dtdev barcodeSetTypeMode:BARCODE_TYPE_EXTENDED error:&error]);

            //setting various opticon barcode engine parameters
            if([dtdev getSupportedFeature:FEAT_BARCODE error:nil]&BARCODE_OPTICON)
            {
//                SHOWERR([dtdev barcodeOpticonSetInitString:@"JXJYDR" error:&error]);
//                SHOWERR([dtdev barcodeOpticonSetInitString:@"VE" error:&error]);
//                SHOWERR([dtdev barcodeOpticonSetInitString:@"B6" error:&error]);
//                SHOWERR([dtdev barcodeOpticonSetInitString:@"OF" error:&error]);
//                SHOWERR([dtdev barcodeOpticonSetInitString:@"V4[D01[DM2[D00" error:&error]);
//                SHOWERR([dtdev barcodeOpticonSetInitString:@"[DM2[D00YQ[BCDE6" error:&error]);
            }
            
            //setting various intermec barcode engine parameters
            if([dtdev getSupportedFeature:FEAT_BARCODE error:nil]&BARCODE_INTERMEC)
            {
//                const uint8_t intermecInit[]=
//                {
//                    0x41, //start
//                    0x7B,0x46,7, //set the illumination to 7%, do not go over 40%
//                    0x4f,0x40,1, //enable gs1 databar omnidirection
//                    0x4f,0x41,1, //enable gs1 databar limited
//                    0x4f,0x42,1, //enable gs1 databar extended
//                    0x4c,0x42,1, //enable micro pdf417
//                    0x55,0x40,1, //enable qr code
//                    0x53,0x40,1, //enable aztec code
//                };
//                SHOWERR([dtdev barcodeIntermecSetInitData:[NSData dataWithBytes:intermecInit length:sizeof(intermecInit)] error:&error]);
            }
            
            
            //setting various code barcode engine parameters
            if([dtdev getSupportedFeature:FEAT_BARCODE error:nil]&BARCODE_CODE)
            {
//                SHOWERR([dtdev barcodeCodeSetParam:0x29 value:1 error:&error]); //enable PDF-417
            }
			
            //encrypted head, you can check supported algorithms and select the one you want
            if([dtdev getSupportedFeature:FEAT_MSR error:nil]&MSR_ENCRYPTED)
            {
                int emsrAlgorithm=[[[NSUserDefaults standardUserDefaults] objectForKey:@"emsrAlgorithm"] intValue];
                if(emsrAlgorithm<=ALG_EH_AES256)
                    emsrAlgorithm=ALG_EH_AES256;
                [dtdev emsrSetEncryption:emsrAlgorithm params:nil error:nil];
                [dtdev emsrConfigMaskedDataShowExpiration:TRUE unmaskedDigitsAtStart:6 unmaskedDigitsAtEnd:2 error:nil];
                //NSArray *supported=[dtdev emsrGetSupportedEncryptions:&error];
                //[dtdev emsrSetEncryption:ALG_EH_IDTECH params:nil error:nil];
            }
            
            if([dtdev getSupportedFeature:FEAT_SMARTCARD error:nil]==FEAT_SUPPORTED)
            {
                SHOWERR([dtdev scInit:SLOT_MAIN error:nil]);
            }
            /*
            //change the sound made by the engine when it reads barcode
            int beep2[]={2730,150,65000,20,2730,150};
            [dtdev barcodeSetScanBeep:true volume:100 beepData:beep2 length:sizeof(beep2) error:nil];
             */
            
			//calling this function last, after all notifications has been called in all registered deleegates,
			//because enabling/disabling charge in firmware versions <2.34 will force disconnect and reconnect
            if([dtdev getSupportedFeature:FEAT_BATTERY_CHARGING error:nil]==FEAT_SUPPORTED)
            {
                [self performSelectorOnMainThread:@selector(enableCharging) withObject:nil waitUntilDone:NO];
            }
			
            //show the basic viewcontrollers only, the notificaton of supported features will add/remove them
            [self setViewControllers:[NSArray arrayWithObjects:scannerViewController,settingsViewController,nil] animated:FALSE];
            
            [self positionChanged:position];
			break;
	}
}

-(void)positionChanged:(int)newpos
{
    position=newpos;
    if(dtdev.connstate==CONN_CONNECTED)
    {
        if(![dtdev uiStopAnimation:ANIM_ALL error:nil])
            return;
        if(![dtdev uiFillRectangle:0 topLeftY:0 width:0 height:0 color:[UIColor blackColor] error:nil])
            return;
        
        if((position==POS_FLIPPED && dtdev.uiDisplayAtBottom) || !dtdev.uiDisplayAtBottom)
        {
            if(dtdev.uiDisplayHeight<64)
            {
                [dtdev uiDrawText:@"Use smart, magnetic\nor paypass card" topLeftX:0 topLeftY:0 font:FONT_6X8 error:nil];
            }else
            {
                [dtdev uiDrawText:@"\x01Use smart,\nmagnetic or\npaypass card" topLeftX:25 topLeftY:3 font:FONT_6X8 error:nil];
                //magnetic card
                [dtdev uiStartAnimation:5 topLeftX:99 topLeftY:0 animated:TRUE error:nil];
                //smartcard
                [dtdev uiStartAnimation:4 topLeftX:0 topLeftY:0 animated:TRUE error:nil];
                [dtdev uiDisplayImage:38 topLeftY:30 image:[UIImage imageNamed:@"paypass_logo.bmp"] error:nil];
            }
        }
    }
}

-(void)accelerometer:(UIAccelerometer *)acel didAccelerate:(UIAcceleration *)aceler
{
    if(position==-1)
    {
        if([aceler z]<0)
            [self positionChanged:POS_NORMAL];
        else
            [self positionChanged:POS_FLIPPED];
    }else
    {
        if(position==POS_NORMAL && [aceler z]>0.5)
            [self positionChanged:POS_FLIPPED];
        if(position==POS_FLIPPED && [aceler z]<-0.5)
            [self positionChanged:POS_NORMAL];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
}

-(void)viewWillDisappear:(BOOL)animated
{

}

-(void)viewDidLoad
{
    mainRect=self.view.frame;
    tabRect=self.tabBar.frame;
    
    //for the pinpad or display enabled devices, show some fancy stuff when turned around
	UIAccelerometer *accel = [UIAccelerometer sharedAccelerometer];
	accel.delegate = self;
	accel.updateInterval = 20.0f/60.0f;
    position=-1;
    
	//init dtdev class and connect it
	dtdev=[DTDevices sharedDevice];
	[dtdev addDelegate:self];
	[dtdev connect];
    [super viewDidLoad];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
        if(interfaceOrientation==UIInterfaceOrientationPortraitUpsideDown || interfaceOrientation==UIInterfaceOrientationPortrait)
            return YES;
    
    return NO;
}

-(void)dealloc
{
	[dtdev disconnect];
}

@end
