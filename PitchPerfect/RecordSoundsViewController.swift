//
//  RecordSoundsViewController.swift
//  PitchPerfect
//
//  Created by Cédric Morier-Roy on 2020-09-28.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {
    
    var audioRecorder:AVAudioRecorder!

    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopRecordingButton: UIButton!
    @IBOutlet weak var recordingLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stopRecordingButton.isEnabled = false   //disable stop button
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    @IBAction func recordAudio(_ sender: Any)
    {
        //Change label text and disable record button, enable stop button
        configureRecordingUI(true)
        
        //Create path for audio file
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = URL(string: pathArray.joined(separator: "/"))
        
        //Create audio session
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSession.Category.playAndRecord, options: .defaultToSpeaker)
        
        //Start recording
        try! audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }
    
    @IBAction func stopRecording(_ sender: Any)
    {
        //reverse most actions from recordAudio()
        configureRecordingUI(false)
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
    }
    
    func configureRecordingUI(_ isRecording: Bool)
    {
        if isRecording
        {
            recordingLabel.text = "Recording in Progress"
            stopRecordingButton.isEnabled = isRecording
            recordButton.isEnabled = !isRecording
        }
        else
        {
            recordingLabel.text = "Tap To Record"
            recordButton.isEnabled = !isRecording
            stopRecordingButton.isEnabled = isRecording
        }
    }
    
    //MARK: Delegate
    //Since RecordSoundsViewController is the delegate for AVAudioRecorder, this function gets called when the recording ends
    //segue to next view when recording ends (based on identifier of stop button)
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag
        {
            performSegue(withIdentifier: "stopRecording", sender: audioRecorder.url)
        }
        else
        {
                print("Recording was unsuccesful.")
        }
    }
    
    //prepare to segue to next view (send recording url to PlaySoundsViewController)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "stopRecording"
        {
            let playSoundsVC = segue.destination as! PlaySoundsViewController
            let recordedAudioURL = sender as! URL
            playSoundsVC.recordedAudioUrl = recordedAudioURL
        }
    }
}

