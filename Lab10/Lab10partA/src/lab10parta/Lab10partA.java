/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package lab10parta;

import java.util.Scanner;
import java.io.File;
import java.io.FileNotFoundException;
import java.util.Formatter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.ResultSet;

/**
 *
 * @author sean.bradley253
 */
public class Lab10partA {
    
    private static String appendDoubleQuote(String str) {
        if(str != null && str.contains(",")){
            str = "\"" + str + "\"";
        }
        return str;
    }
    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        // TODO code application logic here
        
        Connection con = null;
        File outFile = new File("products.csv");
        try{
            Formatter output = new Formatter(outFile);
            output.format("Product Code, Product Description,"
                    + "Product Indate, Product QOH, Product Min,"
                    + "Product Price, Product Discount, Vendor Code");
            Class.forName("com.mysql.jdbc.Driver").newInstance();
            String uid = "root";
            String pwd = "";
            con = DriverManager.getConnection("jdbc:mysql:///saleco", uid, pwd);
            if(!con.isClosed())
                System.out.println("Connected to MySQL server.");
            
            Statement statement = null;
            statement = con.createStatement();
            ResultSet resultSet = statement.executeQuery("select p.* from saleco.product p");
            while(resultSet.next()){
                String pcode = resultSet.getString("p.P_CODE");
                String pdes = resultSet.getString("p.P_DESCRIPT");
                String pindate = resultSet.getString("p.P_INDATE");
                String pqoh = resultSet.getString("p.P_QOH");
                String pmin = resultSet.getString("p.P_MIN");
                String pprice = resultSet.getString("p.P_PRICE");
                String pdiscount = resultSet.getString("p.P_DISCOUNT");
                String vcode = resultSet.getString("p.V_CODE");
                output.format(appendDoubleQuote(pcode) + "," + 
                        appendDoubleQuote(pdes) + "," + 
                        appendDoubleQuote(pindate) + "," + 
                        appendDoubleQuote(pqoh) + "," + 
                        appendDoubleQuote(pmin) + "," +
                        appendDoubleQuote(pprice) + "," + 
                        appendDoubleQuote(pdiscount) + "," + 
                        appendDoubleQuote(vcode) + "\n");
            }
            output.close();
        }
        catch(Exception e){
            System.err.println("Exception:" + e.getMessage());
        }
        finally{
            try{
                if(con != null){
                    con.close();
                    System.out.println("Disconnected from MySQL server.");
                }
            }
            catch(SQLException e){
                System.err.println("Exception:" + e.getMessage());
            }
        }
    }
    
}