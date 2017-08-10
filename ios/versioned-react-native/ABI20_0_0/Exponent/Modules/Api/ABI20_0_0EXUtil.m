// Copyright 2016-present 650 Industries. All rights reserved.

#import "ABI20_0_0EXUtil.h"
#import "ABI20_0_0EXScopedModuleRegistry.h"
#import <ReactABI20_0_0/ABI20_0_0RCTUIManager.h>
#import <ReactABI20_0_0/ABI20_0_0RCTBridge.h>
#import <ReactABI20_0_0/ABI20_0_0RCTUtils.h>

@interface ABI20_0_0EXUtil ()

@property (nonatomic, weak) id kernelUtilServiceDelegate;

@end

@implementation ABI20_0_0EXUtil

@synthesize bridge = _bridge;

// delegate to kernel linking manager because our only kernel work (right now)
// is refreshing the foreground task.
ABI20_0_0EX_EXPORT_SCOPED_MODULE(ExponentUtil, KernelLinkingManager);

- (instancetype)initWithExperienceId:(NSString *)experienceId kernelServiceDelegate:(id)kernelServiceInstance params:(NSDictionary *)params
{
  if (self = [super initWithExperienceId:experienceId kernelServiceDelegate:kernelServiceInstance params:params]) {
    _kernelUtilServiceDelegate = kernelServiceInstance;
  }
  return self;
}

- (dispatch_queue_t)methodQueue
{
  return self.bridge.uiManager.methodQueue;
}

ABI20_0_0RCT_EXPORT_METHOD(reload)
{
  [_kernelUtilServiceDelegate utilModuleDidSelectReload:self];
}

ABI20_0_0RCT_REMAP_METHOD(getCurrentLocaleAsync,
                 getCurrentLocaleWithResolver:(ABI20_0_0RCTPromiseResolveBlock)resolve
                 rejecter:(ABI20_0_0RCTPromiseRejectBlock)reject)
{
  NSArray<NSString *> *preferredLanguages = [NSLocale preferredLanguages];
  if (preferredLanguages.count > 0) {
    resolve(preferredLanguages[0]);
  } else {
    NSString *errMsg = @"This device does not indicate its locale";
    reject(@"E_NO_PREFERRED_LOCALE", errMsg, ABI20_0_0RCTErrorWithMessage(errMsg));
  }
}

ABI20_0_0RCT_REMAP_METHOD(getCurrentDeviceCountryAsync,
                 getCurrentDeviceCountryWithResolver:(ABI20_0_0RCTPromiseResolveBlock)resolve
                 rejecter:(ABI20_0_0RCTPromiseRejectBlock)reject)
{
  NSString *countryCode = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
  if (countryCode) {
    resolve(countryCode);
  } else {
    NSString *errMsg = @"This device does not indicate its country";
    reject(@"E_NO_DEVICE_COUNTRY", errMsg, ABI20_0_0RCTErrorWithMessage(errMsg));
  }
}

ABI20_0_0RCT_REMAP_METHOD(getCurrentTimeZoneAsync,
                 getCurrentTimeZoneWithResolver:(ABI20_0_0RCTPromiseResolveBlock)resolve
                 rejecter:(ABI20_0_0RCTPromiseRejectBlock)reject)
{
  NSTimeZone *currentTimeZone = [NSTimeZone localTimeZone];
  if (currentTimeZone) {
    resolve(currentTimeZone.name);
  } else {
    NSString *errMsg = @"Unable to determine the device's time zone";
    reject(@"E_NO_DEVICE_TIMEZONE", errMsg, ABI20_0_0RCTErrorWithMessage(errMsg));
  }
}

+ (NSString *)escapedResourceName:(NSString *)name
{
  NSString *charactersToEscape = @"!*'();:@&=+$,/?%#[]";
  NSCharacterSet *allowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:charactersToEscape] invertedSet];
  return [name stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
}

@end