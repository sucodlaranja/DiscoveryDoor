package api.discovery_door.Database;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

    
public class UtilizadorDAO {
    private static final Encryption encrypt = new Encryption();

    /**
     * 
     * @param username Username proposed by the user.
     * @param password Password of the user.
     * @return True if the combination is true.
     * 
     */

    public static boolean registerUser(String username, String password) {
        boolean response = false;
        if(!username.isEmpty() && !password.isEmpty()) {
        try {
            
            String encryptedPassword = encrypt.encrypt(password);
            String query = "INSERT INTO `Utilizador` (`username`, `password`, `avaliacaosistema`)" +
                    "VALUES ('" + username + "', '" + encryptedPassword + "', '');";
            Connection c = ConnectionPool.getConnection();
            Statement st = ConnectionPool.getStatement(c);
            if(st.executeUpdate(query) > 0) response = true;
            ConnectionPool.close(st,c);
            
        } catch (SQLException e) {
            

            e.printStackTrace();
            
        }
        }
        return response;

    }

    /**
     *
     * @param username Username of the user.
     * @param password Password of the user.
     * @param query    Login query.
     * @return         True if the combination is true
     */
    private static boolean loginWorker(String username, String password, String query) {
        boolean response = false;
        try {
            Connection c = ConnectionPool.getConnection();
            Statement st = ConnectionPool.getStatement(c);
            ResultSet rs = st.executeQuery(query);

            if (rs.next()) {
                if (!username.isEmpty() && !password.isEmpty() && encrypt.decrypt(rs.getString("password")).equals(password)) {
                    response = true;
                }
            }
            ConnectionPool.close(st,c);

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return response;
    }

    /**
     * 
     * @param username Username of the user.
     * @param password Password of the user.
     * @return True if login was successfully.
     * 
     */
    public static boolean loginUser(String username, String password) {
        return loginWorker(username, password, "SELECT * FROM utilizador WHERE (`username` = '" + username + "');");
    }
    /**
     * 
     * @param username  Username proposed by the user.
     * @param password  Respective password.
     * @return  True if it was registered successfully.
     */
    public static boolean registeradmin(String username, String password) {
        boolean response = false;
        if(!username.isEmpty() && !password.isEmpty()) {
        try {

            String encryptedPassword = encrypt.encrypt(password);
            String query = "INSERT INTO `administrador` (`username`, `password`)" +
                    "VALUES ('" + username + "', '" + encryptedPassword + "');";

            Connection c = ConnectionPool.getConnection();
            Statement st = ConnectionPool.getStatement(c);
            if(st.executeUpdate(query) > 0) response = true;
            ConnectionPool.close(st,c);
            
        } catch (SQLException e) {
            

            e.printStackTrace();
            
        }
        }
        return response;
    }

    /**
     * 
     * @param username  Admin username that is trying to login.
     * @param password  Respective password.
     * @return          True if the combination is true.
     */
    public static boolean loginadmin(String username, String password) {
        return loginWorker(username, password, "SELECT * FROM administrador WHERE (`username` = '" + username + "');");
    }

    /**
     * 
     * @param username User that will evaluate the system.
     * @param score    User score to the system.
     * @return         True if any row is affected.
     */

    public static boolean addSystemRating(String username, int score) {
        String query = "UPDATE `Utilizador` SET `avaliacaosistema` = '" + score +
                    "' WHERE (`username` = '" + username + "');";
        boolean response = false;
        try {
            Connection c = ConnectionPool.getConnection();
            Statement st = ConnectionPool.getStatement(c);
            if(st.executeUpdate(query) > 0) response = true;
            ConnectionPool.close(st,c);
            
        } catch (SQLException e) {
            
            e.printStackTrace();
        }
        return response;

    }

    

    /**
     * Checks if username already exists in database.
     * 
     * @param username Username to check.
     * @return True if exists, false otherwise.
     */
    public static boolean existusername(String username) {
        boolean response = false;
        try {

            String query = "SELECT * FROM utilizador WHERE (`username` = '" + username + "');";
            Connection c = ConnectionPool.getConnection();
            Statement st = ConnectionPool.getStatement(c);

            ResultSet rs = st.executeQuery(query);

            if (rs.next()) {
                response = true;
            }
            ConnectionPool.close(st,c);

        } catch (SQLException e) {
            e.printStackTrace();

        }

        return response;
    }

    

}
