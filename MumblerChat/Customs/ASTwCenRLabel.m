
#import "ASTwCenRLabel.h"

@implementation ASTwCenRLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.font = [UIFont TwCenMTRegularFontWithSize:self.font.pointSize];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.font = [UIFont TwCenMTRegularFontWithSize:self.font.pointSize];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.font = [UIFont TwCenMTRegularFontWithSize:self.font.pointSize];
}

@end
