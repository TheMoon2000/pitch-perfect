//
//  Pure Tone.swift
//  Perfect Pitch
//
//  Created by Jia Rui Shan on 2023/2/13.
//

import Foundation
import AVFoundation

enum Piano {
    
    static func getKeyName(_ keyNumber: Int) -> String {
        let octave = keyNumber < 4 ? 0 : 1 + (keyNumber - 4) / 12
        let note = ["A", "A♯/B♭", "B", "C", "C♯/D♭", "D", "D♯/E♭", "E", "F", "F♯/G♭", "G", "G♯/A♭"][(keyNumber - 1) % 12]
        return "\(note) \(octave)"
    }
}


func playPureTone(frequencyInHz: Float, amplitude: Float, durationInMillis: Int, completion: @escaping ()->Void, triangle: Bool = false) {
    //Use a semaphore to block until the tone completes playing
    let semaphore = DispatchSemaphore(value: 1)
    //Run async in the background so as not to block the current thread
    DispatchQueue.global().async {
        //Build the player and its engine
        let audioPlayer = AVAudioPlayerNode()
        let audioEngine = AVAudioEngine()
        semaphore.wait()//Claim the semphore for blocking
        audioEngine.attach(audioPlayer)
        let mixer = audioEngine.mainMixerNode
        let sampleRateHz = Float(mixer.outputFormat(forBus: 0).sampleRate)
        
        guard let format = AVAudioFormat(commonFormat: AVAudioCommonFormat.pcmFormatFloat32, sampleRate: Double(sampleRateHz), channels: AVAudioChannelCount(1), interleaved: false) else {
            return
        }
        // Connect the audio engine to the audio player
        audioEngine.connect(audioPlayer, to: mixer, format: format)
        
        
        let numberOfSamples = AVAudioFrameCount((Float(durationInMillis) / 1000 * sampleRateHz))
        //create the appropriatly sized buffer
        guard let buffer  = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: numberOfSamples) else {
            return
        }
        buffer.frameLength = numberOfSamples
        //get a pointer to the buffer of floats
        let channels = UnsafeBufferPointer(start: buffer.floatChannelData, count: Int(format.channelCount))
        let floats = UnsafeMutableBufferPointer<Float>(start: channels[0], count: Int(numberOfSamples))
        //calculate the angular frequency
        let angularFrequency = Float(frequencyInHz * 2) * .pi
        // Generate and store the sequential samples representing the sine wave of the tone
        for i in 0 ..< Int(numberOfSamples) {
            if triangle {
                let waveComponent = abs(Float(i).remainder(dividingBy: sampleRateHz / Float(frequencyInHz)) - amplitude / 2)
                floats[i] = waveComponent
            } else {
                let waveComponent = sinf(Float(i) * angularFrequency / sampleRateHz)
                floats[i] = waveComponent * amplitude                
            }
        }
        
        // Smoothing
        for i in 1...8 {
            floats[Int(numberOfSamples) - i] /= Float(i) + 1
        }
        
        do {
            try audioEngine.start()
        }
        catch{
            print("Error: Engine start failure")
            return
        }

        // Play the pure tone represented by the buffer
        audioPlayer.play()
        audioPlayer.scheduleBuffer(buffer, at: nil, options: .interrupts){
            DispatchQueue.main.async {
                completion()
                semaphore.signal()//Release one claim of the semiphore
            }
        }
        semaphore.wait()//Wait for the semiphore so the function doesn't end before the playing of the tone completes
        semaphore.signal()//Release the other claim of the semiphore
    }
}
