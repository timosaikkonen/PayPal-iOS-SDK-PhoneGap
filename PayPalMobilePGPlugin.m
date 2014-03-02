//
//  PayPalMobilePGPlugin.m
//

#import "PayPalMobilePGPlugin.h"


@interface PayPalMobilePGPlugin ()

- (void)sendErrorToDelegate:(NSString *)errorMessage;
- (PayPalConfiguration*)parseConfiguration:(NSDictionary *)jsObject;

@property(nonatomic, strong, readwrite) CDVInvokedUrlCommand *command;
@property(nonatomic, strong, readwrite) PayPalPaymentViewController *paymentController;
@property(nonatomic, strong, readwrite) NSString *currentEnvironment;
@end


#pragma mark -

@implementation PayPalMobilePGPlugin

- (void)version:(CDVInvokedUrlCommand *)command {
  CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                    messageAsString:[PayPalMobile libraryVersion]];
  
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)environment:(CDVInvokedUrlCommand *)command {
  CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                    messageAsString:self.currentEnvironment];
  
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setEnvironment:(CDVInvokedUrlCommand *)command {
  CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  NSString *environment = [command.arguments objectAtIndex:0];
  
  NSString *environmentToUse = nil;
  if ([environment isEqualToString:@"PayPalEnvironmentNoNetwork"]) {
    environmentToUse = PayPalEnvironmentNoNetwork;
  } else if ([environment isEqualToString:@"PayPalEnvironmentProduction"]) {
    environmentToUse = PayPalEnvironmentProduction;
  } else if ([environment isEqualToString:@"PayPalEnvironmentSandbox"]) {
    environmentToUse = PayPalEnvironmentSandbox;
  } else {
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"The provided environment is not supported"];
  }
  
  if (environmentToUse) {
    self.currentEnvironment = environmentToUse;
  }
  
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
- (PayPalConfiguration *)parseConfiguration:(NSDictionary *)configuration {
  PayPalConfiguration *ppconfiguration = [[PayPalConfiguration alloc] init];
  
  if ([configuration.allKeys containsObject:@"defaultUserEmail"])
    ppconfiguration.defaultUserEmail = [configuration valueForKey:@"defaultUserEmail"];
  
  if ([configuration.allKeys containsObject:@"defaultUserPhoneCountryCode"])
    ppconfiguration.defaultUserPhoneCountryCode = [configuration valueForKey:@"defaultUserPhoneCountryCode"];
  
  if ([configuration.allKeys containsObject:@"defaultUserPhoneNumber"])
    ppconfiguration.defaultUserPhoneNumber = [configuration valueForKey:@"defaultUserPhoneNumber"];
  
  if ([configuration.allKeys containsObject:@"merchantName"])
    ppconfiguration.merchantName = [configuration valueForKey:@"merchantName"];
  
  if ([configuration.allKeys containsObject:@"merchantPrivacyPolicyURL"])
    ppconfiguration.merchantPrivacyPolicyURL = [configuration valueForKey:@"merchantPrivacyPolicyURL"];
  
  if ([configuration.allKeys containsObject:@"merchantUserAgreementURL"])
    ppconfiguration.merchantUserAgreementURL = [configuration valueForKey:@"merchantUserAgreementURL"];
  
  if ([configuration.allKeys containsObject:@"acceptCreditCards"])
    ppconfiguration.acceptCreditCards = [[configuration valueForKey:@"acceptCreditCards"] boolValue];
  
  if ([configuration.allKeys containsObject:@"rememberUser"])
    ppconfiguration.rememberUser = [[configuration valueForKey:@"rememberUser"] boolValue];
  
  if ([configuration.allKeys containsObject:@"languageOrLocale"])
    ppconfiguration.languageOrLocale = [configuration valueForKey:@"languageOrLocale"];
  
  if ([configuration.allKeys containsObject:@"disableBlurWhenBackgrounding"])
    ppconfiguration.disableBlurWhenBackgrounding = [[configuration valueForKey:@"disableBlurWhenBackgrounding"] boolValue];
  
  if ([configuration.allKeys containsObject:@"forceDefaultsInSandbox"])
    ppconfiguration.forceDefaultsInSandbox = [[configuration valueForKey:@"forceDefaultsInSandbox"] boolValue];
  
  if ([configuration.allKeys containsObject:@"sandboxUserPassword"])
    ppconfiguration.sandboxUserPassword = [configuration valueForKey:@"sandboxUserPassword"];
  
  if ([configuration.allKeys containsObject:@"sandboxUserPin"])
    ppconfiguration.sandboxUserPin = [configuration valueForKey:@"sandboxUserPin"];
  
  return ppconfiguration;
}

- (void)prepareForPayment:(CDVInvokedUrlCommand *)command {
  CDVPluginResult *pluginResult = nil;
  NSString *productionClientId = [command.arguments objectAtIndex:0];
  NSString *sandboxClientId = [command.arguments objectAtIndex:1];
  
  if (productionClientId.length > 0 && sandboxClientId.length > 0) {
    [PayPalMobile initializeWithClientIdsForEnvironments:@{PayPalEnvironmentProduction : productionClientId,
                                                           PayPalEnvironmentSandbox : sandboxClientId}];
    
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  } else {
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"The provided clientId was null or empty"];
  }
  
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)presentPaymentUI:(CDVInvokedUrlCommand *)command {
  // check number and type of arguments
  int argumentCount = (signed)[command.arguments count];
  if (argumentCount != 2) {
    [self sendErrorToDelegate:@"presentPaymentUI requires exactly two arguments: payment and configuration"];
    return;
  }
  
  NSDictionary *payment = [command.arguments objectAtIndex:0];
  if (![payment isKindOfClass:[NSDictionary class]]) {
    [self sendErrorToDelegate:@"payment must be a PayPalPayment object"];
    return;
  }

  NSDictionary *configuration = [command.arguments objectAtIndex:1];
  if (![configuration isKindOfClass:[NSDictionary class]]) {
    [self sendErrorToDelegate:@"payment must be a PayPalConfiguration object"];
    return;
  }

  PayPalPaymentIntent intent;
  if ([[payment[@"intent"] lowercaseString] isEqualToString: @"authorize"]) {
    intent = PayPalPaymentIntentAuthorize;
  } else {
    intent = PayPalPaymentIntentSale;
  }
  PayPalPayment *pppayment = [PayPalPayment paymentWithAmount:[NSDecimalNumber decimalNumberWithString:payment[@"amount"]]
                                                 currencyCode:payment[@"currency"]
                                             shortDescription:payment[@"shortDescription"]
                                                       intent:intent];

  PayPalConfiguration *ppconfiguration = [self parseConfiguration:configuration];

  if (!pppayment.processable) {
    [self sendErrorToDelegate:@"payment not processable"];
    return;
  }

  PayPalPaymentViewController *controller = [[PayPalPaymentViewController alloc] initWithPayment:pppayment configuration:ppconfiguration delegate:self];

  if (!controller) {
    [self sendErrorToDelegate:@"could not instantiate PayPalPaymentViewController"]; // should never happen
    return;
  }

  if (!self.currentEnvironment) {
    [self sendErrorToDelegate:@"environment set, invoke setEnvironment prior to presenting the payment UI"];
    return;
  }
  
  self.command = command;
  self.paymentController = controller;
  
  [PayPalMobile preconnectWithEnvironment:self.currentEnvironment];
  
  if ([self.viewController respondsToSelector:@selector(presentViewController:animated:completion:)]){
    [self.viewController presentViewController:controller animated:YES completion:nil];
  } else {
    [self.viewController presentModalViewController:controller animated:YES];
  }
}
     
     
#pragma mark - Cordova convenience helpers
     
- (void)sendErrorToDelegate:(NSString *)errorMessage {
  CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                                   messageAsString:errorMessage];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:self.command.callbackId];
}


#pragma mark - PayPalPaymentDelegate implementaiton
     
- (void)payPalPaymentDidCancel:(PayPalPaymentViewController *)paymentViewController {
  [self.viewController dismissModalViewControllerAnimated:YES];
  [self sendErrorToDelegate:@"payment cancelled"];
}

- (void)payPalPaymentViewController:(PayPalPaymentViewController *)paymentViewController
                 didCompletePayment:(PayPalPayment *)completedPayment {
  [self.viewController dismissModalViewControllerAnimated:YES];
  
  CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                messageAsDictionary:completedPayment.confirmation];

  [self.commandDelegate sendPluginResult:pluginResult callbackId:self.command.callbackId];
}

@end
