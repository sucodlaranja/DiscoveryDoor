package api.discovery_door.Database;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class HistoryDAO {
    /**
     * 
     * @param username     Username that will add museum to history.
     * @param museumName   MuseumName that will be added to the user history.
     * @param date         Date the user visited the museum.
     * @param tot          Time of travel.
     * @return             True if any row is affected.
     */
    public static boolean addToHistory(String username, String museumName,String date, int tot) {
        String query = "INSERT INTO Historico (`username`, `nomeMuseu`, `date`, `tempoDeViagem`)" +
                "VALUES ('" + username + "', '" + museumName + "', '"+ date +"', '"+ tot +"');";
                
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
     * @param username User name of the user.
     * @return List with history of a given user.
     */
    public static List<String> getHistory(String username) {
        String query = "SELECT * FROM historico WHERE username = '"+ username +"';";
        try {
            Connection c = ConnectionPool.getConnection();
            Statement st = ConnectionPool.getStatement(c);
            ResultSet rs = st.executeQuery(query);
            List<String> results = new ArrayList<>();
            while(rs.next()) {
                StringBuilder sb = new StringBuilder();
                sb.append(rs.getString("nomeMuseu")).append(";");
                sb.append(rs.getString("date")).append(";");
                sb.append(rs.getInt("tempoDeViagem")).append(";");
                results.add(sb.toString());
            }
            ConnectionPool.close(st, c);
            return results;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    
}
