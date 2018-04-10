//
//  AWSADALSignInButton.h
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 31/10/2017.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AWSAuthCore/AWSSignInProvider.h>
#import <AWSAuthCore/AWSSignInManager.h>
#import <AWSAuthCore/AWSSignInButtonView.h>

NS_ASSUME_NONNULL_BEGIN

@interface AWSADALSignInButton : UIView<AWSSignInButtonView>
    
    /**
     @property textLabel
     @brief The label that displays the ADAL SignIn text
     **/
    @property (strong, nonatomic) UILabel *textLabel;
    
@end

NS_ASSUME_NONNULL_END
