//
//  DSFrameworkTableViewCell.m
//  DrStep
//
//  Created by Juhwan Jeong on 3/21/16.
//
//

#import "DSFrameworkTableViewCell.h"

@interface DSFrameworkTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *frameworkLabel;
@property (weak, nonatomic) IBOutlet UILabel *aboutLabel;
@property (weak, nonatomic) IBOutlet UILabel *licenseLabel;

@end

@implementation DSFrameworkTableViewCell

#pragma mark - Lifecycle

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.frameworkLabel.text = self.framework;
    self.aboutLabel.text = self.about;
    self.licenseLabel.text = self.license;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
