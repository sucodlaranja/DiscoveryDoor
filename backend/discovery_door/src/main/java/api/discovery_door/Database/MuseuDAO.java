package api.discovery_door.Database;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class MuseuDAO {

    /**
     * gets information about determined museu
     * 
     * @param museumName //name of the museum the client wants information
     * @return returns one string with all information about the museum
     */
    public static String getMuseuByName(String museumName) {
        try {
            Connection c = ConnectionPool.getConnection();
            Statement st = ConnectionPool.getStatement(c);
            StringBuilder result = new StringBuilder();
            ResultSet rs = st.executeQuery("SELECT * FROM museu where nomeMuseu = \"" + museumName + "\";");

            rs.next();
            buildMuseumString(result, rs);

            ConnectionPool.close(st, c);

            return result.toString();
        } catch (SQLException e) {
            e.printStackTrace();
            return "deu merda rapazes";
        }
    }

    /**
     * 
     * Adds one museum to the DB.
     * 
     *
     * @param museumName Name of the museum.
     * @param price      Price of the museum.
     * @param location   Location of the museum (address).
     * @param website    Website of the museum.
     * @param contact    Contact of the museum (phone number, email, ...).
     * @param category   Category of the museum (art, science, ...).
     * @param latitude   Latitude of the museum.
     * @param longitude  Longitude of the museum.
     * @param images     Images of the museum - first image is the main one.
     * @return True if the museum was created, false otherwise.
     */
    public static boolean addMuseum(String museumName, int price, String location, String website, String contact,
            String category, Double latitude, Double longitude, List<String> images) {
        String queryaddmuseum = "INSERT INTO `museu` (`nomeMuseu`, `website`, `preco`, `contacto`, `endereco`, `latitude`, `longitude`, `avaliacao`)"
                +
                "VALUES ('" + museumName + "', '" + website + "', '" + price + "', '" + contact + "', '" + location
                + "', '" + latitude + "', '" + longitude + "', '5');";
        String queryFindCategoryId = "select idCategoria from categoria where categoria = '" + category + "';";

        String queryPics = "INSERT INTO `fotografia`(`nomeMuseu`, `urlFotografia`) Values ";
        boolean response = false;
        try {
            Connection c = ConnectionPool.getConnection();
            Statement st = ConnectionPool.getStatement(c);

            if (st.executeUpdate(queryaddmuseum) > 0)
                response = true;
            Statement stfindCategory = ConnectionPool.getStatement(c);
            ResultSet rs = stfindCategory.executeQuery(queryFindCategoryId);
            ConnectionPool.closeStatement(st);
            if (rs.next()) {
                int idcategory = rs.getInt("idCategoria");
                Statement staddMuseuCategory = ConnectionPool.getStatement(c);
                String queryaddMuseuCategory = "INSERT INTO `museucategoria` (`nomeMuseu`, `idCategoria`)" +
                        "VALUES ('" + museumName + "', '" + idcategory + "');";
                staddMuseuCategory.executeUpdate(queryaddMuseuCategory);
                ConnectionPool.closeStatement(staddMuseuCategory);
            }
            int i = 0;
            for (String pic : images) {
                if (i + 1 == images.size())
                    queryPics += "('" + museumName + "', '" + pic + "');";
                else
                    queryPics += "('" + museumName + "', '" + pic + "'),";
                i++;
            }
            Statement stImages = ConnectionPool.getStatement(c);
            stImages.executeUpdate(queryPics);
            ConnectionPool.closeStatement(stImages);

            ConnectionPool.close(st, c);

        } catch (SQLException e) {
            e.printStackTrace();

        }
        return response;
    }

    /**
     * Deletes museum from database
     * 
     * @param museumName Name of the museum that will be deleted.
     * @return True if the museum was deleted successfull.
     */
    public static boolean removeMuseum(String museumName) {
        String queryRemovecategoria = "DELETE FROM `museucategoria` WHERE (`nomeMuseu` = '" + museumName + "');";
        String queryRemovePics = "DELETE FROM fotografia where (nomeMuseu = '" + museumName + "');";
        String queryRemoveHistory = "DELETE FROM `historico` WHERE (`nomeMuseu` = '" + museumName + "');";
        String queryRemoveReview = "DELETE FROM `review` WHERE (`nomeMuseu` = '" + museumName + "');";
        String queryRemoveMuseum = "DELETE FROM `museu` WHERE (`nomeMuseu` = '" + museumName + "');";
        boolean response = false;
        try {
            Connection c = ConnectionPool.getConnection();
            Statement st = ConnectionPool.getStatement(c);

            st.addBatch(queryRemovecategoria);
            st.addBatch(queryRemovePics);
            st.addBatch(queryRemoveHistory);
            st.addBatch(queryRemoveReview);
            st.addBatch(queryRemoveMuseum);
            int[] results = st.executeBatch();
            if (results[4] > 0)
                response = true;

            ConnectionPool.close(st, c);

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return response;
    }

    /**
     * Finds all museums in the Database.
     * 
     * @return List with all museums in the Database.
     */
    public static List<String> getMuseums() {
        List<String> result = new ArrayList<>();

        String query = "SELECT * FROM museu";

        try {
            Connection c = ConnectionPool.getConnection();
            Statement st = ConnectionPool.getStatement(c);
            ResultSet rs = st.executeQuery(query);
            while (rs.next()) {
                StringBuilder temp = new StringBuilder();
                buildMuseumString(temp, rs);
                result.add(temp.toString());

            }
            ConnectionPool.close(st, c);

        } catch (SQLException e) {

            e.printStackTrace();
        }
        return result;
    }

    /**
     * 
     * @param radius        Radius of the surrondings.
     * @param latitudeUser  Latitude of the user.
     * @param longitudeUser Longitude of the user.
     * @param price         Maximum price.
     * @param score         Minimum score.
     * @param theme         Theme that the user want.
     * @return List of museums that are within the conditions
     */
    public static List<String> getMuseumsByFilters(Double radius, Double latitudeUser,
            Double longitudeUser, int price,
            int score, String theme) {
        ArrayList<String> result = new ArrayList<>();

        Double degreeRadiuslat = radius * 0.009044;
        Double degreeRadiusLon = radius * 0.0089831;
        Double latitudeRadiusMax = latitudeUser + degreeRadiuslat;
        Double latitudeRadiusMin = latitudeUser - degreeRadiuslat;
        Double longitudeRadiusMax = longitudeUser + degreeRadiusLon;
        Double longitudeRadiusMin = longitudeUser - degreeRadiusLon;
        String query = "select * FROM MUSEU" +
                " INNER JOIN museucategoria" +
                " ON (museu.nomeMuseu=museucategoria.nomeMuseu)" +
                " INNER JOIN categoria" +
                " ON (museucategoria.idCategoria=categoria.idCategoria)" +
                " WHERE museu.latitude > " + latitudeRadiusMin + " and museu.latitude < " + latitudeRadiusMax +
                " and museu.longitude > " + longitudeRadiusMin + " and museu.longitude < " + longitudeRadiusMax +
                " and museu.preco <= " + price + " and museu.avaliacao > " + score;
        if (!theme.equals("all"))
            query += " and categoria.Categoria = '" + theme + "'";
        query += ";";
        try {
            Connection c = ConnectionPool.getConnection();
            Statement st = ConnectionPool.getStatement(c);

            ResultSet rs = st.executeQuery(query);
            while (rs.next()) {
                StringBuilder temp = new StringBuilder();
                buildMuseumString(temp, rs);
                result.add(temp.toString());
            }
            ConnectionPool.close(st, c);

        } catch (SQLException e) {

            e.printStackTrace();
        }
        return result;

    }

    /**
     * 
     * @param museumName Museum name of the image.
     * @param url        Url of the image.
     * @return True if any row is affected.
     */
    public static boolean addImage(String museumName, String url) {
        String query = "INSERT into fotografia (nomeMuseu,urlFotografia) VALUES ('" + museumName + "', '" + url
                + "');";
        boolean response = false;
        try {
            Connection c = ConnectionPool.getConnection();
            Statement st = ConnectionPool.getStatement(c);

            if (st.executeUpdate(query) > 0)
                response = true;
            ConnectionPool.close(st, c);

        } catch (Exception e) {

            e.printStackTrace();
        }
        return response;
    }

    /**
     * 
     * @param museumName Museum name of the museum.
     * @return List of all URL images of the given museum.
     */
    public static List<String> getImages(String museumName) {

        try {
            Connection c = ConnectionPool.getConnection();
            Statement st = ConnectionPool.getStatement(c);
            ResultSet rs = st
                    .executeQuery("SELECT urlFotografia from fotografia where nomeMuseu='" + museumName + "';");
            List<String> photos = new ArrayList<>();

            while (rs.next()) {
                String response = rs.getString("urlFotografia");
                photos.add(response);
            }
            ConnectionPool.close(st, c);
            return photos;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * 
     * @param museumName Museum name of the Museum.
     * @return List with all categories from given Museum.
     */
    public static List<String> getCategorias(String museumName) {
        String query1 = "select categoria from categoria " +
                "Inner Join museucategoria " +
                "on categoria.idCategoria=museucategoria.idCategoria where museucategoria.nomeMuseu = '" + museumName
                + "';";
        List<String> results = new ArrayList<>();
        try {
            Connection c = ConnectionPool.getConnection();
            Statement st = ConnectionPool.getStatement(c);
            ResultSet rs = st.executeQuery(query1);
            while (rs.next()) {
                results.add(rs.getString("categoria"));
            }
            ConnectionPool.close(st, c);

        } catch (Exception e) {

            e.printStackTrace();
        }
        return results;
    }

    /**
     * Updates museum score.
     * 
     * @param museumName museum name
     */
    public static void updateScore(String museumName) {
        String query = "SELECT avaliacao FROM review WHERE nomeMuseu = '" + museumName + "'; ";
        try {
            Connection c = ConnectionPool.getConnection();
            Statement st = ConnectionPool.getStatement(c);
            ResultSet rs = st.executeQuery(query);
            Double total = 0.0;
            Double soma = 0.0;
            while (rs.next()) {
                total++;
                soma += rs.getDouble("avaliacao");
            }

            st.executeUpdate(
                    "UPDATE museu SET avaliacao = " + (soma / total) + " where nomeMuseu = '" + museumName + "';");
            ConnectionPool.close(st, c);
        } catch (Exception e) {

            e.printStackTrace();
        }
    }

    // Basic toString.
    private static void buildMuseumString(StringBuilder result, ResultSet rs) throws SQLException {

        result.append(rs.getString("nomeMuseu")).append(";");
        result.append(rs.getString("website")).append(";");
        result.append(rs.getInt("preco")).append(";");
        result.append(rs.getString("contacto")).append(";");
        result.append(rs.getString("endereco")).append(";");
        result.append(rs.getDouble("latitude")).append(";");
        result.append(rs.getDouble("longitude")).append(";");
        result.append(rs.getDouble("avaliacao")).append(";");
    }

}
