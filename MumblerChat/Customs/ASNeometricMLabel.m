
#import "ASNeometricMLabel.h"

@implementation ASNeometricMLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.font = [UIFont NeometricMediumFontWithSize:self.font.pointSize];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        self.font = [UIFont NeometricMediumFontWithSize:self.font.pointSize];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.font = [UIFont NeometricMediumFontWithSize:self.font.pointSize];
}


@end
