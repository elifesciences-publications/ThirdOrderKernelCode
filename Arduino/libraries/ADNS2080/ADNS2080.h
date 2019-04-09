/* Arduino ADNS2620 Library
 * Copyright 2010 SparkFun Electronic
 * Written by Ryan Owens
*/

#ifndef ADNS2080_h
#define ADNS2080_h

#include <avr/pgmspace.h>
#include "Arduino.h"

union BurstData {
	unsigned long rawData;
	struct {
		byte deltaX;
		byte deltaY;
		byte deltaH;
		byte squal;
	} data;
};

class ADNS2080
{
	public:
		ADNS2080();
		void begin();
		void sync();
		byte read(byte address);
		void write(byte address, byte value);
		BurstData readBurst();
	private:
		int numMice;
		int _sda;
		int _scl;
};

/* Register Map for the PLX28560 Optical Mouse Sensor */
#define MOUSE_CTRL_REG			0x0d // RW, bit7=1 for 12 bit reporting; bits 5:2 high for 2000dpi; bit 1 0 for ~power down; bit 0 high (I hope)
#define PERFORMANCE_REG			0x16 // RW, bits 6:4 to 100 or 101 to turn off resting
#define BURST_READ_FIRST_REG	0x42 // RW, starting address to read off in burst mode
#define BURST_READ_LAST_REG		0x44 // RW, ending address to read off in burst mode
#define BURST_READ_REG			0x63 // R,  read this register
#define SQUAL_REG				0x05 // R
#define DELTA_X_REG				0x03 // R
#define DELTA_Y_REG				0x04 // R
#define PROD_ID_REG				0x00 // R, used for testing serial communication
#define PIX_ACCUM_REG			0x09 // R, average pixel value:
#define SHUTTER_HI_REG			0x06 // R, lower 4 bits are upper 4 of total shutter in clocks
#define SHUTTER_LO_REG			0x07 // R, lower 8 bits of total shutter in clocks

/* comment these out, not used here
#define MAXIMUM_PIXEL_REG   0x45
#define MINIMUM_PIXEL_REG   0x46

#define PIXEL_DATA_REG      0x48
#define SHUTTER_UPPER_REG   0x49
#define SHUTTER_LOWER_REG   0x4A
#define FRAME_PERIOD		0x4B
 */

#endif