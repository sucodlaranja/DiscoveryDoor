package api.discovery_door.Database;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class ReviewDAO {

    /**
     * Adds one review from username to museum.
     * 
     * @param username   Username of the user.
     * @param museumName Museum name of the museum.
     * @param date       Date that the review as made.
     * @param score      Review score.
     * @param comment    Comment made.
     * @return True if the review was added.
     */
    public static boolean addReview(String username, String museumName, String date, int score, String comment) {
        String query = "INSERT INTO `review` (`username`, `nomeMuseu`, `date`, `avaliacao`, `texto`)" +
                    "VALUES ('" + username + "', '" + museumName + "', '" + date + "', '" + score + "', '" + comment
                    + "');";
        boolean response = false;
        try {
            
            Connection c = ConnectionPool.getConnection();
            Statement st = ConnectionPool.getStatement(c);
            if(st.executeUpdate(query)>0) response = true;
            ConnectionPool.close(st,c);
            
        } catch (SQLException e) {
            e.printStackTrace();
            
        }
        return response;
    }
    /**
     * 
     * @param museumName Museum name of the museum.
     * @return List with all reviews Info about a given museum.
     */
    public static List<String> getReviews(String museumName) {
            List<String> reviews = new ArrayList<>();
        try {
            Connection c = ConnectionPool.getConnection();
            Statement st = ConnectionPool.getStatement(c);
            ResultSet rs = st.executeQuery("SELECT * from review where nomeMuseu='" + museumName + "';");
            
            while (rs.next()) {
                StringBuilder response = new StringBuilder();
               response.append(rs.getString("username")).append(";");
               response.append(rs.getString("date").toString()).append(";");
               response.append(rs.getDouble("avaliacao")).append(";");
               response.append(rs.getString("texto"));
               reviews.add(response.toString());
            }
            ConnectionPool.close(st, c);
            return reviews;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
    
}
