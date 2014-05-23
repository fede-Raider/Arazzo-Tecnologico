
//Arazzo Tecnologico 
// Giontoli, Ciardi, Tommasi, Paolieri

#include <Servo.h>
Servo SG;
Servo DS;

char toDo;

// @ -> su
// # -> giù
// * -> destra
// + -> sinistra
void set()
{
  SG.write(0);
  DS.write(90);
  delay(3.11*180);
}
void setup() {
  
  
  SG.attach(10,544,2400); 
  DS.attach(11,544,2400); 

  set();
  
  Serial.begin(9600);                    // Start serial communication at 9600 bps
  while(Serial.read()!='@'){
    Serial.write("#");            // trova automaticamente la porta (snellito)
  }
  Serial.write("\n\n wOnline..");
  delay(1000);

   
  
  Serial.flush();
}

void loop() {

  if(Serial.available()>0){  
    
    toDo=Serial.read();    
    
    if(toDo=='@'){
      SG.write(SG.read()+1);   // 10 è puramente indicativo, non ho arduini per testare
    }                          // probabilmente andrà modificato fino a trovare quel valore
    else if(toDo =='#'){       // per il quale i servo si muovono in sincronia con quello che invia 
      SG.write(SG.read()-1);   // il processing. Altrimenti, cosa che preferisco, conviene farsi
    }                          // una funzione per calibrare gli spostamenti e anticipare al pc
    else if(toDo =='*'){       // che dovrà smettere di inviare segnali perché è già arrivato.
      DS.write(DS.read()+1);   // Altrimenti la lampada rimane fluttuante attorno al viso.
    }
    else if(toDo =='+'){
      DS.write(DS.read()-1);
    }
    else if(toDo =='s'){
      set();
    }
  }
  
  
}




