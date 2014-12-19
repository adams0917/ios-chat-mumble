

#import "ASNeometricMButton.h"

@implementation ASNeometricMButton



- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        self.titleLabel.font = [UIFont NeometricMediumFontWithSize:self.titleLabel.font.pointSize];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.titleLabel.font = [UIFont NeometricMediumFontWithSize:self.titleLabel.font.pointSize];
}


@end
