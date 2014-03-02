//
//  PayPalMobilePGPlugin.js
//

/**
 * @constructor
 * @parameter amount: string
 * Payment amount as a string, e.g. "1.99"
 * @parameter currency: string
 * Payment currency code e.g. "USD"
 * @parameter shortDescription: string
 * Short description of the payment
 * @parameter intent: string
 * Intent of request. Valid values: "sale", "authorize"
 */
function PayPalPayment(amount, currency, shortDescription, intent) {
  this.amount = amount;
  this.currency = currency;
  this.shortDescription = shortDescription;
  this.intent = intent;
}

/**
 * @constructor
 * @parameter defaultUserEmail: string
 * Optional default user email address to be shown on the PayPal login view.
 *
 * @parameter defaultUserPhoneCountryCode: string
 * Optional default user phone country code used in the PayPal login view.
 *
 * @parameter defaultUserPhoneNumber: string
 * Optional default user phone number to be shown in the PayPal login view.
 *
 * @parameter merchantName: string
 * Your company name, as it should be displayed to the user.
 *
 * @parameter merchantPrivacyPolicyURL: string
 * URL of your company's privacy policy, which will be offered to the user.
 *
 * @parameter merchantUserAgreementURL: string
 * URL of your company's user agreement, which will be offered to the user.
 *
 * @parameter acceptCreditCards: boolean
 * If set to true, the SDK will only support paying with PayPal, not with credit cards.
 *
 * @parameter rememberUser: boolean
 * If set to true, then if the user pays via their PayPal account,
 * the SDK will remember the user's PayPal username or phone number;
 * if the user pays via their credit card, then the SDK will remember
 * the PayPal Vault token representing the user's credit card.
 * If set to false, then any previously-remembered username, phone number, or
 * credit card token will be erased, and subsequent payment information will
 * not be remembered.
 *
 * @parameter languageOrLocale: string
 * If not set, or if set to null, defaults to the device's current language setting.
 * Can be specified as a language code ("en", "fr", "zh-Hans", etc.) or as a locale ("en_AU", "fr_FR", "zh-Hant_HK", etc.).
 * If the library does not contain localized strings for a specified locale, then will fall back to the language. E.g., "es_CO" -> "es".
 * If the library does not contain localized strings for a specified language, then will fall back to American English.
 * If you specify only a language code, and that code matches the device's currently preferred language,
 * then the library will attempt to use the device's current region as well.
 * E.g., specifying "en" on a device set to "English" and "United Kingdom" will result in "en_GB".
 * These localizations are currently included:
 * da,de,en,en_AU,en_GB,en_SV,es,es_MX,fr,he,it,ja,ko,nb,nl,pl,pt,pt_BR,ru,sv,tr,zh-Hans,zh-Hant_HK,zh-Hant_TW.
 *
 * @parameter disableBlurWhenBackgrounding: boolean
 * Normally, the SDK blurs the screen when the app is backgrounded,
 * to obscure credit card or PayPal account details in the iOS-saved screenshot.
 * If your app already does its own blurring upon backgrounding, you might choose to disable this.
 * Defaults to false.
 *
 * @parameter forceDefaultsInSandbox: boolean
 * Sandbox credentials can be difficult to type on a mobile device. Setting this flag to YES will
 * cause the sandboxUserPassword and sandboxUserPin to always be pre-populated into login fields.
 * This setting will have no effect if the operation mode is production.
 *
 * @parameter sandboxUserPassword: string
 * Password to use for sandbox if 'forceDefaultsInSandbox' is set.
 *
 * @parameter sandboxUserPin: string
 * PIN to use for sandbox if 'forceDefaultsInSandbox' is set.
 */
function PayPalConfiguration(defaultUserEmail, defaultUserPhoneCountryCode, defaultUserPhoneNumber, 
  merchantName, merchantPrivacyPolicyURL, merchantUserAgreementURL, acceptCreditCards,
  rememberUser, languageOrLocale, countryForAdaptation, disableBlurWhenBackgrounding,
  forceDefaultsInSandbox, sandboxUserPassword, sandboxUserPin) {
  this.defaultUserEmail = defaultUserEmail;
  this.defaultUserPhoneCountryCode = defaultUserPhoneCountryCode;
  this.defaultUserPhoneNumber = defaultUserPhoneNumber;
  this.merchantName = merchantName; 
  this.merchantPrivacyPolicyURL = merchantPrivacyPolicyURL;
  this.merchantUserAgreementURL = merchantUserAgreementURL; 
  this.acceptCreditCards = acceptCreditCards;
  this.rememberUser = rememberUser; 
  this.languageOrLocale = languageOrLocale; 
  this.countryForAdaptation = countryForAdaptation; 
  this.disableBlurWhenBackgrounding = disableBlurWhenBackgrounding;
  this.forceDefaultsInSandbox = forceDefaultsInSandbox; 
  this.sandboxUserPassword = sandboxUserPassword; 
  this.sandboxUserPin = sandboxUserPin;
}

/**
 * This class exposes the PayPal iOS SDK functionality to javascript.
 *
 * @constructor
 */
function PayPalMobile() {}


/**
 * Retrieve the version of the PayPal iOS SDK library. Useful when contacting support.
 *
 * @parameter callback: a callback function accepting a string
 */
PayPalMobile.prototype.version = function(callback) {
  var failureCallback = function() {
    console.log("Could not retrieve PayPal library version");
  };

  cordova.exec(callback, failureCallback, "PayPalMobile", "version", []);
};

/**
 * Retrieve the current PayPal iOS SDK environment: mock, sandbox, or live.
 *
 * @parameter callback: a callback function accepting a string
 */
PayPalMobile.prototype.environment = function(callback) {
  var failureCallback = function() {
    console.log("Could not retrieve PayPal environment");
  };

  cordova.exec(callback, failureCallback, "PayPalMobile", "environment", []);
};

/**
 * You MUST preconnect to PayPal to prepare the device for processing payments.
 * This improves the user experience, by making the presentation of the
 * UI faster. The preconnect is valid for a limited time, so
 * the recommended time to preconnect is on page load.
 *
 * @parameter productionClientId: string
 * Your production client id from developer.paypal.com
 * @parameter sandboxClientId: string
 * Your sandbox client id
 * @parameter environmentToUse: string
 * Environment to use for payments. 
 * Choices are "PayPalEnvironmentNoNetwork", "PayPalEnvironmentSandbox", or "PayPalEnvironmentProduction"
 * @parameter callback: a parameter-less success callback function (normally not used)
 */
PayPalMobile.prototype.prepareForPayment = function(productionClientId, sandboxClientId, environmentToUse) {
  var failureCallback = function(message) {
    console.log("Could not perform prepareForPurchase " + message);
  };

  cordova.exec(null, failureCallback, "PayPalMobile", "prepareForPayment", [productionClientId, sandboxClientId, environmentToUse]);
};


/**
 * Start PayPal UI to collect payment from the user.
 * See https://developer.paypal.com/webapps/developer/docs/integration/mobile/ios-integration-guide/
 * for more documentation of the parameters.
 *
 * @parameter payment: PayPalPayment object
 * @parameter configuration: PayPalConfiguration object
 * @parameter completionCallback: a callback function accepting a js object, called when the user has completed payment
 * @parameter cancelCallback: a callback function accepting a reason string, called when the user cancels the payment
 */
PayPalMobile.prototype.presentPaymentUI = function(payment, configuration, completionCallback, cancelCallback) {
  cordova.exec(completionCallback, cancelCallback, "PayPalMobile", "presentPaymentUI", [payment, configuration]);
};

/**
 * Start PayPal UI to collect future payment from the user.
 * See https://developer.paypal.com/webapps/developer/docs/integration/mobile/ios-integration-guide/
 * for more documentation of the parameters.
 *
 * @parameter configuration: PayPalConfiguration object
 * @parameter completionCallback: a callback function accepting a js object, called when the user has completed payment
 * @parameter cancelCallback: a callback function accepting a reason string, called when the user cancels the payment
 */
PayPalMobile.prototype.presentFuturePaymentUI = function(configuration, completionCallback, cancelCallback) {
  cordova.exec(completionCallback, cancelCallback, "PayPalMobile", "presentFuturePaymentUI", [configuration]);
};

/**
 * Plugin setup boilerplate.
 */
cordova.addConstructor(function() {
  if (!window.plugins) {
    window.plugins = {};
  }

  if (!window.plugins.PayPalMobile) {
    window.plugins.PayPalMobile = new PayPalMobile();
  }
});
