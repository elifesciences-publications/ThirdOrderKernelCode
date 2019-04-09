/* Arduino ADNS2620 Library
 * Copyright 2010 SparkFun Electronic
 * Written by Ryan Owens
*/

#ifndef plx28560_h
#define plx28560_h

#include <avr/pgmspace.h>
#include "Arduino.h"

class PLX28560
{
	public:
		PLX28560();
		void begin();
		void sync();
		signed char* read(char address);
		void write(char address, char value);
	private:
		int numMice;
		int _sda[5];
		int _scl;
};

/* Register Map for the PLX28560 Optical Mouse Sensor */
#define OPERATION_REG   0x00 // RW, bit7=1 to reset chip, bit6=1 to power down
#define STATUS_REG          0x16 // R, b7=1 if motion, b0=0 if 1000dpi, b3=1 if X overflow, b4=1 if Y overflow
#define DELTA_Y_REG         0x02 // R, -128 to 127 (int8)
#define DELTA_X_REG         0x03 // R, -128 to 127
#define SQUAL_REG           0x04 // R, 0-255
#define CONFIGURATION_REG   0x1B // RW, b7=1 for 500dpi, b7=0 for 1000dpi
#define PIXEL_SUM_REG       0x47

/* comment these out, not used here
#define MAXIMUM_PIXEL_REG   0x45
#define MINIMUM_PIXEL_REG   0x46

#define PIXEL_DATA_REG      0x48
#define SHUTTER_UPPER_REG   0x49
#define SHUTTER_LOWER_REG   0x4A
#define FRAME_PERIOD		0x4B
 */

#endif