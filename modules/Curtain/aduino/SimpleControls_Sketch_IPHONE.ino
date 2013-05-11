#include <Stepper.h>

#include <SPI.h>
#include <ble.h>
#include <Servo.h> 
 
 //connect a LED at pin 3
#define DIGITAL_OUT_PIN    3

#define STEPS 100
//connect a steeper at pin 4,5,6,7
Stepper stepper(STEPS, 4, 5, 6, 7);

int previous = 0;

 
void setup()
{
  SPI.setDataMode(SPI_MODE0);
  SPI.setBitOrder(LSBFIRST);
  SPI.setClockDivider(SPI_CLOCK_DIV16);
  SPI.begin();

  ble_begin();
  pinMode(DIGITAL_OUT_PIN, OUTPUT);
  stepper.setSpeed(80);
  
}

void loop()
{
  // If data is ready
  while(ble_available())
  {
    // read out command and data
    byte data0 = ble_read();
    byte data1 = ble_read();
    byte data2 = ble_read();
    
    data1 = data1 * 1.8;
    
    //check if is steeper
    if (data0 == 0x02) 
    {
        stepper.step(data1 - previous);
        
        previous = data1;
    }
    
    //check if is LED switch
    if (data0 == 0x01) 
    {
      if (data1 == 0x01)
        digitalWrite(DIGITAL_OUT_PIN, HIGH);
      else
        digitalWrite(DIGITAL_OUT_PIN, LOW);
    }
  }
  // Allow BLE Shield to send/receive data
  ble_do_events();  
}



