Device::USB::PCSensor::HidTEMPer::TEMPer1
=========================

This fork may have broken all the other HidTEMPer modules as they are currently untested

All actual credit goes to:
* peterfarsinsen (https://github.com/peterfarsinsen)
* Juan Carlos Perez (cray@isp-sl.com)
* Robert Kavaler (relavak.com)


Supported Devices
-----------------

This is for devices that dmesg shows something similiar to this when you plug it in:
```
[12249.577547] usb 2-3.1: New USB device found, idVendor=0c45, idProduct=7401
[12249.577552] usb 2-3.1: New USB device strings: Mfr=1, Product=2, SerialNumber=0
[12249.577556] usb 2-3.1: Product: TEMPer1V1.4
[12249.577558] usb 2-3.1: Manufacturer: RDing
[12249.580915] input: RDing TEMPer1V1.4 as /devices/pci0000:00/0000:00:1d.7/usb2/2-3/2-3.1/2-3.1:1.0/input/input15
[12249.581080] generic-usb 0003:0C45:7401.0016: input,hidraw0: USB HID v1.10 Keyboard [RDing TEMPer1V1.4] on usb-0000:00:1d.7-3.1/input0
[12249.583179] generic-usb 0003:0C45:7401.0017: hiddev0,hidraw1: USB HID v1.10 Device [RDing TEMPer1V1.4] on usb-0000:00:1d.7-3.1/input1
```
and

lsusb will return:
```
0c45:7401 Microdia
```
