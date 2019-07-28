#import "AAAppIconCell.h"

@implementation AAAppIconCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.appIconImageView = [[[UIImageView alloc] init] autorelease];
        self.appIconImageView.translatesAutoresizingMaskIntoConstraints = NO;

        [self.contentView addSubview:self.appIconImageView];

        [self.appIconImageView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:0.0].active = YES;
        [self.appIconImageView.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor].active = YES;
        self.imageWidthConstraint = [self.appIconImageView.widthAnchor constraintEqualToConstant:60.0];
        self.imageWidthConstraint.active = YES;
        self.imageHeightConstraint = [self.appIconImageView.heightAnchor constraintEqualToConstant:60.0];
        self.imageHeightConstraint.active = YES;

        self.appTitleLabel = [[[UILabel alloc] init] autorelease];

        NSString *name;

        NSString *possibleName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];

        if (possibleName) {
            name = possibleName;
        } else {
            name = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleNameKey];
        }

        self.appTitleLabel.text = name;
        self.appTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.appTitleLabel.textAlignment = NSTextAlignmentCenter;
        self.appTitleLabel.font = [UIFont boldSystemFontOfSize:34.0];

        [self.contentView addSubview:self.appTitleLabel];

        [self.appTitleLabel.topAnchor constraintEqualToAnchor:self.appIconImageView.bottomAnchor constant:8.0].active = YES;
        [self.appTitleLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor].active = YES;
        [self.appTitleLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor].active = YES;
        [self.appTitleLabel.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:0.0].active = YES;
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];

    UIView *separatorView = [self valueForKey:@"_separatorView"];
    separatorView.hidden = YES;

    UIView *topSeparatorView = [self valueForKey:@"_topSeparatorView"];
    topSeparatorView.hidden = YES;

    self.contentView.backgroundColor = [UIColor whiteColor];
    self.backgroundColor = [UIColor whiteColor];
}

-(void)dealloc {
    self.imageWidthConstraint = nil;
    self.imageHeightConstraint = nil;

    [self.appIconImageView removeFromSuperview];

    self.appIconImageView = nil;

    [self.appTitleLabel removeFromSuperview];

    self.appTitleLabel = nil;

    [super dealloc];
}

@end