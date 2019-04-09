/* Arduino ADNS2620 Library
 * Can be used to interface between an ATmega328 (Arduino) and the ADNS2620 Mouse Sensor
 * Copyright 2010 SparkFun ElectronicS
 * Written by Ryan Owens
 * Edited by Damon Clark, 2013-Feb-5, to work with Parallax mouse 28560, which appears to have many similar communication protocols to the ADNS2650
*/

#include <avr/pgmspace.h>
#include "ADNS2080.h"
#include "Arduino.h"

//Constructor sets the pins used for the mock 'i2c' communication
ADNS2080::ADNS2080()
{
	_sda = 9;
	_scl = 8;
}

//Configures the communication pins for their initial state
void ADNS2080::begin()
{
	pinMode(_sda, OUTPUT);
	pinMode(_scl, OUTPUT);
}

//Essentially resets communication to the ADNS2080 module
void ADNS2080::sync()
{
    // sure, keep these going, seems reasonable
    digitalWrite(_scl, HIGH);
    delay(1); // 1ms delay
	digitalWrite(_scl, LOW);
    delay(1);
	digitalWrite(_scl, HIGH);
    delay(100);
}

//Reads a register from the ADNS2080 sensor. Returns the result to the calling function.
//Example: value = mouse.read(CONFIGURATION_REG);
byte ADNS2080::read(byte address)
{
	byte value = 0;
	pinMode(_sda, OUTPUT); //Make sure the SDIO pin is set as an output.
    digitalWrite(_scl, HIGH); //Make sure the clock is high.
    address &= 0x7F;    //Make sure the highest bit of the address byte is '0' to indicate a read.
 
    //Send the Address to the ADNS2080
    for(int address_bit=7; address_bit >=0; address_bit--)
    {
        digitalWrite(_scl, LOW);  //Lower the clock
		//If the current bit is a 1, set the SDIO pin. If not, clear the SDIO pin
		if(address & (1<<address_bit))
		{
			digitalWrite(_sda, HIGH);
		}
		else
		{
			digitalWrite(_sda, LOW);
		}
        delayMicroseconds(10);
        digitalWrite(_scl, HIGH);
        delayMicroseconds(10);
    }
    
    delayMicroseconds(120);   //Allow extra time for ADNS2080 to transition the SDIO pin (per datasheet)
    //Make SDIO an input on the microcontroller
	pinMode(_sda, INPUT);	//Make sure the SDIO pin is set as an input.
    
	//Send the Value byte to the ADNS2080
    for(int value_bit=7; value_bit >= 0; value_bit--)
	{
        digitalWrite(_scl, LOW);  //Lower the clock
        delayMicroseconds(10); //Allow the ADNS2080 to configure the SDIO pin
        digitalWrite(_scl, HIGH);  //Raise the clock
        delayMicroseconds(10);
        
        //If the SDIO pin is high, set the current bit in the 'value' variable. If low, leave the value bit default (0).    
		if(digitalRead(_sda))
			value |= (1<<value_bit);
    }
    
    return value;
}

//Reads a register from the ADNS2080 sensor. Returns the result to the calling function.
//Example: value = mouse.read(CONFIGURATION_REG);
BurstData ADNS2080::readBurst()
{
	byte address = BURST_READ_REG;

	BurstData output;
	output.rawData = 0;
	pinMode(_sda, OUTPUT); //Make sure the SDIO pin is set as an output.
    digitalWrite(_scl, HIGH); //Make sure the clock is high.
    address &= 0x7F;    //Make sure the highest bit of the address byte is '0' to indicate a read.
 
    //Send the Address to the ADNS2080
    for(int address_bit=7; address_bit >=0; address_bit--)
    {
        digitalWrite(_scl, LOW);  //Lower the clock
		//If the current bit is a 1, set the SDIO pin. If not, clear the SDIO pin
		if(address & (1<<address_bit))
		{
			digitalWrite(_sda, HIGH);
		}
		else
		{
			digitalWrite(_sda, LOW);
		}
        delayMicroseconds(10);
        digitalWrite(_scl, HIGH);
        delayMicroseconds(10);
    }
    
    delayMicroseconds(120);   //Allow extra time for ADNS2080 to transition the SDIO pin (per datasheet)
    //Make SDIO an input on the microcontroller
	pinMode(_sda, INPUT);	//Make sure the SDIO pin is set as an input.
    
	//Send the Value byte to the ADNS2080
    for(int value_bit=31; value_bit >= 0; value_bit--)
	{
        digitalWrite(_scl, LOW);  //Lower the clock
        delayMicroseconds(10); //Allow the ADNS2080 to configure the SDIO pin
        digitalWrite(_scl, HIGH);  //Raise the clock
        delayMicroseconds(10);
        
        //If the SDIO pin is high, set the current bit in the 'value' variable. If low, leave the value bit default (0).    
		if(digitalRead(_sda))
			output.rawData |= (1<<value_bit);
    }
    
    return output;
}		

//Writes a value to a register on the ADNS2080.
//Example: mouse.write(CONFIGURATION_REG, 0x01);
void ADNS2080::write(byte address,byte value)
{
	pinMode(_sda, OUTPUT); //Make sure the SDIO pin is set as an output.
    digitalWrite(_scl, HIGH); //Make sure the clock is high.
    address |= 0x80; //Make sure the highest bit of the address byte is '1' to indicate a write.

    //Send the Address to the ADNS2080
    for(int address_bit=7; address_bit >=0; address_bit--){
        digitalWrite(_scl, LOW); //Lower the clock
        
        delayMicroseconds(10); //Give a small delay (only needed for the first iteration to ensure that the ADNS2080 relinquishes
                    //control of SDIO if we are performing this write after a 'read' command.
        
		//If the current bit is a 1, set the SDIO pin. If not, clear the SDIO pin
		if(address & (1<<address_bit))
			digitalWrite(_sda, HIGH);
		else
			digitalWrite(_sda, LOW);
		
        delayMicroseconds(10);
        digitalWrite(_scl, HIGH);
        delayMicroseconds(10);
    }
    
    //Send the Value byte to the ADNS2080
    for(int value_bit=7; value_bit >= 0; value_bit--){
        digitalWrite(_scl, LOW);  //Lower the clock
		//If the current bit is a 1, set the SDIO pin. If not, clear the SDIO pin
		if(value & (1<<value_bit))
			digitalWrite(_sda, HIGH);
		else
			digitalWrite(_sda, LOW);
        delayMicroseconds(10);
        digitalWrite(_scl, HIGH);
        delayMicroseconds(10);
    }
}