package api.discovery_door.Database;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class CategoryDAO {
    /**
     * 
     * @return List with all available categories.
     */
    public static List<String> getCategorias(){
        String query = "SELECT categoria FROM categoria";
        List<String> results = new ArrayList<>();
        try {
            Connection c = ConnectionPool.getConnection();
            Statement st = ConnectionPool.getStatement(c);
            ResultSet rs = st.executeQuery(query);
            while(rs.next()) {
                results.add(rs.getString("categoria"));
            }
            ConnectionPool.close(st, c);
            return results;

        } catch(SQLException e) {
            e.printStackTrace();
        }
        return null;
    }


    /**
     * 
     * @param museumName museum name of the museum.
     * @return Category from given museum.
     */
    public static String getCategoria(String museumName) {
        String query = "SELECT categoria from categoria JOIN museucategoria ON " + 
                       "categoria.idCategoria=museucategoria.idCategoria WHERE museucategoria.nomeMuseu = '"+ museumName +"'";
        String result = null;
        try {
            Connection c = ConnectionPool.getConnection();
            Statement st = ConnectionPool.getStatement(c);
            ResultSet rs = st.executeQuery(query);
            if(rs.next()) {
                result = rs.getString("categoria");
            }
            ConnectionPool.close(st, c);
        } catch( SQLException e) {
            e.printStackTrace();
        }
        return result;
    }
}
