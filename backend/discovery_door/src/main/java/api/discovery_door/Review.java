package api.discovery_door;

public class Review {
    private final String username;
    private final String date;
    private final Double avaliacao;
    private final String texto;

    public Review(String reviewInfo) {
        // Default Values
        var username = "";
        var date = "";
        var avaliacao = -1.0;
        var texto = "";
        

        // Information order username;date;avaliacao;texto;...
        String[] splitInfo = reviewInfo.split(";");
        if(splitInfo.length > 3){
        username = splitInfo[0];
        avaliacao = Double.parseDouble(splitInfo[2]);
        texto = splitInfo[3];

        String[] dateSplit = splitInfo[1].split("T");
        
        String[] hourSplit = dateSplit[1].split(":");
        date = dateSplit[0] + " " + hourSplit[0] + ":" + hourSplit[1];
        }
         

        this.username = username;
        this.date = date;
        this.avaliacao = avaliacao;
        this.texto = texto;
    }

    public String getUsername() {
        return this.username;
    }


    public String getDate() {
        return this.date;
    }


    public Double getAvaliacao() {
        return this.avaliacao;
    }


    public String getTexto() {
        return this.texto;
    }

}
