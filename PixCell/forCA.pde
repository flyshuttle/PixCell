void drawCell(int i, int j)
{
  int b = int ( map(i,0,cellCount,0,512) );
  hue = map(in.mix.get(b),-0.1,0.1,0,250);  //το χρώμα του κυττάρου εξαρτάται από την ένταση
  hue = constrain(hue, 0, 250); 
  fill(hue,255,255);
  noStroke();
  pushMatrix();
  translate(i * cellSize, j * cellSize, 0);
  ellipse(0, 0, map(in.mix.get(b),-0.1,0.1,2,20), map(in.mix.get(b),-0.1,0.1,2,40));  //από τις δοκιμές, προέκυψε ότι οι τιμές είναι πάντα μικρότερες του 0.1
  popMatrix();
}


void updateCells()
{
  for (int i = 0; i < cellCount; i++) 
  {
    for (int j = 0; j < cellCount; j++) 
    {
      cells[i][j] = nextCells[i][j]; // ανανεώνει τα κύτταρα
      sumArray += cells[i][j]; //ελεγχει αν ειναι ολα νεκρα
    }
  }
}


void keyPressed()
{
  
  if(key == 'q') Hstep++; //το νεο σχήμα του κελιου εκτείνεται προς τα δεξιά
  else if (key == 'w' && Hstep >= 2) Hstep--;
  
  if(key == 'a') Vstep++; //το νεο σχήμα του κελιου εκτείνεται προς τα κάτω
  else if (key == 's' && Vstep >= 2) Vstep--;
  
  //println("Vstep : " + Vstep + " Hstep : " + Hstep);
    
  //όταν αλλαζει το step δημιουργούνται οι parents του frame
  if((key == 'q' || key == 'a' || key == 'w' || key == 's') )
  {
    for (int i = 0; i < cellCount; i++) 
    {
      for (int j = 0; j < cellCount; j++) 
      {
        //αν διαιρείται ακριβως είναι parent (η τελευταία θέση δεν ειναι parent)
        if( (i%Hstep == 0) && (j%Vstep == 0) && ( i < cellCount - 1 && j < cellCount - 1 ) )
        {
          parent[i][j] = 1; //ειναι parent
        }
        else
        {
          parent[i][j] = 0;
        }
      }
    }
  }
}


//Αποστολή μηνυμάτων στο SuperCollider
void sendOSCmessages()
{
  for (int j = 0; j < toneCell.length; j++) 
  {
    if(amp[j] > 0)
    {
      //println("TONE VALUE : " + toneCell[toneIndex][j] + " AMP : " + amp[j]);
      OscMessage msg1 = new OscMessage("/PlayS");
      msg1.add(toneCell[j][toneIndex]);
      msg1.add( map(amp[j],0,cellCount/7,0,1) );
      osc.send(msg1, supercollider); 
    }
  }
  
  //αποστολη μηνύματος ηχου - ολα νεκρα
  if (sumArray == 0)
  {
    if (!play) 
    {
      play = true;
      OscMessage msg2 = new OscMessage("/endS");
      osc.send(msg2, supercollider); 
    }
  }
  else play = false;  
}
