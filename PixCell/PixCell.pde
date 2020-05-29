// "PixCell - an interactive installation" script by Anna Gradou 
//  Το κομμάτι του κώδικα που αφορά το Game of Life του Conway βασίζεται σε κώδικα του Tassos Kanellos + Anna Laskari
//  Το κομμάτι του κώδικα που αφορά το kinect βασίστηκε στο παράδειγμα Skeleton3D της βιβλιοθήκης KinectV2ForProcessing

//  Eίναι ένα δισδιάστατο totalistic CA
//  Πλήθος δυνατών καταστάσεων κυττάρου = 2
//  Mέγεθος γειτονιάς = 8 (γειτονιά Moore)

//  Ο κάναβος με τα κύτταρα, αντιστοιχίζεται σε έναν κάναβο 7Χ7  σε κάθε κελί του οποίου βρίσκεται η μεταβλητή ενός ηχητικού σηματος
//  Μια κατακόρυφη γραμμή διαπερνά την εικόνα και καθορίζει τον παραγώμενο ήχο ως εξής :
//  Η ένταση του ήχου καθορίζεται από το πλήθος των κυτταρων που γεννιούνται κατα μήκος της γραμμής και τα ηχητικά σήματα αναλογα με το ύψος της γέννησης στον κατακόρυφο άξονα
//  Μεσω kinect , εντοπίζονται τα χέρια του χρήστη και γεννούν κύτταρα

import netP5.*;
import oscP5.*;
import ddf.minim.*;
import KinectPV2.KJoint;
import KinectPV2.*;

int [][] cells;
int [][] nextCells;
int [][] parent;
int cellCount = 70;
float cellSize;
float hue;
int Vstep = 1;
int Hstep = 1;
int parentJ;
int parentI;
boolean click;
int lpos = 0;
int[][] toneCell = {  {-21, -14, -7, 0, 7, 14, 21},
                      {-20, -13, -6, 1, 8, 15, 22},
                      {-19, -12, -5, 2, 9, 16, 23},
                      {-18, -11, -4, 3 , 10, 17 ,24},
                      {-17, -10, -3, 4, 11, 18, 25},
                      {-16, -9, -2, 5, 12, 19, 26},
                      {-15, -8, -1, 6, 13, 20, 27}   };
int[] amp;
int amplIndex;
int toneIndex;
int sumArray = 0;
boolean play = false;

float rightHandX, rightHandY,leftHandX,leftHandY;

Minim minim;
AudioInput in;
OscP5 osc;
NetAddress supercollider;
KinectPV2 kinect;

void setup()
{
  size(1300, 500,P3D);
  //fullScreen();
  
  //αρχικοποιηση supercollider 
  osc = new OscP5(this, 12000);
  supercollider = new NetAddress("127.0.0.1", 57120);
  
  //αρχικοποιηση kinect
  kinect = new KinectPV2(this);
  kinect.enableSkeletonColorMap(true);
  kinect.init();
  
  //αρχικοποίηση καναβου
  cellSize = float(width) / float(cellCount);
  cells = new int[cellCount][cellCount];
  nextCells = new int[cellCount][cellCount];
  parent = new int[cellCount][cellCount];  
  amp = new int[7];  
  
  //αρχικοποίηση αυτόματου
  for (int i = 0; i < cellCount; i++) 
  {
    for (int j = 0; j < cellCount; j++) 
    {
      cells[i][j] = int(random(2)); // τυχαία αρχική κατάσταση των κυττάρων, 0 ή 1 (νεκρό ή ζωντανό)
      parent[i][j] = 1;
    }
  }  
   
  frameRate(24); //το επιβραδύνουμε
  colorMode(HSB);  
  minim = new Minim(this); 
  //αρχικοποίηση Minim ώστε να έχουμε AudioInput
  in = minim.getLineIn(Minim.STEREO, 512);  
}

void draw()
{
  background(0); 
  drawKinectSkeleton();
  
  //σε ποια στήλη του πίνακα 7X7 με τις ηχητικές πληροφορίες βρίσκεται η κατακόρυφη γραμμή
  toneIndex = int ( map(lpos,0,width,0,6) );
  
  //αρχικοποιηση του πινακα των εντάσεων
  for (int i = 0; i < amp.length; i++) 
  {
    amp[i] = 0;
  }

  for (int i = 0; i < cellCount; i++) 
  {
    for (int j = 0; j < cellCount; j++) 
    {
      if (parent[i][j] == 1 && dist(rightHandX, rightHandY, i*cellSize+cellSize/2, j*cellSize+cellSize/2) < cellSize) // ελέγχει αν το δεξί χέρι βρίσκεται πάνω σε κάποιο κύτταρο
      {
        cells[i][j] = 1; //ζωντανεύει το κύτταρο που πατάω
        if( int ( map(i,0,cellCount-1,0,6) ) == toneIndex ) //αν το κύτταρο που γεννήθηκε βρίσκεται στην ίδια στήλη (του πίνακα 7Χ7 με τις ηχητικές πληροφορίες) με την κατακόρυφη γραμμή
        {
          amplIndex = int ( map(j,0,cellCount-1,0,6) ); //σε ποια γραμμή του πίνακα 7X7 με τις ηχητικές πληροφορίες βρίσκεται το κύτταρο που γεννήθηκε
          amp[amplIndex] = amp[amplIndex] + 1; //προσθετουμε μια μοναδα στην ενταση με την οποία θα ακουστεί ο ήχος που βρίσκεται στο κελί amplIndex
        }
      }
      if (parent[i][j] == 1 && dist(leftHandX, leftHandY, i*cellSize+cellSize/2, j*cellSize+cellSize/2) < cellSize) // ελέγχει αν το αριστερό χέρι βρίσκεται πάνω σε κάποιο κύτταρο
      {
        cells[i][j] = 1; //ζωντανεύει το κύτταρο που πατάω
        if( int ( map(i,0,cellCount-1,0,6) ) == toneIndex ) //αν το κύτταρο που γεννήθηκε βρίσκεται στην ίδια στήλη (του πίνακα 7Χ7 με τις ηχητικές πληροφορίες) με την κατακόρυφη γραμμή
        {
          amplIndex = int ( map(j,0,cellCount-1,0,6) ); //σε ποια γραμμή του πίνακα 7X7 με τις ηχητικές πληροφορίες βρίσκεται το κύτταρο που γεννήθηκε
          amp[amplIndex] = amp[amplIndex] + 1; //προσθετουμε μια μοναδα στην ενταση με την οποία θα ακουστεί ο ήχος που βρίσκεται στο κελί amplIndex
        }
      }
      // ζωγραφίζω τα κύτταρα:
      if (cells[i][j] == 1) 
      {
        drawCell(i,j);
      }
      // μετράει πόσα ζωντανά κύτταρα υπάρχουν στη γειτονιά κάθε κυττάρου
      int sum = 0;
      //Αν ειναι parent 
      if (parent[i][j] == 1)
      {
        for (int m = -Hstep; m <= Hstep; m+=Hstep) 
        {
          for (int n = -Vstep; n <= Vstep; n+=Vstep) 
          {
            if (!(m == 0 && n == 0)) // αυτό εξασφαλίζει ότι δε θα ληφθεί υπόψη η κατάσταση του ίδιου του κυττάρου του οποίου ελέγχεται η γειτονιά!
            {
              if (cells[(i + m + cellCount) % cellCount][(j + n + cellCount) % cellCount] == 1) // με το cellCount και το modulo κάνει wrapping για τα ακριανά κύτταρα
              {
                sum++;
              }
            }
          }
        }
        // κανόνες για την κατάσταση των κυττάρων στην επόμενη γενιά βάσει του αθροίσματος των ζωντανών γειτόνων
        if (sum < 2 || sum > 3) nextCells[i][j] = 0; // αν έχει λιγότερους από 2 γείτονες πεθαίνει από μοναξιά, πάνω από 3 πεθαίνει από υπερπληθυσμό
        else if (sum == 3) 
        {
          nextCells[i][j] = 1; // αν έχει 3 γείτονες ζωντανεύει
          if( int ( map(i,0,cellCount-1,0,6) ) == toneIndex )
          {
            amplIndex = int ( map(j,0,cellCount-1,0,6) ); //σε ποια γραμμή του πίνακα 7X7 με τις ηχητικές πληροφορίες βρίσκεται το κύτταρο που γεννήθηκε
            amp[amplIndex] = amp[amplIndex] + 1; //προσθετουμε μια μοναδα στην ενταση με την οποία θα ακουστεί ο ήχος που βρίσκεται στο κελί amplIndex
          }
        }
        else nextCells[i][j] = cells[i][j]; //αλλιώς μένει ως έχει
        
        //δωσε το αντιστοιχο status στα παιδια
        if (Hstep > 1)
        {
          //println(i,j);
          for(int cH = 1; cH < Hstep; cH++)
          {
            if (i + cH < cellCount) nextCells[i + cH][j] = nextCells[i][j];
          }
        }
        if (Vstep > 1)
        {
          for(int cV = 1; cV < Vstep; cV++)
          {
            if (j + cV < cellCount) nextCells[i][j + cV] = nextCells[i][j];
          }
        }
      }
    }
  }
  
  //κατασκευή γραμμής
  stroke(255);
  strokeWeight(2);
  line(lpos, 0, lpos, height); // κατακόρυφη κινούμενη γραμμή που βασίζεται στη μεταβλητή lpos
  
  //μετακίνηση γραμμής
  if (lpos < width) lpos++;
  else lpos = 0;
  
  //ανανέωση κυττάρων
  updateCells();
  
  //αποστολη μηνυματων
  sendOSCmessages();
       
  sumArray = 0;
}
