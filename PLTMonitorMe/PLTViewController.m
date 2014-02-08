//
//  PLTViewController.m
//  PLTMonitorMe
//
//  Created by Sairam Sankaran on 2/7/14.
//  Copyright (c) 2014 Sairam Sankaran. All rights reserved.
//

#import "PLTViewController.h"
#import "PLTDevice.h"

@interface PLTViewController () <PLTDeviceConnectionDelegate, PLTDeviceInfoObserver>

@property(nonatomic, strong) PLTDevice *device;
@property (weak, nonatomic) IBOutlet UILabel *helloWorldLabel;

@end

@implementation PLTViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	
	NSArray *devices = [PLTDevice availableDevices];
	if ([devices count]) {
		self.device = devices[0];
		self.device.connectionDelegate = self;
		[self.device openConnection];
	}
	else {
		NSLog(@"No available devices.");
        self.helloWorldLabel.text = @"No available devices!";
	}
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newDeviceAvailableNotification:) name:PLTDeviceNewDeviceAvailableNotification object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"MonitorME";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private

- (void)newDeviceAvailableNotification:(NSNotification *)notification
{
	NSLog(@"newDeviceAvailableNotification: %@", notification);
	
	if (!self.device) {
		self.device = notification.userInfo[PLTDeviceNewDeviceNotificationKey];
		self.device.connectionDelegate = self;
		[self.device openConnection];
	}
    
}

- (void)subscribeToInfo
{
    NSError *err = [self.device subscribe:self toService:PLTServiceOrientationTracking withMode:PLTSubscriptionModeOnChange minPeriod:0];
    if (err) NSLog(@"Error: %@", err);
    
    err = [self.device subscribe:self toService:PLTServiceWearingState withMode:PLTSubscriptionModeOnChange minPeriod:0];
    if (err) NSLog(@"Error: %@", err);
    
    err = [self.device subscribe:self toService:PLTServiceProximity withMode:PLTSubscriptionModeOnChange minPeriod:0];
    if (err) NSLog(@"Error: %@", err);
    
    err = [self.device subscribe:self toService:PLTServicePedometer withMode:PLTSubscriptionModeOnChange minPeriod:0];
    if (err) NSLog(@"Error: %@", err);
    
    err = [self.device subscribe:self toService:PLTServiceFreeFall withMode:PLTSubscriptionModeOnChange minPeriod:0];
    if (err) NSLog(@"Error: %@", err);
    
    // note: this doesn't work right.
    err = [self.device subscribe:self toService:PLTServiceTaps withMode:PLTSubscriptionModeOnChange minPeriod:0];
    if (err) NSLog(@"Error: %@", err);
    
    err = [self.device subscribe:self toService:PLTServiceMagnetometerCalStatus withMode:PLTSubscriptionModeOnChange minPeriod:0];
    if (err) NSLog(@"Error: %@", err);
    
    err = [self.device subscribe:self toService:PLTServiceGyroscopeCalibrationStatus withMode:PLTSubscriptionModeOnChange minPeriod:0];
    if (err) NSLog(@"Error: %@", err);
}

#pragma mark - PLTDeviceConnectionDelegate

- (void)PLTDeviceDidOpenConnection:(PLTDevice *)aDevice
{
	NSLog(@"PLTDeviceDidOpenConnection: %@", aDevice);
    self.helloWorldLabel.text = @"Device Connected!";
    self.helloWorldLabel.textColor = [UIColor greenColor];
    
    [self subscribeToInfo];
}

- (void)PLTDevice:(PLTDevice *)aDevice didFailToOpenConnection:(NSError *)error
{
	NSLog(@"PLTDevice: %@ didFailToOpenConnection: %@", aDevice, error);
	self.device = nil;
}

- (void)PLTDeviceDidCloseConnection:(PLTDevice *)aDevice
{
	NSLog(@"PLTDeviceDidCloseConnection: %@", aDevice);
	self.device = nil;
    self.helloWorldLabel.text = @"Device Disconnected!";
    self.helloWorldLabel.textColor = [UIColor redColor];
}

#pragma mark - PLTDeviceInfoObserver

- (void)PLTDevice:(PLTDevice *)aDevice didUpdateInfo:(PLTInfo *)theInfo
{
	//NSLog(@"PLTDevice: %@ didUpdateInfo: %@", aDevice, theInfo);
    
    if ([theInfo isKindOfClass:[PLTOrientationTrackingInfo class]]) {
        PLTEulerAngles eulerAngles = ((PLTOrientationTrackingInfo *)theInfo).eulerAngles;
        NSLog(@"Euler X = %f", eulerAngles.x);
        NSLog(@"Euler Y = %f", eulerAngles.y);
        NSLog(@"Euler Z = %f", eulerAngles.z);
	}
	else if ([theInfo isKindOfClass:[PLTWearingStateInfo class]]) {
        NSLog(@"Device worn: %@", (((PLTWearingStateInfo *)theInfo).isBeingWorn ? @"yes" : @"no"));
	}
	else if ([theInfo isKindOfClass:[PLTProximityInfo class]]) {
		PLTProximityInfo *proximityInfp = (PLTProximityInfo *)theInfo;
        NSLog(@"Mobile proximity = %@", NSStringFromProximity(proximityInfp.mobileProximity));
	}
	else if ([theInfo isKindOfClass:[PLTPedometerInfo class]]) {
        NSLog(@"Pedometer steps = %@", [NSString stringWithFormat:@"%lu", (unsigned long)((PLTPedometerInfo *)theInfo).steps]);
	}
	else if ([theInfo isKindOfClass:[PLTFreeFallInfo class]]) {
		BOOL isInFreeFall = ((PLTFreeFallInfo *)theInfo).isInFreeFall;
        if (isInFreeFall) {
			NSLog(@"Freefall = %@", (isInFreeFall ? @"yes" : @"no"));
		}
	}
	else if ([theInfo isKindOfClass:[PLTTapsInfo class]]) {
		PLTTapsInfo *tapsInfo = (PLTTapsInfo *)theInfo;
		NSString *directionString = NSStringFromTapDirection(tapsInfo.direction);
        NSLog(@"Taps %@", [NSString stringWithFormat:@"%lu in %@", (unsigned long)tapsInfo.taps, directionString]);
	}
	else if ([theInfo isKindOfClass:[PLTMagnetometerCalibrationInfo class]]) {
        NSLog(@"Magnetometer : %@", (((PLTMagnetometerCalibrationInfo *)theInfo).isCalibrated ? @"yes" : @"no"));
	}
	else if ([theInfo isKindOfClass:[PLTGyroscopeCalibrationInfo class]]) {
        NSLog(@"Gyroscope : %@",(((PLTGyroscopeCalibrationInfo *)theInfo).isCalibrated ? @"yes" : @"no" ));
	}
}

@end
