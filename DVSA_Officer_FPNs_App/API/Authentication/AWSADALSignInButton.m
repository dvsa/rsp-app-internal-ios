//
//  AWSSAMLSignInButton.m
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 31/10/2017.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

#import "AWSADALSignInButton.h"
#import "AWSADALSignInProvider.h"

#define SPACING_HORIZONTAL 10
#define SPACING_VERTICAL 5
#define HIGH_HUGGING_PRIORITY 99
#define LOW_HUGGING_PRIORITY 1
// ADAL Blue color to match the logo


typedef void (^AWSSignInManagerCompletionBlock)(id result, NSError *error);

static NSString *ADALLogoImageKey = @"userIcon";

@interface AWSADALSignInButton()

@property (nonatomic, strong) id<AWSSignInProvider> signInProvider;
@property (nonatomic, strong) UIButton *ADALButton;
@property (nonatomic, strong) UIStackView *ADALStackView;
@property (nonatomic, strong) UIImageView *ADALLogoImageView;
    
@end

@implementation AWSADALSignInButton
    
    @synthesize delegate;
    @synthesize buttonStyle;
    
- (id)initWithCoder:(NSCoder*)aDecoder {
    
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}
    
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}
    
- (void)commonInit {
    _signInProvider = [AWSADALSignInProvider sharedInstance];
    [self initADALButton];
    [self setUpButtonEffects];
    [self initStackView];
    [self initLogo];
    [self initLabel];
}
    
- (void)dealloc {
    @try {
        [self removeObserver:self forKeyPath:@"buttonStyle" context:nil];
    } @catch(id exception) {
        // ignore exception
    }
}
    
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    // property set
    if ([keyPath isEqualToString:@"buttonStyle"]) {
        if (self.ADALButton) {
            [self.ADALButton setImage:nil forState:UIControlStateNormal];
        }
        if (buttonStyle == AWSSignInButtonStyleLarge) {
            [self setupLargeADALButton];
        } else {
            [self setupSmallADALButton];
        }
        // refresh views
        [self.ADALButton setNeedsDisplay];
        [self setNeedsDisplay];
    }
}
    
- (void)initADALButton {
    self.ADALButton = [[UIButton alloc] init];
    [self addObserver:self forKeyPath:@"buttonStyle" options:0 context:nil];
    [self.ADALButton addTarget:self
                            action:@selector(logInWithProvider:)
                  forControlEvents:UIControlEventTouchUpInside];
    CGRect buttonFrame = self.ADALButton.frame;
    buttonFrame.size = CGSizeMake(self.frame.size.width, self.frame.size.height);
    self.ADALButton.frame = buttonFrame;
    self.ADALButton.contentMode = UIViewContentModeCenter;
    
    [self.ADALButton setIsAccessibilityElement:YES];
    [self.ADALButton setAccessibilityIdentifier:@"AWSADALSignInButton"];
    [self.ADALButton setTitle:@"" forState:UIControlStateNormal];
    [self addSubview:self.ADALButton];
}
    
- (void)initLogo {
    UIImage *providerImage = [self getImageFromBundle:ADALLogoImageKey];
    UIImageView *ADALLogoImageView = [[UIImageView alloc] initWithImage:providerImage];
    ADALLogoImageView.contentMode = UIViewContentModeScaleAspectFit;
    ADALLogoImageView.exclusiveTouch = NO;
    ADALLogoImageView.userInteractionEnabled = NO;
    [self.ADALStackView addArrangedSubview:ADALLogoImageView];
}
    
-(void)initStackView {
    self.ADALStackView = [[UIStackView alloc] initWithFrame:self.ADALButton.frame];
    self.ADALStackView.axis = UILayoutConstraintAxisHorizontal;
    self.ADALStackView.distribution = UIStackViewDistributionEqualCentering;
    self.ADALStackView.contentMode = UIViewContentModeScaleAspectFit;
    self.ADALStackView.alignment = UIStackViewAlignmentCenter;
    self.ADALStackView.layoutMargins = UIEdgeInsetsMake(SPACING_VERTICAL, SPACING_HORIZONTAL, SPACING_VERTICAL, SPACING_HORIZONTAL);
    [self.ADALStackView setLayoutMarginsRelativeArrangement:YES];
    [self.ADALStackView setSpacing:SPACING_HORIZONTAL];
    self.ADALStackView.exclusiveTouch = NO;
    self.ADALStackView.userInteractionEnabled = NO;
    [self.ADALButton addSubview:self.ADALStackView];
}
    
- (void)initLabel {
    self.textLabel = [[UILabel alloc] initWithFrame:self.ADALButton.frame];
    self.textLabel.numberOfLines = 1;
    self.textLabel.adjustsFontSizeToFitWidth = YES;
    self.textLabel.text = @"    Sign In DVSA Payments";
    self.textLabel.font = [UIFont systemFontOfSize:16];
    self.textLabel.textColor = [UIColor whiteColor];
    self.textLabel.exclusiveTouch = NO;
    self.textLabel.userInteractionEnabled = NO;
    [self.textLabel setContentHuggingPriority:HIGH_HUGGING_PRIORITY forAxis:UILayoutConstraintAxisHorizontal];
    self.textLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    self.textLabel.lineBreakMode = NSLineBreakByCharWrapping;
}
    
- (void)setUpButtonEffects {
    // ADAL Icon Blue Color as background color
    UIColor *backGroundColor = [UIColor colorWithRed:31.0/255.0 green:131.0/255.0 blue:116.0/255.0 alpha:1.0];
    [self.ADALButton setBackgroundColor: backGroundColor];
    self.ADALButton.layer.cornerRadius = 8.0f;
    self.ADALButton.layer.masksToBounds = YES;
}
    
- (void)setupSmallADALButton {
    [self.textLabel removeFromSuperview];
    self.ADALStackView.distribution = UIStackViewDistributionEqualCentering;
}
    
- (void)setupLargeADALButton {
    self.ADALStackView.distribution = UIStackViewDistributionFill;
    [self.ADALLogoImageView setContentHuggingPriority:LOW_HUGGING_PRIORITY forAxis:UILayoutConstraintAxisHorizontal];
    [self.ADALStackView addArrangedSubview:self.textLabel];
}
    
- (UIImage *)getImageFromBundle:(NSString *)imageName {
    NSBundle *currentBundle = [NSBundle bundleForClass:[self class]];
    UIImage *imageFromBundle = [UIImage imageNamed:imageName inBundle:currentBundle compatibleWithTraitCollection:nil];
    if (imageFromBundle) {
        return  imageFromBundle;
    }
    NSURL *url = [[currentBundle resourceURL] URLByAppendingPathComponent:@"AWSADALSignIn.bundle"];
    NSBundle *assetsBundle = [NSBundle bundleWithURL:url];
    return [UIImage imageNamed:imageName inBundle:assetsBundle compatibleWithTraitCollection:nil];
}
    
- (void)setSignInProvider:(id<AWSSignInProvider>)signInProvider {
    self.signInProvider = signInProvider;
}
    
- (void)logInWithProvider:(id)sender {
    
    
    [[AWSSignInManager sharedInstance] loginWithSignInProviderKey:[self.signInProvider identityProviderName]
                                                completionHandler:^(id result, NSError *error) {
                                                    [self.delegate onLoginWithSignInProvider:self.signInProvider
                                                                                      result:result
                                                                                       error:error];
                                                }];
}
    
@end

