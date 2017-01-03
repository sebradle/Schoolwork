/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package lab10partb;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Statement;
import java.sql.ResultSet;
import java.sql.SQLException;
import javax.swing.JTable;
import net.proteanit.sql.DbUtils;
/**
 *
 * @author anthony.resendiz820
 */
public class SQLMethods {
    private Connection connection;
    private String dbUri = "jdbc:mysql://";
    private String dbDriver = "com.mysql.jdbc.Driver";
    private int currentAdvisor;
    
    public boolean connect(String base, String user, String pass){
        try{
            Class.forName(dbDriver);
            String uri = dbUri + '/' + base;
            connection = DriverManager.getConnection(uri, user, pass);
            return true;
        }
        catch(ClassNotFoundException e){
            e.printStackTrace();
            return false;
        }
        catch(SQLException e){
            e.printStackTrace();
            return false;
        }
    }
   
    public Connection getConnection(){
        return connection;
    }
    public boolean login(int employeeID, String password){
        try{
            Connection connect = getConnection();
            Statement statement;
            statement = connect.createStatement();
            ResultSet resultSet = statement.executeQuery("select `adv_id`, `adv_password` from classic.advisor");
            while(resultSet.next()){
                int id = resultSet.getInt("adv_id");
                String pass =resultSet.getString("adv_password");
                if(id == employeeID && password.equals(pass)){
                    currentAdvisor = id;
                    return true;
                }
            }
        }
        catch(SQLException e){
            System.err.println(e.getMessage());
        }
        catch(NullPointerException np){
            System.err.println(np.getMessage());
        }
        
        return false;
    }
    
    public void updateTable(JTable table, String param, String by){
        try{
            ResultSet resultSet;
            Connection connect = getConnection();
            Statement statement;
            String selectStatement = "select video.vid_num as 'Video ID', movie_title as 'Movie Title', movie_year as 'Movie Year', price_rentfee as 'Rental Cost', \n" +
                                        "rent_date as 'Rent Date', detail_duedate as 'Due Date', mem_num as 'Rented By'\n" +
                                        "from video\n" +
                                        "left join detailrental on video.vid_num = detailrental.vid_num\n" +
                                        "left join rental on detailrental.rent_num = rental.rent_num\n" +
                                        "join movie on video.movie_num = movie.movie_num\n" +
                                        "join price on movie.price_code = price.price_code\n";
            if(!param.equals("")){
                    switch(by){
                    case "Movie Title":
                        selectStatement = selectStatement +  " where movie_title like '" + param + "'";
                        break;
                    case "Movie Year":
                        selectStatement = selectStatement +  " where movie_year like '" + param + "'";
                        break;
                    }
            }
            
            selectStatement = selectStatement + "group by video.vid_num\n" +
                                        "order by video.vid_num desc;";
            statement = connect.createStatement();
            resultSet = statement.executeQuery(selectStatement);
            table.setModel(DbUtils.resultSetToTableModel(resultSet));
        }
        catch(SQLException e){
            System.err.println(e.getMessage());
        }
        catch(NullPointerException np){
            System.err.println(np.getMessage());
        }
    }
    
    public boolean newMember(String fname, String lname, String street, String city, String state, String zipcode){
        boolean requestAccepted = false;
        try{
            ResultSet resultSet;
            Connection connect = getConnection();
            CallableStatement stored_proc;
            stored_proc = connect.prepareCall("call sp_new_member(?, ?, ?, ?, ?, ?);");
            stored_proc.setString(1, fname);
            stored_proc.setString(2, lname);
            stored_proc.setString(3, street);
            stored_proc.setString(4, city);
            stored_proc.setString(5, state);
            stored_proc.setString(6, zipcode);
            stored_proc.execute();
            requestAccepted = true;
        }
        catch(SQLException e){
            System.err.println(e.getMessage());
        }
        catch(NullPointerException np){
            System.err.println(np.getMessage());
        }
        return requestAccepted;
    }
    
    
    
}
