
#include <Servo.h>
Servo SG;
Servo DS;
Servo TS;

int Quantity = 1;

char toDo;

// @ -> su
// # -> giù
// * -> destra
// + -> sinistra
// % -> su testa
// $ -> giù testa
void set()
{
  SG.write(90);
  DS.write(0);
  TS.write(90);
  delay(3.11*180);
}
void setup() {
  
  SG.attach(10); 
  DS.attach(9); 
  TS.attach(7);

  set();
  
  Serial.begin(9600);                    // Start serial communication at 9600 bps

  Serial.write("\n\n wOnline..");
  delay(1000);

  Serial.flush();
}

void loop() {
  Serial.flush();
  if(Serial.available()>0){  
    
    toDo=Serial.read();  
    Serial.println(toDo);
   // Serial.println(toDo);
    if(toDo=='@' || toDo=='#' || toDo=='*' || toDo=='+' || toDo=='%' || toDo=='$'){
       
    if(toDo=='@'){
      SG.write(SG.read()+Quantity);   // 10 è puramente indicativo, non ho arduini per testare
    }                          // probabilmente andrà modificato fino a trovare quel valore
    else if(toDo =='#'){       // per il quale i servo si muovono in sincronia con quello che invia 
      SG.write(SG.read()-Quantity);   // il processing. Altrimenti, cosa che preferisco, conviene farsi
    }                          // una funzione per calibrare gli spostamenti e anticipare al pc
    else if(toDo =='*'){       // che dovrà smettere di inviare segnali perché è già arrivato.
      DS.write(DS.read()+Quantity);   // Altrimenti la lampada rimane fluttuante attorno al viso.
    }
    else if(toDo =='+'){
      DS.write(DS.read()-Quantity);
    }
    else if(toDo =='%'){       // che dovrà smettere di inviare segnali perché è già arrivato.
      TS.write(TS.read()+Quantity);   // Altrimenti la lampada rimane fluttuante attorno al viso.
    }
    else if(toDo =='$'){
      TS.write(TS.read()-Quantity);
    }
    else if(toDo =='s'){
      set();
    }
  }
  }
  
  
  
  
}




