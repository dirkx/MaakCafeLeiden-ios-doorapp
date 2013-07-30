//
//  FlipsideViewController.m
//  MaakCafeLeiden
//
// Copyright © 2013 Dirk-Willem van Gulik <dirkx@webweaving.org>, all rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at:
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//


#import "FlipsideViewController.h"
#import "AppDelegate.h"

@interface FlipsideViewController ()

@end

@implementation FlipsideViewController
@synthesize doorNotificationsSoundSwitch, doorNotificationsSwitch, doorNotificationsAlertSwitch, copyrightLabel, appLabel, doorNotificationDistanceSlider, doorNotificationDistanceLabel, proximityDistanceSlider, proximityDistanceLabel, doorNotificationsDistanceSwitch, doorNotificationDistanceMainText, proximityDistanceSwitch, activitySoundSwitch;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 480.0);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString *copyright = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSHumanReadableCopyright"];
    
    copyrightLabel.text = copyright;
    appLabel.text = [NSString stringWithFormat:@"%@/%@", appName, appVersion];
        
    doorNotificationsSwitch.on = configDoorNotificationsOn;
    doorNotificationsAlertSwitch.on = configDoorNotificationsAlertOn;
    doorNotificationsSoundSwitch.on = configDoorNotificationsSoundOn;
    doorNotificationsDistanceSwitch.on = configDoorNotificationsDistanceOn;
    
    proximityDistanceSlider.value = [self meters2slider:configDoorNotificationsDistance];
    
    proximityDistanceSwitch.on = configProximityNotificationOn;
    
    proximityDistanceSlider.value = [self meters2slider:configProximityNotificationDistance];
    
    activitySoundSwitch.on = configActivitySoundOn;
    
    // we need to do this in order - as the swithes override the text
    // with the slider.
    //
    [self doorNotificationSliderChange:self];
    [self proximitySliderChange:self];
    [self switchChangedNotify:self];
    
}

#if DEBUG
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] dumpConfig];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] dumpConfig];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
#endif

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI Buttons

- (IBAction)done:(id)sender
{
    [self.delegate flipsideViewControllerDidFinish:self];
}

-(IBAction)switchChangedNotify:(id)sender {

    // disable secondary switches based on setting of the prime switches.
    //
    doorNotificationsDistanceSwitch.enabled = doorNotificationDistanceLabel.enabled = doorNotificationsAlertSwitch.enabled = doorNotificationsSoundSwitch.enabled = doorNotificationsSwitch.on;
    doorNotificationDistanceSlider.enabled = doorNotificationDistanceLabel.enabled = doorNotificationsDistanceSwitch.on && doorNotificationsSwitch.on;
    proximityDistanceLabel.enabled = proximityDistanceSlider.enabled = proximityDistanceSwitch.on;
    
    // clarify the slider text when they are 'off' - as the normal distance based
    // text does not make much sense in that context.
    //
    doorNotificationDistanceMainText.text = doorNotificationsDistanceSwitch.on ? NSLocalizedString(@"Alert me only when",@"") : NSLocalizedString(@"Alert me",@"");

    
    if (!doorNotificationsDistanceSwitch.on)
        doorNotificationDistanceLabel.text = NSLocalizedString(@"always - regardless as to where I am",@"");

    if (sender != self) {
        [[NSUserDefaults standardUserDefaults] setBool:doorNotificationsSwitch.on forKey:kConfigDoorNotificationsOnOff];
        [[NSUserDefaults standardUserDefaults] setBool:doorNotificationsAlertSwitch.on forKey:kConfigDoorNotificationsAlertOnOff];
        [[NSUserDefaults standardUserDefaults] setBool:doorNotificationsSoundSwitch.on forKey:kConfigDoorNotificationsSoundOnOff];
        [[NSUserDefaults standardUserDefaults] setBool:doorNotificationsDistanceSwitch.on forKey:kConfigDoorNotificationsDistanceOnOff];

        [[NSUserDefaults standardUserDefaults] setBool:doorNotificationsSwitch.on forKey:kConfigProximityNotificationOnOff];
        
        [[NSUserDefaults standardUserDefaults] setBool:activitySoundSwitch.on forKey:kConfigActivitySoundsOnOff];
    }
}

#pragma mark UI Sliders

-(NSString *)textFromDistance:(float)distInMeters {
    if (distInMeters < 30)
        return NSLocalizedString(@"within spitting distance of the space",@"distance < 30 meter");
    if (distInMeters < 250)
        return NSLocalizedString(@"nearby the space",@"distance < 250 meter");
    if (distInMeters < 750)
        return NSLocalizedString(@"within the Singels of Leiden",@"any distance < 750 meter");
    if (distInMeters < 3500)
        return NSLocalizedString(@"in Leiden",@"distance < 4km");
    if (distInMeters < 13500)
        return NSLocalizedString( @"in the region",@"distance > 15km");
    if (distInMeters < 135000)
        return NSLocalizedString(@"firmly in the Netherlands",@"distance  < 150km");
    if (distInMeters < 1000000)
        return NSLocalizedString(@"roughly in this timezone",@"distance < 1000km");
    
    return NSLocalizedString(@"still somewhere in this galaxy",@"any distance");
}

const double pwr = 7.1;

-(float)slider2meters:(float)value {
    return powf(pwr,value);
}

-(float)meters2slider:(float)value {
    return logf(value)/logf(pwr);
}

-(void)doorNotificationSliderChange:(id)sender {
    float d = [self slider2meters:doorNotificationDistanceSlider.value];
    
    if (sender != self) {
        [[NSUserDefaults standardUserDefaults] setFloat:d forKey:kConfigDoorNotificationsDistance];
    };
    
    doorNotificationDistanceLabel.text = [NSString stringWithFormat:NSLocalizedString(@"when I am %@", @"used in distance composition - argument is a distance"),[self textFromDistance:d]];
}

-(void)proximitySliderChange:(id)sender {
    float d = [self slider2meters:proximityDistanceSlider.value];

    if (sender != self) {
        [[NSUserDefaults standardUserDefaults] setFloat:d forKey:kConfigProximityNotificationDistance];
    };
    
    proximityDistanceLabel.text = [NSString stringWithFormat:NSLocalizedString(@"when I am %@ and there is "
                      "some serious making going on", @"used in distance composition - argument is a distance"), [self textFromDistance:d]];
}

#pragma mark - About stuff

-(IBAction)showLicenses:(id)sender {
    AboutViewController *controller = [[AboutViewController alloc] initWithNibName:@"AboutViewController" bundle:nil];
    controller.delegate = self;
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)aboutViewControllerDidFinish:(AboutViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
