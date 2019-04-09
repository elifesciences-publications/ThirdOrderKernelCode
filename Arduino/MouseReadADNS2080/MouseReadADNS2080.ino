/* Reads input from the serial port. If you send
the character 'a' it will write back the sum of
all dX changes since the last request
*/
//Add the ADNS2080 Library to the sketch.
#include <ADNS2080.h>

//Name the ADNS2080, and tell the sketch which pins are used for communication
// first number is SDA line (data), second is SCL line (clock)
ADNS2080 mouse;

unsigned long loopStartTime;
unsigned long loopEndTime;
unsigned long loopEnd2;
unsigned long loopTime = 2600L;
unsigned long timeDiff = 0;

boolean startLoop = false;

void setup()
{
  //Initialize the ADNS2080
  mouse.begin();
  delay(100);
  //A sync is performed to make sure the ADNS2080 is communicating
  mouse.sync();
  //byte configuration = B10111000; //12 bit reporting, 2000dpi
  byte configuration = B00100000; //8 bit reporting, 1000dpi
  mouse.write(MOUSE_CTRL_REG,configuration);
  configuration = B01000000; //Force run mode
  mouse.write(PERFORMANCE_REG,configuration);
  //mouse.write(BURST_READ_LAST_REG,SQUAL_REG);
  
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
    
    //BurstData mouseData = mouse.readBurst();
    
    //byte dXH = mouseData.data.deltaH >> 4;
    //byte dYH = mouseData.data.deltaH & 0x0f;
    
    byte dXArray[5] = {0,0,0,0,0};
    byte dYArray[5] = {0,0,0,0,0};
    byte squalArray[5] = {0,0,0,0,0};
    
    byte dX = mouse.read(DELTA_X_REG);
    byte dY = mouse.read(DELTA_Y_REG);
    byte squal = mouse.read(SQUAL_REG);
    byte prod = mouse.read(PROD_ID_REG);
    byte pix = mouse.read(PIX_ACCUM_REG);
    byte shutHi = mouse.read(SHUTTER_HI_REG);
    byte shutLo = mouse.read(SHUTTER_LO_REG);
    byte shutter = ((shutHi << 4) && 0xf0) || (shutLo && 0x0f);
    
    dXArray[0] = ~(dX-1);//Invert dX so it behaves like other mouse
    
    dYArray[0] = ~(dY-1);

    squalArray[0] = squal;
    squalArray[1] = prod;
    squalArray[2] = pix;
    squalArray[3] = shutHi;
    squalArray[4] = shutLo;   
    
    Serial.write(squalArray,5);
    //Serial.write(dXArray,5);
    Serial.write(dYArray,5);
  
  }
  else {
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
