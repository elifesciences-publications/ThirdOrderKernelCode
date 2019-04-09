/* Arduino ADNS2620 Library
 * Can be used to interface between an ATmega328 (Arduino) and the ADNS2620 Mouse Sensor
 * Copyright 2010 SparkFun ElectronicS
 * Written by Ryan Owens
 * Edited by Damon Clark, 2013-Feb-5, to work with Parallax mouse 28560, which appears to have many similar communication protocols to the ADNS2650
*/

#include <avr/pgmspace.h>
#include "PLX28560.h"
#include "Arduino.h"

//Constructor sets the pins used for the mock 'i2c' communication
PLX28560::PLX28560()
{
	numMice = 5;
	_sda[0] = 9;
	_sda[1] = 10;
	_sda[2] = 11;
	_sda[3] = 12;
	_sda[4] = 13;
	
	_scl = 8;
}

//Configures the communication pins for their initial state
void PLX28560::begin()
{
	for (int mouse = 0; mouse < numMice; mouse++)
	{
		pinMode(_sda[mouse], OUTPUT);
	}
	pinMode(_scl, OUTPUT);
}

//Essentially resets communication to the PLX28560 module
void PLX28560::sync()
{
    // sure, keep these going, seems reasonable
    digitalWrite(_scl, HIGH);
    delay(1); // 1ms delay
	digitalWrite(_scl, LOW);
    delay(1);
	digitalWrite(_scl, HIGH);
    delay(100);
}

//Reads a register from the PLX28560 sensor. Returns the result to the calling function.
//Example: value = mouse.read(CONFIGURATION_REG);
signed char* PLX28560::read(char address)
{
    signed char* value = new signed char[5];

	for (int mouse = 0; mouse < numMice; mouse++)
	{
		value[mouse] = 0;
		pinMode(_sda[mouse], OUTPUT); //Make sure the SDIO pin is set as an output.
	}
    digitalWrite(_scl, HIGH); //Make sure the clock is high.
    address &= 0x7F;    //Make sure the highest bit of the address byte is '0' to indicate a read.
 
    //Send the Address to the PLX28560
    for(int address_bit=7; address_bit >=0; address_bit--)
    {
        digitalWrite(_scl, LOW);  //Lower the clock
		
		for (int mouse = 0; mouse < numMice; mouse++)
		{
			//pinMode(_sda[mouse], OUTPUT); //Make sure the SDIO pin is set as an output. -- DAC need to be done every time?
        
			//If the current bit is a 1, set the SDIO pin. If not, clear the SDIO pin
			if(address & (1<<address_bit))
			{
				digitalWrite(_sda[mouse], HIGH);
			}
			else
			{
				digitalWrite(_sda[mouse], LOW);
			}
		}
        delayMicroseconds(10);
        digitalWrite(_scl, HIGH);
        delayMicroseconds(10);
    }
    
    delayMicroseconds(120);   //Allow extra time for PLX28560 to transition the SDIO pin (per datasheet)
    //Make SDIO an input on the microcontroller
	for (int mouse = 0; mouse < numMice; mouse++)
	{
		pinMode(_sda[mouse], INPUT);	//Make sure the SDIO pin is set as an input.
		//digitalWrite(_sda[mouse], HIGH); //Enable the internal pull-up maybe kill this? -matt
	}
    //Send the Value byte to the PLX28560
    for(int value_bit=7; value_bit >= 0; value_bit--)
	{
        digitalWrite(_scl, LOW);  //Lower the clock
        delayMicroseconds(10); //Allow the PLX28560 to configure the SDIO pin
        digitalWrite(_scl, HIGH);  //Raise the clock
        delayMicroseconds(10);
        
        //If the SDIO pin is high, set the current bit in the 'value' variable. If low, leave the value bit default (0).    
		//if((ADNS_PIN & (1<<ADNS_sda)) == (1<<ADNS_sda))value|=(1<<value_bit);
		for (int mouse = 0; mouse < numMice; mouse++)
		{
			if(digitalRead(_sda[mouse]))value[mouse] |= (1<<value_bit);
		}
    }
    
    return value;
}	

//Writes a value to a register on the PLX28560.
//Example: mouse.write(CONFIGURATION_REG, 0x01);
void PLX28560::write(char address, char value)
{
	for (int mouse = 0; mouse < numMice; mouse++)
	{
		pinMode(_sda[mouse], OUTPUT);	//Make sure the SDIO pin is set as an output.
	}
    digitalWrite(_scl, HIGH);          //Make sure the clock is high.
    address |= 0x80;    //Make sure the highest bit of the address byte is '1' to indicate a write.

    //Send the Address to the PLX28560
    for(int address_bit=7; address_bit >=0; address_bit--){
        digitalWrite(_scl, LOW); //Lower the clock
        
        delayMicroseconds(10); //Give a small delay (only needed for the first iteration to ensure that the PLX28560 relinquishes
                    //control of SDIO if we are performing this write after a 'read' command.
        
		for (int mouse = 0; mouse < numMice; mouse++)
		{
			//If the current bit is a 1, set the SDIO pin. If not, clear the SDIO pin
			if(address & (1<<address_bit))digitalWrite(_sda[mouse], HIGH);
			else digitalWrite(_sda[mouse], LOW);
		}
        delayMicroseconds(10);
        digitalWrite(_scl, HIGH);
        delayMicroseconds(10);
    }
    
    //Send the Value byte to the PLX28560
    for(int value_bit=7; value_bit >= 0; value_bit--){
        digitalWrite(_scl, LOW);  //Lower the clock
		for (int mouse = 0; mouse < numMice; mouse++)
		{
			//If the current bit is a 1, set the SDIO pin. If not, clear the SDIO pin
			if(value & (1<<value_bit))digitalWrite(_sda[mouse], HIGH);
			else digitalWrite(_sda[mouse], LOW);
		}
        delayMicroseconds(10);
        digitalWrite(_scl, HIGH);
        delayMicroseconds(10);
    }
}