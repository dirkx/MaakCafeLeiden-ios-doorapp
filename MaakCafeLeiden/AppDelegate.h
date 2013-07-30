//
//  AppDelegate.h
//  MaakCafeLeiden
//
//
// Copyright © 2013 Dirk-Willem van Gulik <dirkx@webweaving.org>, all rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at:
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "MainViewController.h"

extern NSString * const kConfigDoorNotificationsOnOff;
extern NSString * const kConfigDoorNotificationsSoundOnOff;
extern NSString * const kConfigDoorNotificationsAlertOnOff;
extern NSString * const kConfigDoorNotificationsDistanceOnOff;
extern NSString * const kConfigDoorNotificationsDistance;

extern NSString * const kConfigProximityNotificationOnOff;
extern NSString * const kConfigProximityNotificationDistance;

extern NSString * const kConfigActivitySoundsOnOff;

extern NSString * const kConfigUniqueIdentifier;

#define STD_BOOL(x) ([[NSUserDefaults standardUserDefaults] boolForKey:x])
#define STD_FLOAT(x) ([[NSUserDefaults standardUserDefaults] floatForKey:x])
#define STD_STRING(x) ([[NSUserDefaults standardUserDefaults] stringForKey:x])

#define configDoorNotificationsOn           (STD_BOOL(kConfigDoorNotificationsOnOff))
#define configDoorNotificationsSoundOn      (STD_BOOL(kConfigDoorNotificationsSoundOnOff))
#define configDoorNotificationsAlertOn      (STD_BOOL(kConfigDoorNotificationsAlertOnOff))
#define configDoorNotificationsDistanceOn   (STD_BOOL(kConfigDoorNotificationsDistanceOnOff))
#define configDoorNotificationsDistance     (STD_FLOAT(kConfigDoorNotificationsDistance))

#define configProximityNotificationOn (STD_BOOL(kConfigProximityNotificationOnOff))
#define configProximityNotificationDistance (STD_FLOAT(kConfigProximityNotificationDistance))

#define configActivitySoundOn (STD_BOOL(kConfigActivitySoundsOnOff))

#define configUniqueIdentifier (STD_STRING(kConfigUniqueIdentifier))

// https://maps.google.com/maps?q=rap,+leiden&hl=en&ll=52.157461,4.494441&spn=0.00205,0.003363&sll=37.0625,-95.677068&sspn=82.939223,110.214844&hq=rap,&hnear=Leiden,+South+Holland,+The+Netherlands&t=m&fll=52.157282,4.494165&fspn=0.00205,0.003363&z=19

#define MAAKCAFE_LAT (52.157282)
#define MAAKCAFE_LON (4.494165)

#define PREFIX @"org.webweaving.MaakCafeLeiden.config."

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
}

@property (assign, nonatomic) NSInteger activeMakers;
@property (assign, nonatomic) BOOL makerActivity;

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) MainViewController *mainViewController;

@property (strong, nonatomic) CLLocationManager * locationManager;

@property (assign, nonatomic) float lastDistance;

#ifdef DEBUG
-(void)dumpConfig;
#endif
@end
