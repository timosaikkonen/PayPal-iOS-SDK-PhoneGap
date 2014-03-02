//
//  PayPalMobilePGPlugin.h
//

#import <Cordova/CDV.h>
#import "PayPalMobile.h"

@interface PayPalMobilePGPlugin : CDVPlugin<PayPalPaymentDelegate, PayPalFuturePaymentDelegate>

- (void)version:(CDVInvokedUrlCommand *)command;
- (void)prepareForPayment:(CDVInvokedUrlCommand *)command;

- (void)environment:(CDVInvokedUrlCommand *)command;
- (void)setEnvironment:(CDVInvokedUrlCommand *)command;

- (void)presentPaymentUI:(CDVInvokedUrlCommand *)command;
- (void)presentFuturePaymentUI:(CDVInvokedUrlCommand *)command;

@end
