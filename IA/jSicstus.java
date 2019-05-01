/* jSicstus
* A Java class that communicates with Sicstus Prolog using Jasper
*
* Compiling rules :
* javac -classpath [PATH TO JASPER.JAR]/jasper.jar:. jSicstus.java
*
* java -classpath [PATH TO JASPER.JAR]/jasper.jar:. jSicstus
*
* Default path jasper.jar : /usr/local/sicstus4.4.1/lib/sicstus-4.4.1/bin/jasper.jar
*
*/

import se.sics.jasper.*;
import java.io.*;
import java.util.*;
import java.net.ServerSocket;
import java.net.Socket;

public class jSicstus {
  public static void main(String[] args) {

    System.out.println("* Starting AI..");

    /*--------------------------------------------------------------------------
     * JAVA <-> C
     *------------------------------------------------------------------------*/

    if (args.length != 1) {
      System.out.println("* Error : missing argument -> port");
      System.exit(-1);
    }

    ServerSocket srv = null;
    Socket s = null;
    InputStream is = null;
    OutputStream os = null;
    DataInputStream ids = null;
    DataOutputStream ods = null;
    int port = Integer.parseInt(args[0]);
    boolean sens = false; // piece's sens  false = nord ; true = sud
    // Server creation and waiting the client's connection
    System.out.println("Waiting the client to connect");
    try{
      srv = new ServerSocket(port) ;

      System.out.println("* Waiting client connection");
      s = srv.accept();
      System.out.println("* Client connected");

      is = s.getInputStream();
      os = s.getOutputStream();

      ids = new DataInputStream(is);
      ods =  new DataOutputStream(os);
      // reading the orientation
      sens = ids.readBoolean(); // sens  0 = nord ; 1 = sud
      System.out.println("* Sens [nord (false) / sud(true)] : " + sens);
    }catch(IOException e){
      System.out.println(e);
      System.exit(-1);
    }

    Coup oppStrike = null;
    // lecture d'un coup
    try{
      EnumCoup typeC = EnumCoup.values()[ids.readInt()];
      EnumPiece typeP = EnumPiece.values()[ids.readInt()];
      System.out.println(typeP);
      if(typeC == EnumCoup.DEPLACER){
        Case cFrom = new Case(EnumCol.values()[ids.readInt()],EnumLig.values()[ids.readInt()]);
        Case cTo = new Case(EnumCol.values()[ids.readInt()],EnumLig.values()[ids.readInt()]);
        boolean captured = ids.readBoolean();
        System.out.println("Lecture d'un deplacement \n : captured ? "+captured);
        System.out.println("From : " + cFrom.toString());
        System.out.println("To : " + cTo.toString());
        DeplPiece deplP = new DeplPiece(cFrom,cTo,captured);
        oppStrike = new Coup(typeC,typeP,deplP);

        System.out.println(((DeplPiece)oppStrike.getParams()).getCaseArr().getCol());
      }else{
        Case cOnto = new Case(EnumCol.values()[ids.readInt()],EnumLig.values()[ids.readInt()]);
        System.out.println("Lecture d'une pose de pièce");
        System.out.println(cOnto.toString());
      }
    }catch(IOException e){
      System.out.println("* Error : IOException");
      e.printStackTrace();
      System.exit(-1);
    }

    oppStrike.sendToNetwork(ods);



    /*--------------------------------------------------------------------------
     * JAVA <-> Prolog
     *------------------------------------------------------------------------*/

    // Sicstus Prolog object
    SICStus sp = null;

    // Main loop switch
    boolean run = true;

    // Specify turn order
    boolean opponentTurn = false;

    // Initialize sides
    String side = "north";      // Our side (north/south)
    String opposide = "south";  // Opponent side (north/south)

    if (sens == true) {
      side = "south";
      opposide = "north";
    }

    // The current board
    ArrayList<String> currentBoard = new ArrayList();
    // The current list of pieces captured by north player
    ArrayList<String> currentCaptN = new ArrayList();
    // The current list of pieces captured by south player
    ArrayList<String> currentCaptS = new ArrayList();

    // The new board
    ArrayList<String> newBoard = new ArrayList();
    // The new list of pieces captured by north player
    ArrayList<String> newCaptN = new ArrayList();
    // The new list of pieces captured by south player
    ArrayList<String> newCaptS = new ArrayList();

    System.out.println("* AI ready with the following settings : ");
    System.out.println("\tside = " + side);
    System.out.println("\topposide = " + opposide);

    try {
      sp = new SICStus();   // Initialize Sicstus
      sp.load("./ia.pl");   // Load Prolog file
    }
    catch (SPException e) {
      System.out.println("* Error : SPException");
      e.printStackTrace();
      System.exit(-1);
    }

    // Initialize the board
    try {
      HashMap<String, Term> results = new HashMap();

      // Create a Sicstus query
      Query qu = sp.openQuery("initial_board(Board).", results);

      // Get a solution
      boolean sol = qu.nextSolution();

      // If there is a solution
      if (sol) {
        // Convert list into Java arraylist
        if (results.get("Board").isList()) {
          Term[] term = results.get("Board").toPrologTermArray();

          for (int i = 0; i < term.length; i++) {
            currentBoard.add(term[i].toString());
          }
        }
      }

      qu.close();
    }
    catch (SPException e) {
      System.out.println("* Error : SPException");
      e.printStackTrace();
      System.exit(-1);
    }
    catch (Exception e) {
      System.out.println("* Error : Exception");
      e.printStackTrace();
      System.exit(-1);
    }

    // Main AI loop
    while (run) {
      // Communication avec le fichier client.c
      // afin d'informer du coup de l'adversaire

      System.out.println("* New turn");
      System.out.println("\tcurrentBoard : " + currentBoard);
      System.out.println("\tcurrentCaptN : " + currentCaptN);
      System.out.println("\tcurrentCaptS : " + currentCaptS);

      // Store the result in an hashmap : PrologVarN -> Value
      HashMap<String, Term> results = new HashMap();

      try {
        String request = "";

        if (opponentTurn) {
          String oppopiece = "kodama";      // Opponent piece
          int oppox = 3, oppoy = 4;         // Opponent piece coords
          int opponewx = 3, opponewy = 3;   // Opponent piece new coords

          request = "force_move("
          + opposide + ", "
          + oppopiece + ", "
          + oppox + ", "
          + oppoy + ", "
          + opponewx + ", "
          + opponewy + ", "
          + currentBoard + ", "
          + currentCaptN + ", "
          + currentCaptS + ", NewBoard, NewCaptN, NewCaptS).";
        }
        else {
          request = "try_move("
          + currentBoard + ", "
          + currentCaptN + ", "
          + currentCaptS + ", "
          + side + ", NewBoard, NewCaptN, NewCaptS).";
        }

        // Create a Sicstus query
        Query qu = sp.openQuery(request, results);

        // Get a solution
        boolean sol = qu.nextSolution();

        // If there is a solution
        if (sol) {
          // Convert lists into Java arrays
          if (results.get("NewBoard").isList()) {
            Term[] term = results.get("NewBoard").toPrologTermArray();

            for (int i = 0; i < term.length; i++) {
              newBoard.add(term[i].toString());
            }
          }

          if (results.get("NewCaptN").isList()) {
            Term[] term = results.get("NewCaptN").toPrologTermArray();

            for (int i = 0; i < term.length; i++) {
              newCaptN.add(term[i].toString());
            }
          }

          if (results.get("NewCaptS").isList()) {
            Term[] term = results.get("NewCaptS").toPrologTermArray();

            for (int i = 0; i < term.length; i++) {
              newCaptS.add(term[i].toString());
            }
          }

          // Print
          System.out.println("* Turn end");
          System.out.println("\tnewBoard : " + newBoard);
          System.out.println("\tnewCaptN : " + newCaptN);
          System.out.println("\tnewCaptS : " + newCaptS);

          // TODO : attendre validation serveur
          currentBoard = newBoard;
          currentCaptN = newCaptN;
          currentCaptS = newCaptS;
        }

        newBoard = new ArrayList();
        newCaptN = new ArrayList();
        newCaptS = new ArrayList();

        // Close the query
        qu.close();
      }
      catch (SPException e) {
        System.out.println("* Error : SPException");
        e.printStackTrace();
        System.exit(-1);
      }
      catch (Exception e) {
        System.out.println("* Error : Exception");
        e.printStackTrace();
        System.exit(-1);
      }

      System.out.print("*\n*");
      saisieClavier();
    }

    System.out.println("* AI shutting down..");
  }

  public static String saisieClavier() {
    // declaration du buffer clavier
    BufferedReader buff = new BufferedReader(new InputStreamReader(System.in));

    try {
      return buff.readLine();
    }
    catch (IOException e) {
      System.err.println("IOException " + e);
      e.printStackTrace();
      System.exit(-1);
    }

    return ("halt.");
  }
}
