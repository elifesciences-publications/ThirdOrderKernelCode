/* Reads input from the serial port. If you send
the character 'a' it will write back the sum of
all dX changes since the last request
*/
//Add the PLX28560 Library to the sketch.
//#include "..\libraries\PLX28560\PLX28560.h"
#include <PLX28560.h>
//Name the PLX28560, and tell the sketch which pins are used for communication
// first number is SDA line (data), second is SCL line (clock)
PLX28560 mouse;

//This value will be used to store information from the mouse registers.
signed char* tempX = new signed char[5];
signed char* tempY = new signed char[5];
//sets dots per inch, 0 means 1000 1 means 500
char dpi = 0;
//set power mode. 0 means power saving, 1 means always-on
char power = 1;

unsigned long loopStartTime;
unsigned long loopEndTime;
unsigned long loopEnd2;
unsigned long loopTime = 2600L;
unsigned long timeDiff = 0;

boolean startLoop = false;

uint8_t dX[5] = {0,0,0,0,0};
uint8_t dY[5] = {0,0,0,0,0};

void setup()
{
  //Initialize the PLX28560
  mouse.begin();
  delay(100);
  //A sync is performed to make sure the PLX28560 is communicating
  mouse.sync();
  mouse.write(CONFIGURATION_REG,dpi);
  mouse.write(OPERATION_REG,power);
  
  for(int ii=0;ii<5;ii++)
  {
    tempX[ii] = 0;
    tempY[ii] = 0;
  }
  
  //Create a serial output. can have up to 115200 -- about every 3 ms to sample and send; 20 ms at 9600
  Serial.begin(115200);
}

void loop()
{
  loopStartTime = micros();
  
  switch (Serial.read()) {
    case 97: 
      startLoop = true;
      break;
    case 98:
      startLoop = false;
      break;
    default:
      break;
  }
  
  if (startLoop) {
    tempX = mouse.read(DELTA_X_REG);
    tempY = mouse.read(DELTA_Y_REG);
    
    // dX and dY accumulates as tempX and tempY, as integer
    for(int ii=0;ii<5;ii++)
    {
      dX[ii] = (uint8_t)tempX[ii];
      dY[ii] = (uint8_t)tempY[ii];
    }
    
    Serial.write(dX,5);
    Serial.write(dY,5);
  
    delete[] tempX; //takes ~10 microseconds to delete per variable
    delete[] tempY;
  } else {
    delayMicroseconds(100);
  }
  
  loopEndTime = micros();
  if ((loopEndTime-loopStartTime)<loopTime) {
    timeDiff = loopTime - (loopEndTime - loopStartTime);
  } else {
    timeDiff = 10L;
  }
  
  delayMicroseconds(timeDiff);
  //Serial.println(loopEndTime - loopStartTime);
}
