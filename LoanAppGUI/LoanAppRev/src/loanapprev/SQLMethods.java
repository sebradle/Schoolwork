/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package loanapprev;

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
    
    public void updateTable(JTable table){
        try{
            ResultSet resultSet;
            Connection connect = getConnection();
            Statement statement;
            statement = connect.createStatement();
            resultSet = statement.executeQuery("select `loan_id`, `loan_int_amt`, `loan_start_date`, `loan_current_due`, `rec_id`, `email` "
                    + "from classic.loan "
                    + "join  classic.recepient"
                    + "on loan.rec_id = recepient.rec_id"
                    + "join classic.email"
                    + "on recepient.rec_id = email.rec_id");
            table.setModel(DbUtils.resultSetToTableModel(resultSet));
        }
        catch(SQLException e){
            System.err.println(e.getMessage());
        }
        catch(NullPointerException np){
            System.err.println(np.getMessage());
        }
    }
    
    
    
}
