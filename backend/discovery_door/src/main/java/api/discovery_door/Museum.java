package api.discovery_door;

import java.util.ArrayList;
import java.util.List;

public class Museum {

    private final String name;
    private final String website;
    private final int preco;
    private final String contacto;
    private final String endereco;
    private final List<String> fotografias;
    private final List<Review> reviews;
    private final String categoria;
    private final Double latitude;
    private final Double longitude;
    private final Double avaliacao;

   
    public Museum(String museumInfo,List<String> fotografias,List<Review> reviews,String categoria) {
        // Default Values
        var name = "";
        var website = "";
        var preco = -1;
        var contacto = "";
        var endereco = "";
        var latitude = -1.0;
        var longitude = -1.0;
        var avaliacao = -1.0;
        
        

        // Information order name;website;preco;contacto;endereco;Latitude;Longitude;Avaliacao...
        String[] splitInfo = museumInfo.split(";");
        if(splitInfo.length > 6){
            name = splitInfo[0];
            website = splitInfo[1];
            preco = Integer.parseInt(splitInfo[2]);
            contacto = splitInfo[3];
            endereco = splitInfo[4];
            latitude = Double.parseDouble(splitInfo[5]);
            longitude = Double.parseDouble(splitInfo[6]);
            avaliacao = Double.parseDouble(splitInfo[7]);
        }

        this.name = name;
        this.website = website;
        this.preco = preco;
        this.contacto = contacto;
        this.endereco = endereco;
        this.fotografias = (fotografias != null) ? new ArrayList<>(fotografias) : null;
        this.reviews = (reviews != null) ? new ArrayList<>(reviews) : null;
        this.categoria = categoria;
        this.latitude = latitude;
        this.longitude = longitude;
        this.avaliacao = avaliacao;
    }



    public String getName() {
        return this.name;
    }


    public String getWebsite() {
        return this.website;
    }


    public int getPreco() {
        return this.preco;
    }


    public String getContacto() {
        return this.contacto;
    }


    public String getEndereco() {
        return this.endereco;
    }


    public List<String> getFotografias() {
        return this.fotografias;
    }


    public List<Review> getReviews() {
        return this.reviews;
    }

    public String getCategoria() {
        return this.categoria;
    }


    public Double getLatitude() {
        return this.latitude;
    }


    public Double getLongitude() {
        return this.longitude;
    }

    public Double getAvaliacao() {
        return this.avaliacao;
    }


    

    
}
