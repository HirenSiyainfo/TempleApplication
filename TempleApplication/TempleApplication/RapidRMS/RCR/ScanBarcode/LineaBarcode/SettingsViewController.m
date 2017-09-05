#import "SettingsViewController.h"
#import "NSDataCrypto.h"

@implementation SettingsViewController

@synthesize scanMode;

static NSString *settings[]={
	@"Beep upon scan",
	@"Enable scan button",
	@"Automated charge enabled",
	@"Reset barcode engine",
};

static NSString *scan_modes[]={
	@"Single scan",
	@"Multi scan",
	@"Motion detect",
	@"Single scan on button release",
    @"Multi scan without duplicates",
};

enum SECTIONS{
    SEC_GENERAL=0,
    SEC_BARCODE_MODE,
    SEC_BT_DEVICES,
    SEC_TCP_DEVICES,
    SEC_FIRMWARE_UPDATE,
    SEC_LAST
};


enum SETTINGS{
	SET_BEEP=0,
	SET_ENABLE_SCAN_BUTTON,
	SET_AUTOCHARGING,
	SET_RESET_BARCODE,
    SET_LAST
};

enum UPDATE_TARGETS{
    TARGET_DEVICE=0,
    TARGET_OPTICON,
    TARGET_CODE,
};

static BOOL settings_values[SET_LAST];

int beep1[]={2730,250};
int beep2[]={2730,150,65000,20,2730,150};

-(void)displayAlert:(NSString *)title message:(NSString *)message
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
	[alert show];
}

-(NSString *)getFirmwareFileName
{
	NSError *error;
	NSString *name=[[dtdev.deviceName stringByReplacingOccurrencesOfString:@" " withString:@""] lowercaseString];
	NSArray *files=[[NSFileManager defaultManager] contentsOfDirectoryAtPath:[[NSBundle mainBundle] resourcePath] error:&error];
	int lastVer=0;
	NSString *lastPath;
	for(int i=0;i<[files count];i++)
	{
		NSString *file=[[files objectAtIndex:i] lastPathComponent];
		if([[file lowercaseString] rangeOfString:name].location!=NSNotFound)
		{
			NSString *path=[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:file];
            NSDictionary *info=[dtdev getFirmwareFileInformation:[NSData dataWithContentsOfFile:path] error:&error];
            if(info)
			if(info && [[info objectForKey:@"deviceName"] isEqualToString:dtdev.deviceName] && [[info objectForKey:@"deviceModel"] isEqualToString:dtdev.deviceModel] && [[info objectForKey:@"firmwareRevisionNumber"] intValue]>lastVer)
			{
				lastPath=path;
				lastVer=[[info objectForKey:@"firmwareRevisionNumber"] intValue];
			}
		}
	}
	if(lastVer>0)
		return lastPath;
	return nil;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)theTextField;
{
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField;
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:textField.text forKey:@"tcpAddress"];
    [prefs synchronize];
    
	[textField resignFirstResponder];
	return YES;
}

-(void)connectionState:(int)state {
    NSError *error;
    
	switch (state) {
		case CONN_DISCONNECTED:
		case CONN_CONNECTING:
			break;
		case CONN_CONNECTED:
			//set defaults
			settings_values[SET_BEEP]=TRUE;
			
			//read settings
            int value;
			if([dtdev barcodeGetScanButtonMode:&value error:&error])
                settings_values[SET_ENABLE_SCAN_BUTTON]=(value==BUTTON_ENABLED);
            else
                settings_values[SET_ENABLE_SCAN_BUTTON]=FALSE;
            
			settings_values[SET_AUTOCHARGING]=[[NSUserDefaults standardUserDefaults] boolForKey:@"AutoCharging"];

            if(![dtdev barcodeGetScanMode:&scanMode error:&error])
                scanMode=0;
			
			[settingsTable reloadData];
			break;
	}
}

-(void)bluetoothDeviceDiscovered:(NSString *)btAddress name:(NSString *)btName
{
    if(!btName || btName.length==0)
        btName=@"Unknown";
    [btDevices addObject:btAddress];
    [btDevices addObject:btName];
}

-(void)bluetoothDiscoverComplete:(BOOL)success
{
    [progressViewController.view removeFromSuperview];
    [settingsTable reloadData];
    if(!success)
        [self displayAlert:NSLocalizedString(@"Bluetooth Error",nil) message:NSLocalizedString(@"Discovery failed!",nil)];
    
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:btDevices forKey:@"bluetoothDevices"];
    [prefs synchronize];
}

-(void)deviceFeatureSupported:(int)feature value:(int)value
{
    [settingsTable reloadData];
}

-(void)firmwareUpdateEnd:(NSError *)error
{
    [progressViewController.view removeFromSuperview];
    if(error)
        [self displayAlert:NSLocalizedString(@"Firmware Update",nil) message:[NSString stringWithFormat:NSLocalizedString(@"Firmware updated failed with error:%@",nil),error.localizedDescription]];
}

-(void)firmwareUpdateDisplayProgress
{
    switch (progressPhase)
    {
        case UPDATE_INIT:
            [progressViewController updateProgress:NSLocalizedString(@"Initializing update...",nil) progress:progressPercent];
            break;
        case UPDATE_ERASE:
            [progressViewController updateProgress:NSLocalizedString(@"Erasing flash...",nil) progress:progressPercent];
            break;
        case UPDATE_WRITE:
            [progressViewController updateProgress:NSLocalizedString(@"Writing firmware...",nil) progress:progressPercent];
            break;
        case UPDATE_COMPLETING:
            [progressViewController updateProgress:NSLocalizedString(@"Completing operation...",nil) progress:progressPercent];
            break;
        case UPDATE_FINISH:
            [progressViewController updateProgress:NSLocalizedString(@"Complete!",nil) progress:progressPercent];
            break;
    }
}
    
-(void)firmwareUpdateProgress:(int)phase percent:(int)percent
{
    progressPhase=phase;
    progressPercent=percent;
    [self performSelectorOnMainThread:@selector(firmwareUpdateDisplayProgress) withObject:nil waitUntilDone:FALSE];
}

-(void)firmwareUpdateThread:(NSString *)file
{
	@autoreleasepool {
        NSError *error=nil;
    
        BOOL idleTimerDisabled_Old=[UIApplication sharedApplication].idleTimerDisabled;
        [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
        
        if(firmareTarget==TARGET_DEVICE)
        {
            [progressViewController performSelectorOnMainThread:@selector(updateText:) withObject:@"Updating Linea...\nPlease wait!" waitUntilDone:NO];
            
            //In case authentication key is present in Linea, we need to authenticate with it first, before firmware update is allowed
            //For the sample here I'm using the field "Authentication key" in the crypto settings as data and generally ignoring the result of the
            //authentication operation, firmware update will just fail if authentication have failed
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            //last used decryption key is stored in preferences
            NSString *authenticationKey=[prefs objectForKey:@"AuthenticationKey"];
            if(authenticationKey==nil || authenticationKey.length!=32)
                authenticationKey=@"11111111111111111111111111111111"; //sample default
            
            [dtdev cryptoAuthenticateHost:[authenticationKey dataUsingEncoding:NSASCIIStringEncoding] error:nil];
            [dtdev updateFirmwareData:[NSData dataWithContentsOfFile:file] error:&error];
        }
        if(firmareTarget==TARGET_OPTICON)
        {
            NSString *file09=[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Opticon_FL49J09.bin"];
            NSFileManager *fileManager=[NSFileManager defaultManager];
            
            if([fileManager fileExistsAtPath:file09])
            {
                [progressViewController performSelectorOnMainThread:@selector(updateText:) withObject:@"Updating to version Opticon_FL49J09...\nPlease wait!" waitUntilDone:NO];
                [dtdev barcodeOpticonUpdateFirmware:[NSData dataWithContentsOfFile:file09] bootLoader:FALSE error:&error];
            }
        }
        if(firmareTarget==TARGET_CODE)
        {
            [progressViewController performSelectorOnMainThread:@selector(updateText:) withObject:@"Updating engine...\nPlease wait!" waitUntilDone:NO];
            [dtdev barcodeCodeUpdateFirmware:[firmwareFile lastPathComponent] data:[NSData dataWithContentsOfFile:firmwareFile] error:&error];
        }

        [[UIApplication sharedApplication] setIdleTimerDisabled: idleTimerDisabled_Old];
        [self performSelectorOnMainThread:@selector(firmwareUpdateEnd:) withObject:error waitUntilDone:FALSE];
    
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(buttonIndex == 1)
	{
        //Make firmware update prettier - call it from a thread and listen to the notifications only
        [progressViewController viewWillAppear:FALSE];
        [self.view addSubview:progressViewController.view];
        
        [NSThread detachNewThreadSelector:@selector(firmwareUpdateThread:) toTarget:self withObject:firmwareFile];
	}
}

-(void)checkForFirmwareUpdate;
{
	firmwareFile=[self getFirmwareFileName];
	if(firmwareFile==nil)
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Firmware Update",nil)
														message:NSLocalizedString(@"No firmware for this device model present",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil, nil];
		[alert show];
	}else {
        NSDictionary *info=[dtdev getFirmwareFileInformation:[NSData dataWithContentsOfFile:firmwareFile] error:nil];
		
		if(info && [[info objectForKey:@"deviceName"] isEqualToString:dtdev.deviceName] && [[info objectForKey:@"deviceModel"] isEqualToString:dtdev.deviceModel])
		{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Firmware Update",nil)
                                                            message:[NSString stringWithFormat:NSLocalizedString(@"Device ver: %@\nAvailable: %@\n\nDo you want to update firmware?\n\nDO NOT DISCONNECT DEVICE DURING FIRMWARE UPDATE!",nil),[dtdev firmwareRevision],[info objectForKey:@"firmwareRevision"]]
                                                           delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",nil) otherButtonTitles:NSLocalizedString(@"Update",nil), nil];
            [alert show];
		}else {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Firmware Update",nil)
															message:NSLocalizedString(@"No firmware for this device model present",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil, nil];
			[alert show];
		}
	}
}

-(void)checkForOpticonFirmwareUpdate;
{
    firmwareFile=[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Opticon_FL49J05.bin"];
    NSString *opticonIdent=[dtdev barcodeOpticonGetIdent:nil];
    
	if(firmwareFile==nil)
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Firmware Update",nil)
														message:NSLocalizedString(@"No firmware for this device model present",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil, nil];
		[alert show];
	}else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Firmware Update",nil)
                                                        message:[NSString stringWithFormat:NSLocalizedString(@"Current engine firmware: %@\n\nDo you want to update firmware?\n\nDO NOT DISCONNECT DEVICE DURING FIRMWARE UPDATE!",nil),opticonIdent]
                                                       delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",nil) otherButtonTitles:NSLocalizedString(@"Update",nil), nil];
        [alert show];
	}
}

-(void)checkForCodeFirmwareUpdate;
{
    firmwareFile=[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"C005922_0336-system-cr8000-CD_GEN.CRZ"];
	if(firmwareFile==nil)
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Firmware Update",nil)
														message:NSLocalizedString(@"No firmware for this device model present",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil, nil];
		[alert show];
    }else
    {
        NSDictionary *info=[dtdev barcodeCodeGetInformation:nil];
        if(!info)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Firmware Update",nil)
                                                            message:NSLocalizedString(@"Code engine not present or not responding",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil, nil];
            [alert show];
        }else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Firmware Update",nil)
                                                            message:[NSString stringWithFormat:@"Reader info:\n%@\nDo you want to update engine firmware?",info]
                                                           delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",nil) otherButtonTitles:NSLocalizedString(@"Update",nil), nil];
            [alert show];
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Number of sections is the number of region dictionaries
    return SEC_LAST;
}

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section {
	switch (section)
	{
		case SEC_GENERAL:
			return NSLocalizedString(@"General Settings",nil);
            
		case SEC_BARCODE_MODE:
			return NSLocalizedString(@"Barcode Scan Mode",nil);
            
		case SEC_BT_DEVICES:
			return NSLocalizedString(@"Bluetooth Devices",nil);
            
		case SEC_TCP_DEVICES:
			return NSLocalizedString(@"TCP/IP Devices",nil);
            
		case SEC_FIRMWARE_UPDATE:
			return NSLocalizedString(@"Firmware Update",nil);
	}
	return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Number of rows is the number of names in the region dictionary for the specified section
    NSUInteger nRows=0;
	switch (section)
	{
		case SEC_GENERAL:
            if(dtdev.connstate==CONN_CONNECTED)
                nRows=SET_LAST;
            break;
            
		case SEC_BARCODE_MODE:
            if(dtdev.connstate==CONN_CONNECTED && [dtdev getSupportedFeature:FEAT_BARCODE error:nil]!=FEAT_UNSUPPORTED)
                nRows=5;
            break;
            
		case SEC_BT_DEVICES:
            if(dtdev.connstate==CONN_CONNECTED && [dtdev getSupportedFeature:FEAT_BLUETOOTH error:nil]!=FEAT_UNSUPPORTED)
                nRows=[btDevices count]/2+1;
            break;
            
		case SEC_TCP_DEVICES:
			return 2;
            
		case SEC_FIRMWARE_UPDATE:
            if(dtdev.connstate==CONN_CONNECTED)
            {
                [firmwareUpdates removeAllObjects];
                
//                if([[dtdev.deviceName lowercaseString] hasPrefix:@"linea"])
                    [firmwareUpdates addObject:[NSNumber numberWithInt:TARGET_DEVICE]];

                if([dtdev getSupportedFeature:FEAT_BARCODE error:nil]&BARCODE_OPTICON)
                    [firmwareUpdates addObject:[NSNumber numberWithInt:TARGET_OPTICON]];
                
                if([dtdev getSupportedFeature:FEAT_BARCODE error:nil]&BARCODE_CODE)
                    [firmwareUpdates addObject:[NSNumber numberWithInt:TARGET_CODE]];
                
                nRows=firmwareUpdates.count;
            }
            break;
	}
	return nRows;
}

NSString *getLogFile()
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	return [[paths objectAtIndex:0] stringByAppendingPathComponent:@"random.bin"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch ([indexPath indexAtPosition:0])
	{
		case SEC_GENERAL:
            if(settings_values[indexPath.row])
			{
				settings_values[indexPath.row]=FALSE;
			}else
			{
				settings_values[indexPath.row]=TRUE;
			}
			switch (indexPath.row)
            {
                case SET_BEEP:
                    if(settings_values[SET_BEEP])
                    {
                        [dtdev barcodeSetScanBeep:settings_values[SET_BEEP] volume:100 beepData:beep2 length:sizeof(beep2) error:nil];
                        [dtdev playSound:100 beepData:beep2 length:sizeof(beep2) error:nil];
                    }else
                    {
                        [dtdev barcodeSetScanBeep:settings_values[SET_BEEP] volume:0 beepData:nil length:0 error:nil]; 
                    }
                    break;
                case SET_ENABLE_SCAN_BUTTON:
                    [dtdev barcodeSetScanButtonMode:settings_values[SET_ENABLE_SCAN_BUTTON] error:nil];
                    break;
                case SET_AUTOCHARGING:
                    [[NSUserDefaults standardUserDefaults] setBool:settings_values[SET_AUTOCHARGING] forKey:@"AutoCharging"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [dtdev setCharging:settings_values[SET_AUTOCHARGING] error:nil];
                    break;
                case SET_RESET_BARCODE:
                {
                    NSError *error=nil;
                    if([dtdev barcodeEngineResetToDefaults:&error])
                        [self displayAlert:@"Success" message:@"Barcode engine was resetted"];
                    else
                        ERRMSG(NSLocalizedString(@"Command failed",nil));
                    settings_values[indexPath.row]=FALSE;
                    break;
                }
            }
			[[tableView cellForRowAtIndexPath: indexPath] setAccessoryType:settings_values[indexPath.row]?UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone];
			break;
            
        case SEC_BARCODE_MODE:
            if([dtdev barcodeSetScanMode:indexPath.row error:nil])
                scanMode=indexPath.row;
            [tableView reloadData];
            break;
            
        case SEC_BT_DEVICES:
            if(indexPath.row==0)
            {//perform discovery
                NSError *error=nil;
                [progressViewController viewWillAppear:FALSE];
                [self.view addSubview:progressViewController.view];
                [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
                
                [btDevices removeAllObjects];
                
                if(![dtdev btDiscoverSupportedDevicesInBackground:10 maxTime:8 filter:BLUETOOTH_FILTER_ALL error:&error])
                {
                    [progressViewController.view removeFromSuperview];
                    ERRMSG(NSLocalizedString(@"Bluetooth Error",nil));
                }
            }else
            {//connect to the device
                [progressViewController viewWillAppear:FALSE];
                [self.view addSubview:progressViewController.view];
                [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
                
                NSString *selectedAddress=[btDevices objectAtIndex:(indexPath.row-1)*2];
                [[NSUserDefaults standardUserDefaults] setValue:selectedAddress forKey:@"selectedPrinterAddress"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                if([dtdev.btConnectedDevices containsObject:selectedAddress])
                {
                    [dtdev btDisconnect:selectedAddress error:nil];
                }else
                {
                    NSError *error=nil;
                    if(![dtdev btConnectSupportedDevice:selectedAddress pin:@"0000" error:&error])
                        ERRMSG(NSLocalizedString(@"Bluetooth Error",nil));
                }
                
                [progressViewController.view removeFromSuperview];
                [tableView reloadData];
            }
            break;
            
        case SEC_TCP_DEVICES:
        {
            if(indexPath.row==0)
            {//connect to the specified address
                NSError *error;
                [progressViewController viewWillAppear:FALSE];
                [self.view addSubview:progressViewController.view];
                [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
                
                error=nil;
                
                UITableViewCell *cell=[settingsTable cellForRowAtIndexPath:indexPath];
                NSString *selectedAddress=cell.textLabel.text;
                
                if([dtdev.tcpConnectedDevices containsObject:selectedAddress])
                {
                    [dtdev tcpDisconnect:selectedAddress error:nil];
                }else
                {
                    NSError *error=nil;
                    if(![dtdev tcpConnectSupportedDevice:selectedAddress error:&error])
                        ERRMSG(NSLocalizedString(@"Connection Error",nil));
                }

                [progressViewController.view removeFromSuperview];
                [tableView reloadData];
            }
            break;
        }
            
		case SEC_FIRMWARE_UPDATE:
            firmareTarget=[tableView cellForRowAtIndexPath:indexPath].tag;
            switch (firmareTarget)
            {
                case TARGET_DEVICE:
                    [self checkForFirmwareUpdate];
                    break;
                case TARGET_OPTICON:
                    [self checkForOpticonFirmwareUpdate];
                    break;
                case TARGET_CODE:
                    [self checkForCodeFirmwareUpdate];
                    break;
            }
			break;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"SettingsCell"];
	
	switch ([indexPath indexAtPosition:0])
	{
		case SEC_GENERAL:
			if(settings_values[indexPath.row])
				cell.accessoryType=UITableViewCellAccessoryCheckmark;
			else
				cell.accessoryType=UITableViewCellAccessoryNone;
			[cell.textLabel setText:NSLocalizedString(settings[indexPath.row],nil)];
			break;
            
		case SEC_BARCODE_MODE:
			if(scanMode==indexPath.row)
				cell.accessoryType=UITableViewCellAccessoryCheckmark;
			else
				cell.accessoryType=UITableViewCellAccessoryNone;
			[cell.textLabel setText:NSLocalizedString(scan_modes[indexPath.row],nil)];
			break;
            
		case SEC_BT_DEVICES:
			if(indexPath.row==0)
            {
                [cell.textLabel setText:NSLocalizedString(@"Discover devices",nil)];
            }else
            {
                [cell.textLabel setText:[btDevices objectAtIndex:(indexPath.row-1)*2+1]];
                [cell.detailTextLabel setText:[btDevices objectAtIndex:(indexPath.row-1)*2]];
                if([dtdev.btConnectedDevices containsObject:[btDevices objectAtIndex:(indexPath.row-1)*2]])
                    cell.accessoryType=UITableViewCellAccessoryCheckmark;
                else
                    cell.accessoryType=UITableViewCellAccessoryNone;
            }
			break;
            
		case SEC_TCP_DEVICES:
			if(indexPath.row==0)
            {
                [cell.textLabel setText:NSLocalizedString(@"Connect to device",nil)];
            }else
            {
                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                
                UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 200, 21)];
                textField.placeholder = @"Address";
                textField.text = [prefs objectForKey:@"tcpAddress"];
                if(textField.text.length<=0)
                    textField.text=@"192.168.11.136";
                textField.tag = indexPath.row;
                textField.delegate = self;
                cell.accessoryView = textField;
                if([dtdev.tcpConnectedDevices containsObject:textField.text])
                    cell.accessoryType=UITableViewCellAccessoryCheckmark;
                else
                    cell.accessoryType=UITableViewCellAccessoryNone;
            }
			break;
            
		case SEC_FIRMWARE_UPDATE:
            cell.tag=[[firmwareUpdates objectAtIndex:indexPath.row] intValue];
            switch (cell.tag)
            {
                case TARGET_DEVICE:
                    [[cell textLabel] setText:NSLocalizedString(@"Update device firmware",nil)];
                    break;
                case TARGET_OPTICON:
                    [[cell textLabel] setText:NSLocalizedString(@"Update Opticon firmware",nil)];
                    break;
                case TARGET_CODE:
                    [[cell textLabel] setText:NSLocalizedString(@"Update Code firmware",nil)];
                    break;
            }
			break;
	}
	return cell;	
}

- (void)viewWillAppear:(BOOL)animated
{
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
	btDevices=[[prefs arrayForKey:@"bluetoothDevices"] mutableCopy];
    if(!btDevices)
        btDevices=[[NSMutableArray alloc] init];
    [settingsTable reloadData];
    
	//update display according to current connection state
	[self connectionState:dtdev.connstate];
}


- (void)viewDidLoad
{
    firmwareUpdates=[[NSMutableArray alloc] init];
	dtdev=[DTDevices sharedDevice];
	[dtdev addDelegate:self];
    [super viewDidLoad];
}

@end
