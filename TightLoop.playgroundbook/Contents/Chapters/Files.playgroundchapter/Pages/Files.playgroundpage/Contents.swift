
/*
	Tight Loop Example
*/

import CoreGraphics
import PlaygroundSupport
import UIKit
import Foundation

let imageView = UIImageView()
imageView.contentMode = .scaleAspectFit
imageView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
imageView.layer.magnificationFilter = kCAFilterNearest

PlaygroundPage.current.liveView = imageView

let width = 128
let height = 128
var buffer : [UInt32] = Array(repeating: 0, count: width*height)

let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)
let bmp: UnsafeMutablePointer<UInt32> = UnsafeMutablePointer(mutating: buffer)
let context = CGContext(data: bmp, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width*4, space: CGColorSpace(name: CGColorSpace.genericRGBLinear)!, bitmapInfo: bitmapInfo.rawValue)

var xpos = 0
var direction = 1

func renderFrame()
{
	memset(bmp, 0, width*height*4)
	var xpos2 = xpos+32
	
	for y in 0 ..< height {
		for x in xpos ..< xpos2 {
			buffer[y*width+x] = UInt32(0xff<<24 + (x%255)<<16 + (y%255)<<8 + (xpos+x*y)%255)
		}
	}
	
	if (xpos2 >= width)
	{
		direction = -1
	}
	
	if (xpos <= 0)
	{
		direction = 1
	}
	
	xpos = xpos + direction
}

@objc class Renderer:NSObject
{
	@objc func render()
	{
		renderFrame()
		if let image = context?.makeImage()
		{
			imageView.image = UIImage(cgImage:image)
		}
	}
}

let me = Renderer()

let displayLink = CADisplayLink(target:me , selector: #selector(Renderer.render))
displayLink.preferredFramesPerSecond = 60
displayLink.add(to: RunLoop.current, forMode: .commonModes)

