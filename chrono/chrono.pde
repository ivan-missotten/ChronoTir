/*            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
                    Version 2, December 2004

 Copyright (C) 2012 Sebastien Van Cauwenberghe <svancau@gmail.com>

 Everyone is permitted to copy and distribute verbatim or modified
 copies of this license document, and changing it is allowed as long
 as the name is changed.

            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION

  0. You just DO WHAT THE FUCK YOU WANT TO. 
*/
#include <LiquidCrystal.h>

#define RED 0
#define ORANGE 1
#define GREEN 2

#define ABC 0
#define CAB 1
#define BCA 2

#define ABCD_v 0
#define CDAB_v 1

#define ABC 0
#define ABCD 1

#define D7 5
#define D6 4
#define D5 3
#define D4 2
#define EN 11
#define RS 12

#define BTN0 6
#define BTN1 7
#define BTN2 8

#define MODE_IDLE 0
#define MODE_RUN 1
#define MODE_STOP 2

unsigned char ligne; // Line indicator
unsigned char typeLigne; // ABC or ABCD
unsigned char couleur; // RED, ORANGE, GREEN
unsigned long temps; // Remaining time
unsigned char mode; // Current state
unsigned char nVolee; // Flight number

LiquidCrystal lcd (RS, EN, D7, D6, D5, D4);

void setCouleur(unsigned char color)
{
  couleur = color;
}

// Update Line number on the LCD
void LCDUpdateLine()
{
   if (typeLigne == ABC) {
    lcd.setCursor (13, 0);
    switch (ligne) {
      case ABC:
        lcd.print ("ABC");
        break;

      case CAB:
        lcd.print ("CAB");
        break;

      case BCA:
        lcd.print ("BCA");
        break;
    }
  }
  else if (typeLigne == ABCD) {
    lcd.setCursor (12, 0);
    switch (ligne) {
      case ABCD_v:
        lcd.print ("ABCD");
        break;

      case CDAB_v:
        lcd.print ("CDAB");
        break;
    }
  }
}

// Update time on LCD
void LCDUpdateTime()
{
  unsigned char minutes, secondes;
  lcd.setCursor (0, 0);
  minutes = temps / 60;
  if (minutes < 10)
  {
    lcd.print ('0');
    lcd.print ((int)minutes);
  }
  else
  {
    lcd.print ((int)minutes);
  }
  lcd.print (':');
  secondes = temps % 60;
  if (secondes < 10)
  {
    lcd.print ('0');
    lcd.print ((int)secondes);
  }
  else
  {
    lcd.print ((int)secondes);
  }
}

// Update color status on LCD
void LCDUpdateCouleur()
{
   lcd.setCursor (0, 1);
   lcd.print ("Etat : ");
   switch (couleur) {
      case RED: 
        lcd.print ("Rouge ");
        break;
      case ORANGE:
        lcd.print ("Orange");
        break;
      case GREEN:
       lcd.print ("Vert  ");
       break;     
   }
}

// Update flight number
void LCDUpdateFl()
{
  lcd.setCursor (-4, 2);
  lcd.print ("Volée : ");
  lcd.print (nVolee);
}

// Show context menu
void LCDUpdateMenu()
{
  lcd.setCursor (-4, 3);
  
  switch (mode) {
    case MODE_IDLE:
      lcd.print ("Start Ligne  Rst");
      break;

    case MODE_RUN:
      lcd.print ("      Stop      ");
      break;
    
    case MODE_STOP:
      lcd.print ("Start        Rst");
      break;
  }
}

// Increment line number
void incrementLine()
{
  unsigned char noLignes;
  if (typeLigne == ABC)
    noLignes = 3;
  else if (typeLigne == ABCD)
    noLignes = 4;
  ligne = (ligne + 1) % noLignes;
}

void setup()
{
  typeLigne = ABC;
  couleur = RED;
  ligne = ABC;
  nVolee = 1;

  pinMode (D7, OUTPUT);
  pinMode (D6, OUTPUT);
  pinMode (D5, OUTPUT);
  pinMode (D4, OUTPUT);
  pinMode (EN, OUTPUT);
  pinMode (RS, OUTPUT);
  
  pinMode (BTN0, INPUT);
  pinMode (BTN1, INPUT);
  pinMode (BTN2, INPUT);
  
  lcd.begin (16, 4);
  lcd.clear();
  LCDUpdateLine();
  LCDUpdateTime();
  LCDUpdateCouleur();
  LCDUpdateFl();
  LCDUpdateMenu();
}

void loop()
{
  static long prevMillis;
  static char prvBtn0, prvBtn1, prvBtn2;
  char btn0, btn1, btn2;

  btn0 = digitalRead (BTN0);
  btn1 = digitalRead (BTN1);
  btn2 = digitalRead (BTN2);
    
  switch (mode) {
    case MODE_IDLE: // Waiting to be triggered
      temps = 130;
      setCouleur (RED);

      // To start 
      if (btn0 == 0 && prvBtn0 == 1) {
        prevMillis = millis();
        mode = MODE_RUN;
      }
      
      // To change line number
      if (btn1 == 0 && prvBtn1 == 1) {
        incrementLine();
      }
      break;

    case MODE_RUN: // Counting down
    
      // To Stop
      if (btn1 == 0 && prvBtn1 == 1) {
        mode = MODE_STOP;
      }
      
      if (temps == 0) { // If time elapsed
        mode = MODE_IDLE;
        setCouleur (RED);
        incrementLine();        
      }
      else if (temps <= 30) { // If 30s remaining
        setCouleur (ORANGE);
      }
      else if (temps <= 120) { // If 2 min remaining
        setCouleur (GREEN);
      }

      if ((millis() - prevMillis) >= 1000) { // If 1 sec elapsed
        temps --;
        prevMillis = millis();
      }
      
      break;

    case MODE_STOP: // IF STOPPED
      if (btn0 == 0 && prvBtn0 == 1) {
        mode = MODE_RUN;
      } else if (btn2 == 0 && prvBtn2 == 1) {
        mode = MODE_IDLE;
      }
  }

  LCDUpdateLine();
  LCDUpdateTime();
  LCDUpdateCouleur();
  LCDUpdateFl();
  LCDUpdateMenu();

  prvBtn0 = btn0;
  prvBtn1 = btn1;
  prvBtn2 = btn2;
  
}

