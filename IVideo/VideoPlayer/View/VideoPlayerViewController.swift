//
//  VideoPlayerView.swift
//  IVideo
//
//  Created by Сергей Даровских on 18.02.2022.
//

import UIKit
import AVFoundation

class VideoPlayerViewController: UIViewController {
    private let viewModel: VideoPlayerViewModel
    
    private var player: AVPlayer
    private var playerItem: AVPlayerItem?
    private var playerLayer: AVPlayerLayer
    private var isVideoPlaying = true
    private var gesture : UITapGestureRecognizer?
    private var isViewHide = true
    private var statusBarState = false
    
    override var prefersStatusBarHidden: Bool {
        return statusBarState
    }
    
    private let videoView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray
        view.clipsToBounds = true
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemGray
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .white
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let volumeButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemGray
        button.setImage(UIImage(systemName: "speaker.wave.3.fill"), for: .normal)
        button.tintColor = .white
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(volumeButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let currentTimeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let durationLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let playButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let goForwardButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "goforward.15"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(forwardButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let goBackwardButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "gobackward.15"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(goBackwardButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let sliderTime: UISlider = {
        let slider = UISlider()
        slider.tintColor = UIColor.white
        slider.addTarget(self, action: #selector(sliderTimeTapped), for: .valueChanged)
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    init(videoUrl: URL) {
        if let locationPath = UserDefaultsManager.getVideoLocationPath(url: videoUrl) {
            let baseURL = URL(fileURLWithPath: NSHomeDirectory())
            let assetURL = baseURL.appendingPathComponent(locationPath)
            let asset = AVURLAsset(url: assetURL)
            playerItem = AVPlayerItem(asset: asset)
            
            player = AVPlayer(playerItem: playerItem)
        } else {
            self.player = AVPlayer(url: videoUrl)
        }

        self.playerLayer = AVPlayerLayer(player: player)
        self.viewModel = VideoPlayerViewModel(player: player)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        addTimeObserver()
        playerLayer.videoGravity = .resize
        player.currentItem?.addObserver(self, forKeyPath: "duration", options: [.new, .initial], context: nil)
        player.currentItem?.addObserver(self, forKeyPath: "status", options: [.new, .initial], context: nil)
        videoView.layer.addSublayer(playerLayer)
        (UIApplication.shared.delegate as! AppDelegate).restrictRotation = .all
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        player.play()
        statusBarState = true
        UIView.animate(withDuration: 0.30) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer.frame = videoView.bounds
    }
    
    override func observeValue(forKeyPath: String?, of: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if forKeyPath == "duration", let duration = player.currentItem?.duration.seconds, duration > 0.0 {
            self.durationLabel.text = CMTimeHelper.getTimeString(from: player.currentItem!.duration)
        }
        if forKeyPath == "status" , player.currentItem?.status == .failed {
            showDefaultAlert(title: "ERROR", message: "Failed to load video", actionCompletion: { UIAlertAction in
                self.navigationController?.popViewController(animated: true)
                self.dismiss(animated: true, completion: nil)
            })
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isViewHide {
            containerView.isHidden = true
            closeButton.isHidden = true
            volumeButton.isHidden = true
        } else {
            containerView.isHidden = false
            closeButton.isHidden = false
            volumeButton.isHidden = false
        }
        isViewHide = !isViewHide
    }
    
    func addTimeObserver() {
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        DispatchQueue.main.async {
            self.player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { [weak self] time in
                guard let currentItem = self?.player.currentItem else {return}
                if currentItem.status == .readyToPlay {
                    self?.sliderTime.maximumValue = Float(currentItem.duration.seconds)
                    self?.sliderTime.minimumValue = 0
                    self?.sliderTime.value = Float(currentItem.currentTime().seconds)
                    self?.currentTimeLabel.text = CMTimeHelper.getTimeString(from: currentItem.currentTime())
                }
            })
        }
    }
    
    private func setupViews() {
        view.backgroundColor = .black
    }
    
    @objc private func closeButtonTapped() {
        navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func volumeButtonTapped() {
        if player.isMuted {
            player.isMuted = true
            volumeButton.setImage(UIImage(systemName: "speaker.wave.3.fill"), for: .normal)
        } else {
            player.isMuted = false
            volumeButton.setImage(UIImage(systemName: "speaker.fill"), for: .normal)
        }
        player.isMuted = !player.isMuted
    }
    
    @objc private func playButtonTapped() {
        if isVideoPlaying {
            player.pause()
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        } else {
            player.play()
            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        }
        isVideoPlaying = !isVideoPlaying
    }
    
    @objc private func forwardButtonTapped() {
        viewModel.forwardButtonTapped()
    }
    
    @objc private func goBackwardButtonTapped() {
        viewModel.goBackwardButtonTapped()
    }
    
    @objc private func sliderTimeTapped(_ sender: UISlider) {
        viewModel.sliderTimeTapped(sender)
    }
    
    private func setupConstraints() {
        view.addSubview(videoView)
        NSLayoutConstraint.activate([
            videoView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            videoView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            videoView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
            videoView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0),
            videoView.heightAnchor.constraint(equalTo: videoView.widthAnchor, multiplier: 9.0/16.0)
        ])
        view.addSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 40),
            closeButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 40),
            closeButton.heightAnchor.constraint(equalToConstant: 54),
            closeButton.widthAnchor.constraint(equalToConstant: 58)
        ])
        view.addSubview(volumeButton)
        NSLayoutConstraint.activate([
            volumeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 40),
            volumeButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -40),
            volumeButton.heightAnchor.constraint(equalToConstant: 54),
            volumeButton.widthAnchor.constraint(equalToConstant: 58)
        ])
        view.addSubview(containerView)
        NSLayoutConstraint.activate([
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20 ),
            containerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 40),
            containerView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -40),
            containerView.heightAnchor.constraint(equalToConstant: 110)
        ])
        containerView.addSubview(playButton)
        NSLayoutConstraint.activate([
            playButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10 ),
            playButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            playButton.heightAnchor.constraint(equalToConstant: 54),
            playButton.widthAnchor.constraint(equalToConstant: 58)
        ])
        containerView.addSubview(goForwardButton)
        NSLayoutConstraint.activate([
            goForwardButton.leftAnchor.constraint(equalTo: playButton.rightAnchor, constant: 10),
            goForwardButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10 ),
            goForwardButton.heightAnchor.constraint(equalToConstant: 54),
            goForwardButton.widthAnchor.constraint(equalToConstant: 58)
        ])
        containerView.addSubview(goBackwardButton)
        NSLayoutConstraint.activate([
            goBackwardButton.rightAnchor.constraint(equalTo: playButton.leftAnchor, constant: -10),
            goBackwardButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10 ),
            goBackwardButton.heightAnchor.constraint(equalToConstant: 54),
            goBackwardButton.widthAnchor.constraint(equalToConstant: 58)
        ])
        containerView.addSubview(sliderTime)
        NSLayoutConstraint.activate([
            sliderTime.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -60),
            sliderTime.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10 ),
            sliderTime.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 60),
            sliderTime.heightAnchor.constraint(equalToConstant: 20),
        ])
        containerView.addSubview(currentTimeLabel)
        NSLayoutConstraint.activate([
            currentTimeLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10 ),
            currentTimeLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 10),
            currentTimeLabel.heightAnchor.constraint(equalToConstant: 20),
        ])
        containerView.addSubview(durationLabel)
        NSLayoutConstraint.activate([
            durationLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10 ),
            durationLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -10),
            durationLabel.heightAnchor.constraint(equalToConstant: 20),
        ])
    }
}
