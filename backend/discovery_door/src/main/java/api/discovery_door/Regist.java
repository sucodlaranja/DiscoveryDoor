package api.discovery_door;

public class Regist {
    private final String date;
    private final int tempoDeViagem;
    private final Museum museu;

    public Regist(String[] info,Museum museu) {
        String[] dateSplit = info[1].split("T");
        
        String[] hourSplit = dateSplit[1].split(":");
        this.date = dateSplit[0] + " " + hourSplit[0] + ":" + hourSplit[1];

        this.tempoDeViagem = Integer.parseInt(info[2]);
        this.museu = museu;
    }

    public String getDate() {
        return this.date;
    }


    public int getTempoDeViagem() {
        return this.tempoDeViagem;
    }


    public Museum getMuseu() {
        return this.museu;
    }

}
