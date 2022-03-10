//
//  VideoPlayerViewModel.swift
//  IVideo
//
//  Created by Сергей Даровских on 08.03.2022.
//

import UIKit
import AVFoundation

class VideoPlayerViewModel {
    var player: AVPlayer
    
    init(player: AVPlayer) {
        self.player = player
    }

    func forwardButtonTapped() {
        guard let duration = player.currentItem?.duration else { return }
        let currentTime = CMTimeGetSeconds(player.currentTime())
        let newTime = currentTime + 15.0
        
        if newTime < (CMTimeGetSeconds(duration) - 15.0) {
            let time: CMTime = CMTimeMake(value: Int64(newTime*1000), timescale: 1000)
            player.seek(to: time)
        }
    }
    
    func goBackwardButtonTapped() {
        let currentTime = CMTimeGetSeconds(player.currentTime())
        var newTime = currentTime - 15.0
        
        if newTime < 0 {
            newTime = 0
        }
        let time: CMTime = CMTimeMake(value: Int64(newTime*1000), timescale: 1000)
        player.seek(to: time)
    }
    
    func sliderTimeTapped(_ sender: UISlider) {
        player.seek(to: CMTimeMake(value: Int64(sender.value*1000), timescale: 1000))
    }
}
