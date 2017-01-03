/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package lab10partb;
import java.awt.CardLayout;
import java.awt.event.ActionEvent;
import java.io.File;
import java.util.Formatter;
import javax.swing.AbstractAction;
import javax.swing.Action;
import javax.swing.JOptionPane;
import javax.swing.table.TableModel;

/**
 *
 * @author Corey
 */
public class Lab10partB extends javax.swing.JFrame {
    private SQLMethods db;
    /**
     * Creates new form MainFrame
     */
    public Lab10partB() {
        initComponents();
        this.setVisible(true);
        setLocationRelativeTo(null);
        setResizable(false);
        db = new SQLMethods();
        db.connect("civideo", "root", "");
    }
    /**
     * This method is called from within the constructor to initialize the form.
     * WARNING: Do NOT modify this code. The content of this method is always
     * regenerated by the Form Editor.
     */
    
    private static String appendDoubleQuote(String str) {
        if(str != null && str.contains(",")){
            str = "\"" + str + "\"";
        }
        return str;
    }
    
    
    @SuppressWarnings("unchecked")
    // <editor-fold defaultstate="collapsed" desc="Generated Code">//GEN-BEGIN:initComponents
    private void initComponents() {

        Panel = new javax.swing.JPanel();
        MainApp = new javax.swing.JPanel();
        TabPane = new javax.swing.JTabbedPane();
        Member = new javax.swing.JPanel();
        newmemberbutton = new javax.swing.JButton();
        jLabel7 = new javax.swing.JLabel();
        jLabel8 = new javax.swing.JLabel();
        member_fname = new javax.swing.JTextField();
        member_lname = new javax.swing.JTextField();
        jLabel9 = new javax.swing.JLabel();
        jLabel10 = new javax.swing.JLabel();
        jLabel11 = new javax.swing.JLabel();
        jLabel12 = new javax.swing.JLabel();
        member_address = new javax.swing.JTextField();
        member_city = new javax.swing.JTextField();
        member_state = new javax.swing.JTextField();
        member_zipcode = new javax.swing.JTextField();
        Rental = new javax.swing.JPanel();
        jLabel3 = new javax.swing.JLabel();
        rentVideo = new javax.swing.JTextField();
        searchParam = new javax.swing.JTextField();
        runRent = new javax.swing.JButton();
        searchBy = new javax.swing.JComboBox<>();
        jLabel13 = new javax.swing.JLabel();
        jLabel14 = new javax.swing.JLabel();
        searchButton = new javax.swing.JButton();
        ScrollPane = new javax.swing.JScrollPane();
        Table = new javax.swing.JTable();
        jMenuBar1 = new javax.swing.JMenuBar();
        jMenu1 = new javax.swing.JMenu();
        fileExport = new javax.swing.JMenuItem();

        setDefaultCloseOperation(javax.swing.WindowConstants.EXIT_ON_CLOSE);

        Panel.setLayout(new java.awt.CardLayout());

        MainApp.setName("MainApp"); // NOI18N

        TabPane.setBorder(javax.swing.BorderFactory.createEtchedBorder());
        TabPane.setName("TabPane"); // NOI18N

        newmemberbutton.setText("Enter");
        newmemberbutton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                newmemberbuttonActionPerformed(evt);
            }
        });

        jLabel7.setText("First Name:");

        jLabel8.setText("Last Name:");

        member_lname.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                member_lnameActionPerformed(evt);
            }
        });

        jLabel9.setText("Street:");

        jLabel10.setText("City:");

        jLabel11.setText("State:");

        jLabel12.setText("Zipcode:");

        javax.swing.GroupLayout MemberLayout = new javax.swing.GroupLayout(Member);
        Member.setLayout(MemberLayout);
        MemberLayout.setHorizontalGroup(
            MemberLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(MemberLayout.createSequentialGroup()
                .addGap(51, 51, 51)
                .addGroup(MemberLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addComponent(jLabel7)
                    .addComponent(jLabel8)
                    .addComponent(jLabel9)
                    .addComponent(jLabel10)
                    .addComponent(jLabel11)
                    .addComponent(jLabel12))
                .addGap(18, 18, 18)
                .addGroup(MemberLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING, false)
                    .addComponent(member_zipcode, javax.swing.GroupLayout.DEFAULT_SIZE, 229, Short.MAX_VALUE)
                    .addComponent(member_state)
                    .addComponent(member_city)
                    .addComponent(member_address)
                    .addComponent(member_lname)
                    .addComponent(member_fname))
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
            .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, MemberLayout.createSequentialGroup()
                .addContainerGap(145, Short.MAX_VALUE)
                .addComponent(newmemberbutton, javax.swing.GroupLayout.PREFERRED_SIZE, 136, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(129, 129, 129))
        );
        MemberLayout.setVerticalGroup(
            MemberLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(MemberLayout.createSequentialGroup()
                .addGap(32, 32, 32)
                .addGroup(MemberLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(jLabel7)
                    .addComponent(member_fname, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                .addGap(18, 18, 18)
                .addGroup(MemberLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(jLabel8)
                    .addComponent(member_lname, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                .addGap(18, 18, 18)
                .addGroup(MemberLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(jLabel9)
                    .addComponent(member_address, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                .addGap(18, 18, 18)
                .addGroup(MemberLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(jLabel10)
                    .addComponent(member_city, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                .addGap(14, 14, 14)
                .addGroup(MemberLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(jLabel11)
                    .addComponent(member_state, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                .addGap(18, 18, 18)
                .addGroup(MemberLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(jLabel12)
                    .addComponent(member_zipcode, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                .addGap(31, 31, 31)
                .addComponent(newmemberbutton)
                .addContainerGap(143, Short.MAX_VALUE))
        );

        TabPane.addTab("New Member", Member);

        Rental.setName("Rental"); // NOI18N

        jLabel3.setText("Video ID:");

        rentVideo.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                rentVideoActionPerformed(evt);
            }
        });

        searchParam.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                searchParamActionPerformed(evt);
            }
        });

        runRent.setText("Rent");
        runRent.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                runRentActionPerformed(evt);
            }
        });

        searchBy.setModel(new javax.swing.DefaultComboBoxModel<>(new String[] { "Movie Title", "Movie Year" }));
        searchBy.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                searchByActionPerformed(evt);
            }
        });

        jLabel13.setText("Search By:");

        jLabel14.setText("Search:");

        searchButton.setText("Search");
        searchButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                searchButtonActionPerformed(evt);
            }
        });

        javax.swing.GroupLayout RentalLayout = new javax.swing.GroupLayout(Rental);
        Rental.setLayout(RentalLayout);
        RentalLayout.setHorizontalGroup(
            RentalLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(RentalLayout.createSequentialGroup()
                .addGap(20, 20, 20)
                .addGroup(RentalLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(RentalLayout.createSequentialGroup()
                        .addComponent(jLabel14)
                        .addGap(24, 24, 24)
                        .addComponent(searchParam))
                    .addGroup(RentalLayout.createSequentialGroup()
                        .addComponent(jLabel13)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(searchBy, javax.swing.GroupLayout.PREFERRED_SIZE, 308, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(0, 2, Short.MAX_VALUE))
                    .addGroup(RentalLayout.createSequentialGroup()
                        .addComponent(jLabel3)
                        .addGap(18, 18, 18)
                        .addComponent(rentVideo)))
                .addGap(18, 18, 18))
            .addGroup(RentalLayout.createSequentialGroup()
                .addGroup(RentalLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(RentalLayout.createSequentialGroup()
                        .addGap(106, 106, 106)
                        .addComponent(searchButton, javax.swing.GroupLayout.PREFERRED_SIZE, 98, javax.swing.GroupLayout.PREFERRED_SIZE))
                    .addGroup(RentalLayout.createSequentialGroup()
                        .addGap(105, 105, 105)
                        .addComponent(runRent, javax.swing.GroupLayout.PREFERRED_SIZE, 98, javax.swing.GroupLayout.PREFERRED_SIZE)))
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
        );
        RentalLayout.setVerticalGroup(
            RentalLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(RentalLayout.createSequentialGroup()
                .addGap(48, 48, 48)
                .addGroup(RentalLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(searchBy, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(jLabel13))
                .addGap(18, 18, 18)
                .addGroup(RentalLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(jLabel14)
                    .addComponent(searchParam, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                .addGap(18, 18, 18)
                .addComponent(searchButton)
                .addGap(33, 33, 33)
                .addGroup(RentalLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(jLabel3)
                    .addComponent(rentVideo, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                .addGap(18, 18, 18)
                .addComponent(runRent)
                .addContainerGap(194, Short.MAX_VALUE))
        );

        TabPane.addTab("Rental", Rental);

        ScrollPane.setName("scrollcard"); // NOI18N

        Table.setModel(new javax.swing.table.DefaultTableModel(
            new Object [][] {
                {null, null, null, null, null, null, null},
                {null, null, null, null, null, null, null},
                {null, null, null, null, null, null, null},
                {null, null, null, null, null, null, null}
            },
            new String [] {
                "Video ID", "Movie Title", "Movie Year", "Rental Cost", "Rent Date", "Due Date", "Rented By"
            }
        ) {
            Class[] types = new Class [] {
                java.lang.Double.class, java.lang.String.class, java.lang.String.class, java.lang.Double.class, java.lang.String.class, java.lang.String.class, java.lang.Double.class
            };

            public Class getColumnClass(int columnIndex) {
                return types [columnIndex];
            }
        });
        Table.setName("table"); // NOI18N
        ScrollPane.setViewportView(Table);

        javax.swing.GroupLayout MainAppLayout = new javax.swing.GroupLayout(MainApp);
        MainApp.setLayout(MainAppLayout);
        MainAppLayout.setHorizontalGroup(
            MainAppLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, MainAppLayout.createSequentialGroup()
                .addGap(22, 22, 22)
                .addComponent(TabPane, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(18, 18, 18)
                .addComponent(ScrollPane, javax.swing.GroupLayout.PREFERRED_SIZE, 625, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addContainerGap(19, Short.MAX_VALUE))
        );
        MainAppLayout.setVerticalGroup(
            MainAppLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, MainAppLayout.createSequentialGroup()
                .addContainerGap(24, Short.MAX_VALUE)
                .addGroup(MainAppLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addComponent(TabPane, javax.swing.GroupLayout.PREFERRED_SIZE, 467, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, MainAppLayout.createSequentialGroup()
                        .addComponent(ScrollPane, javax.swing.GroupLayout.PREFERRED_SIZE, 443, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(13, 13, 13)))
                .addContainerGap())
        );

        Panel.add(MainApp, "MainApp");

        jMenu1.setText("File");

        fileExport.setText("Export as CSV");
        fileExport.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                fileExportActionPerformed(evt);
            }
        });
        jMenu1.add(fileExport);

        jMenuBar1.add(jMenu1);

        setJMenuBar(jMenuBar1);

        javax.swing.GroupLayout layout = new javax.swing.GroupLayout(getContentPane());
        getContentPane().setLayout(layout);
        layout.setHorizontalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addComponent(Panel, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
        );
        layout.setVerticalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(layout.createSequentialGroup()
                .addComponent(Panel, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
        );

        pack();
    }// </editor-fold>//GEN-END:initComponents

    private void fileExportActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_fileExportActionPerformed
        // TODO add your handling code here:
            String filename = JOptionPane.showInputDialog(null,"Enter File Name","File export", JOptionPane.QUESTION_MESSAGE);
            TableModel tm = Table.getModel();
            try{
                File outFile = new File(filename + ".csv");
                Formatter output = new Formatter(outFile);
                output.format("Video ID, Movie Title,"
                        + "Movie Year, Rental Cost, Number Avalaible,\n");


                for (int i = 0; i < tm.getRowCount(); i++) {
                  for (int j = 0; j < tm.getColumnCount(); j++) {
                    Object o = tm.getValueAt(i, j);
                    output.format(appendDoubleQuote(o.toString()) + ",");
                  }
                  output.format("\n");
                }
                
                output.close();
            }
            catch(Exception e){
                System.err.println(e.getMessage());
            }
    }//GEN-LAST:event_fileExportActionPerformed

    private void searchByActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_searchByActionPerformed
        // TODO add your handling code here:
    }//GEN-LAST:event_searchByActionPerformed

    private void runRentActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_runRentActionPerformed
        
    }//GEN-LAST:event_runRentActionPerformed

    private void searchParamActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_searchParamActionPerformed
        // TODO add your handling code here:
    }//GEN-LAST:event_searchParamActionPerformed

    private void rentVideoActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_rentVideoActionPerformed
        // TODO add your handling code here:
    }//GEN-LAST:event_rentVideoActionPerformed

    private void member_lnameActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_member_lnameActionPerformed
        // TODO add your handling code here:
    }//GEN-LAST:event_member_lnameActionPerformed

    private void newmemberbuttonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_newmemberbuttonActionPerformed

        if(!(member_fname.getText().length() > 20
            || member_lname.getText().length() > 20
            || member_address.getText().length() > 70
            || member_city.getText().length() > 50
            || member_state.getText().length() > 2
            || member_zipcode.getText().length() > 5
            || member_fname.getText().equals("")
            || member_lname.getText().equals("")
            || member_address.getText().equals("")
            || member_city.getText().equals("")
            || member_state.getText().equals("")
            || member_zipcode.getText().equals(""))){
            boolean result;
            result = db.newMember(member_fname.getText(), member_lname.getText(), member_address.getText(), 
                    member_city.getText(), member_state.getText(), member_zipcode.getText());
            if(result){
                JOptionPane.showMessageDialog(this, "Member placed in system", "Message", JOptionPane.PLAIN_MESSAGE);
            }
            else{
                JOptionPane.showMessageDialog(this, "Could not created new member.", "Rejected", JOptionPane.WARNING_MESSAGE);
            }
        }
        else{
            JOptionPane.showMessageDialog(this, "Please input parameters of correct length.", "Error", JOptionPane.WARNING_MESSAGE);
        }
    }//GEN-LAST:event_newmemberbuttonActionPerformed

    private void searchButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_searchButtonActionPerformed
        // TODO add your handling code here:
        db.updateTable(Table, searchParam.getText(), (String)searchBy.getSelectedItem());
        
    }//GEN-LAST:event_searchButtonActionPerformed
    
   
    /**
     * @param args the command line arguments
     */
    public static void main(String args[]) {
        /* Set the Nimbus look and feel */
        //<editor-fold defaultstate="collapsed" desc=" Look and feel setting code (optional) ">
        /* If Nimbus (introduced in Java SE 6) is not available, stay with the default look and feel.
         * For details see http://download.oracle.com/javase/tutorial/uiswing/lookandfeel/plaf.html 
         */
        try {
            for (javax.swing.UIManager.LookAndFeelInfo info : javax.swing.UIManager.getInstalledLookAndFeels()) {
                if ("Windows".equals(info.getName())) {
                    javax.swing.UIManager.setLookAndFeel(info.getClassName());
                    break;
                }
            }
        } catch (ClassNotFoundException ex) {
            java.util.logging.Logger.getLogger(Lab10partB.class.getName()).log(java.util.logging.Level.SEVERE, null, ex);
        } catch (InstantiationException ex) {
            java.util.logging.Logger.getLogger(Lab10partB.class.getName()).log(java.util.logging.Level.SEVERE, null, ex);
        } catch (IllegalAccessException ex) {
            java.util.logging.Logger.getLogger(Lab10partB.class.getName()).log(java.util.logging.Level.SEVERE, null, ex);
        } catch (javax.swing.UnsupportedLookAndFeelException ex) {
            java.util.logging.Logger.getLogger(Lab10partB.class.getName()).log(java.util.logging.Level.SEVERE, null, ex);
        }
        //</editor-fold>
        //</editor-fold>
        

        java.awt.EventQueue.invokeLater(new Runnable() {
            public void run() {
                new Lab10partB();
            }
        });

    }

    // Variables declaration - do not modify//GEN-BEGIN:variables
    private javax.swing.JPanel MainApp;
    private javax.swing.JPanel Member;
    private javax.swing.JPanel Panel;
    private javax.swing.JPanel Rental;
    private javax.swing.JScrollPane ScrollPane;
    private javax.swing.JTabbedPane TabPane;
    private javax.swing.JTable Table;
    private javax.swing.JMenuItem fileExport;
    private javax.swing.JLabel jLabel10;
    private javax.swing.JLabel jLabel11;
    private javax.swing.JLabel jLabel12;
    private javax.swing.JLabel jLabel13;
    private javax.swing.JLabel jLabel14;
    private javax.swing.JLabel jLabel3;
    private javax.swing.JLabel jLabel7;
    private javax.swing.JLabel jLabel8;
    private javax.swing.JLabel jLabel9;
    private javax.swing.JMenu jMenu1;
    private javax.swing.JMenuBar jMenuBar1;
    private javax.swing.JTextField member_address;
    private javax.swing.JTextField member_city;
    private javax.swing.JTextField member_fname;
    private javax.swing.JTextField member_lname;
    private javax.swing.JTextField member_state;
    private javax.swing.JTextField member_zipcode;
    private javax.swing.JButton newmemberbutton;
    private javax.swing.JTextField rentVideo;
    private javax.swing.JButton runRent;
    private javax.swing.JButton searchButton;
    private javax.swing.JComboBox<String> searchBy;
    private javax.swing.JTextField searchParam;
    // End of variables declaration//GEN-END:variables
}
