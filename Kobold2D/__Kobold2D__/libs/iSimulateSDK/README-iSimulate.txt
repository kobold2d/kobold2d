iSimulate allows you to use accelerometer, GPS and other hardware features not available in the iOS Simulator, by hooking up your device with the Simulator. This saves you the time to deploy a newly built App to the device, which can add up significantly over the course of a project.

You can get the latest iSimulate library here:
http://www.vimov.com/isimulate/


To be able to use iSimulate, you must use the iSimulate iPhone App. Download iSimulate Lite to try it out for free:
http://itunes.apple.com/app/isimulate-lite/id351339630?mt=8

If you find iSimulate helpful, buy the full version to gain access to additional features:
http://itunes.apple.com/app/isimulate/id306908756?mt=8


Build Notes
===========

The iSimulate library is already added to the Kobold2D™ project and set as weak reference, so that you can build the App with or without iSimulate. You may receive architecture mismatch warnings when using iSimulate and when building for the device. 

You can safely ignore warnings like the following:
	ld: warning: in kobold2d/supplements/iSimulateSDK/libisimulate-4.x-opengl.a, file was built for unsupported file format which is not the architecture being linked (armv6)


Legal Note
==========

The libisimulate-4.x-opengl.a file is distributed with permission.
See the accompanying LICENSE.txt for the full license agreement.