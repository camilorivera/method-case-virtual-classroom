package mcvc.hibernate.clases;
// Generated 06-16-2012 08:39:39 AM by Hibernate Tools 3.2.1.GA



/**
 * TblBoard generated by hbm2java
 */
public class TblBoard  implements java.io.Serializable {


     private TblBoardId id;
     private TblSession tblSession;
     private String brdName;
     private String brdText;

    public TblBoard() {
    }

	
    public TblBoard(TblBoardId id, TblSession tblSession, String brdName) {
        this.id = id;
        this.tblSession = tblSession;
        this.brdName = brdName;
    }
    public TblBoard(TblBoardId id, TblSession tblSession, String brdName, String brdText) {
       this.id = id;
       this.tblSession = tblSession;
       this.brdName = brdName;
       this.brdText = brdText;
    }
   
    public TblBoardId getId() {
        return this.id;
    }
    
    public void setId(TblBoardId id) {
        this.id = id;
    }
    public TblSession getTblSession() {
        return this.tblSession;
    }
    
    public void setTblSession(TblSession tblSession) {
        this.tblSession = tblSession;
    }
    public String getBrdName() {
        return this.brdName;
    }
    
    public void setBrdName(String brdName) {
        this.brdName = brdName;
    }
    public String getBrdText() {
        return this.brdText;
    }
    
    public void setBrdText(String brdText) {
        this.brdText = brdText;
    }




}

