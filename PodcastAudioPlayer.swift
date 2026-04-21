import AVFoundation
import Foundation

final class PodcastAudioPlayer: NSObject, AVAudioPlayerDelegate {
    private var player: AVAudioPlayer?
    private var onFinished: (() -> Void)?

    var isPlaying: Bool {
        player?.isPlaying ?? false
    }
    
    var currentTime: TimeInterval {
        player?.currentTime ?? 0
    }
    
    var duration: TimeInterval {
        player?.duration ?? 0
    }

    func play(url: URL, onFinished: @escaping () -> Void) throws {
        self.onFinished = onFinished
        let player = try AVAudioPlayer(contentsOf: url)
        self.player = player
        player.delegate = self
        player.prepareToPlay()
        player.play()
    }
    
    func pause() {
        player?.pause()
    }
    
    func resume() {
        player?.play()
    }

    func stop() {
        player?.stop()
        player = nil
        onFinished = nil
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        onFinished?()
    }
}
