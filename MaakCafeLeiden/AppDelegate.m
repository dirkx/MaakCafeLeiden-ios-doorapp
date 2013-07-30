//
//  AppDelegate.m
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

#import "AppDelegate.h"
#import "MainViewController.h"

#include "/Users/dirkx/.parse.h"

NSString * const kConfigDoorNotificationsOnOff         = PREFIX "configDoorNotificationsOnOff";
NSString * const kConfigDoorNotificationsSoundOnOff    = PREFIX "configDoorNotificationsSoundOnOff";
NSString * const kConfigDoorNotificationsAlertOnOff    = PREFIX "configDoorNotificationsAlertOnOff";
NSString * const kConfigDoorNotificationsDistanceOnOff = PREFIX "configDoorNotificationsDistanceOnOff";
NSString * const kConfigDoorNotificationsDistance      = PREFIX "configDoorNotificationsDistance";

NSString * const kConfigProximityNotificationOnOff     = PREFIX "configProximityNotificationOnOff";
NSString * const kConfigProximityNotificationDistance  = PREFIX "configProximityNotificationDistance";

NSString * const kConfigActivitySoundsOnOff            = PREFIX "configActivitySoundsOnOff";

NSString * const kConfigUniqueIdentifier        = PREFIX "uuid";

NSString * const kRegionIdentifier = @"CircleRegionIdentifier";
CLLocationCoordinate2D maakCafeLoc = { MAAKCAFE_LAT, MAAKCAFE_LON };


@interface CandG
+(id)Arrives:(NSString *)name atTime:(NSDate *)time;
+(id)Leaves:(NSString *)name atTime:(NSDate *)time;
-(NSDate *)date;
-(NSString*)name;
@end

@interface AppDelegate() <CLLocationManagerDelegate> {
    BOOL _makerActivity;
    NSInteger _activeMakers;
}
@end

@implementation AppDelegate
@synthesize lastDistance;

+(void)initialize {
    [self registerDefaultSettings];
}

+(void)registerDefaultSettings {
    NSDictionary *appDefaults = @{
                                  kConfigDoorNotificationsOnOff: [NSNumber numberWithBool:YES],
                                  kConfigDoorNotificationsSoundOnOff: [NSNumber numberWithBool:YES],
                                  kConfigDoorNotificationsAlertOnOff: [NSNumber numberWithBool:YES],
                                  kConfigDoorNotificationsDistanceOnOff: [NSNumber numberWithBool:YES],
                                  kConfigDoorNotificationsDistance: [NSNumber numberWithFloat:5000],
                                  //
                                  kConfigProximityNotificationOnOff: [NSNumber numberWithBool:YES],
                                  kConfigProximityNotificationDistance: [NSNumber numberWithFloat:300],
                                  //
                                  kConfigActivitySoundsOnOff: [NSNumber numberWithBool:YES],
                                  };
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObjects:@"nl", @"en", nil] forKey:@"AppleLanguages"];

    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
}


#ifdef DEBUG
-(void)dumpConfig {
    NSDictionary * dict = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
    NSSet * mine = [dict keysOfEntriesPassingTest:^(id key, id obj, BOOL *stop) {
        return [key hasPrefix:PREFIX];
    }];
    
    NSLog(@"Settings %@", [dict dictionaryWithValuesForKeys:[mine allObjects]]);
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)dealloc {
    [self dumpConfig];
}
#endif

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.mainViewController = [[MainViewController alloc] initWithNibName:@"MainViewController_iPhone" bundle:nil];
    } else {
        self.mainViewController = [[MainViewController alloc] initWithNibName:@"MainViewController_iPad" bundle:nil];
    }
    self.window.rootViewController = self.mainViewController;
    [self.window makeKeyAndVisible];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    [self updateNotifications];
    [self updateNarative];
    
#ifdef DEBUG
    [self dumpConfig];
#endif
    
    [self setActiveMakers:[[UIApplication sharedApplication] applicationIconBadgeNumber]];
    
    UILocalNotification *localNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotif) {
        NSLog(@"local notification received");
        [self handleNotification:localNotif.userInfo];
    }
    
    UILocalNotification *remoteNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (remoteNotif) {
        NSLog(@"remote notification received");
        [self handleNotification:remoteNotif.userInfo];
    }
    
    srand(-time(NULL));
    
    NSLog(@"Started - awaiting registration configs");
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)setActiveMakers:(NSInteger)someActiveMakersCount {
    _activeMakers = someActiveMakersCount;
    self.makerActivity = _activeMakers > 0 ? YES : NO;
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:_activeMakers];
    
    [self.mainViewController.logoView setRotationsPerMinute:_activeMakers * 4.f];
    switch (_activeMakers) {
        case 0:
            self.mainViewController.mainText.text = NSLocalizedString(@"Current no making", @"Main activity label, no one there.");
            break;
        case 1:
            self.mainViewController.mainText.text = NSLocalizedString(@"Some light making going on",@"Main activity label, 1 maker.");
            break;
        case 2:
            self.mainViewController.mainText.text = NSLocalizedString(@"Great making going on", @"Main activity label, 2 makers.");
            break;
        default:
            self.mainViewController.mainText.text = [NSString stringWithFormat:NSLocalizedString(@"%d makers are inspiring society", @"Main activity label, 3 or more makers"), _activeMakers];
            break;
    }
}

-(NSInteger)activeMakers {
    return _activeMakers;
}

-(void)setMakerActivity:(BOOL)someMakerActivity {
    _makerActivity = someMakerActivity;
    
}
-(BOOL)makerActivity {
    return _makerActivity;
};

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken {
    
    if ([configUniqueIdentifier length] != 36) {
        CFUUIDRef uuidref = CFUUIDCreate(kCFAllocatorDefault);
        NSString * uuid = CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uuidref));
        
        NSLog(@"First time - UUID %@ generated", uuid);
        
        [[NSUserDefaults standardUserDefaults] setValue:uuid forKey:kConfigUniqueIdentifier];
    };
    
    // Tell the server of our (new) token.
    //
    NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken -- token %@ for us: %@",newDeviceToken, configUniqueIdentifier);
    
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    if (error.code == 3010) {
        NSLog(@"Push notifications are not supported in the iOS Simulator.");
    } else {
        // show some alert or otherwise handle the failure to register.
        NSLog(@"application:didFailToRegisterForRemoteNotificationsWithError: %@", error);
	}
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"Push received: %@", userInfo);
    
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive) {
        
        if ([[[userInfo objectForKey:@"aps"] objectForKey:@"type"] isEqualToString:@"entry"]) {
            if (configDoorNotificationsOn && configDoorNotificationsSoundOn)
                [self playSound];
        };
    };
    
    [self handleNotification:userInfo];
}

-(void)playSound {
    SystemSoundID completeSound;
    NSURL *audioPath = [[NSBundle mainBundle] URLForResource:@"Creaking Door Spooky-SoundBible.com-1909842345" withExtension:@"wav"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)audioPath, &completeSound);
    AudioServicesPlaySystemSound (completeSound);
}

// - Vandaag -
// niemand gezien

// - Zondag 21 Juni -
// Peter deed rond 14:00 de duur open. Martijn werd rond 21:00 gesignaleerd. Het licht ging rond 23:00 weer uit.

NSMutableArray * tmp;

-(void)updateNarative {
    
    NSURL * url = [NSURL URLWithString:@"http://10.11.0.220/~dirkx/x.txt"];
    
    NSString * content = [NSString stringWithContentsOfURL:url encoding:NSASCIIStringEncoding error:nil];
    if (!content)
        return;
    
    NSArray * lines = [content componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    // Start at the end - and collect up to 7 entries; day blocking them if needed.
    //
    NSDateFormatter * dayFormatter = [[NSDateFormatter alloc] init];
    [dayFormatter setDateFormat:@"DDD"];
    NSDateFormatter * shortFormatter = [[NSDateFormatter alloc] init];
    [shortFormatter setDateFormat:@"EEEE"];
    NSDateFormatter * hourFormatter = [[NSDateFormatter alloc] init];
    [hourFormatter setDateFormat:@"H"];
    
    NSDate * now = [NSDate date];
    NSInteger day = [[dayFormatter stringFromDate:now] integerValue];
    
    NSMutableString * str = [NSMutableString string];
    
    int i = 1, lastH = -1;
    for(NSString * rawLine in lines) {
        NSString * line = [rawLine stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if ([line length] < 2)
            continue;
        
        if ([line hasSuffix:@"#"])
            continue;
        
        NSArray * elements = [line componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ([elements count] < 3) {
            NSLog(@"Cannot parse line #%d, ignoring.", i);
            continue;
        }
        NSTimeInterval since1970 = [[elements objectAtIndex:0] integerValue];
        NSDate * date = [NSDate dateWithTimeIntervalSince1970:since1970];
        
        NSString * al = [elements objectAtIndex:1];
        NSString * who = [elements objectAtIndex:2];
        
        for(int j = 3; j < [elements count]; j++)
            who = [who stringByAppendingFormat:@" %@", [elements objectAtIndex:j]];
        
        
        NSString *shortDay = [shortFormatter stringFromDate:date];
        NSInteger d = [[dayFormatter stringFromDate:date] integerValue];
        NSInteger h = [[hourFormatter stringFromDate:date] integerValue];
        
        if (d != day || [str length] == 0) {
            [str appendFormat:@"%@== %@ ==\n",
             ([str length] == 0) ? @"" : @"\n\n",
             (d == day) ? NSLocalizedString(@"today",@"Used for today.") : shortDay];
            day = d; lastH = -1;
        };
        
        NSString * hstr = @"";
        if (abs(lastH-h) > 2) {
            if (h < 3)
                hstr = NSLocalizedString(@"somewhat after midnight", @"Rough time; 0-3");
            else if (h < 8)
                hstr = NSLocalizedString(@"at some insane early hour", @"Rough time; 4-8");
            else if (h < 10)
                hstr = NSLocalizedString(@"around breakfast", @"Rough time; 9-10");
            else if (h < 11)
                hstr = NSLocalizedString(@"around coffee time", @"Rough time; 10-11");
            else if (h < 13)
                hstr = NSLocalizedString(@"around noon", @"Rough time; 12-13");
            else if (h < 16)
                hstr = NSLocalizedString(@"early afternoon", @"Rough time; 14-15");
            else if (h < 17)
                hstr = NSLocalizedString(@"just in time for tea", @"Rough time; 16");
            else if (h < 19)
                hstr = NSLocalizedString(@"around dinner time", @"Rough time; 17-18");
            else if (h < 21)
                hstr = NSLocalizedString(@"sometime early evening", @"Rough time; 19-20");
            else
                hstr = NSLocalizedString(@"sometime late evening", @"Rough time; 21-23");
        } else {
            hstr = [@[
                    NSLocalizedString(@"a bit later", @"Order specifier"),
                    NSLocalizedString(@"after that", @"Order specifier"),
                    NSLocalizedString(@"thereafter", @"Order specifier"),
                    NSLocalizedString(@"also",@"Order specifier")
                    ] objectAtIndex:i % 4];
        }
        lastH = h;
        
        NSString * action;
        
        if ([al caseInsensitiveCompare:@"A"] == NSOrderedSame)
            action = [@[
                      NSLocalizedString(@"arrived", @"Entry specifier"),
                      NSLocalizedString(@"entered", @"Entry specifier"),
                      NSLocalizedString(@"was seen",  @"Entry specifier"),
                      NSLocalizedString(@"showed up",@"Entry specifier"),
                      NSLocalizedString(@"got in", @"Entry specifier"),
                      ] objectAtIndex:rand() % 5];
        else
            action = [@[
                      NSLocalizedString(@"left", @"Exit specifier"),
                      NSLocalizedString(@"vanished", @"Exit specifier"),
                      NSLocalizedString(@"was last seen", @"Exit specifier"),
                      NSLocalizedString(@"ran out", @"Exit specifier"),
                      NSLocalizedString(@"got out", @"Exit specifier"),
                      ] objectAtIndex:rand() % 5];
        
        [str appendFormat:NSLocalizedString(@"%@ %@ %@. ",@"Narrative line; with who, action and time"), who, action, hstr];
        
        i++;
        if (i > 8)
            break;
    };
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.mainViewController.narrativeText.text = str;
        self.mainViewController.narrativeText.font = [UIFont systemFontOfSize:14.0];
        self.mainViewController.narrativeText.textAlignment = UITextAlignmentCenter;
        self.mainViewController.narrativeText.textColor = [UIColor whiteColor];
    });
    
}

-(void)handleNotification:(NSDictionary *)userInfo {
    self.activeMakers = [[[userInfo objectForKey:@"aps"] objectForKey:@"badge"] intValue];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:self.activeMakers];
    [self performSelectorInBackground:@selector(updateNarative) withObject:nil];
    
    if ([[[userInfo objectForKey:@"aps"] objectForKey:@"type"] isEqualToString:@"event"]) {
        NSString * what = [[userInfo objectForKey:@"aps"] objectForKey:@"what"];
        if ([what caseInsensitiveCompare:@"laser"] == NSOrderedSame)
            [self.mainViewController buzz:LASER];
        if ([what caseInsensitiveCompare:@"radio"] == NSOrderedSame)
            [self.mainViewController buzz:RADIO];
        if ([what caseInsensitiveCompare:@"electric"] == NSOrderedSame)
            [self.mainViewController buzz:ELECTRIC];
        if ([what caseInsensitiveCompare:@"sound"] == NSOrderedSame)
            [self.mainViewController buzz:SOUND];
    };
    
}


#pragma mark - ()

- (void)subscribeFinished:(NSNumber *)result error:(NSError *)error {
    if ([result boolValue]) {
        NSLog(@"ParseStarterProject successfully subscribed to push notifications on the broadcast channel.");
    } else {
        NSLog(@"ParseStarterProject failed to subscribe to push notifications on the broadcast channel.");
    }
}

#pragma mark - ()


-(BOOL)hazLocation {
    if ( ![CLLocationManager regionMonitoringAvailable])
        return NO;
    
    // Check the authorization status
    if (([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized) &&
        ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusNotDetermined))
        return NO;
    
    return YES;
}

-(void)updateNotifications {
    NSInteger flag = UIRemoteNotificationTypeNone;
    
    if (configDoorNotificationsOn) {
        flag |= UIRemoteNotificationTypeBadge;
        
        if (configDoorNotificationsAlertOn)
            flag |= UIRemoteNotificationTypeAlert;
        
        if (configDoorNotificationsSoundOn)
            flag |= UIRemoteNotificationTypeSound;
    };
    
    NSInteger oldFlag =  [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
    
    if (lastDistance > configDoorNotificationsDistance) {
        flag = UIRemoteNotificationTypeNone;
        
        // Place geo barrier ato get (re-)activated when we get near.
        //
        [self.locationManager stopMonitoringSignificantLocationChanges];
        if ([self.locationManager.monitoredRegions count] > 0) {
            for (id obj in self.locationManager.monitoredRegions)
                [self.locationManager stopMonitoringForRegion:obj];
        }
        
        CLRegion* region = [[CLRegion alloc] initCircularRegionWithCenter:maakCafeLoc
                                                                   radius:configDoorNotificationsDistance
                                                               identifier:kRegionIdentifier];
        
        [self.locationManager startMonitoringForRegion:region];
        NSLog(@"We're quite far away - so we've set a geo-fence to be re-activated as we get nearer.");
    }
    
    if (oldFlag != flag || 1) {
        if (flag == UIRemoteNotificationTypeNone) {
            NSLog(@"UIRemoteNotificationTypeNone - so no work.");
            [[UIApplication sharedApplication] unregisterForRemoteNotifications];
        } else {
            NSLog(@"Registering for %04d", flag);
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:flag];
        };
    };
}

-(void)setLocationAlert:(float)distance {
    
    if (![self hazLocation])
        return;
    
    if (distance  > self.locationManager.maximumRegionMonitoringDistance)
        distance =  self.locationManager.maximumRegionMonitoringDistance;
    
    [self setLocAccurace:distance];
    [[NSUserDefaults standardUserDefaults] setFloat:distance forKey:kConfigDoorNotificationsDistance];
    
    lastDistance = 0;
    
    // Always start broad - as the user does not expect to be
    // notified right away about something they already know
    // at that point.
    //
    [self.locationManager startMonitoringSignificantLocationChanges];
}

-(void)setLocAccurace:(float)distance {
    if (distance > 150000 || distance > self.locationManager.maximumRegionMonitoringDistance) {
        self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
    } else if (distance > 10000) {
        self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    } else if (distance > 500) {
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    } else if (distance > 100) {
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    } else {
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    }
}

-(void)locationManager:(CLLocationManager *)manager
    didUpdateLocations:(NSArray *)locations
{
    // Adjust accuracuy of updating based on our *current* distance from the Maak Cafe.
    //
    CLLocation * loc = [[CLLocation alloc] initWithLatitude:MAAKCAFE_LAT longitude:MAAKCAFE_LON];
    float distance = [(CLLocation*)[locations lastObject] distanceFromLocation:loc];
    
    // Adjust update accuracy as needed.
    //
    [self setLocAccurace:distance];
    
    // Change locality if needed
    //
    [self updateNotifications];
    
    NSInteger regionsMonitored = [self.locationManager.monitoredRegions count];
    
    if (regionsMonitored && distance > 5000) {
        // we're now so far away that we can safely to go to significant change
        // monitoring as not to drain the battery too much.
        //
        if ([self.locationManager.monitoredRegions count] > 0) {
            for (id obj in self.locationManager.monitoredRegions)
                [self.locationManager stopMonitoringForRegion:obj];
        }
        [self.locationManager startMonitoringSignificantLocationChanges];
    };
    
    if (distance <= 5000 && configDoorNotificationsDistance <= 5000 && regionsMonitored == 0) {
        // We're pretty near and the user has a fairly nearby the space setting ; so
        // lets skip to the more accurate region alarts.
        //
        [self.locationManager stopMonitoringSignificantLocationChanges];
        
        CLRegion* region = [[CLRegion alloc] initCircularRegionWithCenter:maakCafeLoc
                                                                   radius:distance
                                                               identifier:kRegionIdentifier];
        [self.locationManager startMonitoringForRegion:region];
    }
    
    
    // Vibrate the phone if we used to be further away - and are now closer
    // and there is making going on.
    //
    if (lastDistance != 0 && distance < configProximityNotificationDistance &&  self.makerActivity && configProximityNotificationOn) {
        
    }
    lastDistance = distance;
    
    if (lastDistance < configDoorNotificationsDistance && distance >= configDoorNotificationsDistance) {
        // we've moved out of alerting range - disable the alerts.
        [self updateNotifications];
        NSLog(@"Far away - stopped tracking the ongoings of the space");
    }
    
    if (lastDistance > configDoorNotificationsDistance && distance <= configDoorNotificationsDistance) {
        // re-enable making alarts once again.
        NSLog(@"Came back in range - tracking again.");
        [self updateNotifications];
    }
}

@end


