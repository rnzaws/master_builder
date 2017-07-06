#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "AWSCore.h"
#import "AWSCredentialsProvider.h"
#import "AWSIdentityProvider.h"
#import "AWSSignature.h"
#import "AWSBolts.h"
#import "AWSExecutor.h"
#import "AWSTask.h"
#import "AWSTaskCompletionSource.h"
#import "AWSCognitoIdentity.h"
#import "AWSCognitoIdentityModel.h"
#import "AWSCognitoIdentityResources.h"
#import "AWSCognitoIdentityService.h"
#import "AWSMantle.h"
#import "AWSMTLJSONAdapter.h"
#import "AWSMTLManagedObjectAdapter.h"
#import "AWSMTLModel+NSCoding.h"
#import "AWSMTLModel.h"
#import "AWSMTLReflection.h"
#import "AWSMTLValueTransformer.h"
#import "AWSEXTKeyPathCoding.h"
#import "AWSEXTRuntimeExtensions.h"
#import "AWSEXTScope.h"
#import "AWSmetamacros.h"
#import "NSArray+AWSMTLManipulationAdditions.h"
#import "NSDictionary+AWSMTLManipulationAdditions.h"
#import "NSError+AWSMTLModelException.h"
#import "NSObject+AWSMTLComparisonAdditions.h"
#import "NSValueTransformer+AWSMTLInversionAdditions.h"
#import "NSValueTransformer+AWSMTLPredefinedTransformerAdditions.h"
#import "AWSNetworking.h"
#import "AWSURLSessionManager.h"
#import "AWSSerialization.h"
#import "AWSURLRequestRetryHandler.h"
#import "AWSURLRequestSerialization.h"
#import "AWSURLResponseSerialization.h"
#import "AWSValidation.h"
#import "AWSClientContext.h"
#import "AWSService.h"
#import "AWSServiceEnum.h"
#import "AWSSTS.h"
#import "AWSSTSModel.h"
#import "AWSSTSResources.h"
#import "AWSSTSService.h"
#import "AWSCategory.h"
#import "AWSLogging.h"
#import "AWSModel.h"
#import "AWSSynchronizedMutableDictionary.h"

FOUNDATION_EXPORT double AWSCoreVersionNumber;
FOUNDATION_EXPORT const unsigned char AWSCoreVersionString[];

