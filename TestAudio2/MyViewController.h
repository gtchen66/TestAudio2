//
//  MyViewController.h
//  TestAudio2
//
//  Created by George Chen on 3/5/14.
//  Copyright (c) 2014 George Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface MyViewController : UIViewController <AVAudioPlayerDelegate, AVAudioRecorderDelegate> {
    AVAudioPlayer *audioPlayer;
    AVAudioRecorder *audioRecorder;
}

@end
