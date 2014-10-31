#define log(z) NSLog(@"[StopSend] %@", z)

@interface UIKeyboard : UIView
-(BOOL)hasAutocorrectPrompt;
@end

@interface CKMessageEntryView : UIView
@property (retain, nonatomic) UIButton *sendButton;
+(id)sharedInstance;
@end

@interface CKMessageEntryContentView : UIView
-(UIKeyboard *)findKeyboard;
@end

static CKMessageEntryView* messageEntryView;

%hook CKMessageEntryView
- (void)layoutSubviews {
	messageEntryView = self;
	%orig;
}
%new +(id)sharedInstance {
	return messageEntryView;
}
%end

%hook CKMessageEntryContentView

-(void)textViewDidChange:(id)arg1 {
	%orig;
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		if([self findKeyboard]) {
			[[%c(CKMessageEntryView) sharedInstance] sendButton].enabled = ![[self findKeyboard] hasAutocorrectPrompt];
		}
	});
}

%new -(UIKeyboard *)findKeyboard {
    UIKeyboard* keyboard = nil;
    for (UIWindow* window in [UIApplication sharedApplication].windows) {
    	if(![window isKindOfClass:[objc_getClass("UITextEffectsWindow") class]]) {
    		continue;
    	}
    	if([[[window subviews][0] subviews][0] subviews].count >= 3) {
    		keyboard = [[[[window subviews][0] subviews][0] subviews][2] subviews][0];
    	}
    	break;
    }
    return keyboard;
}

%end
