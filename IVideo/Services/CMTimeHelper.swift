//
//  CMTimeHelper.swift
//  IVideo
//
//  Created by Сергей Даровских on 08.03.2022.
//

import Foundation
import AVFoundation

class CMTimeHelper {
    static func getTimeString(from time: CMTime) -> String {
        let totalSeconds = CMTimeGetSeconds(time)
        let minutes = Int(totalSeconds/60) % 60
        let seconds = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
        return String(format: "%.2i:%.2i", arguments: [minutes, seconds])
    }
}
